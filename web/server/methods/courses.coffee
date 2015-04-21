Meteor.methods
  "checkCourseApplication": (userIsRoleId) ->
    loggedInUserId = Meteor.userId()

    if not loggedInUserId
      throw new Meteor.Error(401, "You need to login")

    userIsRoleData = db.userIsRole.findOne({_id:userIsRoleId})
    console.log "userIsRoleData = ",userIsRoleData

    if userIsRoleData
      roleData = db.roleTypes.findOne({_id:userIsRoleData.roleId})

      if roleData.role is "waitForCheck"
        new Role(roleData.group,"member").add(userIsRoleData.userId)
        db.userIsRole.remove({_id:userIsRoleId})

    else
      throw new Meteor.Error(1402, "[Admin Error] there is no role with id" + roleId)



  "applyCourse": (courseId) ->

    console.log "[in applyCourse]"

    loggedInUserId = Meteor.userId()

    if not loggedInUserId
      throw new Meteor.Error(401, "You need to login")

    else
      if db.courses.find({_id:courseId}).count() is 0
        throw new Meteor.Error(1302, "[Admin Error] there is no course with id" + courseId)

      if db.courses.findOne({_id:courseId}).publicStatus is "public"
        new Role({type:"course",id:courseId},"member").add_f(loggedInUserId)

      else
        unless Is.course(courseId,["admin","member"])
          new Role({type:"course",id:courseId},"waitForCheck").add_f(loggedInUserId)




  "editCourseInfoByAdmin": (courseDoc) ->
    # console.log "courseDoc = "
    # console.log courseDoc

    loggedInUserId = Meteor.userId()
    courseId = courseDoc._id

    if not loggedInUserId
      throw new Meteor.Error(401, "You need to login")

    if Courses.find({_id:courseId}).count() is 0
      throw new Meteor.Error(1302, "[Admin Error] there is no course with id" + courseId)

    else

      if Is.course courseId, "admin"
        delete courseDoc._id
        db.courses.update {_id:courseId}, {$set:courseDoc}
        db.classrooms.update {"courseId":courseId}, {$set: {"publicStatus" : courseDoc.publicStatus} }

  # "createCourse": (courseData) ->

  #   user = Meteor.user()

  #   if not user
  #     throw new Meteor.Error(401, "You need to login")

  #   courseData["creatorId"] = user._id
  #   courseData["creatorAt"] = new Date

  #   Courses.insert courseData

  # "deleteCourse": (courseId) ->
  #   loggedInUserId = Meteor.userId()

  #   if not loggedInUserId
  #     throw new Meteor.Error(401, "You need to login")

  #   if Roles.userIsInRole loggedInUserId, "admin", "system"
  #     if Courses.find({_id:courseId}).count() > 0
  #       Courses.remove({ "_id": courseId })
  #     else
  #       throw new Meteor.Error(1302, "[Admin Error] there is no course with id" + courseId)
  #   else if Roles.userIsInRole loggedInUserId, "manager", "courses"
  #     if Courses.find({_id:courseId}).count() > 0
  #       Courses.remove({ "_id": courseId })
  #   else
  #     throw new Meteor.Error(1301, "[Admin Error] permision deny")
