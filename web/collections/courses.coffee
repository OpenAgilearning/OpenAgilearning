@LearningResources = new Mongo.Collection "learningResources"

@learningResourceSchema = new SimpleSchema
  title:
    type: String
  description:
    type: String  
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

    courseData["creator"] = user._id
    courseData["creatorAt"] = new Date

    Courses.insert courseData

