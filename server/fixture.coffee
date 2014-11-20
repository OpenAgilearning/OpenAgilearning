if DockerLimits.find().count() is 0
   
  dockerDefaultLimit = 
    _id: "defaultLimit"
    limit:
      Cpuset: "0,1"
      CpuShares: 512
      Memory:512000000
      MemorySwap:-1
      
  DockerLimits.insert dockerDefaultLimit

if DockerType.find({_id:"ipynb"}).count() is 0
  DockerType.insert {_id:"ipynb", servicePort:"8888/tcp", env:["PASSWORD"]}

if DockerType.find({_id:"rstudio"}).count() is 0
  DockerType.insert {_id:"rstudio", servicePort:"8787/tcp", env:["PASSWORD", "USER"]}


if Roles.find().count() is 0
  Roles.insert {userId:uid, role:"admin"} for uid in courseCreator

if DockerImages.find().count() is 0
  dockerDefaultImages = [
    {tag:"c3h3/oblas-py278-shogun-ipynb", type:"ipynb"},
    {tag:"c3h3/learning-shogun", type:"ipynb"},
    {tag:"rocker/rstudio", type:"rstudio"},
    {tag:"c3h3/ml-for-hackers", type:"rstudio"},
    {tag:"c3h3/dsc2014tutorial", type:"rstudio"},
    {tag:"c3h3/livehouse20141105", type:"ipynb"},
  ]
  
  DockerImages.insert image for image in dockerDefaultImages
