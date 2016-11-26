_ = require 'lodash'

DEFAULTS =
  perPage: 10
  maxPages: 5

makePath = (path, opts) ->
  opts ?= {}
  path.replace(/:num/g, opts.num).replace(/:tag/g, opts.slug)

getPos = (pagePos, length, maxPages=10, pos=0) ->
  # show limited number of pages like Google
  minDist = maxPages // 2
  notScrolled = length <= maxPages
  numShownPages = Math.min(length, maxPages)

  if (pagePos <= minDist + pos) or notScrolled
    newPos = pos
  else
    newPos = pagePos - minDist

  maxLastPos = newPos + numShownPages - 1
  lastPos = Math.min(length - 1, maxLastPos)
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

      if (!options.path)
        done new TypeError "The path '#{name}' is required"

      perPage = options.perPage or collection.data.length

      if collection.data.length > perPage
        collectionPath = "#{name}/index.html"
        layout = options.layout
        length = Math.ceil(collection.data.length / perPage)
        pages = []
        pagination = totalPages: length, pages: pages

        for pagePos in [0...length]
          pageNum = pagePos + 1
          data = collection.data.slice(pagePos * perPage, pageNum * perPage)
          path = makePath options.path, {num: pageNum}
          [first, last] = getPos pagePos, length, options.maxPages

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
            page.path = makePath options.path, {num: pageNum}
            prev = pages[pagePos - 1]
            prev.next = page
            page.prev = prev

          files[page.path] = page
          pages.push(page)

        collection.pagination = pagination

    done()
