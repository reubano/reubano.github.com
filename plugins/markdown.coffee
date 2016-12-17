path = require 'path'
hljs = require '../node_modules/highlight.js'
helpers = require '../helpers'

marked = helpers.marked
_ = helpers._

DEFAULTS =
  smartypants: true
  highlight: (code, lang) -> hljs.highlight(lang, code).value

markdown = (file) -> /\.md|\.markdown/.test(path.extname(file))

module.exports = (options) ->
  options = options or {}
  opts = _.defaults options, DEFAULTS
  keys = options.keys or []

  (files, metalsmith, done) ->
    for file, data of files
      if markdown(file)
        dir = path.dirname(file)
        htmlPath = "#{path.basename(file, path.extname(file))}.html"

        if dir isnt '.'
          htmlPath = "#{dir}/#{htmlPath}"

        if data.contents
          data.markdown = data.contents
          str = marked data.markdown.toString(), opts
          data.html = new Buffer(str)

        keys.forEach (key) -> data[key] = marked(data[key], opts)
        delete files[file]
        files[htmlPath] = data

    done()
