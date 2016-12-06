helpers = require '../helpers'

_ = helpers._
multimatch = helpers.multimatch

getCollectionMetadata = (collection, settings) ->
  collectionMetadata = settings.metadata ? {}
  collectionData = settings.data ? []
  defMetadata = {data: collectionData, name: collection}
  _.defaults collectionMetadata, defMetadata

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
          metadata[collection] = getCollectionMetadata collection, options[collection]

        data.path = file
        data.collection = collection
        metadata[collection].data.push(data)

    for key, settings of options
      lookup = settings.collection
      collectionData = metadata[key]?.data or metadata[lookup]?.data

      if collectionData
        if settings.filter
          filteredData = _.filter collectionData, settings.filter
        else
          filteredData = collectionData

        sortedData = _.sortBy filteredData, settings.sortBy or 'date'
        if settings.reverse then sortedData.reverse()

        if not sortedData?.length
          continue

        last = sortedData.length - 1
        sortedData.forEach (file, index) ->
          file.prev = if (index > 0) then sortedData[index - 1]
          file.next = if (index < last) then sortedData[index + 1]

        if metadata[key]
          metadata[key].data = sortedData
        else
          settings.data = sortedData
          metadata[key] = getCollectionMetadata key, settings
          extraData = {name: key, title: settings.metadata?.title or key}
          fileData = _.assign {}, files["#{lookup}.html"], extraData
          files["#{key}.html"] = fileData
      else
        metadata[key] = getCollectionMetadata key, settings

      metadata.collections.push metadata[key]

    done()
