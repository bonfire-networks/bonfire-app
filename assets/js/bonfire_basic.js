import "./common"

let Hooks = {}; 

// TODO: put this in something like /config/deps_hooks.js and/or make it extensible/configurable
import { ImageHooks } from "./../../deps/bonfire_ui_common/assets/js/image"

Object.assign(Hooks, ImageHooks);

// run LiveView hooks without LiveView
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
