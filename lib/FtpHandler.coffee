SSH2 = require('ssh2')
JSFtp = require('jsftp')
Path = require 'path'

module.exports =
class AtomSftpMain
  options: {
    'port': 21
    'protocol': 'ftp'
    'username': 'anonymous'
    'password': '@anonymous'
  }
  ftp: null

  constructor: (options) ->
    @setOptions options

  setOptions: (options, forceClear = false) ->
    if options?
      if forceClear
        @options = {}
      for key, value of options
        @options[key] = value

  connect: ->
    if @options? and @options.protocol is 'ftp'
      @ftp = new JSFtp {
        'host': @options.host
        'port': @options.port
        'username': @options.username
        'password': @options.password
      }

  list: (path, callback) ->
    if !path?
      path = '/'
    else
      path = Path.join(@options.remotePath, path)
      console.dir path
    @connect()
    if @options.protocol is 'ftp'
      @ftp.list path, callback
