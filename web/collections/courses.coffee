@Classrooms = new Mongo.Collection "classrooms"
@ClassroomManagers = new Mongo.Collection "classroomManagers"

@LearningResources = new Mongo.Collection "learningResources"

@learningResourceSchema = new SimpleSchema
  title:
    type: String
  description:
    type: String
  image:
    type: String
    optional: true
  type:
    type: String
    allowedValues: ["video","website","slide","youtube"]
    optional: true
  url:
    type: String
    optional: true
    regEx: SimpleSchema.RegEx.Url
  youtubeVideoId:
    type: String
    optional: true
  youtubePlaylistId:
    type: String
    optional: true




Meteor.methods
  "createLearningResource": (data) ->
    user = Meteor.user()

    if not user
      throw new Meteor.Error(401, "You need to login")

    data["creator"] = user._id
    data["creatorAt"] = new Date
    LearningResources.insert data



@Courses = new Mongo.Collection "courses"

@coursesSchema = new SimpleSchema
  courseName:
    type: String

  publicStatus:
    type: String
    allowedValues: ["public","semiprivate","private"]

  dockerImage:
    type: String

  slides:
    type: String
    optional: true
    regEx: SimpleSchema.RegEx.Url
    autoform:
      type: "url"

  description:
    type: String
    optional: true

  video:
    type: String
    optional: true
    regEx: SimpleSchema.RegEx.Url
    autoform:
      type: "url"





Meteor.methods
  "createCourse": (courseData) ->

    user = Meteor.user()

    if not user
      throw new Meteor.Error(401, "You need to login")

    courseData["creatorId"] = user._id
    courseData["creatorAt"] = new Date

    Courses.insert courseData

  "deleteCourse": (courseId) ->
    loggedInUserId = Meteor.userId()

    if not loggedInUserId
      throw new Meteor.Error(401, "You need to login")

    if Roles.userIsInRole loggedInUserId, "admin", "system"
      if Courses.find({_id:courseId}).count() > 0
        Courses.remove({ "_id": courseId })
      else
        throw new Meteor.Error(1302, "[Admin Error] there is no course with id" + courseId)
    else if Roles.userIsInRole loggedInUserId, "manager", "courses"
      if Courses.find({_id:courseId}).count() > 0
        Courses.remove({ "_id": courseId })
    else
      throw new Meteor.Error(1301, "[Admin Error] permision deny")