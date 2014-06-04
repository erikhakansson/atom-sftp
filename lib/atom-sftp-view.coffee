{View} = require 'atom'

module.exports =
class AtomSftpView extends View
  @content: ->
    @div class: 'atom-sftp overlay from-top', =>
      @div "The AtomSftp package is Alive! It's ALIVE!", class: "message"

  initialize: (serializeState) ->
    atom.workspaceView.command "atom-sftp:toggle", => @toggle()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    console.log "AtomSftpView was toggled!"
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)
