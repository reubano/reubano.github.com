path = require 'path'
fs = require 'fs'
helpers = require '../helpers'
pug = require '../node_modules/pug'

_ = helpers._

module.exports =  (opts) ->
  opts = opts or {}
  locals = opts.locals or {}
  def = opts.default or 'post.pug'
  layout_dir = opts.directory or 'layouts'

  (files, metalsmith, done) ->
    if opts.useMetadata
      locals = Object.assign(locals, metalsmith.metadata())

    if opts.filters?
      for filter, func of opts.filters
        pug.filters[filter] = func

    keys = _.keys files
    templateFiles = _.filter keys, (file) -> /\.html/.test path.extname file

    for file, i in templateFiles
      data = files[file]
      locals.page = data
      template = metalsmith.path(layout_dir, data.layout or def)
      filename = path.join(metalsmith.source(), file)
      options = Object.assign(opts, {filename, locals})

      # do (template) ->
      #   console.log("reading #{template}")
      #   fs.readFile template, 'utf8', (err, raw) ->
      #     if (raw)
      #       html = pug.compile(raw, options) locals
      #       data.contents = new Buffer(html)
      #       files[file] = data
      #     if i is templateFiles.length - 1
      #       done()

      html = pug.compileFile(template, options) locals
      data.contents = new Buffer(html)
      files[file] = data
      done()
