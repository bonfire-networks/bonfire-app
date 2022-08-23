import "./common"

let Hooks = {}; 

// TODO: put this in something similar to /config/deps_hooks.js and/or make it extensible/configurable
import { ImageHooks } from "./../../deps/bonfire_ui_common/assets/js/image"

Object.assign(Hooks, ImageHooks);

// run LiveView Hooks without LiveView
(function () {
    [...document.querySelectorAll("[phx-hook]")].map((hookEl) => {
        let hookName = hookEl.getAttribute("phx-hook");
        let hook = Hooks[hookName];

        if (hook) {
            let mountedFn = hook.mounted.bind({ ...hook, el: hookEl });
            mountedFn();
        }
    });
}) ();

function phxClick(event) {
    // event.preventDefault(); // Override the native event?
    let name = this.getAttribute("phx-click")
    if (name.charAt(0) == "[") {
        name = JSON.parse(name)[0][1]["event"]
    }
    window.location = "/LiveHandler/" + name + "?" + new URLSearchParams(getPhxValues(this)).toString()
}  

// attempt graceful degradation for LiveView events without LiveView
(function () {
    [...document.querySelectorAll("[phx-click]")].map((el) => {
        el.addEventListener('click', phxClick);
    });
})();

function getPhxValues(el) {
    console.log(el)
    return el
    .getAttributeNames()
    .filter(name => name.startsWith("phx-value-"))
    .reduce((obj, name) => ({
        ...obj,
        [name.substring(10)]: el.getAttribute(name)
    }), {})
}
