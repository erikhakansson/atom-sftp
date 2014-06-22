{$, View} = require 'atom'

FileView = require './FileView'

Path = require 'path'

module.exports =
class DirectoryView extends View
  ftpHandler: null

  @content: ->
    @li class: 'directory entry list-nested-item collapsed', =>
      @div outlet: 'header', class: 'header list-item', =>
        @span class: 'name icon', outlet: 'directoryName'
      @ol class: 'entries list-tree', outlet: 'entries'

  initialize: (@directory) ->
    if @directory.symlink
      iconClass = 'icon-file-symlink-directory'
    else
      iconClass = 'icon-file-directory'
      if @directory.isRoot
        iconClass = 'icon-repo' if atom.project.getRepo()?.isProjectAtRoot()
      else
        iconClass = 'icon-file-submodule' if @directory.submodule
    @directoryName.addClass(iconClass)
    @directoryName.text(@directory.name)

    relativeDirectoryPath = atom.project.relativize(@directory.path)
    @directoryName.attr('data-name', @directory.name)
    @directoryName.attr('data-path', relativeDirectoryPath)

    unless @directory.isRoot
      @subscribe @directory.$status.onValue (status) =>
        @removeClass('status-ignored status-modified status-added')
        @addClass("status-#{status}") if status?

    @expand() if @directory.isExpanded

  beforeRemove: ->
    @directory.destroy()

  update: ->
    createViewForEntry = @createViewForEntry
    entries = @entries
    internalCallback = (err, result, remotePath) ->

      if err?
        console.dir err
      else
        if remotePath isnt ''
          console.log 'test'
          #@todo do stuff
        for object in result
          object.path = remotePath
          view = createViewForEntry(object)
          entries.append view
    newPath = Path.join @directory.path, @directory.name
    atom.sftp.ftpHandler.list newPath, internalCallback

  getPath: ->
    @directory.path

  createViewForEntry: (entry) ->
    entry.$status = {
      onValue: ->
        return 'ignored'
    }
    if entry.type is 1
      view = new DirectoryView(entry)
    else
      view = new FileView(entry)

    view

  reload: ->
    @directory.reload() if @isExpanded

  toggleExpansion: ->
    if @isExpanded then @collapse() else @expand()

  expand: ->
    return if @isExpanded
    @addClass('expanded').removeClass('collapsed')
    @update()
    @isExpanded = true
    false

  collapse: ->
    @removeClass('expanded').addClass('collapsed')
    @directory.isExpanded = false
    @entries.empty()
    @isExpanded = false
