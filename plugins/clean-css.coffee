helpers = require '../helpers'
CleanCSS = require '../node_modules/clean-css'
async = require '../node_modules/async'

multimatch = helpers.multimatch
_ = helpers._

module.exports = (options) ->
  options = options or {}
  cleanCSS = options.cleanCSS or {}
  pattern = options.files or '**/*.css'
  hasRename = options.rename?
  hasSourceMap = options.sourceMap?
  hasRemoveOriginal = options.removeOriginal?

  rename = if hasRename then options.rename else true
  removeOriginal = if hasRemoveOriginal then options.removeOriginal else true
  createSourceMap = if hasSourceMap then options.sourceMap else true
  sourceMapInlineSources = options.sourceMapInlineSources

  (files, metalsmith, done) ->
    if (createSourceMap)
      cleanCSS.sourceMap = true
      cleanCSS.sourceMapInlineSources = sourceMapInlineSources
      cleanCSS.target = cleanCSS.target or metalsmith._directory

    matches = multimatch _.keys(files), pattern
    cleanCSS = new CleanCSS(cleanCSS)

    asyncCb = (filepath, callback) ->
      file = files[filepath]

      if rename
        basepath = filepath.split('.css')[0]
        outputFilepath = "#{basepath}.min.css"
      else
        outputFilepath = filepath

      sourceMapFilepath = "#{filepath}.map"
      sourceMapFile = files[sourceMapFilepath] or contents: ''
      outputFile = files[outputFilepath] or contents: ''
      cleanCSSOpts = {}
      cleanCSSOpts[filepath] =
        styles: file.contents.toString()
        sourceMap: file.sourceMap or sourceMapFile.contents.toString()

      cleanCSS.minify cleanCSSOpts, (error, minified) ->
        if error
          return callback error

        outputFile.contents = new Buffer(minified.styles)

        if createSourceMap and minified.sourceMap
          minifiedBuf = new Buffer JSON.stringify minified.sourceMap
          outputFile.sourceMap = sourceMapFile.contents = minifiedBuf

          unless sourceMapInlineSources
            files[sourceMapFilepath] = sourceMapFile

        files[outputFilepath] = outputFile

        if removeOriginal and rename
          delete files[filepath]

        callback()

    async.each matches, asyncCb, done
