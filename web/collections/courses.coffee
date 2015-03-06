
@LearningResources = new Mongo.Collection "learningResources"

@Collections.LearningResources = @LearningResources
@db.learningResources = @Collections.LearningResources


# @learningResourceSchema = new SimpleSchema
#   title:
#     type: String
#   description:
#     type: String
#   image:
#     type: String
#     optional: true
#   type:
#     type: String
#     allowedValues: ["video","website","slide","youtube"]
#     optional: true
#   url:
#     type: String
#     optional: true
#     regEx: SimpleSchema.RegEx.Url
#   youtubeVideoId:
#     type: String
#     optional: true
#   youtubePlaylistId:
#     type: String
#     optional: true




Meteor.methods
  "createLearningResource": (data) ->
    user = Meteor.user()

    if not user
      throw new Meteor.Error(401, "You need to login")

    data["creator"] = user._id
    data["creatorAt"] = new Date
    LearningResources.insert data



@Courses = new Mongo.Collection "courses"
# @CourseRoles = new Mongo.Collection "courseRoles"

@Collections.Courses = @Courses
@db.courses = @Collections.Courses




Meteor.methods
  "checkCourseApplication": (roleId) ->
    loggedInUserId = Meteor.userId()

    if not loggedInUserId
      throw new Meteor.Error(401, "You need to login")

    if Collections.Roles.find({_id:roleId}).count() is 0
      throw new Meteor.Error(1402, "[Admin Error] there is no role with id" + roleId)

    groupId = Collections.Roles.findOne({_id:roleId}).groupId

    if Collections.Roles.find({userId:loggedInUserId,role:"admin",groupId:groupId}).count() > 0
      Collections.Roles.update({_id:roleId},{$set:{role:"member"}})

  "applyCourse": (courseId) ->
    loggedInUserId = Meteor.userId()

    if not loggedInUserId
      throw new Meteor.Error(401, "You need to login")

    if Courses.find({_id:courseId}).count() is 0
      throw new Meteor.Error(1302, "[Admin Error] there is no course with id" + courseId)

    queryRoleGroup =
      type: "course"
      id: courseId

    roleGroupId = Collections.RoleGroups.findOne(queryRoleGroup)._id

    data =
      groupId: roleGroupId
      userId: loggedInUserId
      role: "waitForCheck"

    if Collections.Roles.find(data).count() is 0
      data.createdAt = new Date
      Collections.Roles.insert data






  "editCourseInfoByAdmin": (courseDoc) ->
    # console.log "courseDoc = "
    # console.log courseDoc

    loggedInUserId = Meteor.userId()
    courseId = courseDoc._id

    if not loggedInUserId
      throw new Meteor.Error(401, "You need to login")

    if Courses.find({_id:courseId}).count() is 0
      throw new Meteor.Error(1302, "[Admin Error] there is no course with id" + courseId)

    if RoleTools.isRole loggedInUserId, "admin", "course", courseId
      delete courseDoc._id
      Courses.update {_id:courseId}, {$set:courseDoc}
      db.classrooms.update {"courseId":courseId}, {$set: {"publicStatus" : courseDoc.publicStatus} }

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
