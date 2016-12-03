path = require 'path'

_ = require './node_modules/lodash'
slug = require './node_modules/slug'
moment = require './node_modules/moment'
marked = require './node_modules/marked'
multimatch = require './node_modules/multimatch'
config = require './config'

_sizes = [
  {query: '_s', key: 'url_sq', widthKey: 'width_sq'}
  {query: '_t', key: 'url_t', widthKey: 'width_t'}
  {query: '_q', key: 'url_q', widthKey: 'width_q'}
  {query: '_m', key: 'url_s', widthKey: 'width_s'}
  {query: '_n', key: 'url_n', widthKey: 'width_n'}
  {query: '', key: 'url_m', widthKey: 'width_m'}
  # {query: '', key: 'url_e', widthKey: 'width_e'}
  {query: '', key: 'url_e', widthKey: 'width_m'}
  {query: '_z', key: 'url_z', widthKey: 'width_z'}
  {query: '_c', key: 'url_c', widthKey: 'width_c'}
  {query: '_b', key: 'url_l', widthKey: 'width_l'}
  {query: '_h', key: 'url_h', widthKey: 'width_h'}
  {query: '_k', key: 'url_k', widthKey: 'width_k'}
  {query: '_o', key: 'url_o', widthKey: 'width_o'}
]

landSizes = [75, 100, 150, 240, 320, 500, 500, 640, 800, 1024, 1600, 2048, 2048]
portSizes = [75, 75, 150, 180, 240, 375, 375, 480, 600, 768, 1200, 1536, 1536]
REGEX = /:([\w]+(\.[\w]+)*)/g

slugOpts = {lower: true}

getMatch = (entry, pattern) ->
  match = REGEX.exec(pattern)

  if match
    getMatch entry, pattern.replace ":#{match[1]}", slug(entry[match[1]], slugOpts)
  else
    pattern


_getFeatured = (category, filterby) ->
  item = category.data[0]

  if item.views?
    ranked = _.sortBy category.data, (item) -> -item.views
  else if item.stargazers_count?
    ranked = _.sortBy category.data, (item) -> -item.stargazers_count
  else if item.comments?
    ranked = _.sortBy category.data, (item) -> -item.comments
  else if item.featured?
    ranked = _.sortBy category.data, (item) -> -item.featured
  else
    ranked = _.sortBy category.data, (item) -> -item.date

  _.shuffle if filterby then _.filter(ranked[...10], filterby) else ranked[...6]

getFeatured = _.memoize _getFeatured

getHeadings = (items) ->
  names = _.map items, 'name'
  titles = _.map items, 'title'
  _.uniq _.filter _.flatten [names, titles]

filterByHeading = (items, headings) ->
  _.filter items, (item) -> (item.name or item.title) not in headings

_getRecent = (category, filterby) ->
  featured = getFeatured(category, filterby)
  headings = getHeadings featured
  items = filterByHeading category.data, headings
  filtered = if filterby then _.filter(items, filterby) else items
  _.sortBy filtered, (item) -> -item.updated

getRecent = _.memoize _getRecent

_getRandom = (category, filterby) ->
  featured = getFeatured(category, filterby)
  recent = getRecent(category, filterby)[...5]
  headings = _.flatten [getHeadings(featured), getHeadings(recent)]
  items = filterByHeading category.data, headings
  _.shuffle if filterby then _.filter(items, filterby) else items

getRandom = _.memoize _getRandom

pad = (num, size) -> if num then ('000000000' + num).substr(-size) else num
monthsAbrs = [
  "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sept", "Oct",
  "Nov", "Dec"]

monthNames = [
  "January", "February", "March", "April", "May", "June", "July",
  "August", "September", "October", "November", "December"]

module.exports =
  urlFor: (item) ->
    stripped = item.replace '/index.html', ''
    "#{config.site.url}/#{stripped}/"

  formatDate: (date, format) ->
    day = date.getDate()
    index = date.getMonth()
    year = date.getFullYear()
    format
      .replace('DD', pad(day.toString(), 2))
      .replace('D', day)
      .replace('MMMM', monthNames[index])
      .replace('MMM', monthsAbrs[index])
      .replace('MM', index + 1)
      .replace('YYYY', year)
      .replace('YY', year.toString().slice(2))

  min2read: (content, wpm=160) ->
    word_cnt = content.toString().split(' ').length
    Math.ceil word_cnt / wpm

  getRelated: (category, article) ->
    sorted = _.sortBy category.data, (item) ->
      -_.intersection(article.tags, item.tags).length

    sorted.filter (item) -> item.title isnt article.title

  tagsByCollection: (category) -> _.uniq _.flatMap category.data, 'tags'
  getFeatured: getFeatured
  getRecent: getRecent
  getRandom: getRandom

  # css-tricks.com/responsive-images-youre-just-changing-resolutions-use-srcset/
  # sitepoint.com/how-to-build-responsive-images-with-srcset/
  # webdesignerdepot.com/2015/08/the-state-of-responsive-images/
  # stackoverflow.com/a/12158668/408556
  # developer.telerik.com/featured/lazy-loading-images-on-the-web/
  getSrcset: (photo, ext='jpg', flickr=true, portrait=false, optimize=true) ->
    if flickr
      srcset = []
      base = if optimize then "#{config.paths.optimize}/" else ''
      filtered = _.filter _sizes, (s) -> photo[s.key]

      for f in filtered
        srcset.push "#{base}#{photo[f.key]} #{photo[f.widthKey]}w"

      srcset.join(', ')
    else
      refSizes = if portrait then portSizes else landSizes
      sizes = (_.defaults(s, width: refSizes[i]) for s, i in _sizes)
      url = "#{config.site.url}/#{config.paths.images}"
      ("#{url}/#{photo}#{s.query}.#{ext} #{s.width}w" for s in sizes).join(', ')

  buildFlickrURL: (photo, query='', ext='jpg', optimize=true) ->
    base = if optimize then "#{config.paths.optimize}/https:" else ''
    base += "//farm#{photo.farm}.staticflickr.com/"
    base +="#{photo.server}/#{photo.id}_#{photo.secret}#{query}.#{ext}"
    base

  getMatch: getMatch
  slug: (content) -> slug(content, slugOpts)
  _: _
  moment: moment
  marked: marked
  multimatch: multimatch
