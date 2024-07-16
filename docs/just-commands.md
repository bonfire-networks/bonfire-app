# Just commands

Welcome to this guide on navigating the world of Bonfire development, is crafted especially for people taking their first steps in Bonfire or looking to refine their workflow.
      

## General Setup Related Commands

As you dive into developing your own extension or app with the Bonfire framework, you'll quickly encounter an array of dependencies and extensions to deal with. An extension that uses a function or a component from a different extension is not an exception, but rather a common pattern.

This setup means you might likely soon find yourself contributing to multiple extensions simultaneously. Navigating this landscape can be intimidating at first, but Bonfire provides tools to streamline the process.

They help you effortlessly synchronize the latest updates across different extensions or efficiently push your updates to all relevant repositories. Understanding these facilities is key to a smooth and productive development experience in the Bonfire ecosystem.
      
Most of these tools are driven by [just](https://github.com/casey/just#just) and their code can be seen in the [justfile](https://github.com/bonfire-networks/bonfire-app/blob/main/justfile) (which is quite similar to a `Makefile`). Below is a small selection of the most used commands.
      
      
        
`just`
- Print a list of all possible `just` commands a short explanation for each. 

`just update`
- Update the app and all extensions/forks, and run migrations. Use this command to ensure you're in sync with the most recent changes across your development environment. 

`just update-app`
- This command updates the app along with Bonfire extensions located in `./deps`. It's ideal for updating the app while excluding the extensions currently under development located in `./extensions`.

`just dep-clone *[dep]* *[repo]*`
- Clone a git dependency and use the local version, eg: `just dep-clone-local bonfire_me https://github.com/bonfire-networks/bonfire_me`. Active extensions need to be added in `./config/deps.path` (see [the tutorial on how to fork an extension](/courses/how_to_fork_extension/)). To switch between local and remote dependencies, simply comment or uncomment the corresponding lines in this file.

`just contrib`
- Push all changes to the app and extensions in `./forks` and `./extensions`.

`just contrib-release`
- Push all changes to the app and extensions in `./forks`, increment the app version number, and push a new version/release

`just test`
- Run tests of all extensions, or only specific tests, eg: `just test extensions/bonfire_social` or `just test extensions/bonfire_social/test/social/boosts_test.exs`

`just test-watch *[path]*`
- Run stale tests, and wait for changes to any module code, and re-run affected tests. 

`just test-federation-in-extensions *[path]*`
- Test federation integration in your extension. 


