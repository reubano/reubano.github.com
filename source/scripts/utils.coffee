remove = (orginal, to_remove) ->
  regex = "(^|\\b)#{to_remove.split(' ').join('|')}(\\b|$)"
  orginal.replace(new RegExp(regex, 'gi'), ' ')

module.exports =
  addClass: (el, className) ->
    if el.classList and not classList.contains(className)
      el.classList.add(className)
    else if not ~el.className.indexOf(className)
      el.className += " #{className}"

  removeClass: (el, className) ->
    if el.classList and classList.contains(className)
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
