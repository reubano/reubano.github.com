utils = require './utils'

# API_BASE = 'api.nerevu.com'
API_BASE = '127.0.0.1:5000'

# http://jdp.org.uk/ajax/2015/05/20/ajax-forms-without-jquery.html

getRequest = ->
  request = new XMLHttpRequest()
  request.open 'POST', "//#{API_BASE}/subscription", true
  request.setRequestHeader 'accept', 'application/json'
  request

listenToRequest = (request, form, statusMessage, button, curText) ->
  request.onreadystatechange = ->
    if request.readyState is 4 and 300 > request.status >= 200
      message = 'Thank you! Please check your inbox for a confirmation message.'
      button.textContent = curText
      utils.removeClass button, 'disabled'
      utils.addClass form, 'success'
    else if request.readyState is 4
      jsonResponse = JSON.parse request.responseText
      message = 'Whoops! There was a problem subscribing your email.'

      if jsonResponse.suggestion
        message += " #{jsonResponse.message}"

      button.textContent = curText
      utils.removeClass button, 'disabled'
      utils.addClass form, 'error'

    if message
      console.log message
      statusMessage.innerHTML = message
      # form.insertAdjacentHTML('beforeend', message)


module.exports =
  main: ->
    form = document.getElementById 'subscription-form'

    if form
      button = form.children[5].firstElementChild
      curText = button.textContent
      statusMessage = document.createElement('div')
      statusMessage.className = 'status'

    if form and window.FormData
      form.addEventListener 'submit', (event) ->
        if not form.classList.contains('disabled')
          button.textContent = 'Loading...'
          utils.addClass button, 'disabled'
          request = getRequest()
          event.preventDefault()
          form.appendChild(statusMessage)
          formData = new FormData(form)
          request.send formData
          listenToRequest request, form, statusMessage, button, curText
    else if form
      console.log 'FormData not supported'
    else
      console.log 'No form found'

