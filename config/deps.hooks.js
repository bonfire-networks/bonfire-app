let ExtensionHooks = {}; 

// NOTE: any extensions included here need to also be added to ./deps.js.sh
// NOTE: during development you may want to change 'deps' in the path to 'forks', but remember to change it back before committing! 
// TODO: make this more configurable? ie. don't import disabled extensions

// import { ChangeLocaleHooks } from "./../../deps/bonfire_ui_common/assets/js/change_locale"
// import { InputSelectHooks } from "./../../deps/bonfire_ui_common/assets/js/input_select"
// import { NotificationsHooks } from "./../../deps/bonfire_ui_common/assets/js/notifications"
// import { ResponsiveTabsHooks } from "./../../deps/bonfire_ui_common/assets/js/responsive_tabs"
// import { ThemeHooks } from "./../../deps/bonfire_ui_common/assets/js/theme"
// import { CopyHooks } from "./../../deps/bonfire_ui_common/assets/js/copy"
// import { PopupHooks } from "./../../deps/bonfire_ui_common/assets/js/popup"
// import { TooltipHooks } from "./../../deps/bonfire_ui_common/assets/js/tooltip"
// import { FeedHooks } from "./../../deps/bonfire_ui_common/assets/js/feed"
// import { InfiniteScrollHooks } from "./../../deps/bonfire_ui_common/assets/js/infinite_scroll"
// import { ImageHooks } from "./../../deps/bonfire_ui_common/assets/js/image"
// import { EmojiHooks } from "./../../deps/bonfire_ui_common/assets/js/emoji"

// import { MilkdownHooks } from "./../../deps/bonfire_editor_milkdown/assets/js/extension"
// import { EditorCkHooks } from "./../../deps/bonfire_editor_ck/assets/js/extension"
// import { EditorQuillHooks } from "./../../deps/bonfire_editor_quill/assets/js/extension"
// import { ComposerHooks } from "./../../deps/bonfire_ui_common/assets/js/composer"
// import { CodeHooks } from "./../../deps/bonfire_ui_common/assets/js/code"

// import { GeolocateHooks } from "./../../deps/bonfire_geolocate/assets/js/extension"
// import { KanbanHooks } from "./../../deps/bonfire_ui_kanban/assets/js/extension"

// import { EncryptHooks } from "./../../deps/bonfire_encrypt/assets/js/extension"

// import LiveSelect from "./../../deps/live_select/assets/js/live_select"
import LiveSelect from "./../../deps/live_select/priv/static/live_select.min.js"

Object.assign(ExtensionHooks, LiveSelect) // CopyHooks, TooltipHooks, EditorCkHooks, EditorQuillHooks

export { ExtensionHooks }
