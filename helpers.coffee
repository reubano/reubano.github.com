path = require 'path'

_ = require './node_modules/lodash'
slug = require './node_modules/slug'
moment = require './node_modules/moment-timezone'
marked = require './node_modules/marked'
multimatch = require './node_modules/multimatch'
cloudinary = require './node_modules/cloudinary'

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
WIDTHS = [
  75, 100, 150, 180, 240, 320, 375, 480, 500, 600, 640, 768, 800, 1024, 1200,
  1536, 1600, 2048]

REGEX = /:([\w]+(\.[\w]+)*)/g
SRCSET_DEFAULTS = ext: 'jpg', source: 'flickr', portrait: false, optimize: true
CLOUDINARY_DEFAULTS =
  fetch_format: 'auto'
  quality: 'auto'
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME
  api_key: process.env.CLOUDINARY_API_KEY
  api_secret: process.env.CLOUDINARY_API_SECRET

slugOpts = {lower: true}
now = new Date()
localURL = "#{config.site.url}/#{config.paths.images}"

getMatch = (entry, pattern) ->
  match = REGEX.exec(pattern)

  if match
    val = entry[match[1]]
    getMatch entry, pattern.replace ":#{match[1]}", slug(val, slugOpts)
  else
    pattern

_getFeatured = (category, filterby) ->
  item = category.data[0]

  if item.featured?
    ranked = _.filter category.data, (item) -> item.featured
  else if item.views?
    ranked = _.sortBy category.data, (item) -> -item.views
  else if item.stargazers_count?
    ranked = _.sortBy category.data, (item) -> -item.stargazers_count
  else if item.comments?
    ranked = _.sortBy category.data, (item) -> -item.comments
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
  recent = getRecent(category, filterby)[...6]
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

formatDate = (date, format) ->
  if date.toDate
    zone = date.format('z')
    date = new Date date.toString()[...-9]
  else
    zone = moment(date).format('z')

  day = date.getDate()
  index = date.getMonth()
  year = date.getFullYear()
  hour = date.getHours()
  minute = date.getMinutes()

  format
    .replace('a', if hour < 12 then 'AM' else 'PM')
    .replace('DD', pad(day.toString(), 2))
    .replace('D', day)
    .replace('MMMM', monthNames[index])
    .replace('MMM', monthsAbrs[index])
    .replace('MM', index + 1)
    .replace('YYYY', year)
    .replace('YY', year.toString().slice(2))
    .replace('hh', pad(hour.toString(), 2))
    .replace('h', if hour < 12 then hour else hour - 12)
    .replace('mm', pad(minute.toString(), 2))
    .replace('z', zone)
    .replace('m', minute)

module.exports =
  urlFor: (item) ->
    stripped = item.replace '/index.html', ''
    "#{config.site.url}/#{stripped}/"

  min2read: (content, wpm=160) ->
    word_cnt = content.toString().split(' ').length
    Math.ceil word_cnt / wpm

  getRelated: (category, article) ->
    sorted = _.sortBy category.data, (item) ->
      -_.intersection(article.tags, item.tags).length

    sorted.filter (item) -> item.title isnt article.title

  getMentionedProjects: (portfolio, article, one=true) ->
    # flickr removes non-alphanum chars from tags
    match = (project) -> slug(project.title, replacement: '') in article.tags
    if one then _.find(portfolio.data, match) else portfolio.data.filter(match)

  getMentionedPhotos: (gallery, project) ->
    # TODO: filter gallery for screenshot album
    # flickr removes non-alphanum chars from tags
    sanitized = slug(project.title, replacement: '')

    gallery.data.filter (photo) ->
      (sanitized in photo.tags) and ('mockup' not in photo.tags)

  getEventDate: (talk, time) ->
    upcoming = talk.date >= new Date()

    if upcoming
      eventStart = formatDate(talk.event_date, 'D MMM')
      yearStart = formatDate(talk.event_date, 'YYYY')
      monthStart = formatDate(talk.event_date, 'MMM')
      dayStart = formatDate(talk.event_date, 'D')

      eventEnd = formatDate(talk.event_end, 'D MMM')
      yearEnd = formatDate(talk.event_end, 'YYYY')
      monthEnd = formatDate(talk.event_end, 'MMM')
      dayEnd = formatDate(talk.event_end, 'D')
    else
      eventStart = formatDate(talk.date, 'MMM D, YYYY')
      eventTime = formatDate(talk.date, 'h:mm a z')

    if time and not upcoming
      prefix: 'on ', date: "#{eventTime}, #{eventStart}"
    else if not upcoming
      prefix: 'on ', date: eventStart
    else if eventStart is eventEnd
      prefix: 'on ', date: "#{eventStart}, #{yearStart}"
    else if monthStart is monthEnd
      prefix: '', date: "#{dayStart} — #{dayEnd} #{monthStart}, #{yearStart}"
    else if yearStart is yearEnd
      prefix: '', date: "#{eventStart} — #{eventEnd}, #{yearStart}"
    else
      prefix: '', date: "#{eventStart}, #{yearStart} — #{eventEnd}, #{yearEnd}"

  tagsByCollection: (category) -> _.uniq _.flatMap category.data, 'tags'
  formatDate: formatDate
  getFeatured: getFeatured
  getRecent: getRecent
  getRandom: getRandom

  upcoming: (data) ->
    filtered = data.filter (item) -> item.date >= now
    _.sortBy filtered, (item) -> item.date

  past: (data) -> data.filter (item) -> item.date < now

  # css-tricks.com/responsive-images-youre-just-changing-resolutions-use-srcset/
  # sitepoint.com/how-to-build-responsive-images-with-srcset/
  # webdesignerdepot.com/2015/08/the-state-of-responsive-images/
  # stackoverflow.com/a/12158668/408556
  # developer.telerik.com/featured/lazy-loading-images-on-the-web/
  getSrc: (photo, width, options) ->
    options = options or {}
    opts = _.defaults options, SRCSET_DEFAULTS

    switch opts.source
      when 'flickr'
        if opts.optimize and width >= photo.width_o
          url = "#{config.paths.optimize}/#{photo.url_o}"
        else if opts.optimize
          url = "#{config.paths.optimize},w_#{width}/#{photo.url_o}"
        else if width >= photo.width_o
          url = photo.url_o
        else
          size = _.find _sizes, (s) -> photo[s.widthKey] >= width
          url = photo[size.key]
      when 'cloudinary'
        cloudinaryOpts = _.defaults opts, CLOUDINARY_DEFAULTS
        cloudinary.config cloudinaryOpts
        _width = if width >= photo.width_o then photo.width_o else width
        srcOpts = _.assign {width: _width}, cloudinaryOpts
        url = cloudinary.url(opts.location, srcOpts)
        url.replace(/^(https?):\/\//, '//')
      when 'local'
        url = "#{localURL}/#{photo}/logo.#{opts.ext}"

    url

  getSrcset: (photo, options) ->
    options = options or {}
    opts = _.defaults options, SRCSET_DEFAULTS

    switch opts.source
      when 'flickr'
        srcsets = []

        if opts.optimize
          base = config.paths.optimize

          for width in _.filter(WIDTHS, (width) -> photo.width_o >= width)
            srcsets.push "#{base},w_#{width}/#{photo.url_o} #{width}w"
        else
          for f in _.filter(_sizes, (s) -> photo[s.key])
            srcsets.push "#{photo[f.key]} #{photo[f.widthKey]}w"
      when 'cloudinary'
        srcsets = []
        cloudinaryOpts = _.defaults options, CLOUDINARY_DEFAULTS
        cloudinary.config cloudinaryOpts

        for width in _.filter(WIDTHS, (width) -> photo.width_o >= width)
          srcsetOpts = _.assign {width}, cloudinaryOpts
          url = cloudinary.url(opts.location, srcsetOpts)
          protocoless = url.replace(/^(https?):\/\//, '//')
          srcsets.push "#{protocoless} #{width}w"
      when 'local'
        refSizes = if opts.portrait then portSizes else landSizes
        sizes = (_.defaults(s, width: refSizes[i]) for s, i in _sizes)
        srcsets = ("#{localURL}/#{photo}/logo#{s.query}.#{opts.ext} #{s.width}w" for s in sizes)

    srcsets.join(', ')

  getMatch: getMatch
  slug: (content) -> slug(content, slugOpts)
  _: _
  moment: moment
  marked: marked
  multimatch: multimatch
