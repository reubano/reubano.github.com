_ = require 'lodash'
slug = require('slug')

module.exports = (opts) ->
  tagCache = {}
  opts = opts or {}
  opts.path = opts.path or 'tags/:tag/index.html'
  opts.pathPage = opts.pathPage or 'tags/:tag/:num/index.html'
  opts.layout = opts.layout or 'partials/tag.pug'
  opts.handle = opts.handle or 'tags'
  handleCollection = opts.handle + 'Collection'
  opts.metadataKey = opts.metadataKey or 'tags'
  opts.sortBy = opts.sortBy or 'title'
  opts.reverse = opts.reverse or false
  opts.perPage  = opts.perPage or 0

  (files, metalsmith, done) ->
    getFilePath = (path, opts) ->
      opts ?= {}
      path.replace(/:num/g, opts.num).replace(/:tag/g, opts.slug)

    for file, data of files
      if !data
        continue

      tagsData = data[opts.handle]

      if tagsData
        if typeof tagsData is 'string'
          tagsData = tagsData.split(',')

        data[opts.handle] = []
        data[handleCollection] = []

        tagsData.forEach (rawTag) ->
          tag = String(rawTag).trim()

          if not tagCache[tag]
            urlSafeTag = slug(tag, mode: 'rfc3986')
            tagCache[tag] =
              name: tag
              slug: urlSafeTag
              path: getFilePath(opts.path, slug: urlSafeTag)
              files: []

          data[opts.handle].push(tag)
          tagCache[tag].files.push(file)
          data[handleCollection].push tagCache[tag]

    metadata = metalsmith.metadata()
    metadata[opts.metadataKey] = metadata[opts.metadataKey] or []

    for tag, tagData of tagCache
      # Map the array of filesByTag names back to the actual data object.
      posts = tagData.files.map((file) -> files[file]).sort(opts.sortBy)

      if (opts.reverse)
        posts.reverse()

      metadata[opts.metadataKey].push _.assign posts: posts, tagData
      postsPerPage = if opts.perPage is 0 then posts.length else opts.perPage
      numPages = Math.ceil(posts.length / postsPerPage)
      pages = []

      for i in [0...numPages]
        pageFiles = posts.slice(i * postsPerPage, (i + 1) * postsPerPage)

        page =
          layout: opts.layout
          contents: ''
          tag: tag
          pagination:
            num: i + 1
            pages: pages
            tag: tag
            files: pageFiles
            slug: tagData.slug

        # Render the non-first pages differently to the rest, when set.
        if (i > 0 and opts.pathPage)
          page.path = getFilePath(opts.pathPage, page.pagination)
        else
          page.path = getFilePath(opts.path, page.pagination)

        files[page.path] = page
        previousPage = pages[i - 1]

        if (previousPage)
          page.pagination.previous = previousPage
          previousPage.pagination.next = page

        pages.push(page)

    metalsmith.metadata(metadata)
    done()
