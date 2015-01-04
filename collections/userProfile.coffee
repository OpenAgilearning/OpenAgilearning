Meteor.methods
  "createProfile": (createData)->
    user = Meteor.user()
    Meteor.users.update {_id:user._id}, { $set:{"profile.email" : createData["email"]} }

  "updateProfile": (updateData)->
    user = Meteor.user()
    Meteor.users.update {_id:user._id}, { $set:{"profile.email" : updateData["email"]} }