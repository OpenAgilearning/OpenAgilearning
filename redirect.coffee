if Meteor.isClient
  Meteor.startup ->
    if window.location.host is "agilearning.io"
      window.location = "http://agilearning.io"
