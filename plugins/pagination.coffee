helpers = require('../helpers')
_ = helpers._

DEFAULTS =
  perPage: 10
  maxPages: 5
  firstPage: null
  nest: false
  reverse: false
  filter: false
  pick: []
  sortBy: ['parentName']

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

      options = _.assign {}, DEFAULTS, settings
      options.page = options.page or options.pick

      if options.filter
        filtered = _.filter collection.data, options.filter
      else
        filtered = collection.data

      if not filtered?.length
        continue

      if (!options.path)
        done new TypeError "The path option is required"

      firstPage = options.firstPage or "#{colName}/index.html"
      perPage = options.perPage or filtered.length

      if filtered[0].files
        nested = []

        for entry in filtered
          nested.push _.map entry.files, (file) ->
            fileObj = _.assign {parentName: entry.name}, file
            fileObj.picked = _.pick entry, options.pick
            fileObj

        if options.nest
          colData = nested
        else
          sorted = _.sortBy _.flatten(nested), options.sortBy

          if options.reverse
            sorted.reverse()

          colData = [sorted]

        hasFiles = true
      else
        colData = [filtered]
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
              unsorted = []
              sliced = datum.slice(pagePos * perPage, pageNum * perPage)

              for name, group of _.groupBy sliced, 'parentName'
                sortedGroup = _.sortBy group, options.sortBy

                if options.reverse
                  sortedGroup.reverse()

                unsorted.push _.assign {files: sortedGroup}, group[0].picked

              data = _.sortBy unsorted, options.sortBy

              if options.reverse
                data.reverse()
            else
              data = filtered.slice(pagePos * perPage, pageNum * perPage)

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

            if hasFiles and options.page.length
              _.assign page, _.pick data[0], options.page

            matchData = _.assign {num: pageNum}, _.pick data[0], options.pick

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
