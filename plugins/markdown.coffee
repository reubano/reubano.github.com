path = require 'path'
helpers = require '../helpers'

marked = helpers.marked

markdown = (file) -> /\.md|\.markdown/.test(path.extname(file))

module.exports = (options) ->
  options = options or {}
  keys = options.keys or []

  (files, metalsmith, done) ->
    for file, data of files
      if markdown(file)
        dir = path.dirname(file)
        html = path.basename(file, path.extname(file)) + '.html'
        if '.' != dir
          html = dir + '/' + html

        if data.contents
          data.markdown = data.contents
          str = marked(data.markdown.toString(), options)
          data.html = new Buffer(str)

        keys.forEach (key) -> data[key] = marked(data[key], options)
        delete files[file]
        files[html] = data

    done()
