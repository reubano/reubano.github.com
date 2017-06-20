path = require 'path'
helpers = require '../helpers'

marked = helpers.marked
_ = helpers._

DEFAULTS = ext: 'html', regexp: /\s*<!--\s*more\s*-->/, cutoff: 256
UNESCAPE = '&#39;': '\'', '&amp;': '&', '&gt;': '>', '&lt;': '<', '&quot;': '"'

module.exports = (options) ->
  options = options or {}
  opts = _.defaults options, DEFAULTS

  if typeof opts.regexp is 'string' then new RegExp(opts.regexp) else opts.regexp
  ext = if opts.ext[0] is '.' then opts.ext else ".#{opts.ext}"

  (files, metalsmith, done) ->
    for file, data of files
      if path.extname(file) is ext
        data.less = data.less or data.excerpt or data.description

        if data.contents and not data.less
          string = data.contents.toString()
          headingless = string.replace /^#.*$/mg, ''
          index = headingless.search opts.regexp
          less = if index > -1 then index else opts.cutoff
          lessHTML = marked "#{headingless[...less]}..."

          if not data.description
            regexp = /<p>(.*?)<\/p>/g
            match = regexp.exec lessHTML
            detagged = match[1].replace /<(?:.|\n)*?>/gm, ''

            reducer = (result, replacement, tag) ->
              result.replace tag, replacement

            data.description = _.reduce UNESCAPE, reducer, detagged

          data.less = new Buffer lessHTML
          data.more = new Buffer marked headingless[less..]

    done()
