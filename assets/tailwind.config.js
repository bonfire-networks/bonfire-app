module.exports = {
  future: {
    // removeDeprecatedGapUtilities: true,
    // purgeLayersByDefault: true,
  },
  purge: [
    './src/**/*.eex',
    './src/**/*.leex',
  ],
  theme: {
    extend: {
      boxShadow: {
        tick: '-3px 3px 1px 0 rgba(0,0,0,.1)'
      }
    },
  },
  variants: {},
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
  ],
}
