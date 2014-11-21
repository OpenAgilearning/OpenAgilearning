
@rootURL = "0.0.0.0"
@courseCreator = ["W8ry5vcMNY2GhukHA","JESWJnrYeBvB35brZ"]



# if Meteor.isServer

    # FIXME: if there is no port !
    # if filteredPosts.length > 0
    #   filteredPosts[0]
    # else
    #   throw new Meteor.Error(1101, "No Remainder Ports")
    
  # allowImages = ["c3h3/oblas-py278-shogun-ipynb", "c3h3/learning-shogun", "rocker/rstudio", "c3h3/dsc2014tutorial","c3h3/livehouse20141105", "c3h3/ml-for-hackers"]
  
    # "updateDockers": ->
    #   Docker = Meteor.npmRequire "dockerode"
    #   docker = new Docker {socketPath: '/var/run/docker.sock'}
    #   docker.listContainers all: false, (err, containers) ->  
    #     for c in containers
    #       console.log "c = "
    #       console.log c
    #       Dockers.update {name:c.Names[0].replace("/","")}, {$set:{containerId:c.Id}} 

    

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

