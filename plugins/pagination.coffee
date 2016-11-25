_ = require 'lodash'

DEFAULTS =
  perPage: 10
  noPageOne: false
  first: 'index.html'
  maxPages: 5

makePath = (options, num) -> options['path'].replace ':num', num

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

      if not collection.data.length
        continue

      collectionPath = "#{name}/index.html"
      options = _.assign DEFAULTS, settings

      if (!options.path)
        done new TypeError "The path '#{name}' is required"

      if collection.data.length > options.perPage
        _pages = []
        toShow = (_.assign item, {index} for item, index in collection.data)
        grouped = _.groupBy toShow, (item) ->
          Math.ceil((item.index + 1) / options.perPage)

        length = (Object.keys grouped).length

        pagination = totalPages: length, pages: _pages

        for num, data of grouped
          pageNum = parseInt num
          pagePos = pageNum - 1
          path = makePath options, pageNum
          [first, last] = getPos pagePos, length, options.maxPages

          pageData = _.assign options.pageMetadata,
            layout: options.layout
            data: data
            num: pageNum
            index: pagePos
            first: num: first + 1, index: first
            last: num: last + 1, index: last
            pagination: pagination
            collection: collection.name

          if pagePos > 0
            pageData.prev =
              num: pagePos, index: pagePos - 1, path: makePath options, pagePos

          if pageNum < length
            pageData.next =
              num: pageNum + 1,
              index: pageNum,
              path: makePath options, pageNum + 1

          page = _.assign {path: path}, pageData
          _pages.push(page)
          files[path] = page

          if pageNum is 1 and files[collectionPath]
            _.assign files[collectionPath], pageData

        collection.pagination = pagination

    done()
