@Chat = new Meteor.Collection "chat"

@ChatSchema = new SimpleSchema
  msg:
    type: String
    label: "msg"
    max: 200
  courseId:
    type: String
    label: "courseId"


Meteor.methods
  # "postChat": (courseId, msg) ->
  "postChat": (quickFormData) ->
    user = Meteor.user()
    if not user
      throw new Meteor.Error(401, "You need to login")
    console.log quickFormData
    quickFormData.userId = user._id
    quickFormData.userName = user.profile.name
    quickFormData.createAt = new Date
    Chat.insert quickFormData
