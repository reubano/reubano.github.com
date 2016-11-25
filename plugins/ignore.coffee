minimatch = require 'minimatch'
now = new Date()

module.exports = (opts) ->
  if (typeof opts is 'string')
    opts = [opts]
  else if (opts instanceof Array)
    opts = patterns: opts

  opts = opts or {}
  patterns = opts.patterns or ['**/_*', '**/_*/**', '**/.DS_Store']

  (files, metalsmith, done) ->
    filenames = Object.keys(files)
    for pattern in patterns
      filenames = filenames.filter minimatch.filter "!#{pattern}"

    for file, data of files
      future = if data.date then data.date >= now else false
      missing = file not in filenames

      if future or missing or data.draft or data.private or data.fork
        delete files[file]

    done()
