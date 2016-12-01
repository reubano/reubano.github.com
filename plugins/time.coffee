helpers = require '../helpers'
_ = helpers._

module.exports = (options) ->
  (files, metalsmith, done) ->
    metadata = metalsmith.metadata()
    start = metadata.prevEndTime or options.start
    metadata.prevEndTime = _.now()
    time = (metadata.prevEndTime - start) / 1000
    console.log("#{options.plugin} +#{time}s")
    done()
