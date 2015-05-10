Template.classChatroom.created = ->
  Session.set "chatroomIsMinimised", no
  Session.set "readMessages", 0

Template.classChatroom.helpers
  messages: ->
    ChatMessages.find({classroomId: @classroomId}, {sort: {createdAt: -1}}).fetch()
  messageIsSentByCurrentUser: (message) ->
    message.userId is Meteor.user()._id
  showResumeUrl:(userId)-> userId isnt "system"

Template.classChatroom.events
  "submit .new-message-form": (event, template) ->
    event.preventDefault()
    Meteor.call(
      "sendMessage",
      null,
      template.data.classroomId,
      template.$("#new-message-text").val(),
      "M")
    template.$("#new-message-text").val("")

  "click .chat-header": (event, template) ->
    classChatroom = template.$ ".chatroom-main"
    if template.data.type is "classroom"
      classChatroom.hide()
      $(".classroom-body").removeClass("col-md-9").addClass("col-md-12")
      Session.set "chatroomIsMinimised", yes
      Session.set "readMessages", ChatMessages.find().count()
  "mouseenter .message-item":(e)->
    $(e.currentTarget).find(".additional-info").show()
  "mouseleave .message-item":(e)->
    $(e.currentTarget).find(".additional-info").hide()

Template.minimisedChatroom.helpers
  display: ->
    if Session.get("chatroomIsMinimised") is no
      return "display:none"
    else
      return "display:block"
  unreadMessages: ->
    ChatMessages.find().count() - Session.get "readMessages"

Template.minimisedChatroom.events
  "click .minimised-chatroom": (event, template) ->
    Session.set "chatroomIsMinimised", no
    $(".chatroom-main").show()
    $(".classroom-body").removeClass("col-md-12").addClass("col-md-9")
