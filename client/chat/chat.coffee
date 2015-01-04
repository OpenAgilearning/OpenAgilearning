# Template.chatroom.events
#   "change .postChatMsg": (e, t)->
#     e.stopPropagation()

#     courseId = Session.get "courseId"
#     msg = $(".postChatMsg").val()

#     $(".postChatMsg").val("")

#     Meteor.call "postChat", courseId, msg, (err, data) ->
#       if not err
#         console.log "data = "
#         console.log data
