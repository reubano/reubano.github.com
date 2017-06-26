helpers = require('../helpers')

_ = helpers._
moment = helpers.moment

module.exports = (options) ->
  dataCache = []
  periodCache = {}
  options = options or {}
  collections = options.collections
  layout = options.layout or 'archive.pug'
  groupByMonth = options.groupByMonth
  metadataKey = options.metadataKey or 'archive'
  singular = options.singular or 'archive'
  plural = options.metadataKey or 'archives'
  sortBy = options.sortBy or 'date'
  reverse = options.reverse

  if typeof sortBy is 'string'
    sortBy = [sortBy]

  monthPattern = "#{metadataKey}/:year/:month"
  yearPattern = "#{metadataKey}/:year"
  homePath = metadataKey

  (files, metalsmith, done) ->
    metadata = metalsmith.metadata()
    defMetadata = {data: [], name: metadataKey, singular, plural}
    metadata[metadataKey] = metadata[metadataKey] or defMetadata

    for file, data of files
      if not (data?.date and data?.collection)
        continue
      else if collections and data.collection not in collections
        continue

      year = helpers.formatDate(data.date, 'YYYY')

      if year
        if not periodCache[year]
          periodCache[year] =
            layout: layout
            canonical: true
            name: year
            year: year
            files: []

          matched = helpers.getMatch periodCache[year], yearPattern
          periodCache[year].path = "#{matched}.html"

        periodCache[year].files.push(data)

      if groupByMonth
        period = moment(data.date).format('YYYY/MM')
        month = parseInt period.split('/')[1]

        if not periodCache[period]
          periodCache[period] =
            layout: layout
            name: period
            date: new Date(year, month - 1, 1, 0, 0, 0, 0)
            year: year
            month: month
            files: []

          matched = helpers.getMatch periodCache[period], monthPattern
          periodCache[period].path = "#{matched}.html"

        periodCache[period].files.push(data)

    if _.keys(periodCache).length
      for key, period of periodCache
        period.files = _.sortBy period.files, sortBy
        if (reverse) then period.files.reverse()
        dataCache.push period
        files[period.path] = period
        files[period.path].data = [_.pick period, ['year', 'month', 'files']]

    data = _.sortBy dataCache, sortBy
    if (reverse) then data.reverse()
    files["#{homePath}.html"] =
      layout: layout
      data: _.filter data, 'canonical'
      name: metadataKey

    metadata[metadataKey].data = data
    metadata.collections.push metadata[metadataKey]
    done()
