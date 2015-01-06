@SettingSchema = new SimpleSchema
  email: 
    type: String,
    regEx: SimpleSchema.RegEx.Email
    autoform:
      afFieldInput:
        type: "email"

Meteor.methods
  "updateProfile": (updateData)->
    user = Meteor.user()
    console.log "updateData = "
    console.log updateData
    Meteor.users.update {_id:user._id}, { $set:{"profile.email" : updateData["email"]} }