
@Fixture.Courses =
  set: ->
    adminMeetupIds = Meteor.settings.adminMeetupIds

    # http://taiwanrusergroup.github.io/DSC2014Tutorial/
    # public course case
    demoCourses = [
      { _id:"LMNN","languages":["EN"], "courseName" : "Large Margin Nearest Neighbours", "dockerImageTag" : "c3h3/learning-shogun:agilearning", "video":true, "slides":true, "description" : "Fernando Iglesias talks about the GSoC-Project bringing Large Margin Nearest Neighbours into the Shogun Toolbox." , "imageURL":"/images/ipynb_lmnn1.png"},

      { _id:"RBasic","languages":["ZH"], "courseName" : "R Basic", "dockerImageTag" : "c3h3/dsc2014tutorial:latest","video":true, "slides":true,  "description" : "This is a tutorial series about R given by Taiwan R User Group in Data Science Conference 2014 in Taiwan" },
      { _id:"RETL","languages":["ZH"], "courseName" : "R ETL", "dockerImageTag" : "c3h3/dsc2014tutorial:latest", "video":true, "slides":true, "description" : "This is a tutorial series about R given by Taiwan R User Group in Data Science Conference 2014 in Taiwan" , "imageURL":"/images/rstudio_dsc2014_etl2.png"},
      { _id:"R_Data_Analysis","languages":["ZH"], "courseName" : "R Data Analysis", "dockerImageTag" : "c3h3/dsc2014tutorial:latest", "video":true, "slides":true, "description" : "This is a tutorial series about R given by Taiwan R User Group in Data Science Conference 2014 in Taiwan" },
      { _id:"Visualization", "languages":["ZH"], "courseName" : "R Visualization", "dockerImageTag" : "c3h3/dsc2014tutorial:latest", "video":true, "slides":true, "description" : "This is a tutorial series about R given by Taiwan R User Group in Data Science Conference 2014 in Taiwan" },


      { _id:"ml-for-hackers", "languages":["EN"], "courseName" : "ml-for-hackers", "dockerImageTag" : "c3h3/ml-for-hackers:latest", "slides":true, "description" : "This is an learning environment used in Taiwan R Ladies to learn the material in the book 'Machine Learning for Hackers' in RLadies' monthly study group."},
      { _id: "playKaggle" , "languages":["EN","ZH"], "courseName" : "RLadies Play Kaggle", "dockerImageTag" : "c3h3/rladies-hello-kaggle:latest", "slides":true,  "description" : "This is an learning environment used in Taiwan R Ladies to learn how to play 'hello-world' datasets in kaggle with R."}

      { _id:"Chinese_Text_Mining", "languages":["ZH"], "courseName" : "Chinese Text Mining", "dockerImageTag" : "c3h3/r-nlp:sftp", "video":true, "slides":true, "description" : "Introduction to text mining with R (tmcn and Rwordseg)" },
      { _id: "jupyter", "languages":["EN","ZH"], "courseName" : "Play Jupyter", "dockerImageTag" : "adrianliaw/jupyter-irkernel:agilearning", "description" : "The language-agnostic parts of IPython are getting a new home in Project Jupyter.", "imageURL":"/images/jupyter-sq-text.svg"},
      { _id: "TaishinCrawler","languages":["EN","ZH"], "courseName" : "Taishin Crawler", "dockerImageTag" : "c3h3/dsc2014tutorial:latest", "description" : "This course is for Taishin Commercial bank internal trainning.", "imageURL":"http://i.imgur.com/KHtsRCF.png", "publicStatus":"semipublic"},


      # { "courseName" : "livehouse20141105", "dockerImageTag" : "c3h3/livehouse20141105", "slides" : "https://www.slidenow.com/slide/129/play", "description" : "https://event.livehouse.in/2014/combo8/"},
      # { "courseName" : "NCCU Crawler 201411", "dockerImageTag" : "c3h3/nccu-crawler-courses-201411", "slides" : "http://nbviewer.ipython.org/github/c3h3/NCCU-PyData-Courses-2013Spring/blob/master/Lecture1/crawler/Lecture2_WebCrawler.ipynb", "description" : ""},
      # { "courseName" : "TOSSUG DS 20141209 BigO", "dockerImageTag" : "dboyliao/docker-tossug", "slides" : "http://interactivepython.org/runestone/static/pythonds/index.html", "description" : ""},
    ]

    slides = [
      {_id: "shogun_LMNN", title: "shogun_LMNN", url:"http://nbviewer.ipython.org/github/shogun-toolbox/shogun/blob/master/doc/ipython-notebooks/metric/LMNN.ipynb"}
      {_id: "RBasic", title: "RBasic", url:"http://dboyliao.github.io/RBasic_reveal/"}
      {_id: "R_ETL_LAB", title: "R_ETL_LAB", url:"http://ntuaha.github.io/R_ETL_LAB/"}
      {_id: "R_ETL_JIAWEI", title: "R_ETL_JIAWEI", url:"http://ntuaha.github.io/R_ETL_JIAWEI/"}
      {_id: "R_Data_Analysis", title: "R_Data_Analysis", url:"http://whizzalan.github.io/R-tutorial_DataAnalysis/"}
      {_id: "Visualization_1", title: "Visualization_1", url:"http://kuiming.github.io/graphics/index.html"}
      {_id: "Visualization_2", title: "Visualization_2", url:"http://everdark.github.io/lecture_ggplot/lecture_ggplot2/index.html"}
      {_id: "Visualization_3", title: "Visualization_3", url:"http://rpubs.com/mansun_kuo/24330"}
      {_id: "ml-for-hackers", title: "ml-for-hackers", url:"http://shop.oreilly.com/product/0636920018483.do"}
      {_id: "playKaggle", title: "playKaggle", url:"http://www.kaggle.com/c/titanic-gettingStarted/dails/new-getting-started-with-r"}
      {_id: "Chinese_Text_Mining", title: "Chinese_Text_Mining", url:"http://rstudio-pubs-static.s3.amazonaws.com/12422_b2b48bb2da7942acaca5ace45bd8c60c.html"}

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
      {_id: "YTV_7pm91lCWyfE" ,youtubeVideoId:"7pm91lCWyfE",ytTitle:"Large Margin Nearest Neighbours"}
      {_id: "YTV_Ut55jPEm-yE" ,youtubeVideoId:"Ut55jPEm-yE",ytTitle:"R Basic (part1)"}
      {_id: "YTV_zCE4kEnQlkM" ,youtubeVideoId:"zCE4kEnQlkM",ytTitle:"R Basic (part2)"}
      {_id: "YTV_JD1eDxxrur0" ,youtubeVideoId:"JD1eDxxrur0",ytTitle:"R ETL (part1)"}
      {_id: "YTV_aDIVtL2YrPE" ,youtubeVideoId:"aDIVtL2YrPE",ytTitle:"R ETL (part2)"}
      {_id: "YTV_fcRtf4l1Xfc" ,youtubeVideoId:"fcRtf4l1Xfc",ytTitle:"R Data Analysis"}
      {_id: "YTV_oksIFsSWXmM" ,youtubeVideoId:"oksIFsSWXmM",ytTitle:"Visualization (part1)"}
      {_id: "YTV_Da7RNqPWBZA" ,youtubeVideoId:"Da7RNqPWBZA",ytTitle:"Visualization (part2)"}
      {_id: "YTV_0KpLjx5wyJE" ,youtubeVideoId:"0KpLjx5wyJE",ytTitle:"Visualization (part3)"}
      {_id: "YTV_TcMao3r6jYY" ,youtubeVideoId:"TcMao3r6jYY",ytTitle:"Chinese Text Mining"}

    ]

    courseJoinVideos = [
      {courseId:"LMNN", videoId:"YTV_7pm91lCWyfE"}
      {courseId:"RBasic", videoId:"YTV_Ut55jPEm-yE"}
      {courseId:"RBasic", videoId:"YTV_zCE4kEnQlkM"}
      {courseId:"RETL", videoId:"YTV_JD1eDxxrur0"}
      {courseId:"RETL", videoId:"YTV_aDIVtL2YrPE"}
      {courseId:"R_Data_Analysis", videoId:"YTV_fcRtf4l1Xfc"}
      {courseId:"Visualization", videoId:"YTV_oksIFsSWXmM"}
      {courseId:"Visualization", videoId:"YTV_Da7RNqPWBZA"}
      {courseId:"Visualization", videoId:"YTV_0KpLjx5wyJE"}
      {courseId:"Chinese_Text_Mining", videoId:"YTV_TcMao3r6jYY"}
    ]

    courseJoinDockerImageTags = [
      {courseId:"LMNN", tag:"c3h3/learning-shogun:agilearning"}
      {courseId:"RBasic", tag:"c3h3/dsc2014tutorial:latest"}
      {courseId:"RETL", tag:"c3h3/dsc2014tutorial:latest"}
      {courseId:"R_Data_Analysis", tag:"c3h3/dsc2014tutorial:latest"}
      {courseId:"Visualization", tag:"c3h3/dsc2014tutorial:latest"}
      {courseId:"ml-for-hackers",tag:"c3h3/ml-for-hackers:latest"}
      {courseId:"playKaggle",tag:"c3h3/rladies-hello-kaggle:latest"}
      {courseId:"Chinese_Text_Mining", tag:"c3h3/r-nlp:sftp"}
      {courseId:"jupyter",tag:"adrianliaw/jupyter-irkernel:agilearning"}

    ]

    if ENV.isDev

      courseJoinDockerImageTags.push {courseId:"RBasic",tag:"adrianliaw/jupyter-irkernel:agilearning"}
      courseJoinDockerImageTags.push {courseId:"RBasic",tag:"c3h3/r-nlp:sftp"}
      courseJoinDockerImageTags.push {courseId:"jupyter",tag:"c3h3/dsc2014tutorial:latest"}


    for oneCourse in demoCourses
      if Courses.find(oneCourse).count() is 0
        demoUser = Meteor.users.findOne({"services.meetup.id" : {$in: adminMeetupIds}})

        if demoUser
          oneCourse.creatorId = demoUser._id
          oneCourse.creatorAt = new Date
          #oneCourse.publicStatus = "public"

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

    for item in courseJoinDockerImageTags
      if db.courseJoinDockerImageTags.find(item).count() is 0
        db.courseJoinDockerImageTags.insert item

  forceClear: ->
    db.courses.remove {}
    db.slides.remove {}
    db.courseJoinSlides.remove {}
    db.videos.remove {}
    db.courseJoinVideos.remove {}
    db.courseJoinDockerImageTags.remove {}
    db.classrooms.remove {}
    db.roles.remove {}
    db.roleGroups.remove {}
    db.chatrooms.remove {}
    db.chatMessages.remove {}
    db.userJoinsChatroom.remove {}

  reset: ->
    @forceClear()
    @set()


# if ENV.isDev
#   Fixture.Courses.reset()
Meteor.startup ->
  Fixture.Courses.set()


