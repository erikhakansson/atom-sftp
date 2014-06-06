{View} = require 'atom'

SSH2 = require('ssh2')
JSFtp = require('jsftp')

module.exports =
class AtomSftpMain
  pkgName: "Atom-sFTP"

  constructor: (serializeState) ->
    #atom.workspaceView.command "atom-sftp:toggle", => @toggle()
    atom.workspaceView[0].addEventListener "contextmenu", => @generateMenu(event)
    #atom.workspaceView[0].addEventListener "click", => @generateMenu(event)
    atom.workspaceView.command "atom-sftp:listRemote", => @listRemote()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  listRemote: ->
    console.log "test"

  generateMenu: (event) ->


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

    target = event.target
    #console.dir target

    foundParent = false
    noParent = false
    type = null
    while !foundParent && !noParent
      if ((" " + target.className + " ").replace(/[\n\t]/g, " ").indexOf ' editor ') > -1
        foundParent = true
        type = 'editor'
      else if ((" " + target.className + " ").replace(/[\n\t]/g, " ").indexOf ' list-item ') > -1
        foundParent = true
        type = 'list-item'
      else if ((" " + target.className + " ").replace(/[\n\t]/g, " ").indexOf ' tree-view ') > -1
        foundParent = true
        type = 'tree-view'
      else if !target.parentElement? || target.parentElement is ''
        noParent = true
      else
        target = target.parentElement

    if noParent
      return

    file = null
    if type is 'editor'
      editor = atom.workspace.getActivePane().getActiveItem()
      file = editor.buffer.file.path
      file = atom.project.relativize file
    else if type is 'list-item'
      file = target.querySelector('.name').getAttribute 'data-path'
      file = atom.project.relativize file
    else
      file = ''

    projectDir = atom.project.getRootDirectory()
    dir = atom.project.getRootDirectory().getSubdirectory(file)

    if dir.isFile()
      dir = dir.getParent()

    confFile = null
    isRoot = false

    while !confFile && !isRoot
      entries = dir.getEntriesSync()
      for entry in entries
        if entry.isFile() && entry.getBaseName() is 'atom-sftp.config.cson'
          confFile = entry
      if dir.getPath() is projectDir.getPath()
        isRoot = true
      else
        dir = dir.getParent()

    console.dir confFile

    #console.dir dir
    #console.dir dir.isFile()



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
