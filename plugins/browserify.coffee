path = require 'path'
browserify = require '../node_modules/browserify'

module.exports = (options) ->
  options.destFolder ?= 'scripts'
  options.dest ?= 'bundle.js'
  options.transforms ?= ['coffeeify']
  options.ignore ?= []
  options.extensions ?= ['.js', '.coffee']

  for transform, i in options.transforms
    options.transforms[i] = require transform

  bundler = browserify options
  bundler.ignore file for file in options.ignore
  bundler.transform transform for transform in options.transforms

  (files, metalsmith, done) ->
    if options.source?
      bundler.add path.join metalsmith.source(), options.source
      delete files[options.source]
    else
      Object.keys(files).forEach (file) ->
        if path.extname(file) in options.extensions
          bundler.add path.join metalsmith.source(), file
          delete files[file]

    bundler.bundle (err, buf) ->
      dest = path.join options.destFolder, options.dest
      files[dest] = path: dest, contents: buf
      done err
