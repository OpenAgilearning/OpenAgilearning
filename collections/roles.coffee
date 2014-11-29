@Roles = new Meteor.Collection "roles"

Meteor.methods
  "checkIsAdmin": ->
    user = Meteor.user()
    if not user
      throw new Meteor.Error(401, "You need to login")
  
    Roles.find({userId:user._id, role:"admin"}).count() > 0
