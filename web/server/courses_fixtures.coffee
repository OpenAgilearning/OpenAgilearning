
@Fixture.Courses =
  set: ->
    adminMeetupIds = Meteor.settings.adminMeetupIds

    # Test for private course
    # private_course =
    #   'languages':['EN']
    #   'courseName': 'Private course test case'
    #   'dockerImageTag': 'c3h3/learning-shogun:agilearning'
    #   'slides': 'http://nbviewer.ipython.org/github/unpingco/Python-for-Signal-Processing/blob/master/Confidence_Intervals.ipynb'
    #   'description': 'Taishin data team course'
    #   'video' : 'https://www.youtube.com/watch?v=3h_fx95i-bA'
    #   'imageURL': '/images/ipynb_lmnn1.png'
    #   'publicStatus': 'private'
    #   'bundleServer': ['[DockerServer]d4-agilearning']

    # if Courses.find({"publicStatus" : "private"}).count() is 0
    #   demoUser = Meteor.users.findOne({"services.meetup.id" : {$in: adminMeetupIds}})
    #   if demoUser
    #     private_course.creatorId = demoUser._id
    #     private_course.creatorAt = new Date
    #     courseId = Courses.insert private_course
    #     courseRoleGroupData =
    #       type: "course"
    #       id: courseId
    #       collection: "Courses"
    #       query:
    #         _id: courseId
    #     if Collections.RoleGroups.find(courseRoleGroupData).count() is 0
    #       courseRoleGroupData.createdAt = new Date
    #       courseRoleGroupId = Collections.RoleGroups.insert courseRoleGroupData
    #     else
    #       courseRoleGroupId = Collections.RoleGroups.findOne(courseRoleGroupData)._id
    #       courseRoleData =
    #         groupId: courseRoleGroupId
    #         userId: private_course.creatorId
    #         role: "admin"
    #         createdAt: new Date

    #       Collections.Roles.insert courseRoleData

    #   else
    #     private_course = Courses.findOne private_course
    #     courseId = private_course._id
    #   if private_course.publicStatus is "private"
    #     if Classrooms.find({courseId:courseId,publicStatus:"private"}).count() is 0
    #       publicClassroomDoc =
    #         name: "private Classroom"
    #         description: "Everyone is welcome!"
    #         creatorId: private_course.creatorId
    #         courseId: courseId
    #         publicStatus:"private"
    #         createAt: new Date
    #       classroomId = Classrooms.insert publicClassroomDoc

    #       ClassroomRoles.insert {classroomId:classroomId, userId: private_course.creatorId, role:"admin", isActive:true}
    #       Roles.addUsersToRoles(private_course.creatorId, "admin", "classroom_" + classroomId)


    # http://taiwanrusergroup.github.io/DSC2014Tutorial/
    # public course case
    demoCourses = [
      { _id:"LMNN","languages":["EN"], "courseName" : "Large Margin Nearest Neighbours", "dockerImageTag" : "c3h3/learning-shogun:agilearning",  "description" : "Fernando Iglesias talks about the GSoC-Project bringing Large Margin Nearest Neighbours into the Shogun Toolbox." , "imageURL":"/images/ipynb_lmnn1.png"},

      { _id:"RBasic","languages":["ZH"], "courseName" : "R Basic", "dockerImageTag" : "c3h3/dsc2014tutorial:latest",  "description" : "This is a tutorial series about R given by Taiwan R User Group in Data Science Conference 2014 in Taiwan" },
      { _id:"RETL","languages":["ZH"], "courseName" : "R ETL", "dockerImageTag" : "c3h3/dsc2014tutorial:latest",  "description" : "This is a tutorial series about R given by Taiwan R User Group in Data Science Conference 2014 in Taiwan" , "imageURL":"/images/rstudio_dsc2014_etl2.png"},
      { _id:"R_Data_Analysis","languages":["ZH"], "courseName" : "R Data Analysis", "dockerImageTag" : "c3h3/dsc2014tutorial:latest",  "description" : "This is a tutorial series about R given by Taiwan R User Group in Data Science Conference 2014 in Taiwan" },
      { _id:"Visualization", "languages":["ZH"], "courseName" : "Visualization (part1)", "dockerImageTag" : "c3h3/dsc2014tutorial:latest",  "description" : "This is a tutorial series about R given by Taiwan R User Group in Data Science Conference 2014 in Taiwan" },


      { _id:"ml-for-hackers", "languages":["EN"], "courseName" : "ml-for-hackers", "dockerImageTag" : "c3h3/ml-for-hackers:latest",  "description" : "This is an learning environment used in Taiwan R Ladies to learn the material in the book 'Machine Learning for Hackers' in RLadies' monthly study group."},
      { _id: "playKaggle" , "languages":["EN","ZH"], "courseName" : "RLadies Play Kaggle", "dockerImageTag" : "c3h3/rladies-hello-kaggle:latest",  "description" : "This is an learning environment used in Taiwan R Ladies to learn how to play 'hello-world' datasets in kaggle with R."}

      { _id:"Chinese_Text_Mining", "languages":["ZH"], "courseName" : "Chinese Text Mining", "dockerImageTag" : "c3h3/r-nlp:sftp",  "description" : "Introduction to text mining with R (tmcn and Rwordseg)" },
      { "languages":["EN","ZH"], "courseName" : "Play Jupyter", "dockerImageTag" : "adrianliaw/jupyter-irkernel:agilearning", "description" : "The language-agnostic parts of IPython are getting a new home in Project Jupyter.", "imageURL":"/images/jupyter-sq-text.svg"},

      # { "courseName" : "livehouse20141105", "dockerImageTag" : "c3h3/livehouse20141105", "slides" : "https://www.slidenow.com/slide/129/play", "description" : "https://event.livehouse.in/2014/combo8/"},
      # { "courseName" : "NCCU Crawler 201411", "dockerImageTag" : "c3h3/nccu-crawler-courses-201411", "slides" : "http://nbviewer.ipython.org/github/c3h3/NCCU-PyData-Courses-2013Spring/blob/master/Lecture1/crawler/Lecture2_WebCrawler.ipynb", "description" : ""},
      # { "courseName" : "TOSSUG DS 20141209 BigO", "dockerImageTag" : "dboyliao/docker-tossug", "slides" : "http://interactivepython.org/runestone/static/pythonds/index.html", "description" : ""},
    ]

    slides = [
      {_id: "shogun_LMNN", url:"http://nbviewer.ipython.org/github/shogun-toolbox/shogun/blob/master/doc/ipython-notebooks/metric/LMNN.ipynb"}
      {_id: "RBasic", url:"http://dboyliao.github.io/RBasic_reveal/"}
      {_id: "R_ETL_LAB", url:"http://ntuaha.github.io/R_ETL_LAB/"}
      {_id: "R_ETL_JIAWEI", url:"http://ntuaha.github.io/R_ETL_JIAWEI/"}
      {_id: "R_Data_Analysis", url:"http://whizzalan.github.io/R-tutorial_DataAnalysis/"}
      {_id: "Visualization_1", url:"http://kuiming.github.io/graphics/index.html"}
      {_id: "Visualization_2", url:"http://everdark.github.io/lecture_ggplot/lecture_ggplot2/index.html"}
      {_id: "Visualization_3", url:"http://rpubs.com/mansun_kuo/24330"}
      {_id: "ml-for-hackers", url:"http://shop.oreilly.com/product/0636920018483.do"}
      {_id: "playKaggle", url:"http://www.kaggle.com/c/titanic-gettingStarted/dails/new-getting-started-with-r"}
      {_id: "Chinese_Text_Mining", url:"http://rstudio-pubs-static.s3.amazonaws.com/12422_b2b48bb2da7942acaca5ace45bd8c60c.html"}

    ]

    courseJoinSlides = [
      {courseId: "LMNN", slideId: "shogun_LMNN"}
      {courseId: "RBasic", slideId: "RBasic"}
      {courseId: "RETL", slideId: "R_ETL_LAB"}
      {courseId: "RETL", slideId: "R_ETL_JIAWEI"}
      {courseId: "R_Data_Analysis", slideId: "R_Data_Analysis"}
      {courseId: "Visualization", slideId: "Visualization_1"}
      {courseId: "Visualization", slideId: "Visualization_2"}
      {courseId: "Visualization", slideId: "Visualization_3"}
      {courseId: "ml-for-hackers", slideId: "ml-for-hackers"}
      {courseId: "playKaggle", slideId: "playKaggle"}
      {courseId: "Chinese_Text_Mining", slideId: "Chinese_Text_Mining"}
    ]


    videos =[
      {_id:"LMNN",youtubeVideoId:"7pm91lCWyfE",ytTitle:"Large Margin Nearest Neighbours"}
      {_id:"RBasic1",youtubeVideoId:"Ut55jPEm-yE",ytTitle:"R Basic (part1)"}
      {_id:"RBasic2",youtubeVideoId:"zCE4kEnQlkM",ytTitle:"R Basic (part2)"}
      {_id:"R_ETL_1",youtubeVideoId:"JD1eDxxrur0",ytTitle:"R ETL (part1)"}
      {_id:"R_ETL_2",youtubeVideoId:"aDIVtL2YrPE",ytTitle:"R ETL (part2)"}
      {_id:"R_Data_Analysis",youtubeVideoId:"fcRtf4l1Xfc",ytTitle:"R Data Analysis"}
      {_id:"Visualization_1",youtubeVideoId:"oksIFsSWXmM",ytTitle:"Visualization (part1)"}
      {_id:"Visualization_2",youtubeVideoId:"Da7RNqPWBZA",ytTitle:"Visualization (part2)"}
      {_id:"Visualization_3",youtubeVideoId:"0KpLjx5wyJE",ytTitle:"Visualization (part3)"}
      {_id:"Chinese_Text_Mining",youtubeVideoId:"TcMao3r6jYY",ytTitle:"Chinese Text Mining"}

    ]

    courseJoinVideos = [
      {courseId:"LMNN", videoId:"LMNN"}
      {courseId:"RBasic", videoId:"RBasic1"}
      {courseId:"RBasic", videoId:"RBasic2"}
      {courseId:"RETL", videoId:"R_ETL_1"}
      {courseId:"RETL", videoId:"R_ETL_2"}
      {courseId:"R_Data_Analysis", videoId:"R_Data_Analysis"}
      {courseId:"Visualization", videoId:"Visualization_1"}
      {courseId:"Visualization", videoId:"Visualization_2"}
      {courseId:"Visualization", videoId:"Visualization_3"}
      {courseId:"Chinese_Text_Mining", videoId:"Chinese_Text_Mining"}
    ]

    if ENV.isDev
      demoCourses.push
        _id: "Try_SFTP"
        languages: ["ZH"]
        courseName: "Try SFTP"
        dockerImageTag: "c3h3/sftp-share:UsePAM-no"
        description: "This is an learning environment used in Taiwan R Ladies to learn how to play 'hello-world' datasets in kaggle with R."
        imageURL: "/images/rstudio_dsc2014_etl2.png"

      courseJoinSlides.push {courseId: "Try_SFTP", slideId: "playKaggle"}


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

    for item in slides
      if db.slides.find(item).count() is 0
        db.slides.insert item

    for item in courseJoinSlides
      if db.courseJoinSlides.find(item).count() is 0
        db.courseJoinSlides.insert item

    for item in videos
      if db.videos.find(item).count() is 0
        db.videos.insert item

    for item in courseJoinVideos
      if db.courseJoinVideos.find(item).count() is 0
        db.courseJoinVideos.insert item


  forceClear: ->
    db.courses.remove {}
    db.slides.remove {}
    db.courseJoinSlides.remove {}
    db.videos.remove {}
    db.courseJoinVideos.remove {}
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

Fixture.Courses.set()


