# Template.registerHelper "SettingSchema", SettingSchema

Template.profile.rendered = ->
  $(".edit-profile").toggle()

Template.profile.events
  "click input.edit-email": (e,t)->
    $(".edit-profile").toggle()
    $(".show-profile").toggle()

  "click input.btn.btn-primary": (e,t)->
    $(".show-profile").toggle()
    $(".edit-profile").toggle()