
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
    # {_id:"c3h3/oblas-py278-shogun-ipynb:last", type:"ipynb", pictures:["/images/ipynb_lmnn1.png"]},
    # {_id:"c3h3/learning-shogun:last", type:"ipynb", pictures:["/images/ipynb_lmnn2.png"]},
    {_id:"c3h3/learning-shogun:u1404-ocv",description: "This powerful enviroment provide opencv and shogun. You can use this enviroments to study machine learning.", type:"ipynb", pictures:["/images/ipynb_sudoku.png"],publicStatus:"public"},
    # {_id:"c3h3/livehouse20141105:last", type:"ipynb", pictures:["/images/ipynb_docker_default.png"]},
    # {_id: "c3h3/nccu-crawler-courses-201411:last",type : "ipynb", pictures:["/images/ipynb_docker_default.png" ]},
    # {_id: "dboyliao/docker-tossug:last", type : "ipynb", pictures:["/images/ipynb_tossug2.png" ]},
    # {_id:"rocker/rstudio:last", type:"rstudio", pictures:["/images/rstudio_docker_default.png"]},
    {_id:"c3h3/ml-for-hackers", type:"rstudio", pictures:["/images/rstudio_docker_default.png"]},
    {_id:"c3h3/rladies-hello-kaggle", type:"rstudio", pictures:["/images/rstudio_play_kaggle.png"]},
    {_id:"c3h3/dsc2014tutorial", description: "This enviroments was used at 2014 DSC at Taiwan workshop.", type:"rstudio", pictures:["/images/rstudio_docker_default.png"],publicStatus:"public"}
  ]

  DockerImages.insert image for image in dockerDefaultImages

# if DockerImages.find({_id:"c3h3/nccu-crawler-courses-201411",type:"ipynb"}).count() is 0
#   DockerImages.insert {_id:"c3h3/nccu-crawler-courses-201411",type:"ipynb"}

# if DockerImages.find({_id:"c3h3/learning-shogun:u1404-ocv",type:"ipynb"}).count() is 0
#   DockerImages.insert {_id:"c3h3/learning-shogun:u1404-ocv",type:"ipynb"}

# if DockerImages.find({_id:"dboyliao/docker-tossug",type:"ipynb"}).count() is 0
#   DockerImages.insert {_id:"dboyliao/docker-tossug",type:"ipynb"}



Classrooms.find().forEach (classroom) ->
  # console.log classroom
  createCondition = Chatrooms.find( classroomId: classroom._id ).count() is 0
  createCondition = createCondition and Courses.find( _id: classroom.courseId ).count() > 0
  if createCondition
    creator = Meteor.users.findOne(_id: classroom.creatorId)
    chatroom = Chatrooms.insert
      classroomId: classroom._id
      name: Courses.findOne( _id: classroom.courseId ).courseName + "(#{classroom._id[..5]}...)"
      creatorId: creator._id
      lastUpdate: new Date
    ChatMessages.insert
      chatroomId: chatroom
      classroomId: classroom._id
      userId: "system"
      userAvatar: "http://photos1.meetupstatic.com/img/noPhoto_50.png"
      userName: "System"
      createdAt: new Date
      type: "M"
      text: "Chatroom Created by #{creator.profile.name}"
    UserJoinsChatroom.insert
      userId: creator._id
      userName: creator.profile.name
      chatroomId: chatroom
      chatroomName: Chatrooms.findOne(_id: chatroom).name
