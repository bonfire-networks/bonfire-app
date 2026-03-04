# Bonfire.Ecto

`Bonfire.Ecto` contains `Ecto` transactional support as acts for `Bonfire.Epics`

## Introduction 

`Bonfire.Ecto` is designed to facilitate complex Ecto transaction handling within an Elixir application that uses `Bonfire.Epics` to execute a sequence of operations (or `Acts`). These modules provide a structured way to manage database transactions as a series of acts and managing them within an `Epic`, offering flexibility and control over database interactions, ensuring that transactions are executed efficiently.

### Modules Overview

1. `Bonfire.Ecto.Acts.Begin`
    - Responsible for initiating a transaction if certain conditions are met. It ensures that the transaction is only started when it is sensible to do so, based on the current state of the `Epic`.

2. `Bonfire.Ecto.Acts.Work`
    - Handles queued database operations within a transaction. Operations are queued using the `Bonfire.Ecto.Acts.Work.add/2` function and executed if there are no errors in the `Epic` or changesets.

3. `Bonfire.Ecto.Acts.Commit`
    - A placeholder marker used by `Bonfire.Ecto.Acts.Begin` to identify when to commit the transaction.


### Usage 

#### 1. Initial Setup

Ensure that you have `Ecto` and `Bonfire.Epics` installed and configured in your application, and then install this linrary.

#### 2. Using `Bonfire.Ecto.Acts.Begin`

Refer to `Bonfire.Epics` docs to define some `Act`s and `Epic`s: https://github.com/bonfire-networks/bonfire_epics

#### 3. Queue database operation(s) in an Act 

Queue operations by calling the `Bonfire.Ecto.Acts.Work.add/2` function, providing the epic and a key representing the changeset to be processed.

```elixir
epic = Bonfire.Ecto.Acts.Work.add(epic, :some_changeset)
```

#### 3. Add the three `Bonfire.Ecto` Acts to your Epic
```
    # First come the Acts that prepare the changeset and call `Bonfire.Ecto.Acts.Work.add/2` to queue it

    # Open a Postgres transaction and actually do the insertions in DB
    Bonfire.Ecto.Acts.Begin,

    # Run our inserts
    Bonfire.Ecto.Acts.Work,
    Bonfire.Ecto.Acts.Commit,

    # Then can come some Acts that process the result of the transaction 
```