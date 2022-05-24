
import "phoenix_html"

// lightweight JS toolkit
import Alpine from "alpinejs"
import intersect from '@alpinejs/intersect'
import collapse from '@alpinejs/collapse'

Alpine.plugin(intersect)
Alpine.plugin(collapse)

window.Alpine = Alpine
Alpine.start()

// CSS
import * as tagifycss from "../node_modules/@yaireo/tagify/dist/tagify.css";
import * as css from "../css/app.scss"
