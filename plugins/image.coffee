path = require 'path'
helpers = require '../helpers'
_ = helpers._

DEFAULTS =
  source: 'flickr'
  optimize: true
  sourceDir: 'data'
  sourceFile: 'post-images-gallery'

getImgTag = (opts) ->
  sizes = '(min-width: 1024px) 66vw, 100vw'

  if opts.source is 'flickr'
    photo = _.find opts.photos, {id: opts.id}
    description = photo.description?._content
    src = helpers.getSrc photo, 768, opts
    srcset = helpers.getSrcset photo, opts
    "<div class='photo'><img class='fit' sizes='#{sizes}' srcset='#{srcset}' src='#{src}' title='#{photo.title}'><figcaption>#{description} (<a href='#{src}' target='_blank' rel='noopener noreferrer'>view original</a>)</figcaption></div>"
  else
    src = helpers.getSrc {}, 768, opts
    srcset = helpers.getSrcset {width: 1024}, opts
    "<div class='photo'><img class='fit' sizes='#{sizes}' srcset='#{srcset}' src='#{src}'></div>"

exports = module.exports = (options) ->
  options = options or {}
  opts = _.defaults options, DEFAULTS

  (files, metalsmith, done) ->
    filename = "#{opts.sourceFile}.json"
    filepath = path.resolve metalsmith.directory(), opts.sourceDir, filename

    try
      gallery = require filepath
    catch error
      done "Error fetching #{filepath}: #{error.code}"

    opts.photos = gallery.photoset.photo

    for file, data of files
      for element in (data.contents.toString().match(/image\|.\S*/g) or [])
        tag = getImgTag _.assign {id: element.split('|')[1]}, opts
        data.contents = data.contents.toString().replace(element, tag)

    done()
