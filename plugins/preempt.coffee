helpers = require '../helpers'
moment = helpers.moment

parse = (date) ->
  if '/' in date
    moment.utc(date, 'MM/DD/YYYY').toDate()
  else if '-' in date
    moment.utc(date, 'YYYY-MM-DD').toDate()
  else
    new Date date * 1000

module.exports = (opts) ->
  opts = opts or {}

  if (opts.locale)
    moment.locale(opts.locale)

  (files, metalsmith, done) ->
    for file, d of files
      date = d.date or d.datetaken or d.created or d.created_at or d.stats?.ctime
      updated = d.updated or d.updated_at or d.lastupdate or d.stats?.mtime or d.date
      d.date = if typeof date is 'string' then parse(date) else date
      d.updated = if typeof updated is 'string' then parse(updated) else updated
      d.dateFromNow = moment(d.date).fromNow()
      d.updatedFromNow = moment(d.updated).fromNow()
      d.contents = d.contents or d.content or d.description
      d.title = d.title or d.name or d.id
      d.name = d.name or d.title

    done()
