utils = require './utils'

CLASS_NAME = 'is-active'
HAMBURGER_SELECTOR = '.hamburger'
WRAPPER_ID = 'navbar'

hamburger = document.querySelector HAMBURGER_SELECTOR
wrapper = document.getElementById WRAPPER_ID

hamburger_action = (e) ->
  e.preventDefault()
  e.stopPropagation()
  utils.toggleClass hamburger, CLASS_NAME
  utils.toggleClass wrapper, 'hidden-slow'
  utils.toggleClass wrapper, 'visible-slow'

module.exports =
  main: ->
    if hamburger and wrapper
      hamburger.addEventListener 'click', hamburger_action

    if not wrapper
      console.log "wrapper ID '#{WRAPPER_ID}' not found!"

    if not hamburger
      console.log "hamburger selector '#{HAMBURGER_SELECTOR}' not found!"

