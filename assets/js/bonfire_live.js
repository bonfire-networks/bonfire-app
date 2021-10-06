// JS shared with non_live pages
import "./common"

// for JS features & extensions to hook into LiveView
let Hooks = {}; 

// Semi-boilerplate Phoenix+LiveView...

import {Socket} from "phoenix"
import NProgress from "nprogress"
import {LiveSocket} from "phoenix_live_view"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
    params: { _csrf_token: csrfToken },
    dom: {
      onBeforeElUpdated(from, to){
        if(from.__x){ Alpine.clone(from.__x, to) }
      }
    },
    hooks: Hooks
})

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", info => NProgress.start())
window.addEventListener("phx:page-loading-stop", info => NProgress.done())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
 
window.liveSocket = liveSocket

import { ExtensionHooks } from "../../data/current_flavour/config/hooks.js"

// Add Extensions' Hooks... 
Object.assign(liveSocket.hooks, ExtensionHooks);
