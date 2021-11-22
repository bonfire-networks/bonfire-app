let ExtensionHooks = {};

// TODO: make this more configurable? ie. don't import disabled extensions

// import { MyHooks } from "../../../deps/some_extension/assets/js/extension"
import { EditorCkHooks } from "./../../../deps/bonfire_editor_ck/assets/js/extension"

Object.assign(ExtensionHooks, EditorCkHooks)
export { ExtensionHooks }
