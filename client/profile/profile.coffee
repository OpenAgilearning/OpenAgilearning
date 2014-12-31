# Template.registerHelper "SettingSchema", SettingSchema

Template.public_profile.helpers
  user_profile: ->
    pr = Meteor.user().profile
    data =
      email:pr.email

# Template.profile.events
#   "click #update_profile": (e,t)->
#     console.log "you click update button"
#     data =
#       email: $("input.profile.email").val()
    
#     Meteor.call "update profile", data, (err, res)->
#       if err
#         console.log "err = "
#         console.log err