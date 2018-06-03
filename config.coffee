mode = process.env.NODE_ENV
prod = mode is 'production'

URLS =
  gh: 'https://www.reubano.xyz'
  netlify: 'https://www.reubano.xyz'
  local: 'http://localhost:8080'
  api: if prod then 'blog-subs-api.herokuapp.com' else 'localhost:5000'

tags = [
  'programming', 'data', 'finance', 'technology',  'travel',
  'blog', 'python', 'clojure', 'clojurescript', 'javascript', 'mac', 'osx',
  'linux', 'investing', 'asset allocation', 'travel hacking',
  'portfolio performance', 'risk', 'web application development',
  'restful api', 'flask', 'node', 'coffeescript', 'entrepreneurship']

module.exports =
  mode: mode
  prod: prod
  serve: process.env.SERVE
  hidden: []
  site:
    name: 'reubano'
    author: 'Reuben Cummings'
    email: 'reubano@gmail.com'
    title: 'Reuben on Data'
    subtitle: 'musings of a data whisperer'
    url: URLS[process.env.SITE]
    api: URLS.api
    version: '0.0.4'

    description: "I'm Reuben Cummings, an open source enthusiast and " +
      'Pythonista. I help software companies eliminate inefficiencies and ' +
      'identify how customers are using their products and services. When' +
      ' your data starts talking, I’m the one you want listening.'

    tags: tags
    keywords: tags.join ', '

  paths:
    images: 'images'
    css: 'styles'
    js: 'scripts'
    source: 'source'
    dest: 'public'
    rss: '/feed.xml'
    optimize: '//res.cloudinary.com/reubano/image/fetch/f_auto,q_auto'

  laicos:
    facebook:
      id: 700036
    github:
      api_token: process.env.GITHUB_ACCOUNT_KEY
      path: '//github.com/reubano'
      user: 'reubano'
      title: 'GitHub'
    twitter:
      path: '//twitter.com/reubano'
      api_token: process.env.TWITTER_ACCOUNT_KEY
      user: 'reubano'
      title: 'Twitter'
    linkedin:
      path: '//www.linkedin.com/in/reubano'
      title: 'LinkedIn'
    angellist:
      path: '//angel.co/reubano'
      title: 'AngelList'
    rss:
      path: '//feeds.feedburner.com/reubano'
      title: 'RSS'
    flickr:
      user: 'reubano'
      api_token: process.env.FLICKR_ACCOUNT_KEY
      secret: process.env.FLICKR_ACCOUNT_SECRET
