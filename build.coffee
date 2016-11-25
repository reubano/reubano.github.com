_ = require 'lodash'

stamp = _.now()

checkpoint = (name, start) ->
  end = _.now()
  time = (end - start) / 1000
  console.log("#{name} +#{time}s")
  end

Metalsmith = require 'metalsmith'
moment = require 'moment'
marked = require 'marked'
lunr_ = require 'lunr'
jeet = require 'jeet'
axis = require 'axis'
open = require 'open'

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
# archive = require 'metalsmith-archive'

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

end = checkpoint 'require local plugins', end

helpers = require './helpers'
config = require './config'
js = config.paths.js

end = checkpoint 'require rest', end

templateHelpers =
  url_for: helpers.urlFor
  get_archives_url: (year, month) ->
    "#{config.site.url}/archives/#{year}/#{month}/"
  get_last_page: helpers.getLastPage
  get_first_page: helpers.getFirstPage
  get_related: helpers.getRelated
  build_flickr_url: helpers.buildFlickrURL
  get_srcset: helpers.getSrcset
  get_featured: helpers.getFeatured
  get_recent: helpers.getRecent
  get_random: helpers.getRandom
  min2read: helpers.min2read
  # count_tags: helpers.countTags
  # count_categories: helpers.countCategories
  find: _.find
  range: _.range
  format_date: helpers.formatDate

collectionConfig =
  all: '*.html'
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
  'all':
    perPage: 20
    layout: 'archive.pug'
    path: 'archives/page/:num/index.html'
    pageMetadata: title: 'archive', 'name': 'archive'
  'blog':
    perPage: 6
    layout: 'blog.pug'
    path: 'blog/page/:num/index.html'
    pageMetadata: title: 'blog', 'name': 'blog'
  'gallery':
    perPage: 12
    layout: 'gallery.pug'
    path: 'gallery/page/:num/index.html'
    pageMetadata: title: 'gallery', 'name': 'gallery'
  'projects':
    perPage: 10
    layout: 'projects.pug'
    path: 'projects/page/:num/index.html'
    pageMetadata: title: 'projects', 'name': 'projects'

end = checkpoint 'set config', end

Metalsmith(__dirname)
  .use time plugin: 'start', start: end
  .clean false
  .source config.paths.source
  .destination config.paths.dest
  .metadata config
  .use time plugin: 'metadata'
  .use json2files
    source: 'data'
    exclude:
      projects: [
        {field: 'fork', op: 'is', value: false},
        {field: 'description', op: 'not in', value: 'code.google.com'}]

    pick:
      projects: [
        'id', 'name', 'html_url', 'description', 'fork', 'homepage',
        'size', 'watchers', 'forks', 'created_at', 'updated_at', 'language',
        'stargazers_count', 'featured', 'less', 'excerpt', 'open_issues']

      gallery: [
        'id', 'title', 'views', 'license', 'datetaken', 'latitude', 'longitude',
        'name', 'created', 'updated', 'featured', 'url_s', 'url_t', 'url_q',
        'url_m', 'url_n', 'url_', 'url_z', 'url_c', 'url_b', 'url_h', 'url_k',
        'farm', 'server', 'secret']

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
    ]
  .use time plugin: 'permalinks'
  .use collections collectionConfig
  .use time plugin: 'collections'
  # .use lunr
  #   collection: 'blog'
  #   indexPath: 'searchIndex.json'
  #   fields: tags: 5, title: 2, markdown: 1
  #   pipelineFunctions: [lunr_.trimmer]
  # .use archive dateFields: ['publishDate', 'modifiedDate', 'date']
  .use time plugin: 'lunr'
  .use tags
    path: 'tagged/:tag/index.html'
    pathPage: 'tagged/:tag/page/:num/index.html'
    metadataKey: 'tagz'
    perPage: 20
    layout:'tag.pug'
    sortBy: 'date'
    reverse: true
  .use time plugin: 'tags'
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
