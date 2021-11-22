// equivalent of the following + attempted added sass plugin
// plugin is required to support sass imports in any JS deps
// esbuild ./js/bonfire_live.js ./js/bonfire_basic.js --target=es2015 --bundle --sourcemap --loader:.svg=text --outdir=../priv/static/js --watch

const outdir = "../priv/static/js";

// const {sassPlugin} = require("esbuild-sass-plugin")
const { sassPlugin } = require("@es-pack/esbuild-sass-plugin")
// const { createImporter } = require("sass-extended-importer");

// const sass = require('sass')
// var fs = require('fs');

require('esbuild').build({
    plugins: [sassPlugin(
    //     {
    //         cache: true,
    //         importer: createImporter()
    //     }
    )],
    watch: {
        onRebuild(error, result) {
            if (error) console.error('watch build failed:', error)
            else {

                // const result = sass.renderSync({ file: outdir + '/bonfire_live.css' });

                // fs.writeFile(outdir+'/deps.css', result.css.toString(), function (err) {
                //     if (err) throw err;
                //     console.log('sass was transformed');
                // });

                console.log('watch build succeeded:', result)
            }
        },
    },
    bundle: true,
    sourcemap: true,
    target: 'es2015',
    loader: { 
        '.png': 'dataurl',
        '.svg': 'text',
    },
    entryPoints: [
        './js/bonfire_live.js',
        './js/bonfire_basic.js'
    ],
    outdir: outdir
}).then(result => {
    console.log('watching for JS changes...')
})