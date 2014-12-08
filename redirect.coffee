if Meteor.isClient
  Meteor.startup ->
    if window.location.host isnt "agilearning.io"
      window.location = "http://agilearning.io"
