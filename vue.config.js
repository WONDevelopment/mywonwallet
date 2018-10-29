const Dotenv = require('dotenv-webpack');
const ImageminPlugin = require('imagemin-webpack-plugin').default
const webpack = require('webpack');
module.exports = {
  baseUrl: './',
  runtimeCompiler: true,
  configureWebpack: {
    node: {
      process: true
    },
    output: {
      globalObject: 'this'
    },
    devServer: {
      https: false,
      host: '0.0.0.0',
      hotOnly: true,
      port: 3000
    },
    plugins: [
      new Dotenv({
        systemvars: true,
        silent: true
      }),
      new webpack.NormalModuleReplacementPlugin(/^any-promise$/, 'bluebird'),
      new ImageminPlugin({
        test: /\.(jpe?g|png|gif|svg)$/i,
        disable: process.env.NODE_ENV !== 'production',
        pngquant: {
          quality: '95-100'
        }
      })
    ]
  },
  chainWebpack: config => {
    config.module
      .rule('eslint')
      .use('eslint-loader')
      .options({ fix: true });
      //config.resolve.alias.set('vue$', "vue/dist/vue.common.js");
  }
};
