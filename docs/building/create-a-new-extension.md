# Create a new extension
    
Extensions in Bonfire are powerful tools that allow you to extend the functionality and features of your application.
This guide is perfect for developers who are looking to contribute new features or capabilities to the Bonfire ecosystem.
By the end of this page, you should have a solid understanding of how to develop and integrate a new extension in Bonfire, leveraging its modular architecture.


## Create your Bonfire extension

To start building your own extension, you can utilise our custom mix generator task. Simply navigate to the Bonfire app root folder in your terminal and type:
        
```
mix bonfire.extension.new *your_extension_name*
```

This command creates a new directory in `./extensions` named `*your_extension_name*`, complete with all the necessary files and scaffolding.
Once your extension folder is set up, you're ready to dive into coding. If your extension includes new pages, you need to link them in the main router. To do this, include `use_if_enabled(Bonfire.ExtensionTemplate.Web.Routes)` within your app's Router module, located at `./extensions/bonfire/lib/bonfire_spark_web/router.ex`.

> #### Info {: .info}
>
> The Bonfire main router lives in `bonfire` extension. Refer to the [Routing](/docs/building/routing/) page to learn how to add new routes.

Additionally, consider these steps to enhance your extension:

- Implement extension-specific fake functions for testing purposes.
- Create extension-specific database migrations.
- Add dependencies to deps.git and/or deps.hex.
        
        
 Simultaneously, begin tracking your extension’s development with Git. Initialize a new Git repository directly within your extension’s directory:
        
```
git init    
```
After coding your initial features, create an empty repository on your preferred Git platform. Then, commit and push your local changes to make your work accessible and open for collaboration:

```
git add .
git commit -m "first commit"
git branch -M main
git remote add origin {your-remote-repository}
git push -u origin main
```

Remember to add your extension to `./config/deps.git` (including the branch name), allowing others without access to your fork to utilise it and to `.config/deps.flavour.path` to enable it locally.
And just like that, you've successfully created and prepared your first Bonfire extension and shared with the community 🔥!
    