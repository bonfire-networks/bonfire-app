let ExtensionHooks = {}; 

// NOTE: any extensions included here need to also be added to ./deps.js.sh
// NOTE: during development you may want to change 'deps' in the path to 'forks', but remember to change it back before committing! 
// TODO: make this more configurable? ie. don't import disabled extensions

// import { ChangeLocaleHooks } from "bonfire_ui_common/assets/js/change_locale"
// import { InputSelectHooks } from "bonfire_ui_common/assets/js/input_select"
// import { NotificationsHooks } from "bonfire_ui_common/assets/js/notifications"
// import { ResponsiveTabsHooks } from "bonfire_ui_common/assets/js/responsive_tabs"
// import { ThemeHooks } from "bonfire_ui_common/assets/js/theme"
// import { CopyHooks } from "bonfire_ui_common/assets/js/copy"
// import { PopupHooks } from "bonfire_ui_common/assets/js/popup"
// import { TooltipHooks } from "bonfire_ui_common/assets/js/tooltip"
// import { FeedHooks } from "bonfire_ui_common/assets/js/feed"
// import { InfiniteScrollHooks } from "bonfire_ui_common/assets/js/infinite_scroll"
// import { ImageHooks } from "bonfire_ui_common/assets/js/image"
// import { EmojiHooks } from "bonfire_ui_common/assets/js/emoji"

// import { MilkdownHooks } from "bonfire_editor_milkdown/assets/js/extension"
// import { EditorCkHooks } from "bonfire_editor_ck/assets/js/extension"
// import { EditorQuillHooks } from "bonfire_editor_quill/assets/js/extension"
// import { ComposerHooks } from "bonfire_ui_common/assets/js/composer"
// import { CodeHooks } from "bonfire_ui_common/assets/js/code"

// import { GeolocateHooks } from "bonfire_geolocate/assets/js/extension"
// import { KanbanHooks } from "bonfire_ui_kanban/assets/js/extension"

// import { EncryptHooks } from "bonfire_encrypt/assets/js/extension"

import { NotifyHooks } from "bonfire_notify/assets/js/extension" 

// import LiveSelect from "live_select/assets/js/live_select"
import LiveSelect from "live_select/priv/static/live_select.min.js"

Object.assign(ExtensionHooks, LiveSelect, NotifyHooks) // CopyHooks, TooltipHooks, EditorCkHooks, EditorQuillHooks

export { ExtensionHooks }
