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

if document.readyState in ['complete', 'interactive', 'loaded']
  loadJS()
else
  document.addEventListener 'DOMContentLoaded', loadJS, false
