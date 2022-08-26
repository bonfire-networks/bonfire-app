let ExtensionHooks = {};

// NOTE: any extensions included here need to also be added to ./deps.js.sh
// NOTE: during development you may want to change 'deps' in the path to 'forks', but remember to change it back before committing! 
// TODO: make this more configurable? ie. don't import disabled extensions

import { ChangeLocaleHooks } from "./../../../deps/bonfire_ui_common/assets/js/change_locale"
import { InputSelectHooks } from "./../../../deps/bonfire_ui_common/assets/js/input_select"
import { NotificationsHooks } from "./../../../deps/bonfire_ui_common/assets/js/notifications"
// import { EmojiHooks } from "./../../../deps/bonfire_ui_common/assets/js/emoji"
import { ThemeHooks } from "./../../../deps/bonfire_ui_common/assets/js/theme"
import { FeedHooks } from "./../../../deps/bonfire_ui_common/assets/js/feed"
import { ImageHooks } from "./../../../deps/bonfire_ui_common/assets/js/image"
// import { EditorCkHooks } from "./../../../deps/bonfire_editor_ck/assets/js/extension"
import { EditorQuillHooks } from "./../../../deps/bonfire_editor_quill/assets/js/extension"
// import { GeolocateHooks } from "./../../../deps/bonfire_geolocate/assets/js/extension"

Object.assign(ExtensionHooks, FeedHooks, ChangeLocaleHooks, InputSelectHooks, NotificationsHooks, ThemeHooks, ImageHooks, EditorQuillHooks) // EditorCkHooks, GeolocateHooks
 
export { ExtensionHooks }
 