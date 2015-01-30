
@rootURL = Meteor.settings.public.rootURL

if Meteor.isClient
  @UserConnections = new Mongo.Collection("user_status_sessions")

  relativeTime = (timeAgo) ->
    diff = moment.utc(TimeSync.serverTime() - timeAgo)
    time = diff.format("H:mm:ss")
    days = +diff.format("DDD") - 1
    ago = (if days then days + "d " else "") + time
    return ago + " ago"

  Handlebars.registerHelper "userStatus", UserStatus
  Handlebars.registerHelper "localeTime", (date) -> date?.toLocaleString()
  Handlebars.registerHelper "relativeTime", relativeTime

  Template.login.helpers
    loggedIn: -> Meteor.userId()

  Template.status.events =
    "submit form.start-monitor": (e, tmpl) ->
      e.preventDefault()
      UserStatus.startMonitor
        threshold: tmpl.find("input[name=threshold]").valueAsNumber
        interval: tmpl.find("input[name=interval]").valueAsNumber
        idleOnBlur: tmpl.find("select[name=idleOnBlur]").value is "true"

    "click .stop-monitor": -> UserStatus.stopMonitor()
    "click .resync": -> TimeSync.resync()

  Template.status.helpers
    lastActivity: ->
      lastActivity = @lastActivity()
      if lastActivity?
        return relativeTime lastActivity
      else
        return "undefined"

  Template.status.helpers
    serverTime: -> new Date(TimeSync.serverTime()).toLocaleString()
    serverOffset: TimeSync.serverOffset
    serverRTT: TimeSync.roundTripTime

    # Falsy values aren't rendered in templates, so let's render them ourself
    isIdleText: -> @isIdle() || "false"
    isMonitoringText: -> @isMonitoring() || "false"

  Template.serverStatus.helpers
    anonymous: -> UserConnections.find(userId: $exists: false)
    users: -> Meteor.users.find()
    userClass: -> if @status?.idle then "warning" else "success"
    connections = -> UserConnections.find(userId: @_id)

  Template.serverConnection.helpers
    connectionClass: -> if @idle then "warning" else "success"
    loginTime: ->
      return unless @loginTime?
      new Date(@loginTime).toLocaleString()

  Template.login.events =
    "submit form": (e, tmpl) ->
      e.preventDefault()
      input = tmpl.find("input[name=username]")
      input.blur()
      Meteor.insecureUserLogin input.value, (err, res) -> console.log(err) if err

  # Start monitor as soon as we got a signal, captain!
  Deps.autorun (c) ->
    try # May be an error if time is not synced
      UserStatus.startMonitor
        threshold: 30000
        idleOnBlur: true
      c.stop()

if Meteor.isServer
  # Try setting this so it works on meteor.com
  # (https://github.com/oortcloud/unofficial-meteor-faq)
  process.env.HTTP_FORWARDED_COUNT = 1

  Meteor.publish null, ->
    [
      Meteor.users.find { "status.online": true }, # online users only
        fields:
          status: 1,
          username: 1
      UserStatus.connections.find()
    ]


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

