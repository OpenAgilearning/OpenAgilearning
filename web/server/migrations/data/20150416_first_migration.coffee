
chatmessageHandler =
  TODO: (job)->
    console.log "[in chatmessageHandler TODO]"

    finishedAtKey = ["finished", job.status, "At"].join "_"

    defaultcallback = (err,id)->
      if err
        console.log err
      else
        console.log id

    #### DockerEnsureImages

    data =
      serversQuery:
        useIn: "production"
        user:
          type: "toC"
      ensureImageTagId: "[DockerImageTag]adrianliaw/jupyter-irkernel:agilearning"

    db.dockerEnsureImages.insert data, defaultcallback


    #### DockerImageTags

    ipynbHTTPPort =
      port: "8888"
      type: "http"

    data1 =
      tag: "adrianliaw/jupyter-irkernel:agilearning"
      servicePorts: [ipynbHTTPPort]
      envConfigTypeName: "ipynbBasic"
      pictures:["/images/jupyter-sq-text.svg"]
      isPublic: true
      dockerHubId: "[DockerHub]OfficialDockerHub"

    db.dockerImageTags.insert data1, defaultcallback

    db.dockerImageTags.update({tag: "c3h3/dsc2014tutorial:latest"}, {$set:videos:["/videos/R_DSC2014_demo.mp4"]}, defaultcallback)


    #### Insert new courses

    insertNewDocById = (collection, array)->
      for item in array
        if collection.find(_id:item._id).count() is 0
          collection.insert item, (err, id)->
            if err
              console.log err
            else
              console.log item

    insertNewDoc = (collection, array)->
      for item in array
        if collection.find(item).count() is 0
          collection.insert item, (err, id)->
            if err
              console.log err
            else
              console.log item

    newCourses = [
      { _id:"LMNN","languages":["EN"], "courseName" : "Large Margin Nearest Neighbours", "dockerImageTag" : "c3h3/learning-shogun:agilearning", "video":true, "slides":true, "description" : "Fernando Iglesias talks about the GSoC-Project bringing Large Margin Nearest Neighbours into the Shogun Toolbox." , "imageURL":"/images/ipynb_lmnn1.png"},

      { _id:"RBasic","languages":["ZH"], "courseName" : "R Basic", "dockerImageTag" : "c3h3/dsc2014tutorial:latest","video":true, "slides":true,  "description" : "This is a tutorial series about R given by Taiwan R User Group in Data Science Conference 2014 in Taiwan" },
      { _id:"RETL","languages":["ZH"], "courseName" : "R ETL", "dockerImageTag" : "c3h3/dsc2014tutorial:latest", "video":true, "slides":true, "description" : "This is a tutorial series about R given by Taiwan R User Group in Data Science Conference 2014 in Taiwan" , "imageURL":"/images/rstudio_dsc2014_etl2.png"},
      { _id:"R_Data_Analysis","languages":["ZH"], "courseName" : "R Data Analysis", "dockerImageTag" : "c3h3/dsc2014tutorial:latest", "video":true, "slides":true, "description" : "This is a tutorial series about R given by Taiwan R User Group in Data Science Conference 2014 in Taiwan" },
      { _id:"Visualization", "languages":["ZH"], "courseName" : "R Visualization", "dockerImageTag" : "c3h3/dsc2014tutorial:latest", "video":true, "slides":true, "description" : "This is a tutorial series about R given by Taiwan R User Group in Data Science Conference 2014 in Taiwan" },
      { _id:"ml-for-hackers", "languages":["EN"], "courseName" : "ml-for-hackers", "dockerImageTag" : "c3h3/ml-for-hackers:latest", "slides":true, "description" : "This is an learning environment used in Taiwan R Ladies to learn the material in the book 'Machine Learning for Hackers' in RLadies' monthly study group."},
      { _id: "playKaggle" , "languages":["EN","ZH"], "courseName" : "RLadies Play Kaggle", "dockerImageTag" : "c3h3/rladies-hello-kaggle:latest", "slides":true,  "description" : "This is an learning environment used in Taiwan R Ladies to learn how to play 'hello-world' datasets in kaggle with R."}
      { _id:"Chinese_Text_Mining", "languages":["ZH"], "courseName" : "Chinese Text Mining", "dockerImageTag" : "c3h3/r-nlp:sftp", "video":true, "slides":true, "description" : "Introduction to text mining with R (tmcn and Rwordseg)" },
      { _id: "jupyter", "languages":["EN","ZH"], "courseName" : "Play Jupyter", "dockerImageTag" : "adrianliaw/jupyter-irkernel:agilearning", "description" : "The language-agnostic parts of IPython are getting a new home in Project Jupyter.", "imageURL":"/images/jupyter-sq-text.svg"},
    ]

    insertNewDocById Courses, newCourses

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

    insertNewDocById db.slides, slides

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

    insertNewDoc db.courseJoinSlides, courseJoinSlides


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

    insertNewDocById db.videos, videos

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

    insertNewDoc db.courseJoinVideos, courseJoinVideos

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

    insertNewDoc db.courseJoinDockerImageTags, courseJoinDockerImageTags

    #### Move old classroom to new courses

    classroomMapper = (oldCourseQuery, newCourseId)->
      oldCourses = db.courses.find(oldCourseQuery).fetch()

      #### Since new courses and their classrooms have been accidently added to production

      newClassroom  = db.classrooms.findOne courseId:newCourseId

      oldCourseIds = _.map oldCourses, (doc)->doc._id

      console.log "oldCourseIds",oldCourseIds

      # Deal Role group here

      RoleGroups = Collections.RoleGroups.find({collection:"Courses","query._id":{$in:oldCourseIds}}).fetch()

      if RoleGroups.length >0
        RoleGroupIds = _.map RoleGroups, (doc)->doc._id

        Collections.Roles.remove groupId:$in:RoleGroupIds

      # Deal chatrooms and chat messages

      oldClassrooms = db.classrooms.find(courseId:$in:oldCourseIds).fetch()

      oldClassroomIds = _.map oldClassrooms, (doc)->doc._id

      newChatroom =  db.chatrooms.findOne classroomId:newClassroom._id

      selector = {classroomId:{$in:oldClassroomIds}, userId:$ne:"system"}
      modifier = {$set:{chatroomId:newChatroom._id, classroomId:newClassroom._id}}


      db.chatMessages.update selector, modifier, {multi:yes}
      # dont provide callback here, let it block
      # , (err, doc)->
      #   if err
      #     console.log err
      #   else
      #     console.log "update chatMessages success",doc

      db.chatMessages.remove {userId:"system"}

      oldChatrooms = db.chatrooms.find(classroomId:$in:oldClassroomIds).fetch()

      oldChatroomIds = _.map oldChatrooms, (doc)->doc._id

      # db.userJoinsChatroom.update {chatroomId:$in:oldChatroomIds}, {$set:{chatroomId:newChatroom._id, chatroomName:newChatroom.name}},{multi:yes}

      db.userJoinsChatroom.remove chatroomId:$in:oldChatroomIds

      db.chatrooms.remove _id:$in:oldChatroomIds

      db.classroomRoles.remove classroomId:$in:oldClassroomIds

      db.classrooms.remove courseId:$in:oldCourseIds, (err)->
        if err
          console.log "remove classrooms failed",err

      db.courses.remove _id:$in:oldCourseIds, (err)->
        if err
          console.log "remove course failed",err




    classroomMapper {courseName:$in:["R Basic (part1)", "R Basic (part2)"]}, "RBasic"
    classroomMapper {_id:"feNHkwuBGSzqTE6No"}, "LMNN"
    classroomMapper {courseName:$in:["R ETL (part1)", "R ETL (part2)"]}, "RETL"
    classroomMapper {_id:"wrWtgc8WdpbyACkSM"}, "R_Data_Analysis"
    classroomMapper {courseName:$in:["Visualization (part1)","Visualization (part2)", "Visualization (part3)"]}, "Visualization"
    classroomMapper {_id:"LELxbXWQC7it3j8ZL"}, "ml-for-hackers"
    classroomMapper {_id:"C6KjRXgYidYsty3gm"}, "playKaggle"
    classroomMapper {_id:"LHoC4F2uWnNauH86X"}, "Chinese_Text_Mining"


    updateData =
      status: "FINISHED"

    updateData[finishedAtKey] = new Date

    job.collection.update {_id:job.id}, {$set:updateData}



  FINISHED: (job)->
    console.log "[in chatmessageHandler FINISHED]"


Meteor.startup ->
  job_migrate_chatmessage = new Migration.Job "migrate chatMessages", chatmessageHandler
  job_migrate_chatmessage.handle