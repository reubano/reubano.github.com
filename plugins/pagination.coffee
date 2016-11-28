helpers = require('../helpers')
_ = helpers._

DEFAULTS =
  perPage: 10
  maxPages: 5
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
      collection = metadata[name]

      if not collection
        done new TypeError "Collection '#{name}' not found!"

      if not collection.data?.length
        continue

      options = _.assign DEFAULTS, settings
      pickEntry = (entry) -> _.pick entry, options.pick

      if (!options.path)
        done new TypeError "The path '#{name}' is required"

      perPage = options.perPage or collection.data.length

      if collection.data[0].files
        mapped = []

        for entry in collection.data
          mapped.push _.map entry.files, (file) ->
            _.assign {parentName: entry.name}, file, pickEntry entry

        _files = _.sortBy _.flatten(mapped), ['parentName']
        # _files = _.flatten (entry.files for entry in collection.data)
        length = _files.length
        hasFiles = true
      else
        length = collection.data.length
        hasFiles = false

      if length > perPage
        collectionPath = "#{name}/index.html"
        layout = options.layout
        numPages = Math.ceil(length / perPage)
        pages = []
        pagination = totalPages: numPages, pages: pages

        for pagePos in [0...numPages]
          pageNum = pagePos + 1

          if hasFiles
            data = []
            sliced = _files.slice(pagePos * perPage, pageNum * perPage)

            for name, group of _.groupBy sliced, 'parentName'
              data.push _.assign {files: group}, pickEntry group[0]

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

          if pagePos is 0
            page.path = collectionPath
          else
            entry = _.assign {num: pageNum}, pickEntry data[0]
            page.path = helpers.getMatch entry, options.path
            prev = pages[pagePos - 1]
            prev.next = page
            page.prev = prev

          files[page.path] = page
          pages.push(page)

        collection.pagination = pagination

    done()
