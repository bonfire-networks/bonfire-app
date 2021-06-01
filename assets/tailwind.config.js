const colors = require('tailwindcss/colors')


module.exports = {
  future: {
    removeDeprecatedGapUtilities: true,
    purgeLayersByDefault: true,
  },
  purge: {
    enabled: true,
    content: [
      '../forks/**/lib/**/*.leex',
      '../forks/**/lib/**/**/*.leex',
      '../forks/**/lib/**/**/**/*.leex',
      '../deps/bonfire_**/lib/**/*.leex',
      '../deps/bonfire_**/lib/**/**/*.leex',
      '../deps/bonfire_**/lib/**/**/**/*.leex',
      '../lib/web/**/*.leex',
      '../forks/**/lib/**/*.sface',
      '../forks/**/lib/**/**/*.sface',
      '../forks/**/lib/**/**/**/*.sface',
      '../deps/bonfire_**/lib/**/*.sface',
      '../deps/bonfire_**/lib/**/**/*.sface',
      '../deps/bonfire_**/lib/**/**/**/*.sface',
      '../lib/web/**/*.sface',
    ]
  },
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        gray: colors.coolGray,
        blueGray: colors.blueGray,
        amber: colors.amber,
        rose: colors.rose,
        orange: colors.orange,
        teal: colors.teal,
        cyan: colors.cyan
      },
      ringColor: {
        blueGray: colors.blueGray,
        pink: colors.pink,
      },
      borderColor: {
        blueGray: colors.blueGray,
      },
      boxShadow: {
        tick: '0px 1px 2px rgba(0,0,0,2)'
      },
      spacing: {
        '72': '18rem',
        '84': '21rem',
        '96': '26rem',
      },
      typography: (theme) => ({
        light: {
          css: [
            {
              color: theme('colors.gray.400'),
              '[class~="lead"]': {
                color: theme('colors.gray.300'),
              },
              a: {
                color: theme('colors.white'),
              },
              strong: {
                color: theme('colors.white'),
              },
              'ol > li::before': {
                color: theme('colors.gray.400'),
              },
              'ul > li::before': {
                backgroundColor: theme('colors.gray.600'),
              },
              hr: {
                borderColor: theme('colors.gray.200'),
              },
              blockquote: {
                color: theme('colors.gray.200'),
                borderLeftColor: theme('colors.gray.600'),
              },
              h1: {
                color: theme('colors.white'),
              },
              h2: {
                color: theme('colors.white'),
              },
              h3: {
                color: theme('colors.white'),
              },
              h4: {
                color: theme('colors.white'),
              },
              'figure figcaption': {
                color: theme('colors.gray.400'),
              },
              code: {
                color: theme('colors.white'),
              },
              'a code': {
                color: theme('colors.white'),
              },
              pre: {
                color: theme('colors.gray.200'),
                backgroundColor: theme('colors.gray.800'),
              },
              thead: {
                color: theme('colors.white'),
                borderBottomColor: theme('colors.gray.400'),
              },
              'tbody tr': {
                borderBottomColor: theme('colors.gray.600'),
              },
            },
          ],
        },
      }),
    }
  },
  variants: {
    extend: {
     divideColor: ['dark'],
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
    // require('tailwindcss-debug-screens')
  ],
}
