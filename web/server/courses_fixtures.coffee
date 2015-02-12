# http://taiwanrusergroup.github.io/DSC2014Tutorial/
demoCourses = [
  { "featured":true, "courseName" : "Large Margin Nearest Neighbours ", "dockerImage" : "c3h3/learning-shogun:u1404-ocv", "slides" : "http://nbviewer.ipython.org/github/shogun-toolbox/shogun/blob/master/doc/ipython-notebooks/metric/LMNN.ipynb", "description" : "Fernando Iglesias talks about the GSoC-Project bringing Large Margin Nearest Neighbours into the Shogun Toolbox.", "video" : "https://www.youtube.com/watch?v=7pm91lCWyfE", "imageURL":"/images/ipynb_lmnn1.png"},
  
  { "courseName" : "R Basic (part1)", "dockerImage" : "c3h3/dsc2014tutorial", "slides" : "http://dboyliao.github.io/RBasic_reveal/", "description" : "This is a tutorial series about R given by Taiwan R User Group in Data Science Conference 2014 in Taiwan", "video" : "https://www.youtube.com/watch?v=Ut55jPEm-yE"},
  { "courseName" : "R Basic (part2)", "dockerImage" : "c3h3/dsc2014tutorial", "slides" : "http://dboyliao.github.io/RBasic_reveal/", "description" : "This is a tutorial series about R given by Taiwan R User Group in Data Science Conference 2014 in Taiwan", "video" : "https://www.youtube.com/watch?v=zCE4kEnQlkM"},
  { "featured":true, "courseName" : "R ETL (part1)", "dockerImage" : "c3h3/dsc2014tutorial", "slides" : "http://ntuaha.github.io/R_ETL_LAB/", "description" : "This is a tutorial series about R given by Taiwan R User Group in Data Science Conference 2014 in Taiwan", "video" : "https://www.youtube.com/watch?v=JD1eDxxrur0", "imageURL":"/images/rstudio_dsc2014_etl2.png"},
  { "courseName" : "R ETL (part2)", "dockerImage" : "c3h3/dsc2014tutorial", "slides" : "http://ntuaha.github.io/R_ETL_JIAWEI/", "description" : "This is a tutorial series about R given by Taiwan R User Group in Data Science Conference 2014 in Taiwan", "video" : "https://www.youtube.com/watch?v=aDIVtL2YrPE", "imageURL":"/images/rstudio_dsc2014_etl.png"},
  { "courseName" : "R Data Analysis", "dockerImage" : "c3h3/dsc2014tutorial", "slides" : "http://whizzalan.github.io/R-tutorial_DataAnalysis/", "description" : "This is a tutorial series about R given by Taiwan R User Group in Data Science Conference 2014 in Taiwan", "video" : "https://www.youtube.com/watch?v=fcRtf4l1Xfc"},  
  { ,"courseName" : "Visualization (part1)", "dockerImage" : "c3h3/dsc2014tutorial", "slides" : "http://kuiming.github.io/graphics/index.html", "description" : "This is a tutorial series about R given by Taiwan R User Group in Data Science Conference 2014 in Taiwan", "video" : "https://www.youtube.com/watch?v=oksIFsSWXmM"},  
  { "courseName" : "Visualization (part2)", "dockerImage" : "c3h3/dsc2014tutorial", "slides" : "http://everdark.github.io/lecture_ggplot/lecture_ggplot2/index.html", "description" : "This is a tutorial series about R given by Taiwan R User Group in Data Science Conference 2014 in Taiwan", "video" : "https://www.youtube.com/watch?v=Da7RNqPWBZA"},  
  { "courseName" : "Visualization (part3)", "dockerImage" : "c3h3/dsc2014tutorial", "slides" : "http://rpubs.com/mansun_kuo/24330", "description" : "This is a tutorial series about R given by Taiwan R User Group in Data Science Conference 2014 in Taiwan", "video" : "https://www.youtube.com/watch?v=0KpLjx5wyJE"},  


  { "courseName" : "ml-for-hackers", "dockerImage" : "c3h3/ml-for-hackers", "slides" : "http://shop.oreilly.com/product/0636920018483.do", "description" : "This is an learning environment used in Taiwan R Ladies to learn the material in the book 'Machine Learning for Hackers' in RLadies' monthly study group."},
  { "featured":true,"courseName" : "RLadies Play Kaggle", "dockerImage" : "c3h3/rladies-hello-kaggle", "slides" : "http://www.kaggle.com/c/titanic-gettingStarted/dails/new-getting-started-with-r", "description" : "This is an learning environment used in Taiwan R Ladies to learn how to play 'hello-world' datasets in kaggle with R."}
  
  # { "courseName" : "livehouse20141105", "dockerImage" : "c3h3/livehouse20141105", "slides" : "https://www.slidenow.com/slide/129/play", "description" : "https://event.livehouse.in/2014/combo8/"},
  # { "courseName" : "NCCU Crawler 201411", "dockerImage" : "c3h3/nccu-crawler-courses-201411", "slides" : "http://nbviewer.ipython.org/github/c3h3/NCCU-PyData-Courses-2013Spring/blob/master/Lecture1/crawler/Lecture2_WebCrawler.ipynb", "description" : ""},
  # { "courseName" : "TOSSUG DS 20141209 BigO", "dockerImage" : "dboyliao/docker-tossug", "slides" : "http://interactivepython.org/runestone/static/pythonds/index.html", "description" : ""},
]

adminMeetupIds = Meteor.settings.public.adminMeetupIds

for oneCourse in demoCourses
  if Courses.find(oneCourse).count() is 0
    demoUser = Meteor.users.findOne({"services.meetup.id" : {$in: adminMeetupIds}})

    if demoUser
      oneCourse.creatorId = demoUser._id
      oneCourse.creatorAt = new Date
      oneCourse.publicStatus = "public"

      courseId = Courses.insert oneCourse
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

      ClassroomRoles.insert {classroomId:classroomId, userId: oneCourse.creatorId, role:"admin", isActive:true}
      Roles.addUsersToRoles(demoUser, "admin", "classroom_" + classroomId)
      #Roles.addUsersToRoles(demoUser, "teacher", "classroom_" + classroomId)

