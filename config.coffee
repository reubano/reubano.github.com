URLS =
  gh: 'https://reubano.xyz'
  netlify: 'https://reubano.xyz'
  local: 'http://localhost:8080'

tags = [
  'programming', 'data', 'finance', 'technology', 'photography',  'travel',
  'blog', 'python', 'clojure', 'clojurescript', 'javascript', 'mac', 'osx',
  'linux', 'investing', 'asset allocation', 'travel hacking',
  'portfolio performance', 'risk', 'web application development',
  'restful api', 'flask', 'node', 'coffeescript']

module.exports =
  mode: process.env.NODE_ENV
  prod: process.env.NODE_ENV is 'production'
  serve: process.env.SERVE
  hidden: ['friends', 'family']
  site:
    name: 'reubano'
    author: 'Reuben Cummings'
    email: 'reubano@gmail.com'
    title: 'Reuben on Data'
    subtitle: 'musings of a data whisperer'
    url: URLS[process.env.SITE]
    version: '0.0.4'

    description: 'The personal website of Reuben Cummings covering' +
      ' programming, data, finance, technology, photography, and travel'

    tags: tags
    keywords: tags.join ', '

  paths:
    images: 'images'
    css: 'styles'
    js: 'scripts'
    source: 'source'
    dest: 'public'
    rss: 'feed.xml'
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
      path: '/feed.xml'
      title: 'RSS'
    flickr:
      user: 'reubano'
      api_token: process.env.FLICKR_ACCOUNT_KEY
      secret: process.env.FLICKR_ACCOUNT_SECRET
