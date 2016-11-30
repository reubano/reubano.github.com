# stdlib dependencies
path = require 'path'
fs = require 'fs'

# internal dependencies
helpers = require('../helpers')

# external dependencies
web = require '../node_modules/node-static'
winston = require '../node_modules/winston'
chalk = require '../node_modules/chalk'
HTTPStatus = require '../node_modules/http-status'

_ = helpers._
cache_days = 1

DEFAULTS =
  cache: cache_days * 24 * 60 * 60,
  indexFile: 'index.html',
  headers: {},
  gzip: false
  port: 8080,
  host: 'localhost',
  verbose: false,
  listDirectories: false,
  redirects: {}


logger = new winston.Logger transports: [
  new winston.transports.Console colorize: true
  new winston.transports.File filename: 'server.log', maxsize: 2097152
]

formatNumber = (num) -> if num < 10 then "0#{num}" else num

log = (message, options) ->
  options = options or {}
  logFunction = switch options.type
    when 'error' then logger.error
    when 'warn' then logger.warn
    else logger.info

  date = new Date()
  [hours, mins, secs] = [date.getHours(), date.getMinutes(), date.getSeconds()]
  tstamp = "#{formatNumber hours}:#{formatNumber mins}:#{formatNumber secs}"
  timestamp = if options.stamp then " #{tstamp}" else ''
  logFunction "[metalsmith-serve]#{timestamp} #{message}"

sendError = (res, status, message) ->
  res.writeHead status, message
  res.end HTTPStatus[status]

module.exports = (options) ->
  server = false
  options = options or {}
  _.defaults options, DEFAULTS
  root = if options.root then path.resolve options.root
  [host, port] = [options.host, options.port]

  (files, metalsmith, done) ->
    if server
      return done()

    docRoot = root or metalsmith.destination()
    serverKeys = ['cache', 'indexFile', 'headers', 'gzip']
    fileServer = new web.Server docRoot, _.pick(options, serverKeys)

    server = require('http').createServer (req, res) ->
      req.addListener('end', ->
        fileServer.serve req, res, (err, response) ->
          if err and options.redirects[req.url]
            status = HTTPStatus.MOVED_PERMANENTLY
            dest = options.redirects[req.url]
            log "[#{status}] #{req.url} > #{dest}", {type: 'warn', stamp: true}
            return sendError res, status, {'Location': dest}
          else
            errFile = options.http_error_files?[err?.status]

          if errFile
            msg = "[#{err.status}] #{req.url} - served: #{errFile}"
            log msg, {type: 'warn', stamp: true}
            fileServer.serveFile errFile, err.status, {}, req, res
          else if err
            log "[#{err.status}] #{req.url}", {type: 'error', stamp: true}
            sendError res, err.status, err.headers
          else if options.verbose
            log "[#{res.statusCode}] #{req.url}", {stamp: true}
      ).resume()

    process.on 'SIGINT', ->
      server.close -> done()
      process.exit()

    server.on 'error', (err) ->
      if (err.code == 'EADDRINUSE')
        log "Address #{host}:#{port} already in use", type: 'error'
        throw err

    server.listen options.port, options.host
    log "Serving at http://#{host}:#{port}"
    done()
