if Meteor.isClient
  Meteor.startup ->
    absUrl = Meteor.absoluteUrl()
    if absUrl isnt "http://agilearning.io"
      window.location = "http://agilearning.io"
