coffee = require 'coffee-script'
fsUtil = require 'fs'
Path = require 'path'
FtpHandler = require './FtpHandler'
RemoteListView = require './RemoteListView'

module.exports =
class AtomSftpMain
  pkgName: "Atom-sFTP"
  confFile: null
  targetFile: null
  #ftpHandler: null
  remoteListView: null

  constructor: (serializeState) ->
    atom.workspaceView[0].addEventListener "contextmenu", => @generateMenu(event)
    atom.workspaceView.command "atom-sftp:listRemote", => @listRemote()

    atom.sftp = {}
    atom.sftp.ftpHandler = new FtpHandler()

    #@ftpHandler = new FtpHandler()
    @remoteListView = new RemoteListView()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  listRemote: ->
    remoteListView = @remoteListView
    remoteListView.attach()
    if @confFile?
      configRaw = fsUtil.readFileSync(@confFile.path).toString()
      config = coffee.eval configRaw, {sandbox: true}
      atom.sftp.ftpHandler.setOptions config['atom-ssh']
      callback = (err, result, remotePath) ->
        if err?
          console.dir err
        else
          if remotePath isnt ''
            console.log 'test'
            #@todo do stuff
          for object in result
            object.path = remotePath
            remoteListView.addItem object


      target = @targetFile
      if fsUtil.statSync(Path.resolve(atom.project.getRootDirectory().getPath(), target)).isFile()
        target = Path.dirname(target)
      atom.sftp.ftpHandler.list target, callback
      #console.dir config['atom-ssh']

  getTargetFile: (target) ->
    #check if config file exists and add menu based on that
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
    @targetFile = file
    return file

  getConfigFile: (target) ->
    file = @getTargetFile(target)

    if !file?
      return

    projectDir = atom.project.getRootDirectory()
    dir = atom.project.getRootDirectory().getSubdirectory(file)

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
    @confFile = confFile
    return confFile

  generateMenu: (event) ->
    #remove any present package menus
    for selector, objects of atom.contextMenu.definitions
      for index, object of objects
        if object.hasOwnProperty "isAtomSftp"
          atom.contextMenu.definitions[selector].splice index, 1

    target = event.target
    confFile = @getConfigFile(target)

    if confFile
      menu =
        label: @pkgName
        submenu: [
          {
            label: "List remote"
            command: "atom-sftp:listRemote"
          }
        ]
        isAtomSftp: true
    else
      menu =
        label: @pkgName
        submenu: [
          {
            label: "Configure " + @pgkName + " for Project"
            command: "atom-sftp:configurePackage"
          }
        ]
        isAtomSftp: true

    atom.contextMenu.definitions['.editor'] = [] if !atom.contextMenu.definitions['.editor']?
    atom.contextMenu.definitions['.directory .list-item'] = [] if !atom.contextMenu.definitions['.directory .list-item']?

    atom.contextMenu.definitions['.editor'].push menu
    atom.contextMenu.definitions['.directory .list-item'].push menu
