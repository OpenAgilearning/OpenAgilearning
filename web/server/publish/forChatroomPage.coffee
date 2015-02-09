Meteor.publish "chatrooms", ->
  Chatrooms.find
    classroomId:
      $exists: false

Meteor.publish "userJoinsChatroom", ->
  UserJoinsChatroom.find()