let ExtensionHooks = {};

// NOTE: any extensions included here need to also be added to ./deps.js.sh
// NOTE: during development you may want to change 'deps' in the path to 'forks', but remember to change it back before committing! 
// TODO: make this more configurable? ie. don't import disabled extensions

import { ChangeLocaleHooks } from "./../../../forks/bonfire_common/assets/js/change_locale"
import { InputSelectHooks } from "./../../../forks/bonfire_common/assets/js/input_select"
import { NotificationsHooks } from "./../../../forks/bonfire_common/assets/js/notifications"
import { ThemeHooks } from "./../../../forks/bonfire_ui_social/assets/js/theme"
import { EditorCkHooks } from "./../../../forks/bonfire_editor_ck/assets/js/extension"
// import { GeolocateHooks } from "./../../../forks/bonfire_geolocate/assets/js/extension"

Object.assign(ExtensionHooks, ChangeLocaleHooks, InputSelectHooks, NotificationsHooks, ThemeHooks, EditorCkHooks)
 
export { ExtensionHooks }
