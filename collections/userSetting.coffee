Meteor.methods
  "update profile": (data)->
    user = Meteor.user()
    user.profile["email"] = data.email
    Meteor.users.update {_id:user._id}, {$set:user}