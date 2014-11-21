@Courses = new Meteor.Collection "courses"

Meteor.methods
  "createCourse": (courseData) ->
    user = Meteor.user()

    if not user
      throw new Meteor.Error(401, "You need to login")

    courseData["creator"] = user._id
    courseData["creatorName"] = user.profile.name
    courseData["creatorAt"] = new Date

    Courses.insert courseData

