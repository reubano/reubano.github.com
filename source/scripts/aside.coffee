utils = require './utils'

container = document.getElementById 'container'
topnav = document.getElementById 'topnav'
breadcrumb = document.getElementsByClassName('breadcrumb')[0]
aside = document.getElementById 'aside'
toTop = document.getElementById 'to-top'
pageNav = document.getElementsByClassName('page-navigator')[0]
footer = document.getElementById 'footer'
category = document.getElementById 'category'
article = document.getElementsByClassName('article')[0]

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
    fixedHeight = topnav.clientHeight + utils.getFullHeight(breadcrumb)

    if aside
      absHeight = (pageNav or footer)['offsetTop'] - aside.clientHeight
      contHeight = (category or article)['clientHeight']
      normal = (absHeight > fixedHeight) and (aside.clientHeight < contHeight)

      container.addEventListener 'scroll', ->
        window.requestAnimationFrame ->
          updateAsidePosition absHeight, fixedHeight, normal

      updateAsidePosition absHeight, fixedHeight, normal

    if toTop
      toTop.addEventListener 'click', (e) ->
        e.preventDefault()
        container.scrollTop = 0
