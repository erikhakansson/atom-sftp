{$, BufferedProcess, ScrollView} = require 'atom'

module.exports =
class RemoteListView extends ScrollView
  @content: ->
    @div class: 'tree-view-resizer tool-panel', 'data-show-on-right-side': !atom.config.get('tree-view.showOnRightSide'), =>
      @div class: 'tree-view-scroller', outlet: 'scroller', =>
        @ol class: 'tree-view full-menu list-tree has-collapsable-children focusable-panel', tabindex: -1, outlet: 'list'
      @div class: 'tree-view-resize-handle', outlet: 'resizeHandle'

  constructor: (state) ->
    super
    focusAfterAttach = false

  attach: ->
    if !atom.config.get('tree-view.showOnRightSide')
      #@removeClass('panel-left')
      #@addClass('panel-right')
      atom.workspaceView.appendToRight(this)
    else
      #@removeClass('panel-right')
      #@addClass('panel-left')
      atom.workspaceView.appendToLeft(this)
