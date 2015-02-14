
Template.agileCountdown.rendered = ->
  Meteor.autorun ->
    if RoleTools.isRole("developer","agilearning.io")
      ycCountdownSettings =
        until: new Date(2015, 2, 15)
        compact: true
      
      $(".agileCountdown").countdown ycCountdownSettings
