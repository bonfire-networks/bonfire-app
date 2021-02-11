const colors = require('tailwindcss/colors')


module.exports = {
  future: {
    // removeDeprecatedGapUtilities: true,
    // purgeLayersByDefault: true,
  },
  purge: {
    // enabled: true,
    content: [
      '../forks/**/**/**/*.leex',
      './lib/web/**/*.leex',
    ]
  },
  theme: {
    extend: {
      colors: {
        blueGray: colors.blueGray,
        amber: colors.amber,
        rose: colors.rose,
        orange: colors.orange,
        teal: colors.teal,
        cyan: colors.cyan
      },
      ringColor: {
        blueGray: colors.blueGray,
      },
      boxShadow: {
        tick: '-3px 3px 1px 0 rgba(0,0,0,.1)'
      },
    }
  },
  variants: {
    extend: {
     ringWidth:['hover'],
     ringColor: ['group-hover', 'hover'],
     borderWidth: ['hover', 'focus'],
    }
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
  ],
}
