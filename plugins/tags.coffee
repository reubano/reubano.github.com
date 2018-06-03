helpers = require '../helpers'
_ = helpers._

module.exports = (options) ->
  tagCache = {}
  options = options or {}
  layout = options.layout or 'tagged.pug'
  pattern = options.pattern or 'tagged/:slug'
  handle = options.handle or 'tags'
  metadataKey = options.metadataKey or 'tags'
  singular = options.singular or 'tag'
  plural = options.plural or 'tags'
  sortBy = options.sortBy or 'title'
  tagsFilter = options.tagsFilter
  dataFilter = options.dataFilter
  reverse = options.reverse

  past = pattern.split('/')[0]
  homePath = metadataKey

  if typeof sortBy is 'string'
    sortBy = [sortBy]

  (files, metalsmith, done) ->
    metadata = metalsmith.metadata()
    defMetadata = {data: [], name: metadataKey, singular, plural, homePath, past}
    metadata[metadataKey] = metadata[metadataKey] or defMetadata

    for file, data of files
      if not data
        continue

      tagsData = data[handle]

      if tagsData
        if typeof tagsData is 'string'
          tagsData = tagsData.split(',')

        if tagsFilter and not tagsFilter tagsData
          continue

        # reset original tag data so we can replace it with cleaned tags
        data[handle] = []

        tagsData.forEach (rawTag) ->
          tag = String(rawTag).trim()

          if not tagCache[tag]
            tagCache[tag] =
              sanitizedLength: {all: 0}
              layout: layout
              name: tag
              slug: helpers.slug tag
              files: []

            matched = helpers.getMatch tagCache[tag], pattern
            tagCache[tag].path = "#{matched}.html"

          data[handle].push(tag)
          tagCache[tag].files.push(data)

        if dataFilter and not dataFilter data
          continue

        for tag in data[handle]
          sanitizedLength = tagCache[tag].sanitizedLength
          sanitizedLength.all += 1

          if sanitizedLength[data.collection]?
            sanitizedLength[data.collection] += 1
          else
            sanitizedLength[data.collection] = 0

    if _.keys(tagCache).length
      for key, tag of tagCache
        tag.files = _.sortBy tag.files, sortBy
        if (reverse) then tag.files.reverse()
        metadata[metadataKey].data.push tag
        files[tag.path] = tag
        files[tag.path].data = [_.pick tag, ['name', 'slug', 'files']]

    data = _.sortBy metadata[metadataKey].data, ['name']
    files["#{homePath}.html"] = {layout, data, name: metadataKey}
    metadata[metadataKey].data = data
    metadata.collections.push metadata[metadataKey]
    done()
