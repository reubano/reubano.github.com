_ = require 'lodash'

module.exports = (opts) ->
  (files, metalsmith, done) ->
    metadata = metalsmith.metadata()
    start = metadata.prevEndTime or opts.start
    metadata.prevEndTime = _.now()
    time = (metadata.prevEndTime - start) / 1000
    console.log("#{opts.plugin} +#{time}s")
    done()
