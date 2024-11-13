# LiveView optimizations

Following are some tips to optimize LiveView performance.

## Minimize dynamic parts

1. Use assigns or components intead of function calls: function calls returns a string to the server and cannot be parsed to check what changed and what not
2. Use CSS state/aria/data selector instead of functions or inline conditionals:
  - ```<button disabled={@disabled} class={my_class(@disabled)}>increment</button>```  in this case the server will receive all the css classes that returns with the my_class fn. So instead of using the function and inject dynamic code directly in the template, we can use data/aria/state selector (that will remain the only dynamic part ) and add code on the css file (which is passed only 1time on mount) like: ```button class="btn" disabled={@disabled}>increment</button>``` and on the css file : `.btn {...} .btn[disabled] {...}`  or can use tailwind variants such `<div class="disabled:bg-red-500 ...">` <- this trick can save a lot especially since we're using tailwind!
 
  - instead of: 
      ```
      <div class={
      "max-w-xs text-sm text-white rounded-md shadow-lg",
      "bg-yellow-500": @kind == "warning",
      "bg-red-500": @kind == "error"
      }
      ``` 
      do this: `<div data-kind={@kind} class="toast">....</div>` and in the css `.toast {...} .toast[data-kind="warning"] {...} .toast[data-kind="error"]{...}` or can use tailwind custom variants such `<div class="data-[kind=error]:bg-red-500 ...">` or using tailwind `group` operator to style several elements based on a variable set in a single parent

## Minimize re-rendering
> For stateless components, if there's any change in an attr, it needs to be re-rendered, meaning while the static parts don't need to be resent, the dynamic parts will _even if they haven't changed_. 

1. Define separate assigns for computed/derived data: do not calculate computed information inline in the component, but rather create a new assign and calculate the assign separately and set in the socket assign
- also make sure we don't re-load data unecessarily, eg. `Bonfire.Boundaries.LiveHandler.my_acls/1`
   
3. Avoid passing more info to stateless components (especially ones likely to change often, e.g in nav, activity preview or composer) than they actually use. This is usually fine for smaller scenarios, but when the component updates several time or lives in a for loop can become messy. example: 
     `<Profile user={@user} />` -> `<Profile first_name={@user.first_name} last_name={@user.last_name} />`

## Minimize server/client communication (<-- this seems also crucial for bonfire)

1. Limit the number of messages that update assigns
2. Batch the assigns' updates (eg. for incoming pubsub messages). See also https://www.youtube.com/watch?v=bodV9Tk_kpQ for tips to optimise pubsub.
- check `:erlang.statistics(:run_queue)` to see if VM schedulers are too busy when messages start to piled up, this can happen even when CPU’s utilization (and load average) stays consistently low.
