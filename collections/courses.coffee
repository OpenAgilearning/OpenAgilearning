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

coursesCheck = (courseData) ->
  console.log "hello"



Meteor.methods
  "createCourse": (courseData) ->
    console.log "courseData = "
    console.log courseData
    console.log "check ="
    console.log check
    console.log check(courseData,coursesSchema)

    user = Meteor.user()

    if not user
      throw new Meteor.Error(401, "You need to login")

    courseData["creator"] = user._id
    courseData["creatorName"] = user.profile.name
    courseData["creatorAt"] = new Date

    Courses.insert courseData

