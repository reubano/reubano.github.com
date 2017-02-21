remove = (orginal, toRemove) ->
  regex = "(^|\\b)#{toRemove.split(' ').join('|')}(\\b|$)"
  orginal.replace(new RegExp(regex, 'gi'), ' ')

module.exports =
  addClass: (el, className) ->
    if el.classList and not el.classList.contains(className)
      el.classList.add(className)
    else if not ~el.className.indexOf(className)
      el.className += " #{className}"

  removeClass: (el, className) ->
    if el.classList and el.classList.contains(className)
      el.classList.remove(className)
    else if ~el.className.indexOf(className)
      el.className = remove el.className, className

  toggleClass: (el, className) ->
    if (el.classList)
      el.classList.toggle(className)
    else if ~el.className.indexOf(className)
      el.className = remove el.className, className
    else if el.className
      el.className += " #{className}"
    else
      el.className = className

  getFullHeight: (el, props...) ->
    if el
      height = el.clientHeight

      unless props.length
        props = ['padding-top', 'margin-top', 'border-bottom']

      for prop in props
        value = window.getComputedStyle(el, null).getPropertyValue prop
        height += parseFloat value

      height
    else
      0

  ajax: (url, method='GET') ->
    request = new XMLHttpRequest()
    request.open method, url, true
    request.setRequestHeader 'accept', 'application/json'
    request
