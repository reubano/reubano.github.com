helpers = require('../helpers')
_ = helpers._

DEFAULTS =
  perPage: 10
  maxPages: 5
  firstPage: null
  nest: false
  pick: []

getPos = (pagePos, numPages, maxPages=10, pos=0) ->
  # show limited number of pages like Google
  minDist = maxPages // 2
  notScrolled = numPages <= maxPages
  numShownPages = Math.min(numPages, maxPages)

  if (pagePos <= minDist + pos) or notScrolled
    newPos = pos
  else
    newPos = pagePos - minDist

  maxLastPos = newPos + numShownPages - 1
  lastPos = Math.min(numPages - 1, maxLastPos)
  firstPos = lastPos - numShownPages + 1
  [firstPos, lastPos]

module.exports = (opts) ->
  (files, metalsmith, done) ->
    metadata = metalsmith.metadata()

    for name, settings of opts
      colName = if settings.collection then settings.collection else name
      collection = metadata[colName]

      if not collection
        done new TypeError "Collection '#{colName}' not found!"

      if not collection.data?.length
        continue

      options = _.assign DEFAULTS, settings
      pickEntry = (entry) -> _.pick entry, options.pick

      if (!options.path)
        done new TypeError "The path option is required"

      firstPage = options.firstPage or "#{colName}/index.html"
      perPage = options.perPage or collection.data.length

      if collection.data[0].files
        nested = []

        for entry in collection.data
          nested.push _.map entry.files, (file) ->
            fileObj = _.assign {parentName: entry.name}, file
            fileObj.picked = pickEntry entry
            fileObj

        if options.nest
          colData = nested
        else
          colData = [_.sortBy _.flatten(nested), ['parentName']]

        hasFiles = true
      else
        colData = [collection.data]
        hasFiles = false

      for datum in colData
        if datum.length > perPage
          layout = options.layout
          numPages = Math.ceil(datum.length / perPage)
          pages = []
          pagination = totalPages: numPages, pages: pages

          for pagePos in [0...numPages]
            pageNum = pagePos + 1

            if hasFiles
              data = []
              sliced = datum.slice(pagePos * perPage, pageNum * perPage)

              for name, group of _.groupBy sliced, 'parentName'
                data.push _.assign {files: group}, group[0].picked

            else
              data = collection.data.slice(pagePos * perPage, pageNum * perPage)

            [first, last] = getPos pagePos, numPages, options.maxPages

            page = _.assign {}, options.pageMetadata,
              layout: layout
              data: data
              num: pageNum
              index: pagePos
              first: num: first + 1, index: first
              last: num: last + 1, index: last
              collection: collection.name
              pagination: pagination

            matchData = _.assign {num: pageNum}, pickEntry data[0]

            if pagePos is 0
              page.path = helpers.getMatch matchData, firstPage
            else
              page.path = helpers.getMatch matchData, options.path
              prev = pages[pagePos - 1]
              prev.next = page
              page.prev = prev

            files[page.path] = page
            pages.push(page)

          if not options.nest
            collection.pagination = pagination

    done()
