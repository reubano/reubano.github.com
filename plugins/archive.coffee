_ = require 'lodash'
moment = require('moment')

isArray = _.isarray
isEmpty = _.isempty
remove = _.remove

options =
  pages: 'pages' # directory containing pages
  articles: 'articles' # directory containing contents to paginate

getArchives: (contents, type='all') ->
  articles = _getArticles contents

  if type in ['yearly', 'monthly']
    archives = _.map articles, (item) ->
      year = item.date.getFullYear()
      switch type
        when 'yearly' then year
        when 'monthly' then "#{year}/#{item.date.getMonth() + 1}"

    unique = _.uniq archives
    unique.sort()
    _.filter unique, (item) -> item
  else
    articles

countArchives: (articles) ->
  _.countBy articles, (item) -> moment(item.date).format 'YYYY/MM'

module.exports = (options) ->
  periodCache = {}
  options = options or {}
  groupByMonth = options.groupByMonth
  sortBy = options.sortBy or 'date'
  reverse = options.reverse or false
  metadataKey = options.metadataKey or 'archive'

  if (groupByMonth)
    path = 'archive/:year/:month/index.html'
  else
    path = 'archive/:year/index.html'


  if typeof collections is 'string'
    collections = [collections]

  (files, metalsmith, done) ->
    metadata = metalsmith.metadata()
    defMetadata = data: [], name: metadataKey
    metadata[metadataKey] = metadata[metadataKey] or defMetadata

    for file, data of files
      if not data?.date
        continue

      if (groupByMonth)
        period = moment(data.date).format('YYYY/MM')
        [year, month] = period.split('/')
      else
        period = data.date.getFullYear()
        [year, month] = [period, null]

      if period
        if not periodCache[period]
          periodCache[period] =
            name: period
            path: path.replace(/:year/g, year).replace(/:month/g, month)
            files: []

        periodCache[period].files.push(data)
        data[metadataKey] = periodCache[period]

    if _.keys(periodCache).length
      for period, data of periodCache
        data.files.sort(sortBy)
        if (reverse) then data.files.reverse()
        metadata[metadataKey].data.push data

    metadata.collections.push metadata[metadataKey]
    metalsmith.metadata(metadata)
    done()

