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
        tick: '-4px 4px 0px 0 rgba(0,0,0,0)'
      },
    }
  },
  variants: {
    extend: {
     ringWidth:['hover'],
     ringColor: ['group-hover', 'hover'],
     fontWeight: ['group-hover'],
     borderWidth: ['hover', 'focus'],
    }
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
  ],
}
