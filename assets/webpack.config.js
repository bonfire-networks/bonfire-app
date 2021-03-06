const path = require('path');
const glob = require('glob');
const HardSourceWebpackPlugin = require('hard-source-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const TerserPlugin = require('terser-webpack-plugin');
const OptimizeCSSAssetsPlugin = require('optimize-css-assets-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');

module.exports = (env, options) => {
  const devMode = options.mode !== 'production';

  return {
    optimization: {
      minimizer: [
        new TerserPlugin({ cache: true, parallel: true, sourceMap: devMode }),
        new OptimizeCSSAssetsPlugin({})
      ]
    },
    entry: {
      'non_live': glob.sync('./vendor/**/*.js').concat(['./js/non_live.js']),
      'live': glob.sync('./vendor/**/*.js').concat(['./js/live.js'])
    },
    output: {
      filename: '[name].js',
      path: path.resolve(__dirname, '../priv/static/js'),
      publicPath: '/js/'
    },
    devtool: devMode ? 'eval-cheap-module-source-map' : undefined,
    module: {
      rules: [
        {
          test: /\.js$/,
          exclude: /node_modules/,
          use: {
            loader: 'babel-loader'
          }
        },
        {
          // fonts
          test: /\.(woff(2)?|ttf|otf|eot)(\?v=\d+\.\d+\.\d+)?$/,
          use: [
            {
              loader: "file-loader",
              options: {
                name: "[name].[ext]",
                outputPath: "../fonts",
              },
            },
          ]
        },
        {
          test: /\.[s]?css$/,
          use: [
            MiniCssExtractPlugin.loader,
            'css-loader',
            // 'sass-loader',
            'postcss-loader',
          ],
        },
        {
          // images assets
          test: /\.(gif|png|svg|jpg|jpeg)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
          use: ['file-loader'],
        },
      ]
    },
    plugins: [
      new MiniCssExtractPlugin({ filename: '../css/app.css' }),
      new CopyWebpackPlugin([{ from: 'static/', to: '../' }])
    ]
    .concat(devMode ? [new HardSourceWebpackPlugin()] : [])
  }
};
