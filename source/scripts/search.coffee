utils = require './utils'
fromPairs = require 'lodash.frompairs'
# lunr = require 'lunr'

elements = document.getElementsByClassName 'plugin'
pl_count = document.getElementById 'plugin-list-count'
ps_input = document.getElementById 'plugin-search-input'

# http://stackoverflow.com/questions/16991341/json-parse-file-path
# request = utils.ajax '/searchIndex.json'
# request.send(null)

# request.onreadystatechange = ->
#   if request.readyState is 4 and request.status is 200
#     index = JSON.parse(request.responseText)
#     idx = lunr.Index.load(index)
#   else
#     console.log 'error loading searchIndex.json'
#     console.log request

updateCount = (results) ->
  count = results.length
  es = if count is 1 then '' else 's'
  pl_count.innerHTML = "#{count} result#{es}"

search = (value) ->
  results = idx.search(value)
  selected = fromPairs([value.ref, true] for value in results)

  for element, i in elements
    func = if selected[i] then utils.addClass else utils.removeClass
    func element, 'on'

  updateCount(results)

displayAll = ->
  utils.addClass(element, 'on') for element in elements
  updateCount(elements)

hashchange = ->
  hash = location.hash.substring(1)
  ps_input.value = hash
  if (hash) then search(hash) else displayAll()

module.exports =
  main: ->
    ps_input.addEventListener 'input', =>
      if @value then search @value else displayAll()

    window.addEventListener('hashchange', hashchange)
    hashchange()
