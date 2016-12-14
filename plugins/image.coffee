cloudinary = require '../node_modules/cloudinary'
helpers = require '../helpers'
_ = helpers._

WIDTHS = [
  75, 100, 150, 180, 240, 320, 375, 480, 500, 600, 640, 768, 800, 1024, 1200,
  1536, 1600, 2048]

DEFAULTS = fetch_format: 'auto', quality: 'auto'

getImgTag = (loc, opts) ->
  name = loc.split('/')[1].split('.')[0]
  alt = (i[0].toUpperCase() + i[1..].toLowerCase() for i in name.split '_').join(' ')
  srcOpts = _.assign {width: 768}, opts
  src = cloudinary.url(loc, srcOpts).replace(/^(https?):\/\//, '//')
  srcsets = []

  for width in WIDTHS
    srcsetOpts = _.assign {width}, opts
    url = cloudinary.url(loc, srcsetOpts).replace(/^(https?):\/\//, '//')
    srcsets.push "#{url} #{width}w"

  srcset = srcsets.join(', ')
  "<img class='fit' sizes='(min-width: 1024px) 66vw, 100vw' srcset='#{srcset}' src='#{src}' alt='#{alt}'>"

exports = module.exports = (options) ->
  options = options or {}
  opts = _.defaults options, DEFAULTS

  cloudinary.config
    cloud_name: options.cloud_name or process.env.CLOUDINARY_CLOUD_NAME
    api_key: options.api_key or process.env.CLOUDINARY_API_KEY
    api_secret: options.api_secret or process.env.CLOUDINARY_API_SECRET

  (files, metalsmith, done) ->
    for file, data of files
      for element in (data.contents.toString().match(/image\|.\S*/g) or [])
        tag = getImgTag element.split('|')[1], opts
        data.contents = data.contents.toString().replace(element, tag)

    done()
