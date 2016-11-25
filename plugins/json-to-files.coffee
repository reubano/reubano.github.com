_ = require('lodash')
path = require('path')
slug = require('slug-component')

regex = /:([\w]+(\.[\w]+)*)/g

getMatch = (entry, pattern) ->
  match = regex.exec(pattern)

  if match
    getMatch entry, pattern.replace ":#{match[1]}", slug(entry[match[1]])
  else
    pattern

module.exports = (options) ->
  options = options or {}
  source = options.source or 'data'
  extension = options.extension or 'md'
  def_omit = ['source', 'pattern', 'as_permalink']

  (files, metalsmith, done) ->
    for file, data of files
      if data.json_files
        collection = data.json_files.collection

        if _.isArray data.json_files.source
          source_files = data.json_files.source
        else
          source_files = [data.json_files.source]

        for source_file in source_files
          filename = "#{source_file}.json"
          filepath = path.resolve(metalsmith.directory(), source, filename)

          try
            json = require(filepath)
          catch error
            console.log "Error fetching #{filepath}: #{error.code}"
            json = []

          if options.exclude?[collection]
            for filter in options.exclude[collection]
              if filter.op is 'is'
                json = _.filter json, [filter.field, filter.value]
              else if filter.op in ['contains', 'not in']
                json = _.filter json, (entry) ->
                  if filter.op is 'contains'
                    filter.value in entry[filter.field]
                  else
                    entry[filter.field].indexOf(filter.value) is -1

          for entry in json
            if options.pick?[collection]
              metadata = _.pick entry, options.pick[collection]
            else
              metadata = entry

            _.extend metadata, data.json_files
            pattern = getMatch metadata, metadata.pattern
            suffix = if metadata.as_permalink then '/index' else ''
            new_filename = "#{pattern}#{suffix}.#{extension}"

            if options.omit?[collection]
              metadata = _.omit metadata, options.omit[collection]
            else
              metadata = _.omit metadata, def_omit

            files[new_filename] = metadata

    done()
