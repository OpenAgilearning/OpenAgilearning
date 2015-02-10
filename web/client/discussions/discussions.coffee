Template.chatroomsPage.created = ->
  Session.set "currentChatroom", undefined

Template.chatroomsPage.helpers

  myChatrooms: ->
    res = []
    for key, value of Meteor.user().roles
      if key[0..9] is "classroom_"
        room = Chatrooms.findOne {classroomId: key[10..]}
        res.push room if room
    res.concat(UserJoinsChatroom.find
        userId: Meteor.userId()
      .map (rel) ->
        Chatrooms.findOne
          _id: rel.chatroomId
    )

  otherChatrooms: ->
    res = []
    Chatrooms.find().forEach (chatroom) ->
      if not UserJoinsChatroom.findOne {userId: Meteor.userId(), chatroomId: chatroom._id}
        res.push chatroom
    res

  messages: ->
    if Session.get("currentChatroom") is undefined
      []
    ChatMessages.find
      _id: Session.get "currentChatroom"

  isCurrentChatroom: (chatroom) ->
    chatroom._id is Session.get "currentChatroom"

  currentChatroomName: ->
    (Chatrooms.findOne({_id: Session.get "currentChatroom"}) or {name: ""}).name

  messageIsSentByCurrentUser: (message) ->
    message.userId is Meteor.userId

