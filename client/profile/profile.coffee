# Template.registerHelper "SettingSchema", SettingSchema

Template.profile.events
  "click #update_profile": (e,t)->
    console.log "you click update button"
    data =
      email: $("input.profile.email").val()
    
    Meteor.call "update profile", data, (err, res)->
      if err
        console.log "err = "
        console.log err

      if res
        console.log "res = "
        console.log res
