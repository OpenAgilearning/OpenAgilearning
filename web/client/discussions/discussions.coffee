Template.chatroomsPage.created = ->
  Session.set "currentChatroom", undefined

Template.chatroomsPage.helpers

  myChatrooms: ->
    res = []
    for key, value of Meteor.user().roles
      if key[0..9] is "classroom_"
        room = Chatrooms.findOne {classroomId: key[10..]}
        res.push room if room
    res = res.concat(UserJoinsChatroom.find
        userId: Meteor.userId()
      .map (rel) ->
        Chatrooms.findOne
          _id: rel.chatroomId
    )
    chatrooms = Chatrooms.find({
      $or: res.map (chatroom) ->
        _id: chatroom._id
      }, {
        sort: 
          lastUpdate: -1
      }).fetch()
    Session.set "currentChatroom", chatrooms[0]?._id
    Meteor.subscribe "chatMessages", chatrooms[0]?._id
    chatrooms

  otherChatrooms: ->
    res = []
    Chatrooms.find({classroomId: {$exists: false}}).forEach (chatroom) ->
      if not UserJoinsChatroom.findOne {userId: Meteor.userId(), chatroomId: chatroom._id}
        res.push chatroom
    res

  messages: ->
    if Session.get("currentChatroom") is undefined
      []
    ChatMessages.find(
      {chatroomId: Session.get "currentChatroom"},
      {sort: {createdAt: -1}}
    )

  chatroomCreatorName: (chatroom) ->
    UserJoinsChatroom.findOne({chatroomId: chatroom._id, userId: chatroom.creatorId}).userName

  isCurrentChatroom: (chatroom) ->
    chatroom._id is Session.get "currentChatroom"

  currentChatroomName: ->
    (Chatrooms.findOne({_id: Session.get "currentChatroom"}) or {name: ""}).name

  messageIsSentByCurrentUser: (message) ->
    message.userId is Meteor.userId()



Template.chatroomsPage.events

  "click .select-chatroom": (event, template) ->
    Session.set "currentChatroom", $(event.target).attr "roomid"
    Meteor.subscribe "chatMessages", Session.get "currentChatroom"

  "submit #new-message-form": (event, template) ->
    event.preventDefault()
    room = Session.get "currentChatroom"
    if room and Chatrooms.findOne(_id: room)
      Meteor.call(
        "sendMessage", 
        room, 
        Chatrooms.findOne(_id: room).classroomId, 
        template.$("#new-message-text").val(), 
        "M"
      )
      template.$("#new-message-text").val ""

  "click #submit-creation": (event, template) ->
    event.preventDefault()
    newRoomName = template.$("#new-room-text").val()
    if newRoomName.length >= 1
      Meteor.call "createRoom", newRoomName, (error, newChatroomId) ->
        if not error
          Session.set "currentChatroom", newChatroomId
          Meteor.subscribe "chatMessages", newChatroomId
      $("#create-room-modal").modal "hide"
      template.$("#new-room-text").val ""

  "click .join-chat": (event, template) ->
    chatroomId = $(event.target).attr "chatroomId"
    Meteor.call "joinRoom", chatroomId
    Session.set "currentChatroom", chatroomId
    Meteor.subscribe "chatMessages", chatroomId
