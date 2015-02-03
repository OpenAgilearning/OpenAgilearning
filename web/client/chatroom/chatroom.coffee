Template.chatroom.created = ->
	Session.set "chatroomIsMinimised", no

Template.chatroom.helpers
	messages: ->
		ChatMessages.find({}, {sort: {createdAt: -1}}).fetch()
	messageIsSentByCurrentUser: (message) ->
		return message.userId is Meteor.user()._id

Template.chatroom.events
	"submit .new-message-form": (event, template) ->
		event.preventDefault()
		Meteor.call(
			"sendMessage", 
			template.data.classroomId, 
			template.$("#new-message-text").val(), 
			"M")
		template.$("#new-message-text").val("")

	"click .chat-header": (event, template) ->
		classChatroom = template.$ ".class-chatroom"
		if Session.get("chatroomIsMinimised") is no
			classChatroom.hide()
			$(".classroom-body").removeClass("col-md-9").addClass("col-md-12")
			Session.set "chatroomIsMinimised", yes
		# newMessageFormWrapper = template.$ ".new-message-form-wrapper"
		# chatroomBody = template.$ ".chatroom-body"
		# if newMessageFormWrapper.css("display") is "none"
		# 	newMessageFormWrapper.show()
		# 	chatroomBody.show()
		# else
		# 	newMessageFormWrapper.hide()
		# 	chatroomBody.hide()

Template.minimisedChatroom.helpers
	display: ->
		if Session.get("chatroomIsMinimised") is no
			return "display:none"
		else
			return "display:block"

Template.minimisedChatroom.events
	"click .minimised-chatroom": (event, template) ->
		Session.set "chatroomIsMinimised", not Session.get("chatroomIsMinimised")
		$(".class-chatroom").show()
		$(".classroom-body").removeClass("col-md-12").addClass("col-md-9")
		Session.set "chatroomIsMinimised", no