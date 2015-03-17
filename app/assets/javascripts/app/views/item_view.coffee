#= require app/collections/items

###
This class is responsible for displaying a single item. Items may or may not
have child items. If our item does have children, we put them in an ItemListView.

ItemViews can collapse (stop displaying) their children.
###
class App.views.ItemView extends Backbone.View
  tagName: 'li'
  className: 'item'
  template: HandlebarsTemplates['item']
  events:
    'click .collapse': 'toggleChildren'
    'input .title':    'updateTitle'
    'input .content':  'updateContent'

  initialize: () ->
    @children = new App.collections.Items(@model.get('children'))
    @state    = collapsed: false
    Backbone.Events.bind 'filterItems', (s) => @hideIfNotMatched(s)

    Backbone.Events.bind 'itemChangedPosition', () =>
      @model.set
        position:  @$el.index()
        parent_id: @$el.parents('.item').data('id') || 0

  renderChildren: () ->
    childView = new App.views.ItemListView(collection: @children)
    @$el.append(childView.render().el)

  toggleChildren: () ->
    @state.collapsed = !@state.collapsed
    @render()

  # Careful! The title that was edited might be the title of one of my children
  updateTitle: (e) ->
    title = $(e.currentTarget)
    if title.parent().data('id') == @model.get('id')
      @model.set('title', title.text())

  # Same as above
  updateContent: (e) ->
    content = $(e.currentTarget)
    if content.parent().data('id') == @model.get('id')
      @model.set('content', content.text())

  hideIfNotMatched: (searchText) ->
    @$('.title, .content').show()
    searchText = searchText.toLowerCase()
    title = @model.get('title').toLowerCase()
    content = @model.get('content').toLowerCase()

    titleMatches   = title.indexOf(searchText)   != -1
    contentMatches = content.indexOf(searchText) != -1
    @$('.title, .content').hide() unless contentMatches or titleMatches

  render: ->
    @$el.html @template(@model.attributes)
    @$el.attr "data-id", @model.get('id')
    @renderChildren() unless @state.collapsed
    this
