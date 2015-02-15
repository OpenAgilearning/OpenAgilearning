db.forumPosts = new Mongo.Collection "forumPosts"


Meteor.methods
  
  postQuestion: (title, content) ->
    user = Meteor.user()
    if not user
      throw new Meteor.Error 401, "Please Login"
    db.forumPosts.insert
      title: title
      content: content
      createdAt: new Date
      userId: user._id
      userName: user.profile.name
      userAvatar: user.profile.photo?.thumb_link? or "http://photos1.meetupstatic.com/img/noPhoto_50.png"