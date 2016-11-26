_ = require 'lodash'
moment = require 'moment'
config = require './config'

sizes = [
  {width: 75, query: '_s', key: 'url_sq'}
  {width: 100, query: '_t', key: 'url_t'}
  {width: 150, query: '_q', key: 'url_q'}
  {width: 240, query: '_m', key: 'url_s'}
  {width: 320, query: '_n', key: 'url_n'}
  {width: 500, query: '', key: 'url_m'}
  {width: 500, query: '', key: 'url_e'}
  {width: 640, query: '_z', key: 'url_z'}
  {width: 800, query: '_c', key: 'url_c'}
  {width: 1024, query: '_b', key: 'url_l'}
  {width: 1600, query: '_h', key: 'url_h'}
  {width: 2048, query: '_k', key: 'url_k'}
  {width: 2048, query: '_o', key: 'url_o'}
]

REGEX = /:([\w]+(\.[\w]+)*)/g

getMatch = (entry, pattern) ->
  match = REGEX.exec(pattern)

  if match
    getMatch entry, pattern.replace ":#{match[1]}", slug(entry[match[1]])
  else
    pattern


_filterData = (data) -> _.filter data, (item) -> item.featured
filterData = _.memoize _filterData

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
      .replace('YYYY', year)
      .replace('YY', year.toString().slice(2))

  min2read: (content, wpm=160) ->
    word_cnt = content.toString().split(' ').length
    Math.ceil word_cnt / wpm

  getRelated: (category, article) ->
    sorted = _.sortBy category.data, (item) ->
      -_.intersection(article.tags, item.tags).length

    sorted.filter (item) -> item.title isnt article.title

  getFeatured: (category, filterby) ->
    if filterby
      filtered = _.filter (filterData category.data), filterby
    else
      filtered = filterData category.data

    _.sortBy filtered, (item) -> -item.updated

  getRecent: (category, filterby) ->
    if filterby
      filtered = _.filter category.data, filterby
    else
      filtered = category.data

    _.sortBy filtered, (item) -> -item.date

  getRandom: (category, filterby) ->
    if filterby
      _.shuffle _.filter category.data, filterby
    else
      _.shuffle category.data

  # css-tricks.com/responsive-images-youre-just-changing-resolutions-use-srcset/
  # sitepoint.com/how-to-build-responsive-images-with-srcset/
  # webdesignerdepot.com/2015/08/the-state-of-responsive-images/
  # stackoverflow.com/a/12158668/408556
  # developer.telerik.com/featured/lazy-loading-images-on-the-web/
  getSrcset: (photo, ext='jpg', flickr=true) ->
    if flickr
      filtered = _.filter sizes, (s) -> photo[s.key]
      ("#{photo[s.key]} #{s.width}w" for s in filtered).join(', ')
    else
      url = "#{config.site.url}/#{config.paths.images}"
      ("#{url}/#{photo}#{s.query}.#{ext} #{s.width}w" for s in sizes).join(', ')

  buildFlickrURL: (photo, query='', ext='jpg') ->
    base = "https://farm#{photo.farm}.staticflickr.com/"
    base +="#{photo.server}/#{photo.id}_#{photo.secret}#{query}.#{ext}"
    base

  getMatch: getMatch
  slug: (content) -> slug(content, mode: 'rfc3986')
  _: _
  moment: moment
  marked: marked
  minimatch: minimatch
