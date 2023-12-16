let ExtensionHooks = {};

// NOTE: any extensions included here need to also be added to ./deps.js.sh
// NOTE: during development you may want to change 'deps' in the path to 'forks', but remember to change it back before committing! 
// TODO: make this more configurable? ie. don't import disabled extensions

import { CopyHooks } from "./../../../deps/bonfire_ui_common/assets/js/copy"
import { TooltipHooks } from "./../../../deps/bonfire_ui_common/assets/js/tooltip"
// import { PopupHooks } from "./../../../deps/bonfire_ui_common/assets/js/popup"

import LiveSelect from "./../../../deps/live_select/priv/static/live_select.min.js"

import { GeolocateHooks } from "./../../../deps/bonfire_geolocate/assets/js/extension"
// import { KanbanHooks } from "./../../../deps/bonfire_ui_kanban/assets/js/extension"

Object.assign(ExtensionHooks, CopyHooks, TooltipHooks, LiveSelect, GeolocateHooks) // EditorCkHooks, EditorQuillHooks

export { ExtensionHooks }
