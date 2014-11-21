@Chat = new Meteor.Collection "chat"

Meteor.methods
  "postChat": (courseId, msg) ->
    user = Meteor.user()
    if not user
      throw new Meteor.Error(401, "You need to login")
    
    if not courseId
      throw new Meteor.Error(501, "Need courseId")

    if not msg
      throw new Meteor.Error(501, "Need msg")

    chatData = 
      userId: user._id
      userName: user.profile.name 
      courseId: courseId 
      msg: msg 
      createAt: new Date

    Chat.insert chatData
