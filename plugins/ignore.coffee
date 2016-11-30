helpers = require '../helpers'

_ = helpers._
multimatch = helpers.multimatch

now = new Date()

module.exports = (patterns) ->
  values = patterns or ['!**/_*', '!**/_*/**', '!**/.DS_Store']
  patterns = _.concat ['**/*'], values

  (files, metalsmith, done) ->
    filenames = multimatch Object.keys(files), patterns

    for file, data of files
      future = if data.date then data.date >= now else false
      missing = file not in filenames

      if future or missing or data.draft or data.private or data.fork
        delete files[file]

    done()
