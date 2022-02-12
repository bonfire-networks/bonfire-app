let ExtensionHooks = {};

// TODO: make this more configurable? ie. don't import disabled extensions

import { ThemeHooks } from "./../../../assets/js/theme"
import { CommonHooks } from "./../../../deps/bonfire_common/assets/js/extension"
import { InputSelectHooks } from "./../../../assets/js/input_select"
import { GeolocateHooks } from "./../../../deps/bonfire_geolocate/assets/js/extension"
// import { KanbanHooks } from "./../../../deps/bonfire_ui_kanban/assets/js/extension"
import { EditorCkHooks } from "./../../../deps/bonfire_editor_ck/assets/js/extension"
import { NotificationsHooks } from "./../../../assets/js/notifications"

Object.assign(ExtensionHooks, ThemeHooks, InputSelectHooks, CommonHooks, GeolocateHooks, EditorCkHooks, NotificationsHooks)

export { ExtensionHooks }
