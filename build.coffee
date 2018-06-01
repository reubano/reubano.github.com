path = require 'path'
helpers = require './helpers'
descriptions = require './data/descriptions'

_ = helpers._
moment = helpers.moment
marked = helpers.marked
stamp = _.now()

checkpoint = (name, start) ->
  end = _.now()
  time = (end - start) / 1000
  console.log("#{name} +#{time}s")
  end

Metalsmith = require './node_modules/metalsmith'
_lunr = require './node_modules/lunr'
jeet = require './node_modules/jeet'
axis = require './node_modules/axis'
open = require './node_modules/open'
chokidar = require './node_modules/chokidar'
rm = require './node_modules/rimraf'

end = checkpoint 'require base', stamp

permalinks = require './node_modules/metalsmith-permalinks'
fingerprint = require './node_modules/metalsmith-fingerprint-ignore'
sitemap = require './node_modules/metalsmith-sitemap'
uglify = require './node_modules/metalsmith-uglify'
htmlMinifier = require './node_modules/metalsmith-html-minifier'
msIf = require './node_modules/metalsmith-if'
# changed = require './node_modules/metalsmith-changed'
# gist = require './node_modules/metalsmith-gist'
# livereload = require './node_modules/metalsmith-livereload'

end = checkpoint 'require metalsmith plugins', end

stylus = require './plugins/stylus'
pug = require './plugins/pug'
ignore = require './plugins/ignore'
preempt = require './plugins/preempt'
collections = require './plugins/collections'
more = require './plugins/more'
markdown = require './plugins/markdown'
browserify = require './plugins/browserify'
pagination = require './plugins/pagination'
tags = require './plugins/tags'
lunr = require './plugins/lunr'
json2files = require './plugins/json-to-files'
time = require './plugins/time'
archive = require './plugins/archive'
feed = require './plugins/feed'
cleanCSS = require './plugins/clean-css'
serve = require './plugins/serve'
compress = require './plugins/compress'
blc = require './plugins/blc'
image = require './plugins/image'

end = checkpoint 'require local plugins', end

config = require './config'
js = config.paths.js

end = checkpoint 'require rest', end

templateHelpers =
  url_for: helpers.urlFor
  get_last_page: helpers.getLastPage
  get_first_page: helpers.getFirstPage
  get_related: helpers.getRelated
  get_mentioned_photos: helpers.getMentionedPhotos
  get_mentioned_projects: helpers.getMentionedProjects
  get_src: helpers.getSrc
  get_srcset: helpers.getSrcset
  get_featured: helpers.getFeatured
  get_recent: helpers.getRecent
  get_random: helpers.getRandom
  min2read: helpers.min2read
  find: _.find
  range: _.range
  format_date: helpers.formatDate
  tags_by_collection: helpers.tagsByCollection
  upcoming: helpers.upcoming
  past: helpers.past
  get_event_date: helpers.getEventDate

fafFilter = (item) -> not _.intersection(item.tags, config.hidden).length

collectionConfig =
  home: 'index.html'
  pages:
    sortBy: 'order'
    reverse: false
    metadata:
      singular: 'page'
      plural: 'pages'
      title: 'pages'
  blog:
    sortBy: 'date'
    reverse: true
    metadata:
      singular: 'article'
      plural: 'posts'
      title: 'blog'
      show: true
      count: 5
      order: 1
      description: 'My writings on technology and entrepreneurship'
      image:
        src: 'team-meeting'
        title: 'Open Data Day attendees planning their team presentation'
  friends:
    collection: 'gallery'
    sortBy: 'datetaken'
    reverse: true
    filter: (item) -> 'friends' in item.tags
    metadata:
      singular: 'photo'
      filterby: 'datetaken'
      plural: 'photos'
      title: 'friends'
      count: 6
  family:
    collection: 'gallery'
    sortBy: 'datetaken'
    reverse: true
    filter: (item) -> 'family' in item.tags
    metadata:
      singular: 'photo'
      filterby: 'datetaken'
      plural: 'photos'
      title: 'family'
      count: 6
  gallery:
    sortBy: 'datetaken'
    reverse: true
    filter: fafFilter
    metadata:
      singular: 'photo'
      filterby: 'datetaken'
      plural: 'photos'
      title: 'gallery'
      show: true
      count: 6
      description: 'My photos and screen-shots'
      image:
        src: 'bird'
        title: 'Bird at fountain'
  portfolio:
    sortBy: ['featured', 'updated']
    reverse: true
    metadata:
      singular: 'project'
      plural: 'projects'
      title: 'portfolio'
      show: true
      count: 5
      order: 3
      description: 'My client and personal projects'
      image:
        src: 'akili'
        title: 'U.S. choropleth'
  podium:
    sortBy: ['featured', 'event_date']
    reverse: true
    metadata:
      singular: 'talk'
      plural: 'talks'
      title: 'podium'
      show: true
      count: 3
      order: 2
      description: 'My talks and workshops'
      image:
        src: 'kodi2'
        title: 'Reuben Cummings teaching a workshop on open data'

paginationConfig =
  blog:
    perPage: 6
    layout: 'blog.pug'
    path: 'blog/page/:num/index.html'
    pageMetadata: title: 'blog', name: 'blog'
  family:
    perPage: 12
    layout: 'gallery.pug'
    path: 'family/page/:num/index.html'
    pageMetadata: title: 'family', name: 'family'
  friends:
    perPage: 12
    layout: 'gallery.pug'
    path: 'friends/page/:num/index.html'
    pageMetadata: title: 'friends', name: 'friends'
  gallery:
    perPage: 12
    layout: 'gallery.pug'
    path: 'gallery/page/:num/index.html'
    pageMetadata: title: 'gallery', name: 'gallery'
  portfolio:
    perPage: 9
    layout: 'portfolio.pug'
    path: 'portfolio/page/:num/index.html'
    pageMetadata: title: 'portfolio', name: 'portfolio'
  podium:
    perPage: 6
    layout: 'podium.pug'
    path: 'podium/page/:num/index.html'
    pageMetadata: title: 'podium', name: 'podium'
  tagz:
    perPage: 12
    layout: 'tagged.pug'
    pick: ['slug', 'path']
    page: []
    path: 'tagz/page/:num/index.html'
    pageMetadata: title: 'tagz', name: 'tagz'
    fileFilter: fafFilter
  tagged:
    collection: 'tagz'
    perPage: 12
    layout: 'tagged.pug'
    pick: ['slug', 'path']
    nest: true
    firstPage: 'tagged/:slug/index.html'
    path: 'tagged/:slug/page/:num/index.html'
    pageMetadata: title: 'tagged :slug', name: 'tagged :slug'
    fileFilter: fafFilter
  archive:
    perPage: 15
    layout: 'archive.pug'
    pick: ['year', 'path']
    sortBy: ['date']
    page: []
    path: 'archive/page/:num/index.html'
    pageMetadata: title: 'archive', name: 'archive'
    reverse: true
    filter: 'canonical'
  archiveYear:
    collection: 'archive'
    perPage: 15
    layout: 'archive.pug'
    pick: ['year', 'path']
    sortBy: ['date']
    nest: true
    firstPage: 'archive/:year/index.html'
    path: 'archive/:year/page/:num/index.html'
    pageMetadata: title: 'archive', name: 'archive'
    reverse: true
    filter: 'canonical'
  archiveMonth:
    collection: 'archive'
    perPage: 15
    layout: 'archive.pug'
    pick: ['year', 'month', 'date', 'path']
    sortBy: ['date']
    nest: true
    firstPage: 'archive/:year/:month/index.html'
    path: 'archive/:year/:month/page/:num/index.html'
    pageMetadata: title: 'archive', name: 'archive'
    reverse: true
    filter: 'month'

end = checkpoint 'set config', end
DIR = __dirname

addLess = (entry) -> _.get descriptions, entry.name, ''
addFeatured = (entry) -> 'featured' in entry.topics
sortByCollection = (entry) -> collectionConfig[entry.collection].metadata.order

addTags = (entry) ->
  tags = (tag for tag in entry.topics when tag isnt 'featured')

  if entry.language
    tags.push helpers.slug entry.language

  tags

addTitle = (entry) -> entry.session_name or entry.event_name

gallEnrichFunc = (entry) ->
  tags = _.filter entry.tags.split(' '), (tag) ->
    tag not in ['facebook', 'iphotorating5']

  tags = if tags[0] is '' then [] else tags

  if entry.source in ['nahla', 'arusha']
    tags.push 'family'
  else if entry.source in ['misc', 'arusha']
    tags.push 'friends'
  else if _.intersection(tags, config.hidden).length
    false
  else if entry.source is 'travel'
    tags.push 'travel'

  if entry.country
    tags.push entry.country.toLowerCase()

  if entry.latitude and entry.longitude
    tags.push 'geocoded'
  else
    tags.push 'uncoded'

  tags

geocodes =
  '-1,37': city: 'Nairobi', country: 'Kenya', location: 'Nairobi, Kenya'
  '-10,34': city: 'Kyela', country: 'Tanzania', location: 'Kyela, Tanzania'
  '-3,37': city: 'Arusha', country: 'Tanzania', location: 'Arusha, Tanzania'
  '-30,29': city: 'Sanipass', country: 'South Africa', location: 'Sanipass, South Africa'
  '-6,39': city: 'Zanzibar', country: 'Tanzania', location: 'Zanzibar, Tanzania'
  '-6,40': city: 'Zanzibar', country: 'Tanzania', location: 'Zanzibar, Tanzania'
  '-9,33': city: 'Mbeya', country: 'Tanzania', location: 'Mbeya, Tanzania'
  '42,-71': city: 'Boston', state: 'MA', country: 'USA', location: 'Boston, MA'
  '9,39': city: 'Addis Ababa', country: 'Ethiopia', location: 'Addis Ababa, Ethiopia'

reverseGeoCode = (entry) ->
  if entry.latitude and entry.longitude
    key = "#{Math.round(entry.latitude)},#{Math.round(entry.longitude)}"
    defValue = city: 'Unknown', country: 'Unknown', location: 'Unknown'
    _.get geocodes, key, defValue
  else
    {}

app = new Metalsmith(DIR)
  .use time plugin: 'start', start: end
  .source config.paths.source
  .destination config.paths.dest
  .metadata config
  .use time plugin: 'metadata'
  .use json2files
    source: 'data'
    extract: gallery: 'photoset.photo'
    enrich:
      portfolio: [
        {field: 'tags', func: addTags}
        {field: 'less', func: addLess}
        {field: 'featured', func: addFeatured}]
      gallery: [
        {field: 'location', func: (entry) -> reverseGeoCode(entry).location}
        {field: 'country', func: (entry) -> reverseGeoCode(entry).country}
        {field: 'tags', func: gallEnrichFunc}
        {field: 'description', func: (entry) -> ''}]

      podium: [
        {field: 'title', func: addTitle}
      ]

    filter:
      portfolio: [
        {field: 'fork', op: 'is', value: false},
        {field: 'description', op: 'not in', value: 'code.google.com'}]

    pick:
      portfolio: [
        'id', 'name', 'html_url', 'description', 'fork', 'homepage',
        'size', 'watchers', 'forks', 'created_at', 'updated_at', 'language',
        'stargazers_count', 'open_issues', 'tags', 'less', 'topics', 'featured']

      gallery: [
        'id', 'title', 'views', 'datetaken', 'latitude', 'longitude', 'url_sq',
        'url_t', 'url_q', 'url_s','url_n', 'url_m', 'url_e', 'url_z', 'url_c',
        'url_l', 'url_h', 'url_k', 'url_o', 'tags', 'name', 'description',
        'width_sq', 'width_t', 'width_q', 'width_s','width_n', 'width_m',
        'width_e', 'width_z', 'width_c', 'width_l', 'width_h', 'width_k',
        'width_o', 'place_id', 'woeid', 'lastupdate', 'location', 'country']

  .use time plugin: 'json2files'
  # .use changed force: true
  # .use time plugin: 'changed'
  .use preempt()
  .use time plugin: 'preempt'
  .use ignore()
  .use time plugin: 'ignore'
  .use image()
  .use time plugin: 'image'
  .use markdown()
  .use time plugin: 'markdown'
  .use stylus
    compress: false
    use: [axis(), jeet()]
    # debug: not config.prod
  .use time plugin: 'stylus'
  .use browserify destFolder: js
  .use time plugin: 'browserify'
  .use fingerprint pattern: ['**/*.css', '**/*.js']
  .use time plugin: 'fingerprint'
  .use more()
  .use time plugin: 'more'
  .use collections collectionConfig
  .use time plugin: 'collections'
  .use tags
    metadataKey: 'tagz'
    plural: 'tagz'
    sortBy: ['featured', sortByCollection, 'updated']
    reverse: true
    filter: (tags) -> not _.intersection(tags, config.hidden).length
  .use time plugin: 'tags'
  .use archive
    groupByMonth: true
    sortBy: 'date'
    reverse: true
    collections: ['portfolio', 'blog', 'podium']
  .use time plugin: 'archive'
  .use permalinks
    pattern: ':title'
    date: 'YYYY-MM-DD'
    relative: false
    linksets: [
      {match: {collection: 'home'}, pattern: ''}
      {match: {collection: 'pages'}, pattern: ':title'}
      {match: {collection: 'blog'}, pattern: 'blog/:title'}
      {match: {collection: 'gallery'}, pattern: 'gallery/:id'}
      {match: {collection: 'family'}, pattern: 'family/:id'}
      {match: {collection: 'friends'}, pattern: 'friends/:id'}
      {match: {collection: 'portfolio'}, pattern: 'portfolio/:title'}
      {match: {collection: 'podium'}, pattern: 'podium/:title-:location'}
      {match: {collection: 'tagz'}, pattern: 'tagged/:slug'}
      {match: {collection: 'archive'}, pattern: 'archive/:year'}
    ]
  .use time plugin: 'permalinks'
  .use pagination paginationConfig
  .use time plugin: 'pagination'
  # .use lunr
  #   collection: 'blog'
  #   indexPath: 'searchIndex.json'
  #   fields: tags: 5, title: 2, markdown: 1
  #   pipelineFunctions: [_lunr.trimmer]
  # .use time plugin: 'lunr'
  .use pug
    locals: templateHelpers
    filters: marked: marked
    useMetadata: true
    pretty: true
    cache: true
    # debug: not config.prod
  .use time plugin: 'pug'
  # .use gist debug: not config.prod
  .use feed
    collection: 'blog'
    limit: 20
    destination: config.paths.rss
  .use time plugin: 'feed'
  .use sitemap
    hostname: config.site.url
    omitIndex: true
    lastmod: new Date()
    modifiedProperty: 'lastmod'
    urlProperty: 'canonical'
  .use time plugin: 'sitemap'
  .use blc warn: true
  .use time plugin: 'blc'
  .use msIf config.prod, cleanCSS
    files: "#{config.paths.css}/main*.css"
    rename: false
    sourceMap: false
    cleanCSS: rebase: true
  .use msIf config.prod, time plugin: 'cleanCSS'
  .use msIf config.prod, uglify sourceMap: false, nameTemplate: '[name].[ext]'
  .use msIf config.prod, time plugin: 'uglify'
  .use msIf config.prod, htmlMinifier()
  .use msIf config.prod, time plugin: 'htmlMinifier'
  .use msIf config.prod, compress overwrite: false
  .use msIf config.prod, time plugin: 'compress'

build = (clean) ->
  afterProcess = (err, files) ->
    if err
      console.log "process error: #{err.message}"
    else
      app.write files, (err) ->
        endTime = (_.now() - stamp) / 1000

        if err
          console.log "write error: #{err.message} "
        else
          _.keys(files).length
          console.log "Successfully built #{_.keys(files).length} files"
        # for filename, data of _files
        #   console.log "built #{filename}"

        console.log "built site in #{endTime}s "

  if clean
    rm path.join(app.destination(), '*'), (err) ->
      if err
        console.log "rimraf error: #{err.message}"
      else
        app.process afterProcess
  else
    app.process afterProcess

build true

app
  .use msIf config.serve, serve
    redirects: '/tagged': '/tagz/', '/tagged/': '/tagz/'
    gzip: true

  .use msIf config.serve, time plugin: 'serve'
  # .use livereload debug: false
  # .use time plugin: 'livereload'

# modifiedFiles = []

# trigger = ->
#   if modifiedFiles.length
#     build()
#     modifiedFiles = []

# watcher = chokidar.watch ['data', 'layouts', 'plugins', 'source', '*.coffee']
# debounced = _.debounce(trigger, 100)

# watcher.on 'change', (file) ->
#   console.log "#{file} has changed!"
#   relativeFile = path.relative path.join(DIR, 'source'), file
#   modifiedFiles.push(relativeFile)
#   debounced()

# open 'http://localhost:8080'
