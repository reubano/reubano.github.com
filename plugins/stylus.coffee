path = require 'path'
stylus = require '../node_modules/stylus'
helpers = require('../helpers')

minimatch = helpers.minimatch

absPath = (relative) ->
  cwd = process.cwd()
  if (relative.slice(0, cwd.length) is cwd)
    relative
  else
    path.join(process.cwd(), relative)

module.exports = (opts) ->
  opts = opts or {}
  opts.paths = (opts.paths or []).map(absPath)

  (files, metalsmith, done) ->
    destination = metalsmith.destination()
    source = metalsmith.source()
    styles = Object.keys(files)
      .filter(minimatch.filter("*.+(styl|stylus)", matchBase: true))
      .filter(minimatch.filter("!**/_*"))
      .filter(minimatch.filter("!**/_*/**"))

    paths = styles.map (path) ->
      ret = path.split('/')
      ret.pop()
      source + '/' + ret.join('/')

    opts.paths = paths.concat(opts.paths)

    styles.forEach (file, index, arr) ->
      out = file.split('.')
      out.pop()
      out = out.join('.') + '.css'
      s = stylus(files[file].contents.toString()).set('filename', file)

      # for k, v of opts
      #   if k is 'use'
      #     v.forEach (fn) -> s.use(fn)
      #   else if k is 'define'
      #     for defk, defv of v
      #       s.define(defk, defv)
      #   else
      #     s.set(k, v)

      for k, v of opts
        if k in ['use', 'define']
          continue
        else
          s.set(k, v)

      if (opts.use)
        opts.use.forEach (fn) -> s.use(fn)

      if (opts.define)
        for k, v of opts.define
          s.define(k, v)

      s.render (err, css) ->
        if (err) then throw err
        delete files[file]
        files[out] = contents: new Buffer(css)
        if (opts.sourcemap)
          files["#{out}.map"] = contents: new Buffer JSON.stringify s.sourcemap

    done()
