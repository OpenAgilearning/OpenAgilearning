Meteor.methods
  "update profile": (data)->
    user = Meteor.user()
    user.profile["email"] = data.email
# insert update data will cause _id be override, error happen.
# create a object to store _id. avoid Mod error, about minimongo error.
    u={}
    u._id = user._id
    delete user._id
    Meteor.users.update {_id:u._id}, {$set:user}