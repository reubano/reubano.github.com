utils = require './utils'

HAMBURGER_SELECTOR = '.hamburger'
WRAPPER_ID = 'navbar'

hamburger = document.querySelector HAMBURGER_SELECTOR
wrapper = document.getElementById WRAPPER_ID

hamburger_action = (e) ->
  e.preventDefault()
  e.stopPropagation()
  utils.toggleClass hamburger, 'is-active'
  utils.toggleClass wrapper, 'hidden-slow'
  utils.toggleClass wrapper, 'visible-slow'

module.exports =
  main: ->
    if hamburger and wrapper
      hamburger.addEventListener 'click', hamburger_action
    else if wrapper
      console.log "hamburger selector '#{HAMBURGER_SELECTOR}' not found!"
    else if hamburger
      console.log "wrapper ID '#{WRAPPER_ID}' not found!"
    else
      console.log "hamburger selector '#{HAMBURGER_SELECTOR}' nor wrapper ID '#{WRAPPER_ID}' found!"
