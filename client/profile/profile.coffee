# Template.registerHelper "SettingSchema", SettingSchema

Template.profile.rendered = ->
  $(".profile-editor").toggle()

Template.profile.events
  "click input.btn.btn-primary": (e,t)->
    $(".profile-editor").toggle()
    $(".show-profile").toggle()

AutoForm.hooks profileUpdate:
  onSuccess: (updateProfile, result, template) ->
    $(".show-profile").toggle()
    $(".profile-editor").toggle()
