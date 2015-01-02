Meteor.methods
  "createProfile": (createData)->
    user = Meteor.user()
    # console.log "createData = "
    # console.log createData
    Meteor.users.update {_id:user._id}, { $set:{"profile.email" : createData["email"]} }

  "updateProfile": (updateData)->
    user = Meteor.user()
    # console.log "updateData = "
    # console.log updateData
    Meteor.users.update {_id:user._id}, { $set:{"profile.email" : updateData["email"]} }