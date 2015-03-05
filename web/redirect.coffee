if Meteor.isClient
  Meteor.startup ->
    if ENV.isProduction
      if window.location.host isnt Meteor.settings.public.redirectTo
        window.location = "http://" + Meteor.settings.public.redirectTo
