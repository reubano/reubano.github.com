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

end = checkpoint 'require base', stamp

watch = require 'metalsmith-watch'
changed = require 'metalsmith-changed'
permalinks = require 'metalsmith-permalinks'
metallic = require 'metalsmith-metallic'
serve = require 'metalsmith-serve'
fingerprint = require 'metalsmith-fingerprint-ignore'
# sitemap = require 'metalsmith-sitemap'
# cleanCSS = require 'metalsmith-clean-css'
# linkcheck = require 'metalsmith-linkcheck'
# blc = require 'metalsmith-broken-link-checker'
# gist = require 'metalsmith-gist'
# compress = require 'metalsmith-gzip'
# htmlMinifier = require "metalsmith-html-minifier"
# slug = require 'metalsmith-slug'
# uglify = require 'metalsmith-uglify'
# uncss = require 'metalsmith-uncss'
# feed = require 'metalsmith-feed'
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
    perPage: 20
    layout: 'tagged.pug'
    path: 'tagged/:tag/page/:num/index.html'
    pageMetadata: title: 'tags', name: 'tags'
  archive:
    perPage: 20
    layout: 'archive.pug'
    path: 'archive/page/:num/index.html'
    pageMetadata: title: 'archive', name: 'archive'

end = checkpoint 'set config', end

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

Metalsmith(__dirname)
  .use time plugin: 'start', start: end
  .clean false
  .source config.paths.source
  .destination config.paths.dest
  .metadata config
  .use time plugin: 'metadata'
  .use json2files
    source: 'data'
    enrich: projects: [{field: 'tags', func: enrichFunc}]
    exclude:
      projects: [
        {field: 'fork', op: 'is', value: true},
        {field: 'description', op: 'contains', value: 'code.google.com'}]

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
  .use changed force: true
  .use time plugin: 'changed'
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
  # .use feed
  #   collection: 'blog'
  #   limit: 20
  #   destination: config.social.rss.path
  #   postDescription: (file) -> file.less or file.excerpt or file.contents
  # .use sitemap
  #   hostname: config.site.url
  #   omitIndex: true
  #   modifiedProperty: 'lastmod'
  #   urlProperty: 'canonical'
  # .use linkcheck timeout: 5, failWithoutNetwork: false
  # .use(livereload({ debug: true }))
  # .use uncss
  #   css: ['app.css']
  #   output: 'uncss-app.css'
  #   basepath: config.paths.css
  #   removeOriginal: true
  # .use cleanCSS
  #   files: "#{config.paths.source}/**/*.css"
  #   sourceMap: false
  #   cleanCSS: rebase: true
  # .use htmlMinifier '*.html'
  # .use uglify sourceMap: true, removeOriginal: false
  # .use compress overwrite: false
  .use watch
    paths:
      'layouts/**/*': '**/*'
      'data/**/*': '**/*'
      '**/*.coffee': true
      '**/*.coffee': '**/*'
  # .use livereload debug: true
  .use serve()
  .use time plugin: 'serve'
  .build (err, files) ->
    if (err)
      throw err
    else
      for filename in _.keys(files)
        console.log("built #{filename}")

      time = (_.now() - stamp) / 1000
      # checkpoint 'build', end
      console.log("Successfully built site in #{time}s")

# open 'http://localhost:8080'
