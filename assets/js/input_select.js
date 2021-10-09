let InputSelectHooks = {};

import Tagify from '@yaireo/tagify'

InputSelectHooks.InputOrSelectOne = {


    initInputOrSelectOne() {
        let hook = this,
            $input = hook.el.querySelector("input"),
            $select = hook.el.querySelector("select");

        var suggestions = []
        
        Array.from($select.options).forEach(opt => {
            var entry = {};
            entry.value = opt.value;
            entry.text = opt.text;
            suggestions.push(entry);
        });
        console.log(suggestions)

        suggestionItemTemplate = function(tagData){
            return `
            <div ${this.getAttributes(tagData)}
                class='tagify__dropdown__item ${tagData.class ? tagData.class : ""}'
                tabindex="0"
                role="option">
                <span>${tagData.text}</span>
            </div>
            `
        }

        new Tagify($input, {
            tagTextProp: 'text',
            enforceWhitelist: false,
            mode: "select",
            whitelist: suggestions,
            // blacklist: ['foo', 'bar'],
            templates: {
                dropdownItem: suggestionItemTemplate
            },
        })
    },

    mounted() {
        this.initInputOrSelectOne();
    },

    // selected(hook, event) {
    //     let id = event.params.data.id;
    //     hook.pushEvent("country_selected", { country: id })
    // }
}

export { InputSelectHooks }