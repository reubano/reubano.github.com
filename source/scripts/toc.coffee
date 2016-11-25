utils = require './utils'

navbar = document.getElementById('navbar')
container = document.getElementById('container')
toc = document.getElementById('article-toc')
tocTop = document.getElementById('article-toc-top')

if navbar
  navbarHeight = navbar.clientHeight
else
  console.log 'navbar not found!'

updateSidebarPosition = ->
  isScrolled = container.scrollTop > navbarHeight
  func = if isScrolled then utils.addClass else utils.removeClass
  func toc, 'fixed'

container_action = ->
  window.requestAnimationFrame(updateSidebarPosition)

module.exports =
  main: ->
    if toc
      container.addEventListener 'scroll', container_action
      updateSidebarPosition()

      tocTop.addEventListener 'click', (e) ->
        e.preventDefault()
        container.scrollTop = 0
