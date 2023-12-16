let ExtensionHooks = {};

// TODO: make this more configurable? ie. don't import disabled extensions

import { CopyHooks } from "./../../../deps/bonfire_ui_common/assets/js/copy"
import { TooltipHooks } from "./../../../deps/bonfire_ui_common/assets/js/tooltip"
// import { PopupHooks } from "./../../../deps/bonfire_ui_common/assets/js/popup"

import LiveSelect from "./../../../deps/live_select/priv/static/live_select.min.js"

Object.assign(ExtensionHooks, CopyHooks, TooltipHooks, LiveSelect) // EditorCkHooks, EditorQuillHooks

export { ExtensionHooks }
