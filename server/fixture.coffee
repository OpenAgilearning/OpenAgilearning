
adminMeetupIds = [59393362]

@courseCreator = Meteor.users.find({"services.meetup.id" : {$in:adminMeetupIds}}).fetch().map (xx) -> xx._id

console.log "courseCreator = "
console.log courseCreator

if Chat.find({courseId:"ipynbBasic"}).count() is 0
  Chat.insert {userId:"systemTest",userName:"systemTest",courseId:"ipynbBasic", msg:"Hello, ipynbBasic", createAt:new Date}

if Chat.find({courseId:"rstudioBasic"}).count() is 0
  Chat.insert {userId:"systemTest",userName:"systemTest",courseId:"rstudioBasic", msg:"Hello, rstudioBasic", createAt:new Date}

if Chat.find({courseId:"wishFeatures"}).count() is 0
  Chat.insert {userId:"systemTest",userName:"systemTest",courseId:"wishFeatures", msg:"Hello, wishFeatures", createAt:new Date}


for oneCourse in Courses.find({}, {_id:1}).fetch()
  if Chat.find({courseId:oneCourse._id}).count() is 0
    Chat.insert {userId:"systemTest",userName:"systemTest",courseId:oneCourse._id, msg:"Hello!", createAt:new Date}


if DockerLimits.find().count() is 0
   
  dockerDefaultLimit = 
    _id: "defaultLimit"
    limit:
      Cpuset: "0,1"
      CpuShares: 512
      Memory:512000000
      
  DockerLimits.insert dockerDefaultLimit

if DockerTypes.find({_id:"ipynb"}).count() is 0
  DockerTypes.insert {_id:"ipynb", servicePort:"8888/tcp", env:["PASSWORD","IPYNB_PROFILE"]}

if DockerTypes.find({_id:"rstudio"}).count() is 0
  DockerTypes.insert {_id:"rstudio", servicePort:"8787/tcp", env:["USER", "PASSWORD"]}


if Meteor.users.find({"services.meetup.id" : {$in:adminMeetupIds}}).count() > 0
  defaultAdminUidArray = Meteor.users.find({"services.meetup.id" : {$in:adminMeetupIds}}).fetch().map (xx) -> xx._id
  filterArray = Roles.find({role:"admin"}).fetch().map (xx) -> xx._id
  filteredArray = defaultAdminUidArray.filter (xx) -> xx not in filterArray
  Roles.insert {userId:uid, role:"admin"} for uid in filteredArray

if DockerImages.find().count() is 0
  dockerDefaultImages = [
    {_id:"c3h3/oblas-py278-shogun-ipynb", type:"ipynb"},
    {_id:"c3h3/learning-shogun", type:"ipynb"},
    {_id:"rocker/rstudio", type:"rstudio"},
    {_id:"c3h3/ml-for-hackers", type:"rstudio"},
    {_id:"c3h3/dsc2014tutorial", type:"rstudio"},
    {_id:"c3h3/livehouse20141105", type:"ipynb"},
    {_id:"c3h3/rladies-hello-kaggle", type:"rstudio"},
  ]
  
  DockerImages.insert image for image in dockerDefaultImages
