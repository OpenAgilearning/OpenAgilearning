if Meteor.isClient
  Meteor.startup ->
    absUrl = Meteor.absoluteUrl()
    if absUrl is "http://dockerhack2014.opennote.info/"
      window.location = "http://agilearning.io"
