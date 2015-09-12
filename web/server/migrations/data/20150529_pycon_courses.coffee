
pycon_course_handler =
  TODO: (job)->
    console.log "[in pycon_course_handler TODO]"
    finishedAtKey = ["finished", job.status, "At"].join "_"

    usefulCallback = (err)->
      if err
        console.log "update taishin course fail:", err
      else
        console.log "update taishin course success"

    # set new image for taishin course

    adminMeetupIds = Meteor.settings.adminMeetupIds
    demoUser = Meteor.users.findOne({"services.meetup.id" : {$in: adminMeetupIds}})

    courseId = "pycon_crawler"
    imageTag = "agilearning/pycon-crawlers:basic"

    courseDoc =
      _id:courseId
      languages:["EN","ZH"]
      courseName: "PyConAPAC 2015 Tutorial - 模仿遊戲 用爬蟲類學爬蟲"
      dockerImageTag : imageTag
      description: """「現在告訴我，我是一個人，還是一隻爬蟲呢？」
      http://pycontw.kktix.cc/events/python-crawler
      """
      imageURL:"http://i.imgur.com/eX6IiuJ.png"
      publicStatus:"semipublic"
      creatorId: demoUser._id
      creatorAt:new Date

    db.courses.insert courseDoc, usefulCallback

    db.courseJoinDockerImageTags.insert {courseId:courseId, tag:imageTag}


    classroomDoc =
      name: "PyConAPAC 2015 Tutorial - 模仿遊戲 用爬蟲類學爬蟲"
      description: "Welcome"
      creatorId: demoUser._id
      courseId: courseId
      publicStatus:"public"
      createAt: new Date

    classroomId = db.classrooms.insert classroomDoc

    chatroomDoc =
      classroomId: classroomId
      name: "#{courseDoc.courseName} (#{classroomId[..5]}...)"
      creatorId: demoUser._id
      lastUpdate: new Date

    chatroomId = db.chatrooms.insert chatroomDoc

    creatorDoc = Meteor.users.findOne _id: demoUser._id

    db.chatMessages.insert
      chatroomId: chatroomId
      classroomId: classroomId
      userId: "system"
      userAvatar: "/images/noPhoto.png"
      userName: "System"
      createdAt: new Date
      type: "M"
      text: "Chatroom Created by #{creatorDoc.profile.name}"

    # Now the Probability Modeling & Text Mining


    courseId = "PMTM"
    imageTag = "agilearning/pyconapac2015-prob-nlp:latest"

    courseDoc =
      _id:courseId
      languages:["EN","ZH"]
      courseName: "PyConAPAC 2015 Tutorial - Play Probability Modeling and Text Mining"
      dockerImageTag : imageTag
      description: """本課程將透由一連串的實作練習，帶領聽眾學習 Probability Modeling 和 Text Mining 的各種技巧！
      http://pycontw.kktix.cc/events/play-modeling-mining
      """
      imageURL:"http://i.imgur.com/KfzRryL.png"
      publicStatus:"semipublic"
      creatorId: demoUser._id
      creatorAt:new Date

    db.courses.insert courseDoc, usefulCallback

    db.courseJoinDockerImageTags.insert {courseId:courseId, tag:imageTag}


    classroomDoc =
      name: "Play Probability Modeling and Text Mining"
      description: "Welcome"
      creatorId: demoUser._id
      courseId: courseId
      publicStatus:"public"
      createAt: new Date

    classroomId = db.classrooms.insert classroomDoc

    chatroomDoc =
      classroomId: classroomId
      name: "#{courseDoc.courseName} (#{classroomId[..5]}...)"
      creatorId: demoUser._id
      lastUpdate: new Date

    chatroomId = db.chatrooms.insert chatroomDoc

    creatorDoc = Meteor.users.findOne _id: demoUser._id

    db.chatMessages.insert
      chatroomId: chatroomId
      classroomId: classroomId
      userId: "system"
      userAvatar: "/images/noPhoto.png"
      userName: "System"
      createdAt: new Date
      type: "M"
      text: "Chatroom Created by #{creatorDoc.profile.name}"

    bundleServerGroups = [
      {
        _id: "pycon-PMTM"
        name: "Play Probability Modeling and Text Mining Course"
        desc: "This is a bundle server group for PyConAPAC 2015 Tutorial - Play Probability Modeling and Text Mining"
        members: Meteor.users.find("services.meetup.id": $in: Meteor.settings.adminMeetupIds).map (u) -> u._id
        admins: Meteor.users.find("services.meetup.id": $in: Meteor.settings.adminMeetupIds).map (u) -> u._id
        servers: ["[DockerServer]ds13-agilearning","[DockerServer]ds14-agilearning"]
        usageLimits: [
          name: "basic"
          NCPU: 1
          Memory: 512 * 1024 * 1024
        ]
      }
      {
        _id: "pycon-crawler"
        name: "PyConAPAC 2015 Tutorial - 模仿遊戲 用爬蟲類學爬蟲"
        desc: "This is a bundle server group for PyConAPAC 2015 Tutorial - 模仿遊戲 用爬蟲類學爬蟲"
        members: Meteor.users.find("services.meetup.id": $in: Meteor.settings.adminMeetupIds).map (u) -> u._id
        admins: Meteor.users.find("services.meetup.id": $in: Meteor.settings.adminMeetupIds).map (u) -> u._id
        servers: ["[DockerServer]ds15-agilearning","[DockerServer]ds16-agilearning"]
        usageLimits: [
          name: "basic"
          NCPU: 1
          Memory: 512 * 1024 * 1024
        ]
      }
      ]

    for group in bundleServerGroups
      db.bundleServerUserGroup.insert group

    db.dockerServers.update(
      {_id:$in:["[DockerServer]ds13-agilearning","[DockerServer]ds14-agilearning"]},
      {$set:user:type:"toB"},
      multi:yes
      upsert:no
      )


    updateData =
      status: "FINISHED"

    updateData[finishedAtKey] = new Date

    job.collection.update {_id:job.id}, {$set:updateData}



  FINISHED: (job)->
    console.log "[in pycon_course_handler FINISHED]"


Meteor.startup ->
  migrateJob = new Migration.Job "add pycon courses", pycon_course_handler
  migrateJob.handle