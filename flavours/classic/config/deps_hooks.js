let ExtensionHooks = {};

// NOTE: any extensions included here need to also be added to ./deps.js.sh
// NOTE: during development you may want to change 'deps' in the path to 'forks', but remember to change it back before committing! 
// TODO: make this more configurable? ie. don't import disabled extensions

import { ChangeLocaleHooks } from "./../../../deps/bonfire_ui_common/assets/js/change_locale"
import { InputSelectHooks } from "./../../../deps/bonfire_ui_common/assets/js/input_select"
import { NotificationsHooks } from "./../../../deps/bonfire_ui_common/assets/js/notifications"
import { CarouselHooks } from "./../../../deps/bonfire_ui_common/assets/js/carousel"
import { ResponsiveTabsHooks } from "./../../../deps/bonfire_ui_common/assets/js/responsive_tabs"
import { ThemeHooks } from "./../../../deps/bonfire_ui_common/assets/js/theme"
import { PopupHooks } from "./../../../deps/bonfire_ui_common/assets/js/popup"

import { FeedHooks } from "./../../../extensions/bonfire_ui_common/assets/js/feed"
import { ImageHooks } from "./../../../deps/bonfire_ui_common/assets/js/image"
import { EmojiHooks } from "./../../../deps/bonfire_ui_common/assets/js/emoji"
// import { EditorCkHooks } from "./../../../deps/bonfire_editor_ck/assets/js/extension"
// import { EditorQuillHooks } from "./../../../deps/bonfire_editor_quill/assets/js/extension"
import { ComposerHooks } from "./../../../deps/bonfire_ui_common/assets/js/composer"

// import { EditorQuillHooks } from "./../../../deps/bonfire_editor_quill/assets/js/extension"

// import { GeolocateHooks } from "./../../../deps/bonfire_geolocate/assets/js/extension"
// import { KanbanHooks } from "./../../../deps/bonfire_ui_kanban/assets/js/extension"

// import { EncryptHooks } from "./../../../deps/bonfire_encrypt/assets/js/extension"

// import LiveSelect from "./../../../deps/live_select/assets/js/live_select"
import LiveSelect from "./../../../deps/live_select/priv/static/live_select.min.js"

Object.assign(ExtensionHooks, ComposerHooks, PopupHooks, EmojiHooks, ResponsiveTabsHooks, CarouselHooks, FeedHooks, ChangeLocaleHooks, InputSelectHooks, NotificationsHooks, ThemeHooks, ImageHooks, LiveSelect) // EditorCkHooks

export { ExtensionHooks }
