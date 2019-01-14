// Webpack dependencies
let path = require('path'),
    webpack = require('webpack'),
    appRoot = path.resolve(__dirname, '../app'),
    ExtractTextPlugin = require('extract-text-webpack-plugin'),
    buildPath = path.resolve(__dirname, '../../static/znbmain');

let DJANGO_STATIC_PATH = process.env.DJANGO_STATIC_PATH || '';

// Any script from packaje.json can receive an environment value like this:
// NODE_ENV=production npm run watch
// process.env.NODE_ENV is conventionally used and the value can be used by webpack.DefinePlugin to pass to other modules
// or used here in webpack.config.js. See UglifyJsPlugin below.
let NODE_ENV = process.env.NODE_ENV || 'development';

// DJANGO_STATIC_PATH=/home/alexis/mydocker/zinibu/static/znbmain npm run watch
if (DJANGO_STATIC_PATH) {
	console.log("DJANGO_STATIC_PATH set to " + DJANGO_STATIC_PATH);
	buildPath = DJANGO_STATIC_PATH;
} else {
	console.log("Normal mode running...");
}


module.exports = {
  context: path.resolve(__dirname, '../app'),
  entry: {
    main: [
      './main.js',
      '../scss/main.scss'
    ],
    vendor: [
      'jquery'
    ]
  },
  output: {
    path: buildPath,
    publicPath: '../',
    filename: 'js/[name].bundle.js'
  },
  resolve: {
    extensions: ['', '.js']
  },
  plugins: [
    new ExtractTextPlugin('css/styles.css'),
    new webpack.optimize.CommonsChunkPlugin({
      name: ['main', 'vendor'],
      minChunks: Infinity
    }),
    new webpack.DefinePlugin({
      'process.env': {
        'NODE_ENV': JSON.stringify(NODE_ENV)
      }
    }),
    new webpack.ProvidePlugin({
      $: 'jquery'
    })
  ],
  eslint: {
    configFile: path.join(__dirname, '.eslintrc.json')
  },
  module: {
    preLoaders: [
      {
        test: /\.js$/,
        loader: 'eslint-loader',
        exclude: /node_modules/
      },
    ],
    loaders: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        loader: 'babel',
        query: {
          presets: ['es2015']
        }
      },
      {
        test: /\.png$/,
        loader: 'url',
        query: {
          mimetype: 'image/png',
          name: 'i/[name].[ext]',
          limit: 10000
        }
      },
      {
        test: /\.jpg$/,
        loader: 'url',
        query: {
          mimetype: 'image/jpg',
          name: 'i/[name].[ext]',
          limit: 10000
        }
      },
      {
        test: /\.scss$/,
        loader: ExtractTextPlugin.extract('style-loader', 'css?sourceMap!autoprefixer?{browsers:["last 3 version"]}' + '!sass?outputStyle=compact&sourceMap=true&sourceMapContents=true')
      }
    ]
  }
};

// UglifyJsPlugin and OccurrenceOrderPlugin run anyway with -p (alias for --optimize-minimize and --optimize-occurrence-order)
// but we have extra control here, disabling warnings, for example.
if ('production' === NODE_ENV) {
  module.exports.plugins.push(
    new webpack.optimize.UglifyJsPlugin({
      compress: {
    	  warnings: false
        }
    })
  );
  module.exports.plugins.push(
    new webpack.optimize.OccurrenceOrderPlugin()
  );
  module.exports.plugins.push(
    new webpack.optimize.DedupePlugin()
  );
  module.exports.plugins.push(
    new webpack.optimize.AggressiveMergingPlugin()
  );
} else {
  // Enable sourcemaps for debugging webpack's output.
  module.exports.devtool = 'source-map';
}
