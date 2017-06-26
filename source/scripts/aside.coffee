utils = require './utils'

container = document.getElementById 'container'
topnav = document.getElementById 'topnav'
crumb = document.getElementsByClassName('breadcrumb')[0]
aside = document.getElementById 'aside'
toTop = document.getElementById 'to-top'
category = document.getElementById 'category'
article = document.getElementsByClassName('article')[0]
meat = category or article

updateAsidePosition = (absHeight, fixedHeight, normal) ->
  if normal and container.scrollTop >= absHeight
    utils.addClass aside, 'absolute'
    utils.removeClass aside, 'fixed'
  else if normal and container.scrollTop >= fixedHeight
    utils.addClass aside, 'fixed'
    utils.removeClass aside, 'absolute'
  else
    utils.removeClass aside, 'fixed'
    utils.removeClass aside, 'absolute'

module.exports =
  main: ->
    if aside
      crumbMarginTop = utils.propHeight(crumb, 'marginTop')
      crumbHeight = utils.outerHeight(crumb, false, true) + crumbMarginTop
      topnavHeight = utils.outerHeight topnav
      contHeight = utils.outerHeight meat
      asideHeight = utils.outerHeight aside

      fixedHeight = topnavHeight + crumbHeight
      absHeight = utils.outerHeight(meat, true) + fixedHeight - asideHeight
      normal = (absHeight > fixedHeight) and (contHeight > asideHeight)

      container.addEventListener 'scroll', ->
        window.requestAnimationFrame ->
          updateAsidePosition absHeight, fixedHeight, normal

      updateAsidePosition absHeight, fixedHeight, normal

    if toTop
      toTop.addEventListener 'click', (e) ->
        e.preventDefault()
        container.scrollTop = 0
