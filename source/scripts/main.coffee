hamburger = require './hamburger'
# search = require './search'
toc = require './toc'

callback = ->
  hamburger.main()
  # search.main()
  toc.main()

window.addEventListener 'load', callback, false
