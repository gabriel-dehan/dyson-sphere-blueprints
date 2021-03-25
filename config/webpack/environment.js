const { environment } = require('@rails/webpacker')
const erb = require('./loaders/erb')

const webpack = require('webpack');
// Preventing Babel from transpiling NodeModules packages
environment.loaders.delete('nodeModules');
environment.plugins.prepend('Provide',
  new webpack.ProvidePlugin({
    Popper: ['popper.js', 'default']
  })
);
environment.loaders.prepend('erb', erb)
module.exports = environment
