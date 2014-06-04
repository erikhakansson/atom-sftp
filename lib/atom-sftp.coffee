#AtomSftpView = require './atom-sftp-view'
AtomSftpMain = require './atom-sftp-main'

module.exports =
  atomSftpView: null

  activate: (state) ->
    @atomSftpMain = new AtomSftpMain(state.atomSftpMainState)

  deactivate: ->
    @atomSftpMain.destroy()

  serialize: ->
    atomSftpMainState: @atomSftpMain.serialize()
