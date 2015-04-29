#forumPostsFilter = new Meteor.FilterCollections db.forumPosts, 
#  name: "forumPostsFilter"
#  template: "postsFilter"
#  sort:
#    defaults: [
#      ["createdAt", "desc"]
#    ]


#Template.postsFilter.helpers
#  partOf: (content) ->
#    if content.length < 500
#      content
#    else
#      content[..300] + "....."



#Template.postQuestionModal.events
#  "click #submit-question": (event, template) ->
#    title = template.$("#new-question-title").val()
#    content = template.$("#new-question-content").val()
#    Meteor.call "postQuestion", title, content, (error, data) ->
#      if not error
#        if data
#          Router.go "forumPost",
#            postId: data

