hamburger = require './hamburger'
aside = require './aside'
form = require './form'
# search = require './search'

loadJS = (e) ->
  console.log 'DOM ready'
  hamburger.main()
  aside.main()
  form.main()
  # search.main()

if document.readyState is 'complete'
  loadJS()
else
  window.onload = loadJS
