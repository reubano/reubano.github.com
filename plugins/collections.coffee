helpers = require '../helpers'

_ = helpers._
multimatch = helpers.multimatch

module.exports = (options) ->
  keys = _.keys options

  match = (file, val) ->
    val and (typeof val is 'string') and multimatch([file], val).length

  (files, metalsmith, done) ->
    metadata = metalsmith.metadata()

    if metadata.collections
      for collection in metadata.collections
        delete metadata[collection.name]

    metadata.collections = []

    for file, data of files
      collections = if data.collection then [data.collection] else []

      for key, val of options
        if match(file, val)
          collections.push key

      for collection in _.uniq collections
        if (collection in keys) and collection not in _.keys metadata
          collectionMetadata = options[collection].metadata ? {}
          defMetadata = {data: [], name: collection}
          metadata[collection] = _.defaults collectionMetadata, defMetadata

        data.path = file
        data.collection = collection
        metadata[collection].data.push(data)

    for key, settings of options
      if metadata[key]?.data
        collectionData = _.sortBy metadata[key]?.data, settings.sortBy or 'date'
        if (settings.reverse) then collectionData.reverse()

        last = collectionData.length - 1
        collectionData.forEach (file, index) ->
          file.prev = if (index > 0) then collectionData[index - 1]
          file.next = if (index < last) then collectionData[index + 1]

        metadata[key].data = collectionData
      else
        metadata[key] = _.assign {data: [], name: key}, settings.metadata ? {}

      metadata.collections.push metadata[key]

    done()
