utils = require './utils'

resetButton = (message, form, statusMessage, buttons, curText, err) ->
  for button in buttons
    button.textContent = curText
    utils.removeClass button, 'disabled'

  if err
    formClass = 'error'
    message = "Whoops! There was a problem subscribing your email. #{message}"
  else
    formClass = 'success'

  utils.addClass form, formClass
  statusMessage.innerHTML = message
  utils.removeClass statusMessage, 'hidden'
  # form.insertAdjacentHTML('beforeend', message)

# http://jdp.org.uk/ajax/2015/05/20/ajax-forms-without-jquery.html
listenToRequest = (xhr, form, statusMessage, buttons, curText) ->
  xhr.onerror = ->
    message = 'Could not connect to the subscription service.'
    resetButton message, form, statusMessage, buttons, curText, true

  xhr.ontimeout = ->
    message = 'The subscription service timed out.'
    resetButton message, form, statusMessage, buttons, curText, true

  xhr.onreadystatechange = ->
    if 300 > xhr.status >= 200
      message = 'Thank you! Please check your inbox for a confirmation message.'
    else
      err = true
      responseText = xhr.responseText

      if responseText
        jsonResponse = JSON.parse responseText
        message = jsonResponse.suggestion or jsonResponse.message
      else
        message = 'The subscription service returned an empty response.'

    if xhr.readyState is 4
      resetButton message, form, statusMessage, buttons, curText, err


module.exports =
  main: ->
    form = document.getElementById 'subscription-form'
    apiInput = document.getElementById 'api-url'

    if form
      buttons = document.getElementsByClassName('form-btn')
      curText = buttons[0].textContent
      statusMessage = document.getElementsByClassName('status')[0]

    if form and window.FormData
      form.addEventListener 'submit', (event) ->
        if not form.classList.contains('disabled')
          utils.removeClass form, 'success'
          utils.removeClass form, 'error'
          utils.addClass statusMessage, 'hidden'

          for button in buttons
            button.textContent = 'Loading...'
            utils.addClass button, 'disabled'

          xhr = utils.ajax "//#{apiInput.value}/subscription", 'POST'
          event.preventDefault()
          formData = new FormData(form)
          xhr.send formData
          listenToRequest xhr, form, statusMessage, buttons, curText
    else if form
      console.log 'FormData not supported'
    else
      console.log 'No form found'

