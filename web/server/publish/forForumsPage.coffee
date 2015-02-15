Meteor.publish "forumQuestions", ->
  return db.forumPosts.find()