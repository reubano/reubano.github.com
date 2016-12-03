path = require 'path'
helpers = require './helpers'

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

changed = require './node_modules/metalsmith-changed'
permalinks = require './node_modules/metalsmith-permalinks'
metallic = require './node_modules/metalsmith-metallic'
fingerprint = require './node_modules/metalsmith-fingerprint-ignore'
sitemap = require './node_modules/metalsmith-sitemap'
uglify = require './node_modules/metalsmith-uglify'
htmlMinifier = require './node_modules/metalsmith-html-minifier'
msIf = require './node_modules/metalsmith-if'
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

end = checkpoint 'require local plugins', end

config = require './config'
js = config.paths.js

end = checkpoint 'require rest', end

templateHelpers =
  url_for: helpers.urlFor
  get_last_page: helpers.getLastPage
  get_first_page: helpers.getFirstPage
  get_related: helpers.getRelated
  build_flickr_url: helpers.buildFlickrURL
  get_srcset: helpers.getSrcset
  get_featured: helpers.getFeatured
  get_recent: helpers.getRecent
  get_random: helpers.getRandom
  min2read: helpers.min2read
  find: _.find
  range: _.range
  format_date: helpers.formatDate

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
      singular: 'post'
      plural: 'posts'
      title: 'blog'
      show: true
      count: 5
  gallery:
    sortBy: 'date'
    reverse: true
    metadata:
      singular: 'photo'
      filterby: 'datetaken'
      plural: 'photos'
      title: 'gallery'
      show: true
      count: 6
  projects:
    sortBy: 'date'
    reverse: true
    metadata:
      singular: 'project'
      plural: 'projects'
      title: 'projects'
      show: true
      count: 3

paginationConfig =
  blog:
    perPage: 6
    layout: 'blog.pug'
    path: 'blog/page/:num/index.html'
    pageMetadata: title: 'blog', name: 'blog'
  gallery:
    perPage: 12
    layout: 'gallery.pug'
    path: 'gallery/page/:num/index.html'
    pageMetadata: title: 'gallery', name: 'gallery'
  projects:
    perPage: 10
    layout: 'projects.pug'
    path: 'projects/page/:num/index.html'
    pageMetadata: title: 'projects', name: 'projects'
  tagz:
    perPage: 12
    layout: 'tagged.pug'
    pick: ['slug', 'path']
    page: []
    path: 'tagz/page/:num/index.html'
    pageMetadata: title: 'tagz', name: 'tagz'
  tagged:
    collection: 'tagz'
    perPage: 12
    layout: 'tagged.pug'
    pick: ['slug', 'path']
    nest: true
    firstPage: 'tagged/:slug/index.html'
    path: 'tagged/:slug/page/:num/index.html'
    pageMetadata: title: 'tagged :slug', name: 'tagged :slug'
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

projEnrichFunc = (entry) ->
  tags = if entry.language then [helpers.slug(entry.language)] else []
  description = entry.description.toLowerCase().split(' ')

  vizList = [
    'visualization', 'viz', 'visualizer', 'graph', 'chart', 'displays', '4w',
    '3w']

  if _.intersection(vizList, description).length
    tags.push 'visualization'

  if _.intersection(['hdx', 'ckan'], description).length
    tags.push 'open-data'

  if _.intersection(['api'], description).length
    tags.push 'api'

  if _.intersection(['stock', 'portfolio', 'ofx', 'qif'], description).length
    tags.push 'finance'

  if _.intersection(['application', 'app', 'apps', 'webapp'], description).length
    tags.push 'app'

  dataList = ['csv', 'json', 'data', 'analysis', 'processing']

  if _.intersection(dataList, description).length
    tags.push 'data'

  tags

gallEnrichFunc = (entry) ->
  tags = _.filter entry.tags.split(' '), (tag) ->
    tag not in ['facebook', 'iphotorating5']

  tags = if tags[0] is '' then [] else tags

  if entry.source is 'nahla'
    tags.push 'family'
  else if entry.source is 'gcs'
    tags.push 'gcs'
  else if entry.source is 'travel'
    tags.push 'travel'
  else if entry.source is 'misc'
    tags.push 'friends'

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

reverseGeoCode = (entry, cb) ->
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
      projects: [{field: 'tags', func: projEnrichFunc}]
      gallery: [
        {field: 'location', func: (entry) -> reverseGeoCode(entry).location}
        {field: 'country', func: (entry) -> reverseGeoCode(entry).country}
        {field: 'tags', func: gallEnrichFunc}
        {field: 'title', func: (entry) -> entry.title or entry.id}
        {field: 'name', func: (entry) -> entry.title}
        {field: 'description', func: (entry) -> ''}]

    filter:
      projects: [
        {field: 'fork', op: 'is', value: false},
        {field: 'description', op: 'not in', value: 'code.google.com'}]

    pick:
      projects: [
        'id', 'name', 'html_url', 'description', 'fork', 'homepage',
        'size', 'watchers', 'forks', 'created_at', 'updated_at', 'language',
        'stargazers_count', 'open_issues', 'tags']

      gallery: [
        'id', 'title', 'views', 'datetaken', 'latitude', 'longitude', 'url_sq',
        'url_t', 'url_q', 'url_s','url_n', 'url_m', 'url_e', 'url_z', 'url_c',
        'url_l', 'url_h', 'url_k', 'url_o', 'farm', 'server', 'secret', 'tags',
        'width_sq', 'width_t', 'width_q', 'width_s','width_n', 'width_m',
        'width_e', 'width_z', 'width_c', 'width_l', 'width_h', 'width_k',
        'width_o', 'place_id', 'woeid', 'lastupdate', 'location', 'country',
        'name', 'description']

  .use time plugin: 'json2files'
  # .use changed force: true
  # .use time plugin: 'changed'
  .use preempt()
  .use time plugin: 'preempt'
  .use ignore()
  .use time plugin: 'ignore'
  .use markdown()
  .use time plugin: 'markdown'
  .use stylus compress: false, use: [axis(), jeet()]
  .use time plugin: 'stylus'
  .use browserify destFolder: js
  .use time plugin: 'browserify'
  .use fingerprint pattern: ['**/*.css', '**/*.js']
  .use time plugin: 'fingerprint'
  .use metallic()
  .use time plugin: 'metallic'
  .use more()
  .use time plugin: 'more'
  .use collections collectionConfig
  .use time plugin: 'collections'
  .use tags
    metadataKey: 'tagz'
    plural: 'tagz'
    sortBy: 'date'
    reverse: true
  .use time plugin: 'tags'
  .use archive
    groupByMonth: true
    sortBy: 'date'
    reverse: true
    collections: ['projects', 'blog', 'gallery']
  .use time plugin: 'archive'
  .use permalinks
    pattern: ':title'
    date: 'YYYY-MM-DD'
    relative: false
    linksets: [
      {match: {collection: 'home'}, pattern: ''}
      {match: {collection: 'pages'}, pattern: ':title'}
      {match: {collection: 'blog'}, pattern: 'blog/:title'}
      {match: {collection: 'gallery'}, pattern: 'gallery/:title'}
      {match: {collection: 'projects'}, pattern: 'projects/:title'}
      {match: {collection: 'tagz'}, pattern: 'tagged/:slug'}
      {match: {collection: 'archive'}, pattern: 'archive/:year'}
    ]
  .use time plugin: 'permalinks'
  # .use lunr
  #   collection: 'blog'
  #   indexPath: 'searchIndex.json'
  #   fields: tags: 5, title: 2, markdown: 1
  #   pipelineFunctions: [_lunr.trimmer]
  # .use time plugin: 'lunr'
  .use pagination paginationConfig
  .use time plugin: 'pagination'
  .use pug
    locals: templateHelpers
    filters: marked: marked
    useMetadata: true
    pretty: true
    cache: true
  .use time plugin: 'pug'
  # .use gist debug: true
  .use feed
    collection: 'blog'
    limit: 20
    destination: config.laicos.rss.path
    postDescription: (file) -> file.less or file.excerpt or file.contents or ''
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
