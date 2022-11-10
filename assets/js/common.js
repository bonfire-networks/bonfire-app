
import "phoenix_html"

// lightweight JS toolkit
import Alpine from "alpinejs"
import intersect from '@alpinejs/intersect'
import collapse from '@alpinejs/collapse'

Alpine.plugin(intersect)
Alpine.plugin(collapse)

window.Alpine = Alpine
Alpine.start()

const winnerDimension = () => {
  // set the viewport inner height in a custom property on the root of the document
  document.documentElement.style.setProperty('--inner-window-height', `${window.innerHeight}px`);
  document.documentElement.style.setProperty('--inner-window-width', `${document.getElementById('inner').getBoundingClientRect().width}px`);
}

winnerDimension()
window.addEventListener('resize', winnerDimension)

// CSS
// import * as tagifycss from "../node_modules/@yaireo/tagify/dist/tagify.css";
// import * as css from "../css/app.scss"
