Template.feedback.rendered = ->
  Session.set "feedbackFormSubmitted", no

Template.feedback.helpers
  submitted: ->
    Session.get "feedbackFormSubmitted"

Template.feedback.events
  "click #send-another, show.bs.collapse #collapse-body":(e,t)->
    e.stopPropagation()
    Session.set "feedbackFormSubmitted", no
  "click .feedback-header":(e,t)->
    $("#collapse-body").collapse "toggle"
  "click #feedback":(e,t)->
    $('#feedback').popover('destroy')

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