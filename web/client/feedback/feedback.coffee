Template.feedback.rendered = ->
  Session.set "submitted", no

Template.feedback.helpers
  submitted: ->
    Session.get "submitted"

Template.feedback.events
  "submit #feedbackForm":(e,t)->
    e.stopPropagation()
    Session.set "submitted", yes
  "click #send-another, show.bs.collapse #collapse-body":(e,t)->
    e.stopPropagation()
    Session.set "submitted", no