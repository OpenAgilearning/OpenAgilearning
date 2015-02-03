
adminMeetupIds = [59393362, 173080282, 129433302,114542292]
courseManagerIds = [183363484]

# if Chat.find({courseId:"ipynbBasic"}).count() is 0
#   Chat.insert {userId:"systemTest",userName:"systemTest",courseId:"ipynbBasic", msg:"Hello, ipynbBasic", createAt:new Date}

# if Chat.find({courseId:"rstudioBasic"}).count() is 0
#   Chat.insert {userId:"systemTest",userName:"systemTest",courseId:"rstudioBasic", msg:"Hello, rstudioBasic", createAt:new Date}

# if Chat.find({courseId:"wishFeatures"}).count() is 0
#   Chat.insert {userId:"systemTest",userName:"systemTest",courseId:"wishFeatures", msg:"Hello, wishFeatures", createAt:new Date}


# for oneCourse in Courses.find({}, {_id:1}).fetch()
#   if Chat.find({courseId:oneCourse._id}).count() is 0
#     Chat.insert {userId:"systemTest",userName:"systemTest",courseId:oneCourse._id, msg:"Hello!", createAt:new Date}


if DockerLimits.find().count() is 0

  dockerDefaultLimit =
    _id: "defaultLimit"
    limit:
      Cpuset: "0"
      CpuShares: 256
      Memory:512000000

  DockerLimits.insert dockerDefaultLimit

if DockerTypes.find({_id:"ipynb"}).count() is 0
  DockerTypes.insert {_id:"ipynb", servicePort:"8888/tcp", env:[{name:"PASSWORD",mustHave:true},{name:"IPYNB_PROFILE",limitValues:["","default","c3h3-dark"]}]}

if DockerTypes.find({_id:"rstudio"}).count() is 0
  DockerTypes.insert {_id:"rstudio", servicePort:"8787/tcp", env:[{name:"USER",mustHave:true}, {name:"PASSWORD",mustHave:true}]}


if Meteor.users.find({"services.meetup.id" : {$in:adminMeetupIds}}).count() > 0
  defaultAdminUidArray = Meteor.users.find({"services.meetup.id" : {$in:adminMeetupIds}}).fetch().map (xx)-> xx._id
  defaultCourseManagerUidArray = Meteor.users.find({"services.meetup.id" : {$in:courseManagerIds}}).fetch().map (xx)-> xx._id

  console.log "defaultAdminUidArray = "
  console.log defaultAdminUidArray

  Roles.addUsersToRoles(defaultAdminUidArray, 'admin', "system")
  # Roles.addUsersToRoles(defaultCourseManagerUidArray, "admin", "courses")
  # filterArray = Roles.find({role:"admin"}).fetch().map (xx) -> xx.userId  
  # console.log "filterArray = "
  # console.log filterArray

  # filteredArray = defaultAdminUidArray.filter (xx) -> xx not in filterArray
  # console.log "filteredArray = "
  # console.log filteredArray

  # Roles.insert {userId:uid, role:"admin"} for uid in filteredArray


if DockerImages.find().count() is 0
  dockerDefaultImages = [
    {_id:"c3h3/oblas-py278-shogun-ipynb", type:"ipynb", imageURL:"/images/ipynb_lmnn1.png"},
    {_id:"c3h3/learning-shogun", type:"ipynb", imageURL:"/images/ipynb_lmnn2.png"},
    {_id:"c3h3/learning-shogun:u1404-ocv", type:"ipynb", imageURL:"/images/ipynb_sudoku.png"},
    {_id:"c3h3/livehouse20141105", type:"ipynb", imageURL:"/images/ipynb_docker_default.png"},
    {_id: "c3h3/nccu-crawler-courses-201411", type : "ipynb", imageURL:"/images/ipynb_docker_default.png" },
    {_id: "dboyliao/docker-tossug", type : "ipynb", imageURL:"/images/ipynb_tossug2.png" },
    {_id:"rocker/rstudio", type:"rstudio", imageURL:"/images/rstudio_docker_default.png"},
    {_id:"c3h3/ml-for-hackers", type:"rstudio", imageURL:"/images/rstudio_docker_default.png"},
    {_id:"c3h3/dsc2014tutorial", type:"rstudio", imageURL:"/images/rstudio_docker_default.png"},
    {_id:"c3h3/rladies-hello-kaggle", type:"rstudio", imageURL:"/images/rstudio_play_kaggle.png"}
  ]

  DockerImages.insert image for image in dockerDefaultImages

if DockerImages.find({_id:"c3h3/nccu-crawler-courses-201411",type:"ipynb"}).count() is 0
  DockerImages.insert {_id:"c3h3/nccu-crawler-courses-201411",type:"ipynb"}

if DockerImages.find({_id:"c3h3/learning-shogun:u1404-ocv",type:"ipynb"}).count() is 0
  DockerImages.insert {_id:"c3h3/learning-shogun:u1404-ocv",type:"ipynb"}

if DockerImages.find({_id:"dboyliao/docker-tossug",type:"ipynb"}).count() is 0
  DockerImages.insert {_id:"dboyliao/docker-tossug",type:"ipynb"}

demoCourses = [
  { "courseName" : "R Basic", "dockerImage" : "c3h3/dsc2014tutorial", "slides" : "http://dboyliao.github.io/dockerhack2014_RBasic/#1", "description" : "This is a tutorial series about R given by Taiwan R User Group in Data Science Conference 2014 in Taiwan", "video" : "https://www.youtube.com/watch?v=Ut55jPEm-yE"},
  { "courseName" : "Large Margin Nearest Neighbours ", "dockerImage" : "c3h3/learning-shogun:u1404-ocv", "slides" : "http://nbviewer.ipython.org/github/shogun-toolbox/shogun/blob/master/doc/ipython-notebooks/metric/LMNN.ipynb", "description" : "Fernando Iglesias talks about the GSoC-Project bringing Large Margin Nearest Neighbours into the Shogun Toolbox.", "video" : "https://www.youtube.com/watch?v=7pm91lCWyfE", "imageURL":"/images/ipynb_lmnn1.png"}
  # { "courseName" : "livehouse20141105", "dockerImage" : "c3h3/livehouse20141105", "slides" : "https://www.slidenow.com/slide/129/play", "description" : "https://event.livehouse.in/2014/combo8/"},
  # { "courseName" : "ml-for-hackers", "dockerImage" : "c3h3/ml-for-hackers", "slides" : "http://shop.oreilly.com/product/0636920018483.do", "description" : ""},
  # { "courseName" : "RLadies Play Kaggle", "dockerImage" : "c3h3/rladies-hello-kaggle", "slides" : "http://www.kaggle.com/c/titanic-gettingStarted/dails/new-getting-started-with-r", "description" : ""},
  # { "courseName" : "NCCU Crawler 201411", "dockerImage" : "c3h3/nccu-crawler-courses-201411", "slides" : "http://nbviewer.ipython.org/github/c3h3/NCCU-PyData-Courses-2013Spring/blob/master/Lecture1/crawler/Lecture2_WebCrawler.ipynb", "description" : ""},
  # { "courseName" : "TOSSUG DS 20141209 BigO", "dockerImage" : "dboyliao/docker-tossug", "slides" : "http://interactivepython.org/runestone/static/pythonds/index.html", "description" : ""},  
]

for oneCourse in demoCourses
  if Courses.find(oneCourse).count() is 0
    demoUser = Meteor.users.findOne({"services.meetup.id" : {$in: adminMeetupIds}})

    if demoUser
      oneCourse.creatorId = demoUser._id
      oneCourse.creatorAt = new Date
      oneCourse.publicStatus = "public"

      courseId = Courses.insert oneCourse
      
      if oneCourse.publicStatus is "public"
        if Classrooms.find({courseId:courseId,publicStatus:"public"}).count() is 0
          publicClassroomDoc = 
            creatorId: oneCourse.creatorId
            courseId: courseId
            publicStatus:"public"
            createAt: new Date
          classroomId = Classrooms.insert publicClassroomDoc

          ClassroomRoles.insert {classroomId:classroomId, userId: oneCourse.creatorId, role:"admin", isActive:true}
          Roles.addUsersToRoles(demoUser, "admin", "classroom_" + classroomId)
          #Roles.addUsersToRoles(demoUser, "teacher", "classroom_" + classroomId)


if Meteor.settings.public.DOCKER_CERT_PATH isnt ""
  DOCKER_CERT_PATH = Meteor.settings.public.DOCKER_CERT_PATH
else
  if process.env["DOCKER_CERT_PATH"]
    DOCKER_CERT_PATH = process.env["DOCKER_CERT_PATH"]
  else
    DOCKER_CERT_PATH = ""


defaultLocalDockerServerData =
  name:"localhost"
  connect:
    socketPath: '/var/run/docker.sock'
  

defaultDockerServerData =
  name:"d3-agilearning"
  connect:
    protocol: 'https'
    host:"130.211.244.66"
    port:2376
  security:
    caPath: DOCKER_CERT_PATH + 'ca.pem'
    certPath: DOCKER_CERT_PATH + 'cert.pem'
    keyPath: DOCKER_CERT_PATH + 'key.pem'
  
defaultDockerServerData2 =
  name:"d1-agilearning"
  connect:
    protocol: 'https'
    host:"107.167.180.118"
    port:2376
  security:
    caPath: DOCKER_CERT_PATH + 'ca.pem'
    certPath: DOCKER_CERT_PATH + 'cert.pem'
    keyPath: DOCKER_CERT_PATH + 'key.pem'
  

defaultDockerServers = [defaultLocalDockerServerData, defaultDockerServerData,defaultDockerServerData2] 

for dockerServerData in defaultDockerServers
  if DockerServers.find(dockerServerData).count() is 0
    dockerServerData.active = false
    dockerServerData.createAt = new Date
    DockerServers.insert dockerServerData

  