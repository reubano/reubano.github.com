helpers = require '../helpers'
moment = helpers.moment

parse = (date) ->
  if ~date.indexOf(', ')
    split = date.split(', ')
    moment.tz(split[0], split[1])
  else if ~date.indexOf('/')
    moment.utc(date, 'MM/DD/YYYY')
  else if ~date.indexOf('-')
    moment.utc(date, 'YYYY-MM-DD')
  else
    new Date date * 1000

module.exports = (opts) ->
  opts = opts or {}

  if (opts.locale)
    moment.locale(opts.locale)

  (files, metalsmith, done) ->
    for file, d of files
      date = d.date or d.datetaken or d.created or d.created_at or d.stats?.ctime or d.session_date or d.event_date
      d.date = if typeof date is 'string' then parse(date) else date
      updated = d.updated or d.updated_at or d.lastupdate or d.stats?.mtime or d.date
      d.updated = if typeof updated is 'string' then parse(updated) else updated

      if typeof d.session_date is 'string'
        d.session_date = parse(d.session_date)

      if typeof d.event_date is 'string'
        d.event_date = parse(d.event_date)

      if typeof d.event_end is 'string'
        d.event_end = parse(d.event_end)

      d.dateFromNow = moment(d.date).fromNow()
      d.updatedFromNow = moment(d.updated).fromNow()
      d.description = d.description?._content or d.description
      d.contents = d.contents or d.content or d.description
      d.title = d.title or d.name or d.id
      d.name = d.name or d.title

    done()
