let ThemeHooks = {};

import { themeChange } from "theme-change"

// run to load previously chosen theme when first loading any page
themeChange()

ThemeHooks.Themeable = {

    mounted() {
        // run on a view/component with theme-changing controls (wrapper should have phx-hook="Themeable")
        themeChange(false) 
    },

}

export { ThemeHooks }