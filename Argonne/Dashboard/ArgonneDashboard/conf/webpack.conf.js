const webpack = require('webpack');
const conf = require('./gulp.conf');
const path = require('path');

const HtmlWebpackPlugin = require('html-webpack-plugin');
const autoprefixer = require('autoprefixer');

module.exports = {
    module: {
        loaders: [
          {
              test: /.json$/,
              loaders: [
                'json'
              ]
          },
          {
              test: /\.(css|scss)$/,
              loaders: [
                'style',
                'css',
                'sass',
                'postcss'
              ]
          },
          {
              test: /\.js$/,
              exclude: /node_modules/,
              loaders: [
                'babel'
              ]
          },
          {
              test: /.html$/,
              loaders: [
                'html'
              ]
          },
          {
              test: /\.(ttf|eot|svg|woff(2)?)(\?[a-z0-9]+)?$/,
              loader: 'file-loader'
          }
        ]
    },
    plugins: [
        new webpack.ProvidePlugin({
            'window.jQuery': 'jquery'
        }),
        new webpack.optimize.OccurrenceOrderPlugin(),
        new webpack.NoErrorsPlugin(),
        new HtmlWebpackPlugin({
            template: conf.path.src('index.html'),
            inject: true
        })
    ],
    postcss: () =>[autoprefixer],
    debug: true,
    devtool: 'cheap-module-eval-source-map',
    output: {
        path: path.join(process.cwd(), conf.paths.tmp),
        filename: 'index.js'
    },
    entry: `./${conf.path.src('index')}`
};
