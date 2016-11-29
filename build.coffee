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
lunr_ = require './node_modules/lunr'
jeet = require './node_modules/jeet'
axis = require './node_modules/axis'
open = require './node_modules/open'
chokidar = require 'chokidar'

end = checkpoint 'require base', stamp

changed = require 'metalsmith-changed'
permalinks = require 'metalsmith-permalinks'
metallic = require 'metalsmith-metallic'
fingerprint = require 'metalsmith-fingerprint-ignore'
# linkcheck = require 'metalsmith-linkcheck'
# blc = require 'metalsmith-broken-link-checker'
sitemap = require 'metalsmith-sitemap'
uglify = require 'metalsmith-uglify'
htmlMinifier = require "metalsmith-html-minifier"
# gist = require 'metalsmith-gist'
# slug = require 'metalsmith-slug'
# uncss = require 'metalsmith-uncss'
# livereload = require 'metalsmith-livereload'

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
    perPage: 30
    layout: 'tagged.pug'
    pick: ['slug', 'path']
    page: []
    path: 'tagz/page/:num/index.html'
    pageMetadata: title: 'tagz', name: 'tagz'
  tagged:
    collection: 'tagz'
    perPage: 30
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

enrichFunc = (entry) ->
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

app = new Metalsmith(DIR)
  .use time plugin: 'start', start: end
  .clean true
  .source config.paths.source
  .destination config.paths.dest
  .metadata config
  .use time plugin: 'metadata'
  .use json2files
    source: 'data'
    enrich: projects: [{field: 'tags', func: enrichFunc}]
    filter:
      projects: [
        {field: 'fork', op: 'is', value: false},
        {field: 'description', op: 'not in', value: 'code.google.com'}]

    pick:
      projects: [
        'id', 'name', 'html_url', 'description', 'fork', 'homepage',
        'size', 'watchers', 'forks', 'created_at', 'updated_at', 'language',
        'stargazers_count', 'featured', 'open_issues', 'tags']

      gallery: [
        'id', 'title', 'views', 'license', 'datetaken', 'latitude',
        'longitude', 'name', 'created', 'updated', 'featured', 'url_s',
        'url_t', 'url_q','url_m', 'url_n', 'url_', 'url_z', 'url_c',
        'url_b', 'url_h', 'url_k', 'farm', 'server', 'secret', 'tags']

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
  .use fingerprint pattern: "styles/main.css"
  .use time plugin: 'fingerprint'
  .use metallic()
  .use time plugin: 'metallic'
  .use browserify destFolder: js
  .use time plugin: 'browserify'
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
      {match: {collection: 'tagz'}, pattern: 'tags/:title'}
      {match: {collection: 'archive'}, pattern: 'archive/:title'}
    ]
  .use time plugin: 'permalinks'
  # .use lunr
  #   collection: 'blog'
  #   indexPath: 'searchIndex.json'
  #   fields: tags: 5, title: 2, markdown: 1
  #   pipelineFunctions: [lunr_.trimmer]
  .use time plugin: 'lunr'
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
  # .use slug patterns: ['*.md', '*.rst'], renameFiles: true, lower: true
  .use feed
    collection: 'blog'
    limit: 20
    destination: config.social.rss.path
    postDescription: (file) -> file.less or file.excerpt or file.contents or ''
  .use time plugin: 'feed'
  .use sitemap
    hostname: config.site.url
    omitIndex: true
    lastmod: new Date()
    modifiedProperty: 'lastmod'
    urlProperty: 'canonical'
  .use time plugin: 'sitemap'
  # .use linkcheck timeout: 5, failWithoutNetwork: false
  # .use uncss
  #   css: ['app.css']
  #   output: 'uncss-app.css'
  #   basepath: config.paths.css
  #   removeOriginal: true
  .use cleanCSS
    files: "#{config.paths.css}/main*.css"
    rename: false
    sourceMap: false
    cleanCSS: rebase: true
  .use time plugin: 'cleanCSS'
  .use uglify sourceMap: false, removeOriginal: true
  .use time plugin: 'uglify'
  .use htmlMinifier()
  .use time plugin: 'htmlMinifier'
  .use compress overwrite: false
  .use time plugin: 'compress'

build = ->
  end = _.now()
  app.build (err, files) ->
    if (err)
      throw err

    if _.keys(files).length
      console.log "built #{_.keys(files).length} files"
    # for filename, data of _files
    #   console.log "built #{filename}"

    endTime = (_.now() - stamp) / 1000
    console.log "Successfully built site in #{endTime}s"

build()
app
  .use serve
    redirects: '/tagged': '/tagz'
    gzip: true

  .use time plugin: 'serve'
  # .use livereload debug: false
  # .use time plugin: 'livereload'

modifiedFiles = []

trigger = ->
  if modifiedFiles.length
    build()
    modifiedFiles = []

watcher = chokidar.watch ['data', 'layouts', 'plugins', 'source', '*.coffee']

debounced = _.debounce(trigger, 100)

watcher.on 'change', (file) ->
  console.log "#{file} has changed!"
  relativeFile = path.relative path.join(DIR, 'source'), file
  modifiedFiles.push(relativeFile)
  debounced()

# open 'http://localhost:8080'
