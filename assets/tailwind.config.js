const colors = require('tailwindcss/colors')


module.exports = {
  mode: 'jit',
  future: {
    removeDeprecatedGapUtilities: true,
    purgeLayersByDefault: true,
  },
  content: [
    '../{lib,forks,deps}/**/*{.leex,.heex,.sface,_live.ex,.js}',
    '../deps/bonfire_ui_common/live_select/lib/live_select/component.*ex', // FIXME: what should this point to?
    './js/*.js'
  ],
  theme: {
    extend: {
      fontFamily: {
        'sans': ['OpenDyslexic', 'Inter', 'Noto Sans', 'Roboto', 'system-ui', 'sans-serif']
      },
      screens: {
        'tablet': '920px',
        'tablet-lg': '1200px',
        'desktop-lg': '1448px',
        'wide': '1920px'
      },
      maxWidth: {
        '600': '600px'
      },
      colors: {
        gray: colors.gray,
        blueGray: colors.slate,
        amber: colors.amber,
        rose: colors.rose,
        orange: colors.orange,
        teal: colors.teal,
        cyan: colors.cyan
      },
      spacing: {
        '72': '18rem',
        '84': '21rem',
        '90': '22rem',
        '96': '26rem',
      },
      typography: (theme) => ({
        sm: {
          css: {
            fontSize: '15px',
            h1: {
              margin: 0
            },
            h2: {
              margin: 0
            },
            h3: {
              margin: 0
            },
            p: {
              margin: 0,
              lineHeight: '20px' 
            },
            li: {
              lineHeight: '20px'
            }
          }
        },
        lg: {
          css: {
            h1: {
              margin: 0
            },
            h2: {
              margin: 0
            },
            h3: {
              margin: 0
            },
            p: {
              margin: 0,
              lineHeight: '20px' 
            },
            li: {
              lineHeight: '20px'
            }
          }
        }
      }),
    }
  },
  daisyui: {
    darkTheme: "bonfire",
    themes: [
      {
        bonfire: {
          ...require("daisyui/src/colors/themes")["[data-theme=dracula]"],
          "primary": "#fde047"
        },
      },
      "dark", "light", "cupcake", "bumblebee", "emerald", "corporate", "synthwave", "retro", "cyberpunk", "valentine", "halloween", "garden", "forest", "aqua", "lofi", "pastel", "fantasy", "wireframe", "black", "luxury", "dracula", "cmyk", "autumn", "business", "acid", "lemonade", "night", "coffee", "winter"
    ]
  },
  variants: {
    extend: {
     ringWidth:['hover'],
     divideColor: ['dark'],
     ringColor: ['group-hover', 'hover'],
     fontWeight: ['group-hover'],
     borderWidth: ['hover', 'focus'],
     typography: ['dark']
    }
  },
  plugins: [
    require('@tailwindcss/line-clamp'),
    require('@tailwindcss/typography'),
    require('daisyui')
    // require('tailwindcss-debug-screens')
  ],
}
