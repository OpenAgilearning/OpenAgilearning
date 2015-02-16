forumPostsFilter = new Meteor.FilterCollections db.forumPosts, 
  name: "forumPostsFilter"
  template: "postsFilter"
  sort:
    defaults: [
      ["createdAt", "desc"]
    ]


Template.postsFilter.helpers
  partOf: (content) ->
    if content.length < 500
      content
    else
      content[..300] + "....."