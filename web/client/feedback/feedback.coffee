Template.feedback.rendered = ->
  Session.set "submitted", no

Template.feedback.helpers
  submitted: ->
    Session.get "submitted"

Template.feedback.events
  "submit #feedbackForm":(e,t)->
    Session.set "submitted", yes
  "click #send-another, show.bs.collapse #collapse-body":(e,t)->
    e.stopPropagation()
    Session.set "submitted", no
  "click .feedback-header":(e,t)->
    $("#collapse-body").collapse "toggle"
  "click #feedback":(e,t)->
    $('#feedback').popover('destroy')
#  "change input[type=radio]":(e,t)->
#    console.log "change!!!!!!!!!!!!"

Template.afRadioGroupInline_custom.helpers
  atts: ->
    atts = _.clone(@atts)
    if @selected
      atts.checked = ""
    # remove data-schema-key attribute because we put it
    # on the entire group
    delete atts['data-schema-key']
    atts
  dsk: ->
    { 'data-schema-key': @atts['data-schema-key'] }

AutoForm.addInputType 'select-radio-inline-custom',
  template: 'afRadioGroupInline_custom'
  valueOut: ->
    @find('input[type=radio]:checked').val()
#  contextAdjust: (context) ->
#    itemAtts = _.omit(context.atts)
#    # build items list
#    context.items = []
#    # Add all defined options
#    _.each context.selectOptions, (opt) ->
#      context.items.push
#        name: context.name
#        label: opt.label
#        value: opt.value
#        _id: opt.value
#        selected: opt.value == context.value
#        atts: itemAtts
#      return
#    context