helpers = require('../helpers')

_ = helpers._
Matcher = helpers.minimatch.Minimatch

module.exports = (opts) ->
  keys = Object.keys(opts)

  match = (file, data) ->
    matches = []
    if data.collection
      matches.push(data.collection)

    for key, val of opts
      if val and (typeof val is 'string') and (new Matcher(val)).match(file)
        matches.push(key)

    _.uniq(matches)

  (files, metalsmith, done) ->
    metadata = metalsmith.metadata()

    if metadata.collections
      for collection in metadata.collections
        delete metadata[collection.name]

    metadata.collections = []

    for file, data of files
      match(file, data).forEach (collection) ->
        if (collection in keys) and collection not in _.keys metadata
          collectionMetadata = opts[collection].metadata ? {}
          defMetadata = {data: [], name: collection}
          metadata[collection] = _.assign defMetadata, collectionMetadata

        data.path = file
        data.collection = collection
        metadata[collection].data.push(data)

    for key, settings of opts
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
