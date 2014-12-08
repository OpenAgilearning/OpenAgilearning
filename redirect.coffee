if Meteor.isClient
  Meteor.startup ->
    absUrl = Meteor.absoluteUrl()
    String::startsWith ?= (s) -> @slice(0, s.length) == s
    String::endsWith   ?= (s) -> s == '' or @slice(-s.length) == s
    if absUrl.startsWith("http://agilearning.io")
      window.location = "http://agilearning.io"
