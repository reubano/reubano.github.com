lunr = require '../node_modules/lunr'

helpers = require('../helpers')
_ = helpers._

createDocumentIndex = (fields, datum) ->
  index = path: datum.path

  for field in fields
    contents = datum[field]
    isBuffer = contents instanceof Buffer
    isArray = _.isArray contents
    isObject = _.isObject contents

    if isBuffer
      index[field] = contents.toString()
    else if isArray
      index[field] = contents.toString()
    else if isObject
      index[field] = JSON.stringify contents
    else
      index[field] = contents

  index

module.exports = (opts) ->
  opts = opts or {}
  opts.indexPath = opts.indexPath or 'searchIndex.json'
  opts.fields = opts.fields or contents: 1
  opts.pipelineFunctions = opts.pipelineFunctions or []
  opts.ref = opts.ref or 'path'

  (files, metalsmith, done) ->
    metadata = metalsmith.metadata()
    collection = metadata[opts.collection]

    index = lunr ->
      if opts.pipelineFunctions
        @pipeline.add f for f in opts.pipelineFunctions

      @field field, {boost} for field, boost of opts.fields
      @ref opts.ref

    for datum in collection.data
      docIndex = createDocumentIndex(Object.keys(opts.fields), datum)
      index.add(docIndex)

    files[opts.indexPath] = contents: new Buffer(JSON.stringify(index))
    done()
