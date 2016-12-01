prod_url = 'https://reubano.github.io'
dev_url = 'http://localhost:8080'
prod = process.env.NODE_ENV is 'production'

tags = [
  'programming', 'data', 'finance', 'technology', 'photography',  'travel',
  'blog', 'python', 'clojure', 'clojurescript', 'javascript', 'mac', 'osx',
  'linux', 'investing', 'asset allocation', 'travel hacking',
  'portfolio performance', 'risk', 'web application development',
  'restful api', 'flask', 'node', 'coffeescript']

module.exports =
  mode: process.env.NODE_ENV
  prod: prod
  site:
    name: 'reubano'
    author: 'Reuben Cummings'
    email: 'reubano@gmail.com'
    title: 'Reuben on Data'
    subtitle: 'musings of a data wrangler'
    url: if prod then prod_url else dev_url
    version: '0.0.4'

    description: """
      My personal website covering programming, data, finance, technology,
      photography, and travel
      """
    tags: tags
    keywords: tags.join ', '

  paths:
    images: 'images'
    css: 'styles'
    js: 'scripts'
    source: 'source'
    dest: 'public'

  social:
    facebook:
      id: 700036
    github:
      api_token: process.env.GITHUB_ACCOUNT_KEY
      path: 'https://github.com/reubano'
      user: 'reubano'
      title: 'GitHub'
    twitter:
      path: 'https://twitter.com/reubano'
      api_token: process.env.TWITTER_ACCOUNT_KEY
      user: 'reubano'
      title: 'Twitter'
    linkedin:
      path: 'https://www.linkedin.com/in/reubano'
      title: 'LinkedIn'
    angellist:
      path: 'https://angel.co/reubano'
      title: 'AngelList'
    rss:
      path: '/feed.xml'
      title: 'RSS'
    flickr:
      user: 'reubano'
      api_token: process.env.FLICKR_ACCOUNT_KEY
      secret: process.env.FLICKR_ACCOUNT_SECRET
