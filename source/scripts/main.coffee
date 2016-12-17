hamburger = require './hamburger'
aside = require './aside'
# search = require './search'

loadJS = (e) ->
  console.log 'DOM ready'
  hamburger.main()
  aside.main()
  # search.main()

if document.readyState in ['complete', 'interactive', 'loaded']
  loadJS()
else
  document.addEventListener 'DOMContentLoaded', loadJS, false
