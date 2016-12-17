path = require 'path'
helpers = require '../helpers'

marked = helpers.marked
_ = helpers._

DEFAULTS = ext: 'html', regexp: /\s*<!--\s*more\s*-->/, cutoff: 256
UNESCAPE =
  '&#39;': '\''
  '&amp;': '&'
  '&gt;': '>'
  '&lt;': '<'
  '&quot;': '"'

module.exports = (options) ->
  options = options or {}
  opts = _.defaults options, DEFAULTS

  if typeof opts.regexp is 'string' then new RegExp(opts.regexp) else opts.regexp
  ext = if opts.ext[0] is '.' then opts.ext else ".#{opts.ext}"

  (files, metalsmith, done) ->
    for file, data of files
      if path.extname(file) is ext
        if data.open_issues?
          data.less = "#{data.name} is written in #{data.language}, has #{data.stargazers_count} stars, #{data.forks} forks, #{data.open_issues} open issues, and was last updated #{data.updatedFromNow}."
        else
          data.less = data.less or data.excerpt or data.description

        if data.contents and not data.less
          string = data.contents.toString()

          index = string.search(opts.regexp)

          if index > -1
            less = Buffer.byteLength(string[...index])
          else
            less = opts.cutoff

          lessHTML = marked "#{data.contents[...less].toString()}..."

          if not data.description
            regexp = /<p>(.*?)<\/p>/g
            match = regexp.exec lessHTML
            detagged = match[1].replace /<(?:.|\n)*?>/gm, ''
            reducer = (result, replacement, tag) ->
              result.replace tag, replacement

            data.description = _.reduce UNESCAPE, reducer, detagged

          data.less = new Buffer lessHTML
          data.more = new Buffer marked data.contents[less..].toString()

    done()
