{$, BufferedProcess, ScrollView, View} = require 'atom'

DirectoryView = require './DirectoryView'
FileView = require './FileView'

module.exports =
class RemoteListView extends ScrollView
  @content: ->
    @div class: 'tree-view-resizer tool-panel', 'data-show-on-right-side': !atom.config.get('tree-view.showOnRightSide'), =>
      @div class: 'tree-view-scroller', outlet: 'scroller', =>
        @ol class: 'tree-view full-menu list-tree has-collapsable-children focusable-panel', tabindex: -1, outlet: 'list'
      @div class: 'tree-view-resize-handle', outlet: 'resizeHandle'

  constructor: (state) ->
    super
    focusAfterAttach = true

    @on 'dblclick', '.tree-view-resize-handle', => @resizeToFitContent()
    @on 'click', '.entry', (e) =>
      return if e.shiftKey || e.metaKey
      @entryClicked(e)
    @on 'mousedown', '.entry', (e) =>
      e.stopPropagation()
      currentTarget = $(e.currentTarget)
      # return early if we're opening a contextual menu (right click) during multi-select mode
      return if @multiSelectEnabled() && currentTarget.hasClass('selected') &&
                # mouse right click or ctrl click as right click on darwin platforms
                (e.button is 2 || e.ctrlKey && process.platform is 'darwin')

      entryToSelect = currentTarget.view()

      if e.shiftKey
        @selectContinuousEntries(entryToSelect)
        @showMultiSelectMenu()
      # only allow ctrl click for multi selection on non darwin systems
      else if e.metaKey || (e.ctrlKey && process.platform isnt 'darwin')
        @selectMultipleEntries(entryToSelect)

        # only show the multi select menu if more then one file/directory is selected
        @showMultiSelectMenu() if @selectedPaths().length > 1
      else
        @selectEntry(entryToSelect)
        @showFullMenu()

    # turn off default scrolling behavior from ScrollView
    @off 'core:move-up'
    @off 'core:move-down'
    @on 'mousedown', '.tree-view-resize-handle', (e) => @resizeStarted(e)

  attach: ->
    if !atom.config.get('tree-view.showOnRightSide')
      #@removeClass('panel-left')
      #@addClass('panel-right')
      atom.workspaceView.appendToRight(this)
    else
      #@removeClass('panel-right')
      #@addClass('panel-left')
      atom.workspaceView.appendToLeft(this)

  addItem: (item) ->
    if item.type is 0
      item.$status = {
        onValue: ->
          return 'ignored'
      }
      entry = new FileView item
      @list.append entry
    else if item.type is 1
      item.$status = {
        onValue: ->
          return 'ignored'
      }
      entry = new DirectoryView item
      @list.append entry

  resizeStarted: =>
    $(document.body).on('mousemove', @resizeTreeView)
    $(document.body).on('mouseup', @resizeStopped)

  resizeStopped: =>
    $(document.body).off('mousemove', @resizeTreeView)
    $(document.body).off('mouseup', @resizeStopped)

  resizeTreeView: ({pageX}) =>
    if !atom.config.get('tree-view.showOnRightSide')
      width = $(document.body).width() - pageX
    else
      width = pageX
    @width(width)

  resizeToFitContent: ->
    @width(1) # Shrink to measure the minimum width of list
    @width(@list.outerWidth())

  entryClicked: (e) ->
    entry = $(e.currentTarget).view()
    switch e.originalEvent?.detail ? 1
      when 1
        @selectEntry(entry)
        @openSelectedEntry(false) if entry instanceof FileView
        entry.toggleExpansion() if entry instanceof DirectoryView
      when 2
        if entry.is('.selected.file')
          atom.workspaceView.getActiveView()?.focus()
        else if entry.is('.selected.directory')
          entry.toggleExpansion()

    false

  # Public: Check for multi-select class on the main list
  #
  # Returns boolean
  multiSelectEnabled: ->
    @list.hasClass('multi-select')

  selectEntry: (entry) ->
    entry = entry?.view()
    return false unless entry?

    @selectedPath = entry.getPath()
    @deselect()
    entry.addClass('selected')

  deselect: ->
    @list.find('.selected').removeClass('selected')

  # Public: Toggle full-menu class on the main list element to display the full context
  #         menu.
  #
  # Returns noop
  showFullMenu: ->
    @list.removeClass('multi-select').addClass('full-menu')
