Meteor.publish "chatrooms", ->
  Chatrooms.find()

Meteor.publish "userJoinsChatroom", ->
  UserJoinsChatroom.find()

Meteor.publish "chatMessages", (chatroomId) ->
  ChatMessages.find
    chatroomId: chatroomId