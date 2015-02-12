@Chatrooms = new Mongo.Collection "chatrooms"
@ChatMessages = new Mongo.Collection "chatMessages"
@UserJoinsChatroom = new Mongo.Collection "userJoinsChatroom"


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
    Chatrooms.update {_id: chatroomId}, 
      $set:
        lastUpdate: new Date


  createRoom: (name) ->

    user = Meteor.user()

    if not user
      throw new Meteor.Error 401, "Please Login"

    chatroomId = Chatrooms.insert
      name: name
      creatorId: user._id
      lastUpdate: new Date

    UserJoinsChatroom.insert
      userId: user._id
      userName: user.profile.name
      chatroomId: chatroomId
      chatroomName: name

    ChatMessages.insert
      userId: "system"
      userAvatar: "http://photos1.meetupstatic.com/img/noPhoto_50.png"
      userName: "System"
      createdAt: new Date
      chatroomId: chatroomId
      type: "M"
      text: "Chatroom Created by #{user.profile.name}"

    chatroomId

  joinRoom: (chatroomId) ->

    user = Meteor.user()
    chatroom = Chatrooms.findOne(_id: chatroomId)

    if not user
      throw new Meteor.Error 401, "Please Login"

    if not chatroom
      throw new Meteor.Error 402, "No such chatroom"

    if UserJoinsChatroom.findOne( {userId: user._id, chatroomId: chatroom._id} )
      throw new Meteor.Error 402, "Already in the chatroom"

    UserJoinsChatroom.insert
      userId: user._id
      userName: user.profile.name
      chatroomId: chatroomId
      chatroomName: chatroom.name

    ChatMessages.insert
      userId: "system"
      userAvatar: "http://photos1.meetupstatic.com/img/noPhoto_50.png"
      userName: "System"
      createdAt: new Date
      chatroomId: chatroomId
      type: "M"
      text: "#{user.profile.name} joins the room"

    Chatrooms.update {_id: chatroomId}, 
      $set:
        lastUpdate: new Date

  leaveRoom: (chatroomId) ->

    user = Meteor.user()
    chatroom = Chatrooms.findOne(_id: chatroomId)

    if not user
      throw new Meteor.Error 401, "Please Login"

    if not chatroom
      throw new Meteor.Error 402, "No such chatroom"

    joinInfo = UserJoinsChatroom.findOne( {userId: user._id, chatroomId: chatroom._id} )

    if not joinInfo
      throw new Meteor.Error 402, "Not in the chatroom"

    UserJoinsChatroom.remove(_id: joinInfo._id)

    ChatMessages.insert
      userId: "system"
      userAvatar: "http://photos1.meetupstatic.com/img/noPhoto_50.png"
      userName: "System"
      createdAt: new Date
      chatroomId: chatroomId
      type: "M"
      text: "#{user.profile.name} left the room"


  deleteRoom: (chatroomId) ->

    user = Meteor.user()
    chatroom = Chatrooms.findOne(_id: chatroomId)

    if not user
      throw new Meteor.Error 401, "Please Login"

    if not chatroom
      throw new Meteor.Error 402, "No such chatroom"

    if user._id isnt chatroom.creatorId
      throw new Meteor.Error 401, "Permission Denied"

    UserJoinsChatroom.remove(chatroomId: chatroomId)
    Chatrooms.remove(_id: chatroomId)
    ChatMessages.remove(chatroomId: chatroomId)

