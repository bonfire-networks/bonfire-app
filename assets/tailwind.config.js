const colors = require('tailwindcss/colors')


module.exports = {
  mode: 'jit',
  future: {
    removeDeprecatedGapUtilities: true,
    purgeLayersByDefault: true,
  },
  content: [
    '../{lib,forks,deps}/**/*{.leex,.heex,.sface,_live.ex,.js}',
    './js/*.js'
  ],
  theme: {
    extend: {
      fontFamily: {
        'sans': ['IBM Plex Sans', 'system-ui']
      },
      screens: {
        'tablet': '920px',
        'tablet-lg': '1200px'
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
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('daisyui')
    // require('tailwindcss-debug-screens')
  ],
}
