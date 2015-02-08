Meteor.publish "chatroomsWithoutClassChatroom", ->
  Chatrooms.find
    classroomId:
      $exists: false

Meteor.publish "userJoinsChatroom", ->
  UserJoinsChatroom.find()