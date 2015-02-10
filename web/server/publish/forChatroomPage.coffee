Meteor.publish "chatrooms", ->
  Chatrooms.find()

Meteor.publish "userJoinsChatroom", ->
  UserJoinsChatroom.find()