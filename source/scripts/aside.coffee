utils = require './utils'

container = document.getElementById 'container'
topnav = document.getElementById 'topnav'
breadcrumb = document.getElementsByClassName('breadcrumb')[0]
aside = document.getElementById 'aside'
toTop = document.getElementById 'to-top'

updateAsidePosition = (height) ->
  if container.scrollTop > height
    utils.addClass aside, 'fixed'
  else
    utils.removeClass aside, 'fixed'

module.exports =
  main: ->
    height = topnav.clientHeight + utils.getFullHeight(breadcrumb)

    if aside
      container.addEventListener 'scroll', ->
        window.requestAnimationFrame -> updateAsidePosition height

      updateAsidePosition height

    if toTop
      toTop.addEventListener 'click', (e) ->
        e.preventDefault()
        container.scrollTop = 0
