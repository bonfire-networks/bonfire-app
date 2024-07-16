# Make changes to an extension
  
This tutorial guides you through the process of editing an existing Bonfire extension. We'll cover how to clone, enable, and contribute to an extension, ensuring you can test and implement your changes effectively.
Ideal for developers looking to modify and enhance Bonfire's functionalities.
By the end, you'll be adept at including and working with extensions in the Bonfire development environment.

      
In Bonfire, in order to edit an existing extension and test the changes you need to set up the extension in your development environment. The process is quite straightforward:

## Fork the extension

If you want to share your changes to the extension, you may want to first fork it on Github.

Use `just dep-clone-local *[dep]* *[repo]*` to clone an extension from its Git repository. Replace <i>dep</i> with the extension name and <i>repo</i> with the full URL of your fork. The cloned extension will be cloned in `./extensions`:
       
```
just dep-clone-local bonfire_social https://github.com/bonfire-networks/bonfire_social
```

## Enable the extension

After cloning, choose to use the local version by editing `./config/deps.flavour.path` (create the file in the `./flavours/[flavour]/config/` directory if it doesn’t exist). 
The format to follow is the following: `dep_name = "dep_path"`.
To disable a local extension, comment or delete its line in `./config/deps.flavour.path`.
Use just dev to run the app with changes hot-reloading.

```
# ./config/deps.flavour.path
bonfire_me = "./extensions/bonfire_me"
# bonfire_boundaries = "./extensions/bonfire_boundaries" # disabled local copy
```

## Make and test your changes

You can now make your edits to the `./extensions`, run the app with `just dev` and run tests with `just test-watch`.

## Push changes
You can push your changes remotely, use Bonfire's helpers like `just contrib` if you need to commit files that belong to multiple extensions or `just update-dep *dep*` for a specific one (e.g.` just update-dep bonfire_me`).

## Great works 🎉🎉🎉

You're now equipped to contribute to Bonfire extensions, enhancing the framework's capabilities. You can do so by opening a PR on Github from your forked extension. Your contributions are vital to the Bonfire community, and we encourage you to keep exploring and improving the project.

