
import "phoenix_html"

// lightweight JS toolkit
import Alpine from "alpinejs"
import intersect from '@alpinejs/intersect'

Alpine.plugin(intersect)

window.Alpine = Alpine
Alpine.start()
