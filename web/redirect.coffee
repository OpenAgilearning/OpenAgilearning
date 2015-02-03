if Meteor.isClient
  Meteor.startup ->
    if Meteor.settings.public.environment is "production"
      if window.location.host isnt Meteor.settings.public.redirectTo
        window.location = "http://" + Meteor.settings.public.redirectTo
