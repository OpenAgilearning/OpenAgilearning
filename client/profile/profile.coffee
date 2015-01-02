Template.registerHelper "SettingSchema", SettingSchema

Template.public_profile.helpers
  user_profile: ->
    pr = Meteor.user().profile
    data =
      email:pr.email