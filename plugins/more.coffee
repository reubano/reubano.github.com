path = require 'path'
helpers = require '../helpers'

marked = helpers.marked
defaults = ext: 'html', regexp: /\s*<!--\s*more\s*-->/, cutoff: 30

module.exports = (options) ->
  options = options or {}
  ext = options.ext or defaults.ext
  regexp = options.regexp or defaults.regexp
  key = options.key or defaults.key
  ext = if ext[0] is '.' then ext else '.' + ext
  cutoff = options.cutoff or defaults.cutoff

  if typeof regexp is 'string'
    regexp = new RegExp(regexp)

  (files, metalsmith, done) ->
    for file, data of files
      if path.extname(file) is ext
        if data.open_issues?
          data.less = "#{data.name} is written in #{data.language}, has #{data.stargazers_count} stars, #{data.forks} forks, #{data.open_issues} open issues, and was last updated #{data.updatedFromNow}."
        else
          data.less = data.less or data.excerpt or data.description

        if data.contents and not data.less
          string = data.contents.toString()

          index = string.search(regexp)
          less = if index > -1 then Buffer.byteLength(string[...index]) else cutoff

          data.less = new Buffer marked "#{data.contents[...less].toString()}..."
          data.more = new Buffer marked data.contents[less..].toString()

    done()
