
rolesMigrationHandler =
  "TODO": (job) ->
    console.log "[in rolesMigrationHandler TODO]"
    finishedAtKey = ["finished", job.status, "At"].join "_"

    # Remove Private Course test
    db.courses.remove _id:"gbJfM9n3EoztvB2Gh"
    db.classrooms.remove courseId:"gbJfM9n3EoztvB2Gh"


    # Add Taishin course

    adminMeetupIds = Meteor.settings.adminMeetupIds
    demoUser = Meteor.users.findOne({"services.meetup.id" : {$in: adminMeetupIds}})

    taishinCourse =
      _id: "TaishinCrawler"
      languages:["EN","ZH"]
      courseName: "Taishin Courses"
      dockerImageTag : "c3h3/dsc2014tutorial:latest"
      description: "This course is for Taishin Commercial bank internal trainning."
      imageURL:"http://i.imgur.com/KHtsRCF.png"
      publicStatus:"semipublic"
      creatorId: demoUser._id
      creatorAt:new Date

    if db.courses.find({_id:taishinCourse._id}).count() is 0

	    courseId = db.courses.insert taishinCourse
	    db.courseJoinDockerImageTags.insert {courseId:"TaishinCrawler", tag:"c3h3/dsc2014tutorial:latest"}

	    classroomDoc =
	      name: "Semi-Public Classroom"
	      description: "Taishin's fellow only!"
	      creatorId: demoUser._id
	      courseId: courseId
	      publicStatus:"public"
	      createAt: new Date

	    classroomId = db.classrooms.insert classroomDoc

	    chatroomDoc =
	      classroomId: classroomId
	      name: "#{taishinCourse.courseName} (#{classroomId[..5]}...)"
	      creatorId: taishinCourse.creatorId
	      lastUpdate: new Date

	    chatroomId = db.chatrooms.insert chatroomDoc

	    creatorDoc = Meteor.users.findOne _id: taishinCourse.creatorId

	    db.chatMessages.insert
	      chatroomId: chatroomId
	      classroomId: classroomId
	      userId: "system"
	      userAvatar: "/images/noPhoto.png"
	      userName: "System"
	      createdAt: new Date
	      type: "M"
	      text: "Chatroom Created by #{creatorDoc.profile.name}"



    courseIds =  db.courses.find().map (data) -> data._id

    console.log "courseIds = ", courseIds

    db.roleGroups.find({type:"course"},{fields:{id:1}}).fetch().filter((data)-> data.id in courseIds).map (groupData)->

      db.roles.find({groupId:groupData._id}).map (roleData)->

        new Role({type: "course",id: groupData.id}, roleData.role).add_f roleData.userId

    db.roleGroups.remove {}
    db.roles.remove {}

    classroomIds =  db.classrooms.find().map (data) -> data._id

    console.log "classroomIds = ", classroomIds

    Meteor.users.find({roles:{$exists:true}},{fields:{roles:1}}).map (userData)->
      for roleString in Object.keys(userData.roles)
        [type, id] = roleString.split("_")


        if type is "classroom" and id in classroomIds
          # console.log "[type, id] = ", [type, id]

          for role in userData.roles[roleString]

            new Role({type: type,id: id}, role).add_f userData._id

    Meteor.users.update({roles:{$exists:true}},{$unset:{roles:""}})


    for instanceDoc in db.dockerInstances.find().fetch()
      # console.log "instanceDoc = ",instanceDoc
      # dockerInstanceDoc = _.extend {}, instanceDoc
      # docker = new Class.DockerServer instanceDoc.serverId
      # # docker.stop instanceDoc.containerId
      # # docker.rm instanceDoc.containerId
      # docker.rmf instanceDoc.containerId

      dockerInstanceDoc = instanceDoc
      db.dockerInstances.remove _id: dockerInstanceDoc._id

      dockerInstanceDoc.removeAt = new Date
      dockerInstanceDoc.removeBy = "shutdown"
      # dockerInstanceDoc.removeByUid = user._id
      db.dockerInstancesLog.insert dockerInstanceDoc


    db.dockerServers.remove {name:{$in:["ds4-agilearning","ds5-agilearning","ds6-agilearning"]}}

    updateData =
      status: "FINISHED"

    updateData[finishedAtKey] = new Date

    job.collection.update {_id:job.id}, {$set:updateData}


Meteor.startup ->
  # rolesMigrationJob = new Migration.Job "20150420RolesMigration", rolesMigrationHandler
  # rolesMigrationJob.remove
  rolesMigrationJob = new Migration.Job "20150420RolesMigration", rolesMigrationHandler
  rolesMigrationJob.handle