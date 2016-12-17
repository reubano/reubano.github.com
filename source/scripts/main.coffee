hamburger = require './hamburger'
aside = require './aside'
# search = require './search'

callback = ->
  hamburger.main()
  aside.main()
  # search.main()

window.addEventListener 'load', callback, false
