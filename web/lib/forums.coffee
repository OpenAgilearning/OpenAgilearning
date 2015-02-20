db.forumPosts = new Mongo.Collection "forumPosts"

Meteor.methods
  
  postQuestion: (title, content) ->
    user = Meteor.user()
    if not user
      throw new Meteor.Error 401, "Please Login"
    if not (title and content)
      return undefined
    if not user.profile.photo?.thumb_link
      user.profile.photo = {thumb_link: "http://photos1.meetupstatic.com/img/noPhoto_50.png"}
    db.forumPosts.insert
      title: title
      content: content
      createdAt: new Date
      userId: user._id
      userName: user.profile.name
      userAvatar: user.profile.photo.thumb_link