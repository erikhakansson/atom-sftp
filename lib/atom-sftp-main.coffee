{View} = require 'atom'

SSH2 = require('ssh2')
JSFtp = require('jsftp')

module.exports =
class AtomSftpMain
  pkgName: "Atom-sFTP"

  constructor: (serializeState) ->
    #atom.workspaceView.command "atom-sftp:toggle", => @toggle()
    console.dir atom.workspaceView
    atom.workspaceView[0].addEventListener "contextmenu", => @generateMenu(event)
    atom.workspaceView[0].addEventListener "click", => @generateMenu(event)
    atom.workspaceView.command "atom-sftp:listRemote", => @listRemote()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  listRemote: ->
    console.log "test"

  generateMenu: (event) ->
    console.dir event
    target = event.target


    #remove any present package menus
    for selector, objects of atom.contextMenu.definitions
      for index, object of objects
        if object.hasOwnProperty "isAtomSftp"
          atom.contextMenu.definitions[selector].splice index, 1
    #for label, submenu of atom.menu.template
    #  for index, object of submenu
    #    if object.hasOwnProperty "isAtomSftp"
    #      atom.menu.template[label].splice index, 1

    #check if config file exists and add menu based on that
    hasConfig = true



    if hasConfig
      menu =
        label: @pkgName
        submenu: [
          {
            label: "List remote"
            command: "atom-sftp:listRemote"
          }
        ]
        isAtomSftp: true


      atom.contextMenu.definitions['.editor'] = [] if !atom.contextMenu.definitions['.editor']?
      atom.contextMenu.definitions['.directory .list-item'] = [] if !atom.contextMenu.definitions['.directory .list-item']?

      atom.contextMenu.definitions['.editor'].push menu
      atom.contextMenu.definitions['.directory .list-item'].push menu
      #atom.menu.add [
      #  {
      #    label: 'Packages'
      #    submenu: [menu]
      #  }
      #]
