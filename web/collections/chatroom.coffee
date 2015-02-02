@ChatMessages = new Mongo.Collection "chatMessages"


@MessageSchema = new SimpleSchema

  text:
    type: String
    label: "Message Content"
    min: 1

  classroomId:
    type: String
    label: "Classroom ID"

  type:
    type: String
    label: "Message Type: Q (Question), R (Reply), M (Message)"
    regEx: /^[QRM]$/



Meteor.methods

  sendMessage: (classroomId, text, type) ->

    user = Meteor.user()

    if not user
      throw new Meteor.Error 401, "Please Login"

    if not Match.test {text: text, classroomId: classroomId, type: type}, MessageSchema
      throw new Meteor.Error 402, "Message must have content"

    user.profile.photo = user.profile.photo or {}
    user.profile.photo.thumb_link = user.profile.photo.thumb_link or "http://photos1.meetupstatic.com/img/noPhoto_50.png"

    ChatMessages.insert
      userId: user._id
      userAvatar: user.profile.photo.thumb_link
      userName: user.profile.name
      createdAt: new Date
      classroomId: classroomId
      type: type
      text: text

