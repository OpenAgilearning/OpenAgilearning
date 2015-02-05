@Chatrooms = new Mongo.Collection "chatrooms"
@ChatMessages = new Mongo.Collection "chatMessages"


@MessageSchema = new SimpleSchema

  text:
    type: String
    label: "Message Content"
    min: 1

  chatroomId:
    type: String
    label: "Chatroom ID"

  classroomId:
    type: String
    label: "Classroom ID"
    optional: true

  type:
    type: String
    label: "Message Type: Q (Question), R (Reply), M (Message)"
    regEx: /^[QRM]$/



Meteor.methods

  sendMessage: (chatroomId, classroomId, text, type) ->

    user = Meteor.user()

    if not user
      throw new Meteor.Error 401, "Please Login"

    if not chatroomId
      chatroomId = Chatrooms.findOne(classroomId: classroomId)._id

    if not Match.test {text: text, classroomId: classroomId, chatroomId: chatroomId, type: type}, MessageSchema
      throw new Meteor.Error 402, "Message must have content"

    if not Chatrooms.findOne(_id: chatroomId)
      throw new Meteor.Error 402, "No such chatroom"

    user.profile.photo = user.profile.photo or {}
    user.profile.photo.thumb_link = user.profile.photo.thumb_link or "http://photos1.meetupstatic.com/img/noPhoto_50.png"

    doc =
      userId: user._id
      userAvatar: user.profile.photo.thumb_link
      userName: user.profile.name
      createdAt: new Date
      chatroomId: chatroomId
      type: type
      text: text

    if classroomId
      doc.classroomId = classroomId

    ChatMessages.insert doc


