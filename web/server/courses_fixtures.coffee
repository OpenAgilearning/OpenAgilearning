
@Fixture.Courses =
  set: ->
    adminMeetupIds = Meteor.settings.adminMeetupIds
    # Test for private course
    private_course =
      'languages':['EN']
      'courseName': 'Private course test case'
      'dockerImageTag': 'c3h3/learning-shogun:agilearning'
      'slides': 'http://nbviewer.ipython.org/github/unpingco/Python-for-Signal-Processing/blob/master/Confidence_Intervals.ipynb'
      'description': 'Taishin data team course'
      'video' : 'https://www.youtube.com/watch?v=3h_fx95i-bA'
      'imageURL': '/images/ipynb_lmnn1.png'
      'publicStatus': 'private'
      'bundleServer': ['[DockerServer]d1-agilearning','[DockerServer]d4-agilearning']

    if Courses.find({"publicStatus" : "private"}).count() is 0
      demoUser = Meteor.users.findOne({"services.meetup.id" : {$in: adminMeetupIds}})
      if demoUser
        private_course.creatorId = demoUser._id
        private_course.creatorAt = new Date
        courseId = Courses.insert private_course
        courseRoleGroupData =
          type: "course"
          id: courseId
          collection: "Courses"
          query:
            _id: courseId
        if Collections.RoleGroups.find(courseRoleGroupData).count() is 0
          courseRoleGroupData.createdAt = new Date
          courseRoleGroupId = Collections.RoleGroups.insert courseRoleGroupData
        else
          courseRoleGroupId = Collections.RoleGroups.findOne(courseRoleGroupData)._id
          courseRoleData =
            groupId: courseRoleGroupId
            userId: private_course.creatorId
            role: "admin"
            createdAt: new Date

          Collections.Roles.insert courseRoleData

      else
        private_course = Courses.findOne private_course
        courseId = private_course._id
      if private_course.publicStatus is "private"
        if Classrooms.find({courseId:courseId,publicStatus:"private"}).count() is 0
          publicClassroomDoc =
            name: "private Classroom"
            description: "Everyone is welcome!"
            creatorId: private_course.creatorId
            courseId: courseId
            publicStatus:"private"
            createAt: new Date
          classroomId = Classrooms.insert publicClassroomDoc

          ClassroomRoles.insert {classroomId:classroomId, userId: private_course.creatorId, role:"admin", isActive:true}
          Roles.addUsersToRoles(private_course.creatorId, "admin", "classroom_" + classroomId)


    # http://taiwanrusergroup.github.io/DSC2014Tutorial/
    # public course case
    demoCourses = [
      { "languages":["EN"], "courseName" : "Large Margin Nearest Neighbours", "dockerImageTag" : "c3h3/learning-shogun:agilearning", "slides" : "http://nbviewer.ipython.org/github/shogun-toolbox/shogun/blob/master/doc/ipython-notebooks/metric/LMNN.ipynb", "description" : "Fernando Iglesias talks about the GSoC-Project bringing Large Margin Nearest Neighbours into the Shogun Toolbox.", "video" : "https://www.youtube.com/watch?v=7pm91lCWyfE", "imageURL":"/images/ipynb_lmnn1.png"},

      { "languages":["ZH"], "courseName" : "R Basic (part1)", "dockerImageTag" : "c3h3/dsc2014tutorial:latest", "slides" : "http://dboyliao.github.io/RBasic_reveal/", "description" : "This is a tutorial series about R given by Taiwan R User Group in Data Science Conference 2014 in Taiwan", "video" : "https://www.youtube.com/watch?v=Ut55jPEm-yE"},
      { "languages":["ZH"], "courseName" : "R Basic (part2)", "dockerImageTag" : "c3h3/dsc2014tutorial:latest", "slides" : "http://dboyliao.github.io/RBasic_reveal/", "description" : "This is a tutorial series about R given by Taiwan R User Group in Data Science Conference 2014 in Taiwan", "video" : "https://www.youtube.com/watch?v=zCE4kEnQlkM"},
      { "languages":["ZH"], "courseName" : "R ETL (part1)", "dockerImageTag" : "c3h3/dsc2014tutorial:latest", "slides" : "http://ntuaha.github.io/R_ETL_LAB/", "description" : "This is a tutorial series about R given by Taiwan R User Group in Data Science Conference 2014 in Taiwan", "video" : "https://www.youtube.com/watch?v=JD1eDxxrur0", "imageURL":"/images/rstudio_dsc2014_etl2.png"},
      { "languages":["ZH"], "courseName" : "R ETL (part2)", "dockerImageTag" : "c3h3/dsc2014tutorial:latest", "slides" : "http://ntuaha.github.io/R_ETL_JIAWEI/", "description" : "This is a tutorial series about R given by Taiwan R User Group in Data Science Conference 2014 in Taiwan", "video" : "https://www.youtube.com/watch?v=aDIVtL2YrPE", "imageURL":"/images/rstudio_dsc2014_etl.png"},
      { "languages":["ZH"], "courseName" : "R Data Analysis", "dockerImageTag" : "c3h3/dsc2014tutorial:latest", "slides" : "http://whizzalan.github.io/R-tutorial_DataAnalysis/", "description" : "This is a tutorial series about R given by Taiwan R User Group in Data Science Conference 2014 in Taiwan", "video" : "https://www.youtube.com/watch?v=fcRtf4l1Xfc"},
      { "languages":["ZH"], "courseName" : "Visualization (part1)", "dockerImageTag" : "c3h3/dsc2014tutorial:latest", "slides" : "http://kuiming.github.io/graphics/index.html", "description" : "This is a tutorial series about R given by Taiwan R User Group in Data Science Conference 2014 in Taiwan", "video" : "https://www.youtube.com/watch?v=oksIFsSWXmM"},
      { "languages":["ZH"], "courseName" : "Visualization (part2)", "dockerImageTag" : "c3h3/dsc2014tutorial:latest", "slides" : "http://everdark.github.io/lecture_ggplot/lecture_ggplot2/index.html", "description" : "This is a tutorial series about R given by Taiwan R User Group in Data Science Conference 2014 in Taiwan", "video" : "https://www.youtube.com/watch?v=Da7RNqPWBZA"},
      { "languages":["ZH"], "courseName" : "Visualization (part3)", "dockerImageTag" : "c3h3/dsc2014tutorial:latest", "slides" : "http://rpubs.com/mansun_kuo/24330", "description" : "This is a tutorial series about R given by Taiwan R User Group in Data Science Conference 2014 in Taiwan", "video" : "https://www.youtube.com/watch?v=0KpLjx5wyJE"},


      { "languages":["EN"], "courseName" : "ml-for-hackers", "dockerImageTag" : "c3h3/ml-for-hackers:latest", "slides" : "http://shop.oreilly.com/product/0636920018483.do", "description" : "This is an learning environment used in Taiwan R Ladies to learn the material in the book 'Machine Learning for Hackers' in RLadies' monthly study group."},
      { "languages":["EN","ZH"], "courseName" : "RLadies Play Kaggle", "dockerImageTag" : "c3h3/rladies-hello-kaggle:latest", "slides" : "http://www.kaggle.com/c/titanic-gettingStarted/dails/new-getting-started-with-r", "description" : "This is an learning environment used in Taiwan R Ladies to learn how to play 'hello-world' datasets in kaggle with R."}


      # { "courseName" : "livehouse20141105", "dockerImageTag" : "c3h3/livehouse20141105", "slides" : "https://www.slidenow.com/slide/129/play", "description" : "https://event.livehouse.in/2014/combo8/"},
      # { "courseName" : "NCCU Crawler 201411", "dockerImageTag" : "c3h3/nccu-crawler-courses-201411", "slides" : "http://nbviewer.ipython.org/github/c3h3/NCCU-PyData-Courses-2013Spring/blob/master/Lecture1/crawler/Lecture2_WebCrawler.ipynb", "description" : ""},
      # { "courseName" : "TOSSUG DS 20141209 BigO", "dockerImageTag" : "dboyliao/docker-tossug", "slides" : "http://interactivepython.org/runestone/static/pythonds/index.html", "description" : ""},
    ]

    if ENV.isDev
      demoCourses.push
        languages: ["ZH"]
        courseName: "Try SFTP"
        dockerImageTag: "c3h3/sftp-share:UsePAM-no"
        slides: "http://www.kaggle.com/c/titanic-gettingStarted/dails/new-getting-started-with-r"
        description: "This is an learning environment used in Taiwan R Ladies to learn how to play 'hello-world' datasets in kaggle with R."
        imageURL: "/images/rstudio_dsc2014_etl2.png"


    for oneCourse in demoCourses
      if Courses.find(oneCourse).count() is 0
        demoUser = Meteor.users.findOne({"services.meetup.id" : {$in: adminMeetupIds}})

        if demoUser
          oneCourse.creatorId = demoUser._id
          oneCourse.creatorAt = new Date
          oneCourse.publicStatus = "public"

          courseId = Courses.insert oneCourse

          courseRoleGroupData =
            type: "course"
            id: courseId
            collection: "Courses"
            query:
              _id: courseId

          if Collections.RoleGroups.find(courseRoleGroupData).count() is 0
            courseRoleGroupData.createdAt = new Date
            courseRoleGroupId = Collections.RoleGroups.insert courseRoleGroupData
          else
            courseRoleGroupId = Collections.RoleGroups.findOne(courseRoleGroupData)._id

          courseRoleData =
            groupId: courseRoleGroupId
            userId: oneCourse.creatorId
            role: "admin"
            createdAt: new Date

          Collections.Roles.insert courseRoleData

          # Roles.addUsersToRoles(oneCourse.creatorId, "admin", "course_" + courseId)

      else
        oneCourse = Courses.findOne oneCourse
        courseId = oneCourse._id

      if oneCourse.publicStatus is "public"
        if Classrooms.find({courseId:courseId,publicStatus:"public"}).count() is 0
          publicClassroomDoc =
            name: "Public Classroom"
            description: "Everyone is welcome!"
            creatorId: oneCourse.creatorId
            courseId: courseId
            publicStatus:"public"
            createAt: new Date
          classroomId = Classrooms.insert publicClassroomDoc
          if db.chatrooms.find(classroomId: classroomId).count() is 0
            chatroomDoc =
              classroomId: classroomId
              name: "#{oneCourse.courseName} (#{classroomId[..5]}...)"
              creatorId: oneCourse.creatorId
              lastUpdate: new Date
            chatroomId = db.chatrooms.insert chatroomDoc
            creatorDoc = Meteor.users.findOne _id: oneCourse.creatorId
            db.chatMessages.insert
              chatroomId: chatroomId
              classroomId: classroomId
              userId: "system"
              userAvatar: "/images/noPhoto.png"
              userName: "System"
              createdAt: new Date
              type: "M"
              text: "Chatroom Created by #{creatorDoc.profile.name}"
            db.userJoinsChatroom.insert
              userId: oneCourse.creatorId
              userName: creatorDoc.profile.name
              chatroomId: chatroomId
              chatroomName: chatroomDoc.name

          ClassroomRoles.insert {classroomId:classroomId, userId: oneCourse.creatorId, role:"admin", isActive:true}
          Roles.addUsersToRoles(oneCourse.creatorId, "admin", "classroom_" + classroomId)
          #Roles.addUsersToRoles(demoUser, "teacher", "classroom_" + classroomId)

  forceClear: ->
    db.courses.remove {}
    db.classrooms.remove {}
    db.roles.remove {}
    db.roleGroups.remove {}
    db.chatrooms.remove {}
    db.chatMessages.remove {}
    db.userJoinsChatroom.remove {}

  reset: ->
    @forceClear()
    @set()


if ENV.isDev
  Fixture.Courses.reset()
