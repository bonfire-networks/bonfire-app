let ExtensionHooks = {};

// TODO: make this more configurable? ie. don't import disabled extensions

import { ThemeHooks } from "./../../../assets/js/theme"
import { InputSelectHooks } from "./../../../assets/js/input_select"
import { GeolocateHooks } from "./../../../deps/bonfire_geolocate/assets/js/extension"
import { KanbanHooks } from "./../../../deps/bonfire_ui_kanban/assets/js/extension"
import { EditorCkHooks } from "./../../../forks/bonfire_editor_ck/assets/js/extension"

Object.assign(ExtensionHooks, ThemeHooks, InputSelectHooks, GeolocateHooks, KanbanHooks, EditorCkHooks)

export { ExtensionHooks }
