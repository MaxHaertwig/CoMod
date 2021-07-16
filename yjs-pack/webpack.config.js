const path = require('path');

module.exports = {
  entry: './yjs/src/index.js',
  mode: 'production',
  output: {
    path: path.resolve(__dirname),
    filename: 'yjs.js',
    library: 'yjs',
  },
};
