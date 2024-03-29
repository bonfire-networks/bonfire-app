/*
This file was generated by the Surface compiler.
*/


let PreviewActivity = {
  isTruncated(element) {
    if (element && (element.offsetHeight < element.scrollHeight ||
      element.offsetWidth < element.scrollWidth)) {
      console.log("element has an overflow, ie. truncated with CSS line-clamp")
      return true
    } else {
      console.log("element is not truncated")
      return false
    }
  },
  mounted() {
    this.el.addEventListener("click", e => {
      console.log("PreviewActivity clicked")
      let trigger = this.el.querySelector('.open_preview_link')
        let anchor = e.target.closest('a')
        console.log(e.target)

        // this was used to expand long posts by clicking on them, now replaced with a 'Read more' button
        // let previewable_activity = e.target.closest('.previewable_activity')
        // anchor == trigger || (!anchor && previewable_activity && ( previewable_activity.classList.contains('previewable_expanded') || this.isTruncated(previewable_activity.querySelector('.previewable_truncate')) == false)

      if ((trigger || !window.liveSocket) && ((!anchor || anchor.classList.contains('preview_activity_link')) && !e.ctrlKey && !e.metaKey && (!window.getSelection().toString() || window.getSelection().toString() == "") && !e.target.closest('button') && !e.target.closest('figure') && !e.target.closest('.dropdown') && !e.target.closest('[data-id=activity_actions]')
        )) {
          let uri = this.el.dataset.href || (trigger !== undefined && trigger.getAttribute('href')) 
          if (window.liveSocket) {
            // const feed = document.querySelector(".feed")
            const main = document.getElementById("inner")
            const layout = document.getElementById("root")
            const preview_content = document.getElementById("preview_content")
            let previous_scroll = null

            console.log("push event to load up the PreviewContent")
            this.pushEventTo(trigger, "open", {})

            // this.pushEvent("Bonfire.Social.Feeds:open_activity", { id: this.el.dataset.id, permalink: uri })

            if (layout) {
              previous_scroll = layout.scrollTop
            }

            if (preview_content) {
              preview_content.classList.remove("hidden")
            }
            if (main) {
              main.classList.add("hidden")
            }
            if (uri) {
              // console.log(uri)

              history.pushState(
                {
                  'previous_url': document.location.href,
                  'previous_scroll': previous_scroll
                },
                '',
                uri)
            }

            e.preventDefault();

          } else {

            // fallback if not connected with live socket

            if (uri) {
              console.log(uri)
              window.location = uri;
              e.preventDefault();
            } else {
              console.log("No URL")
            }
          }

        } else {

        // e.preventDefault();
        
        console.log("PreviewActivity: do not trigger preview in favour of another link or button's action (or opening in new tab)")

        console.log(trigger)
        console.log(window.liveSocket)
        console.log(anchor)
        console.log(anchor.classList)
        console.log(e.ctrlKey)
        console.log(e.metaKey)
        console.log(window.getSelection().toString())
        console.log(e.target.closest('button'))
        console.log(e.target.closest('figure'))
        console.log(e.target.closest('.dropdown'))
        console.log(e.target.closest('[data-id=activity_actions]'))

          // if (previewable_activity) { previewable_activity.classList.add("previewable_expanded") }

          return;

        }


      

    })
  }
}


// let Back = {
//   mounted() {

//     if (window.history.length > 1) {
//       // show the back icon svg
//       this.el.classList.remove("hidden")

//       this.el.addEventListener("click", e => {
//         console.log(window.history)
//         e.preventDefault();
//         // window.history.back();

//        })
//       } else {
//       // se la cronologia del browser è vuota, non fare nulla
//     }

//     }
// }


let ClosePreview = { 
  mounted() {

    const back = function () {
      const layout = document.getElementById("root")
      const main = document.getElementById("inner")
      const preview_content = document.getElementById("preview_content")
      if (preview_content) {
        preview_content.classList.add("hidden")
      }
      if (history.state) {
        location_before_preview = history.state["previous_url"]
        previous_scroll = history.state["previous_scroll"]
        main.classList.remove("hidden")
        if (location_before_preview) {
          history.pushState({}, '', location_before_preview)
        }
        if (previous_scroll) {
          layout.scrollTo({ top: previous_scroll, behavior: 'instant' })
          // window.scrollTo(0, previous_scroll);
        }
      }
    }

    // close button
    this.el.addEventListener("click", e => {
      console.log("click - attempt going back")
      back()
    })

    // intercept browser "back" action
    window.addEventListener("popstate", e => {
      console.log("popstate - attempt going back via browser")

      // prevent the app from firing the event
      e.preventDefault();
      console.log("qui")

      // this.pushEvent("Bonfire.UI.Common.OpenPreviewLive:close", {})
      back();
    })
  }
  
}

export { PreviewActivity, ClosePreview }
