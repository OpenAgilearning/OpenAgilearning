
Meteor.FilterCollections.publish db.forumPosts, 
  name: "forumPostsFilter"

Meteor.publish "forumPost", (postId) ->
  return db.forumPosts.find(_id: postId)