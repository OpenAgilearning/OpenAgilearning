
@rootURL = "0.0.0.0"

@courseCreator = ["W8ry5vcMNY2GhukHA","JESWJnrYeBvB35brZ"]


if Meteor.isClient
  

  Template.course.events
    "click .connectBt": (e, t)->
      e.stopPropagation()
      $("#docker").attr 'src', ""

      docker = Session.get "docker"
      url = "http://"+rootURL+":"+docker.port
      
      $("#docker").attr 'src', url


  Template.analyzer.events
    "click .connectBt": (e, t)->
      e.stopPropagation()
      $("#docker").attr 'src', ""
      
      docker = Session.get "docker"
      url = "http://"+rootURL+":"+docker.servicePort
      
      $("#docker").attr 'src', url
  
  Template.chatroom.events
    "change .postChatMsg": (e, t)->
      e.stopPropagation()

      courseId = Session.get "courseId"
      msg = $(".postChatMsg").val()

      $(".postChatMsg").val("")

      Meteor.call "postChat", courseId, msg, (err, data) ->
        if not err
          console.log "data = "
          console.log data

      
      



  Template.courses.events
    "click input.createBt": (e,t) ->
      e.stopPropagation()
      data =
        courseName: $("input.courseName").val()
        dockerImage: $("input.dockerImage").val()
        slides: $("input.slides").val()
        description: $("input.description").val()
      
      Meteor.call "createCourse", data



          
  # Template.shogunIndex.rendered = ->
  #   ipynb = Session.get "ipynb"
  #   console.log "ipynb = "
  #   console.log ipynb 
  #   console.log @data.ipynb()



if Meteor.isServer

  @basePort = 8000
  @topPort = 9000

  @getFreePort = ->
    ports = [basePort..topPort].map String
    filterPorts = DockerInstances.find().fetch().map (x)-> x.servicePort
    filteredPorts = ports.filter (x) -> x not in filterPorts
    filteredPorts[0]
    # FIXME: if there is no port !
    # if filteredPosts.length > 0
    #   filteredPosts[0]
    # else
    #   throw new Meteor.Error(1101, "No Remainder Ports")
    
  @allowImages = ["c3h3/oblas-py278-shogun-ipynb", "c3h3/learning-shogun", "rocker/rstudio", "c3h3/dsc2014tutorial","c3h3/livehouse20141105", "c3h3/ml-for-hackers"]
  

  Meteor.publish "dockers", ->
    userId = Meteor.userId()

    if not userId
      throw new Meteor.Error(401, "You need to login")
    
    Dockers.findOnd userId:userId 



  Meteor.publish "allDockerImages", ->
    # TODO: different roles can access different images ...
    DockerImages.find()
  
  Meteor.publish "allDockerTypes", ->
    DockerTypes.find()

  Meteor.publish "oneDockerTypes", (typeId) ->
    DockerTypes.find _id:typeId

  Meteor.publish "userDockers", ->
    userId = @userId()

    if not userId
      throw new Meteor.Error(401, "You need to login")
    
    Dockers.find userId:userId 
  

  Meteor.publish "userDockerInstances", ->
    userId = @userId

    if userId
      DockerInstances.find {userId:userId}

  Meteor.publish "userDockerTypeConfig", ->
    userId = @userId

    if userId
      DockerTypeConfig.find {userId:userId}

    
  Meteor.publish "allCourses", ->
    Courses.find()

  Meteor.publish "Chat", (courseId) -> 
    Chat.find({courseId:courseId}, {sort: {createAt:-1}, limit:20})


  Meteor.methods

    "getCourseDocker": (courseId) -> 
      user = Meteor.user()
      if not user
        throw new Meteor.Error(401, "You need to login")
      
      if Courses.find({_id:courseId}).count() is 0
        throw new Meteor.Error(1201, "Course doesn't exist")
      
      course = Courses.findOne _id:courseId

      Meteor.call "runDocker", course.dockerImage


    "removeDocker": (containerId)-> 
      user = Meteor.user()
      if not user
        throw new Meteor.Error(401, "You need to login")

      if DockerInstances.find({userId:user._id,containerId:containerId}).count() is 0
        throw new Meteor.Error(1101, "User is not the instance owner!")
      else
        Docker = Meteor.npmRequire "dockerode"
        docker = new Docker {socketPath: '/var/run/docker.sock'}
        
        Future = Npm.require 'fibers/future'
        
        stopFuture = new Future
        container = docker.getContainer containerId

        container.stop {}, (err,data)->
          console.log "[inside container.stop] data = "
          console.log data
          stopFuture.return data

        data = stopFuture.wait()
        console.log "[outside container.stop] data = "
        console.log data

        removeFuture = new Future
        container = docker.getContainer containerId

        container.remove {}, (err,data)->
          console.log "[inside container.stop] data = "
          console.log data
          removeFuture.return data

        data = removeFuture.wait()
        console.log "[outside container.stop] data = "
        console.log data


        Alldata = DockerInstances.find({userId:user._id,containerId:containerId}).fetch()
        DockerInstances.remove {userId:user._id,containerId:containerId}

        for x in Alldata
          x.remoteAt = new Date
          DockerInstancesLog.insert x

        


    "runDocker": (imageId)-> 

      user = Meteor.user()
      if not user
        throw new Meteor.Error(401, "You need to login")

      if DockerImages.find({_id:imageId}).count() is 0
        throw new Meteor.Error(1001, "Docker Image ID Error!")

      # TODO: different roles can access different images ...

      if DockerInstances.find({userId:user._id,imageId:imageId}).count() is 0
        
        dockerLimit = DockerLimits.findOne _id:"defaultLimit"
        
        console.log "[in createContainer] dockerLimit = "
        console.log dockerLimit

        Docker = Meteor.npmRequire "dockerode"
        docker = new Docker {socketPath: '/var/run/docker.sock'}
        fport = getFreePort()

        imageType = DockerImages.findOne({_id:imageId}).type 

        containerData = dockerLimit.limit
        containerData.Image = imageId

        if DockerTypeConfig.find({userId:user._id,typeId:imageType}).count() > 0
          config = DockerTypeConfig.findOne({userId:user._id,typeId:imageType})
          containerData.Env = config.env

        servicePort = DockerTypes.findOne({_id:imageType}).servicePort

        # console.log "[before1] containerData = "
        # console.log containerData
        # console.log typeof containerData
        
        # outPort = [{"HostPort": fport}]        

        # console.log "[before1] outPort = "
        # console.log outPort
        
        # console.log "[before1] servicePort = "
        # console.log servicePort
        # console.log typeof servicePort
        
        containerData.HostConfig = {}
        containerData.HostConfig.PortBindings = {}
        containerData.HostConfig.PortBindings[servicePort] = [{"HostPort": fport}] 


        console.log "[before2] containerData = "
        console.log containerData
          
        Future = Npm.require 'fibers/future'
        createFuture = new Future

        docker.createContainer containerData, (err, container) -> 
          console.log "[inside] container = "
          console.log container
          createFuture.return container

        container = createFuture.wait()
        console.log "[outside] contaner = "
        console.log container

        startFuture = new Future

        cont = docker.getContainer container.id
        cont.start {}, (err, data) -> 
          console.log "data = ",
          console.log data
          startFuture.return data

        data = startFuture.wait()

        dockerData = 
          userId: user._id
          imageId: containerData.Image
          containerInfo: containerData
          containerId: container.id
          servicePort: fport
          imageType:imageType
          createAt: new Date

        console.log "[outside] dockerData = "
        console.log dockerData

        DockerInstances.insert dockerData




    "setENV": (typeId, envData) ->
      user = Meteor.user()
      if not user
        throw new Meteor.Error(401, "You need to login")
      
      dockerType = DockerTypes.findOne _id:typeId
      typeFilter = dockerType.env
      filteredEnvData = Object.keys(envData).filter((x) -> x in typeFilter).filter((x) -> envData[x] isnt "").map((x)-> x+"="+envData[x])

      DockerTypeConfig.upsert {userId:user._id,typeId:typeId}, {$set:{env:filteredEnvData}}

    "postChat": (courseId, msg) ->
      user = Meteor.user()
      if not user
        throw new Meteor.Error(401, "You need to login")
      
      if not courseId
        throw new Meteor.Error(501, "Need courseId")

      if not msg
        throw new Meteor.Error(501, "Need msg")

      chatData = 
        userId: user._id
        userName: user.profile.name 
        courseId: courseId 
        msg: msg 
        createAt: new Date

      Chat.insert chatData

    "checkIsAdmin": ->
      user = Meteor.user()
      if not user
        throw new Meteor.Error(401, "You need to login")
    
      Roles.find({userId:user._id}).count() > 0

    "createCourse": (courseData) ->
      user = Meteor.user()

      if not user
        throw new Meteor.Error(401, "You need to login")
    
      courseData["creator"] = user._id
      courseData["creatorName"] = user.profile.name
      courseData["creatorAt"] = new Date

      Courses.insert courseData
    
    # "updateDockers": ->
    #   Docker = Meteor.npmRequire "dockerode"
    #   docker = new Docker {socketPath: '/var/run/docker.sock'}
    #   docker.listContainers all: false, (err, containers) ->  
    #     for c in containers
    #       console.log "c = "
    #       console.log c
    #       Dockers.update {name:c.Names[0].replace("/","")}, {$set:{containerId:c.Id}} 

    "createContainer": -> 
      user = Meteor.user()
      if not user
        throw new Meteor.Error(401, "You need to login")

      dockerLimit = DockerLimits.findOne _id:"defaultLimit"
      console.log "[in createContainer] dockerLimit = "
      console.log dockerLimit

      Docker = Meteor.npmRequire "dockerode"
      docker = new Docker {socketPath: '/var/run/docker.sock'}
      fport = "8080"

      containerData = 
        Cpuset: "0,1"
        CpuShares: 512
        Memory:512000000
        MemorySwap:-1
        Image: "c3h3/ml-for-hackers"
        name: "tryml"
        Env:["USER=c3h3","PASSWORD=c3h33211"]
        HostConfig:
          PortBindings:
            "8787/tcp":[{"HostPort": fport}] 

      
      Future = Npm.require 'fibers/future'
      createFuture = new Future

      docker.createContainer containerData, (err, container) -> 
        console.log "[inside] container = "
        console.log container
        createFuture.return container

      container = createFuture.wait()
      console.log "[outside] contaner = "
      console.log container

      dockerData = 
        userId: user._id
        baseImage: containerData.Image
        containerInfo: containerData
        containerId: container.id

      console.log "[outside] dockerData = "
      console.log dockerData

      TryDockers.insert dockerData

      cont = docker.getContainer container.id
      cont.start {}, (err, data) -> 
        console.log "data = ",
        console.log data
      


    # "getDockers": (baseImage) -> 
    #   user = Meteor.user()
    #   if not user
    #     throw new Meteor.Error(401, "You need to login")

    #   if baseImage not in allowImages
    #     throw new Meteor.Error(402, "Image is not allow")  

    #   Docker = Meteor.npmRequire "dockerode"
    #   docker = new Docker {socketPath: '/var/run/docker.sock'}
    #   fport = String(basePort + Dockers.find().count())

    #   if baseImage is "c3h3/oblas-py278-shogun-ipynb"
    #     imageTag = "ipynb"
    #   else if baseImage is "rocker/rstudio"
    #     imageTag = "rstudio"
    #   else if baseImage is "c3h3/learning-shogun"
    #     imageTag = "shogun"
    #   else if baseImage is "c3h3/dsc2014tutorial"
    #     imageTag = "dsc2014tutorial"
    #   else if baseImage is "c3h3/livehouse20141105"
    #     imageTag = "livehouse20141105"
    #   else if baseImage is "c3h3/ml-for-hackers"
    #     imageTag = "ml-for-hackers"

    #   dockerData = 
    #     userId: user._id
    #     port: fport
    #     baseImage: baseImage
    #     name:user._id+"_"+imageTag

    #   console.log "dockerData = "
    #   console.log dockerData

    #   dockerQuery = 
    #     userId:dockerData.userId
    #     baseImage:dockerData.baseImage

    #   if Dockers.find(dockerQuery).count() is 0
    #     console.log "create new docker instance"

    #     # Dockers.insert dockerData

    #     Future = Npm.require 'fibers/future'
    #     F1 = new Future

    #     docker.createContainer {Image: dockerData.baseImage, name:dockerData.name}, (err, container) ->

    #       console.log "[inside] container = "
    #       console.log container
                    

    #       if imageTag in ["ipynb","shogun","livehouse20141105"]
    #         portBind = 
    #           "8888/tcp": [{"HostPort": fport}] 
    #       else if imageTag in ["rstudio", "dsc2014tutorial", "ml-for-hackers"]
    #         portBind = 
    #           "8787/tcp": [{"HostPort": fport}] 
          
    #       F2 = new Future

    #       container.start {"PortBindings": portBind}, (err, data) => 
    #         console.log "data = "
    #         console.log data
    #         console.log "this = "
    #         console.log @
    #         F2.return {}

    #       F2.wait()
    #       F1.return container

    #     container = F1.wait()
    #     console.log "[outside] container = "
    #     console.log container
          
    #     dockerData.cid = container.id
    #     console.log "[outside] dockerData = "
    #     console.log dockerData

    #     # Dockers.insert dockerData

    #   else
    #     console.log "docker is created"

    #   Dockers.findOne dockerQuery

    # "getCourseDocker": (courseId) -> 
    #   user = Meteor.user()
    #   if not user
    #     throw new Meteor.Error(401, "You need to login")

    #   course = Courses.findOne _id:courseId


    #   Docker = Meteor.npmRequire "dockerode"
    #   docker = new Docker {socketPath: '/var/run/docker.sock'}
    #   fport = String(basePort + Dockers.find().count())

    #   baseImage = course.dockerImage
      

    #   if baseImage not in allowImages
    #     throw new Meteor.Error(402, "Image is not allow")  

    #   if baseImage is "c3h3/oblas-py278-shogun-ipynb"
    #     imageTag = "ipynb"
    #   else if baseImage is "rocker/rstudio"
    #     imageTag = "rstudio"
    #   else if baseImage is "c3h3/learning-shogun"
    #     imageTag = "shogun"
    #   else if baseImage is "c3h3/dsc2014tutorial"
    #     imageTag = "dsc2014tutorial"
    #   else if baseImage is "c3h3/livehouse20141105"
    #     imageTag = "livehouse20141105"
    #   else if baseImage is "c3h3/ml-for-hackers"
    #     imageTag = "ml-for-hackers"


    #   dockerData = 
    #     userId: user._id
    #     port: fport
    #     baseImage: baseImage
    #     name:user._id+"_"+imageTag

    #   console.log "dockerData = "
    #   console.log dockerData

    #   dockerQuery = 
    #     userId:dockerData.userId
    #     baseImage:dockerData.baseImage

    #   if Dockers.find(dockerQuery).count() is 0
    #     console.log "create new docker instance"

    #     # Dockers.insert dockerData

    #     # Future = Npm.require 'fibers/future'
    #     # myFuture = new Future

    #     docker.createContainer {Image: dockerData.baseImage, name:dockerData.name}, (err, container) ->
          
    #       console.log "[inside] container = "
    #       console.log container
    #       dockerData.cid = container.id

    #       console.log "[inside] dockerData = "
    #       console.log dockerData

    #       Dockers.insert dockerData


    #       if imageTag in ["ipynb","shogun", "livehouse20141105"]
    #         portBind = 
    #           "8888/tcp": [{"HostPort": fport}] 
    #       else if imageTag in ["rstudio", "dsc2014tutorial", "ml-for-hackers"]
    #         portBind = 
    #           "8787/tcp": [{"HostPort": fport}] 
          
            
    #       container.start {"PortBindings": portBind}, (err, data) -> 
    #         console.log "this = "
    #         console.log @

    #         console.log "data = "
    #         console.log data


    #     #   myFuture.return container

    #     # container = myFuture.wait()
    #     # console.log "[outside]container = "
    #     # console.log container


    #   else
    #     console.log "docker is created"

    #   Dockers.findOne dockerQuery

  Accounts.onCreateUser (options, user) ->

    userMeetupId = String(user.services.meetup.id)
    userMeetupToken = user.services.meetup.accessToken

    userProfileUrl = "https://api.meetup.com/2/member/" + userMeetupId + "?&sign=true&photo-host=public&access_token=" + userMeetupToken

    res = Meteor.http.call "GET", userProfileUrl
    
    resData = JSON.parse res.content
    
    user.services.meetup.apiData = {}
    _.extend user.services.meetup.apiData, resData 

    user.profile = {}

    user.profile.name = resData.name
    user.profile.hometown = resData.hometown
    user.profile.photo = resData.photo
    user.profile.link = resData.link
    user.profile.city = resData.city
    user.profile.country = resData.country
    user.profile.joined = resData.joined
    user.profile.topics = resData.topics
    user.profile.other_services = resData.other_services

    user
