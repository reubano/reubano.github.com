path = require 'path'
helpers = require '../helpers'

_ = helpers._
getMatch = helpers.getMatch

module.exports = (options) ->
  options = options or {}
  source = options.source or 'data'
  extension = options.extension or 'md'
  def_omit = ['source', 'pattern']

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

          if options.filter?[collection]
            for filter in options.filter[collection]
              if filter.op is 'is'
                json = _.filter json, [filter.field, filter.value]
              else if filter.op in ['contains', 'not in']
                json = _.filter json, (entry) ->
                  contains = entry[filter.field].indexOf(filter.value) > -1
                  if filter.op is 'contains' then contains else not contains

          for entry in json
            if options.enrich?[collection]
              for enrich in options.enrich[collection]
                entry[enrich.field] = enrich.func entry

            if options.pick?[collection]
              metadata = _.pick entry, options.pick[collection]
            else
              metadata = entry

            _.assign metadata, data.json_files
            matched = getMatch(metadata, metadata.pattern).toLowerCase()

            if options.omit?[collection]
              metadata = _.omit metadata, options.omit[collection]
            else
              metadata = _.omit metadata, def_omit

            files["#{matched}.#{extension}"] = metadata

    done()
