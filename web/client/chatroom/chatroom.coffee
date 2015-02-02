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