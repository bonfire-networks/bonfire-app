# Entrepôt

Minimal, composable file upload, storage, and streamed data migrations for Elixir apps, flexibly and with minimal dependencies.

[![hex package](https://img.shields.io/hexpm/v/entrepot.svg)](https://hex.pm/packages/entrepot)
[![CI status](https://github.com/bonfire-networks/entrepot/workflows/CI/badge.svg)](https://github.com/bonfire-networks/entrepot/actions)

:warning: Although it's been used in production for over a year without issue, Entrepôt is experimental and still in active development. Accepting file uploads introduces specific security vulnerabilities. Use at your own risk.

## Concepts

Entrepôt intentionally strips file storage logic down to its most composable parts and lets you decide how you want to use them. These components are: [storage](#storage), [upload](#upload), [locator](#locator), and optionally, [uploader](#uploader), which provides a more ergonomic API for the other 3.

It is intentionally agnostic about versions, transformation, validations, etc. Most of the convenience offered by other libraries around these features comes at the cost of locking in dependence on specific tools and hiding complexity. Entrepôt puts a premium on simplicity and explicitness.

So what does it do? Here's a theoretical example of a use case with an Ecto<sup>1</sup> schema, which stores the file retrieved from a URL, along with some additional metadata:

```
  def create_attachment(upload, user) do
    Multi.new()
    |> Multi.run(:upload, fn _, _ ->
      YourStorage.put(upload, prefix: :crypto.hash(:md5, [user.id, url]) |> Base.encode16())
    end)
    |> Multi.insert(:attachment, fn %{upload: file_id} ->
      %Attachment{file_data: Locator.new!(id: file_id, storage: YourStorage, metadata: %{type: "document"})
    end)
    |> Repo.transaction()
  end
```

Then to access the file:

```
%Attachment{file_data: file} = attachment

{:ok, contents} = Disk.read(file.id)
```

<sup>1</sup> *See [integrations](#integrations) for streamlined use with Ecto.*

### Storage

A "storage" is a [behaviour](https://elixirschool.com/en/lessons/advanced/behaviours/) that implements the following "file-like" callbacks:

* read
* put
* delete

Implementing your own storage is as easy as creating a module that quacks this way. Each callback should accept an optional list of options as the last arg. Which options are supported is up to the module that implements the callbacks.

### Upload

Upload is a [protocol](https://elixir-lang.org/getting-started/protocols.html) consisting of the following two functions:

* contents
* name

A storage uses this interface to figure how to extract the file data from a given struct and how to identify it. See `Entrepot.Locator` for an example of how this protocol can be implemented.

### Locator

Locators are the mediators between storages and uploads. They represent where an uploaded file was stored so it can be retrieved. They contain a unique id, the name of the storage to which the file was uploaded, and a map of user defined metadata.

Locator also implements the upload protocol, which means moving a file from one storage to another is straightforward, and very useful for "promoting" a file from temporary (e.g. Disk) to permanent (e.g. S3) storage<sup>2</sup>:

```
old_file_data = %Locator{id: "/path/to/file.jpg", storage: Disk, metadata: %{}}
{:ok, new_id} = S3.put(old_file_data)`
```

Note: always remember to take care of cleaning up the old file as Entrepot *never* automatically removes files:

`Disk.delete(old_file_data.id)`

### Uploader

This helper was added in order to support DRYing up storage access. In most apps, there are certain types of assets that will be uploaded and handled in a similar, if not the same way, if only when it comes to where they are stored. You can `use` the uploader to codify the handling for specific types of assets.

```
defmodule AvatarUploader do
  use Entrepot.Uploader, storages: [cache: Disk, store: S3]

  def build_options(upload, :cache, opts) do
    Keyword.put(opts, :prefix, "cache/#{Date.utc_today()}")
  end

  def build_options(upload, :store, opts) do
    opts
    |> Keyword.put(:prefix, "users/#{opts[:user_id]}/avatar")
    |> Keyword.drop([:user_id])
  end

  def build_metadata(upload, :store, _), do: [uploaded_at: DateTime.utc_now()]
end
```

Then you can get the files where they need to be without constructing all the options everywhere they might be uploaded: `AvatarUploader.store(upload, :store, user_id: 1)`

Note: as this example demonstrates, the function can receive arbitrary data and use it to customize how it builds the storage options before they are passed on.


## Built-in Integrations

Entrepôt's module design is intended to make it easy to implement your own custom utilities for handling files in the way you need. However, anticipating the most common use cases, that is facilitated with the following optional modules and add-on library.

There are several implementations some common file storages (including S3/Digital Ocean) and uploads (including `Plug.Upload`).

## Storages

Entrepôt ships with the following storage implementations:

- [Disk](#Disk)
- [S3](#S3)
- [RAM](#RAM)

### Disk

This saves uploaded files to a local disk. It is useful for caching uploads while you validate other data, and/or perform some file processing.

#### configuration

- To set the root directory where files will be stored: `Application.put_env(:entrepot, Entrepot.Storages.Disk, root_dir: "tmp")`

#### options

- `prefix`: This should be a valid system path that will be appended to the root. If it does not exist, Disk will create it.
- `force`: If this option is set to a truthy value, Disk will overwrite any existing file at the derived path. Use with caution!

#### notes

Since it is possible for files with the same name to be uploaded multiple times, Disk needs some additional info to uniquely identify the file. Disk _does not_ overwrite files with the same name by default. To ensure an upload can be stored, the combination of the `Upload.name` and `prefix` should be unique.

### S3

This storage uploads files to [AWS's S3](https://aws.amazon.com/s3/) service. It also works with [Digital Ocean Spaces](https://www.digitalocean.com/products/spaces/).

#### configuration

- To set the bucket where files will be stored: `Application.put_env(:entrepot, Entrepot.Storages.S3, bucket: "whatever")`

#### options

- prefix: A string to prepend to the upload's key
- s3_options: Keyword list of option that will passed directly to ex_aws_s3

#### dependencies

Some of the implementations might require further dependencies (currently only [S3](#s3)-compatible storage) that you will also need to add to your project's deps
```
{:ex_aws, "~> 2.0"}
{:ex_aws_s3, "~> 2.0"}
```

### RAM

Uses Elixir's [StringIO](https://hexdocs.pm/elixir/StringIO.html) module to store file contents in memory. Since the "files" are essentially just strings, they will not be persisted and will error if they are read back from a database, for example. However, operations are correspondingly very fast and thus suitable for tests or other temporary file operations.


## uploads

There are implementation of the `Entrepot.Upload` protocol for the following modules:

- [URI](#URI)
- [Plug.Upload](#plugupload)


### URI

This is useful for transferring files already hosted elsewhere, for example in cloud storage not controlled by your application, or a [TUS server](https://tus.io/).

You can use it to allow users to post a url string in lieu of downloading and reuploading a file. A Phoenix controller action implementing this feature might look like this:

```
def attach(conn, %{"attachment" => %{"url" => url}}) when url != "" do
  URI.parse(url)
  |> Disk.put(upload)

  # ...redirect, etc
end
```

#### notes

This implementation imposes a hard timeout limit of 15 seconds to download the file from the remote location.

### Plug.Upload

This supports multi-part form submissions handled by [Plug](https://hexdocs.pm/plug/Plug.Upload.html#content).

## [EntrepôtEcto](https://github.com/bonfire-networks/entrepot_ecto)

There is an external library (because it needs Ecto as a dependency) which provides `Entrepot.Ecto.Type` for Ecto schema fields to easily handle persisting Locator data in your repository.

---

Note: Entrepôt was originally forked from [Capsule](https://github.com/elixir-capsule)
