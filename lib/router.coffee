Router.configure
  layoutTemplate: 'layout'
    

Meteor.startup ->
  Router.map -> 

    @route "index",
      path: "/"
      template: "index"
      data:
        rootURL:rootURL
        user: ->
          Meteor.user()


    @route "userStatus",
      path: "/userStatus/"
      template: "userStatus"
      data:
        rootURL:rootURL
        user: ->
          Meteor.user()
      waitOn: ->
        Meteor.call "checkIsAdmin", (err, res) ->
          if err
            Router.go "pleaseLogin"
          else
            if not res
              Router.go "index"


    @route "about",
      path: "about/"
      template: "about"
      data:
        rootURL:rootURL
        user: ->
          Meteor.user()


    @route "howToUse",
      path: "howToUse/"
      template: "howToUse"
      data:
        rootURL:rootURL
        user: ->
          Meteor.user()


    @route "wishFeatures",
      path: "wishFeatures/"
      template: "wishFeatures/"
      data:
        rootURL:rootURL
        user: ->
          Meteor.user()

        chats: ->
          Chat.find {}, {sort: {createAt:-1}}

      waitOn: ->
        Meteor.subscribe "Chat", "wishFeatures"
        Session.set "courseId", "wishFeatures"

      
    @route "dockers",
      path: "dockers/"
      template: "dockers"
      data:
        alertMessage: ->
          user = Meteor.user()
          if DockerTypes.find().count() > DockerTypeConfig.find({userId:user._id}).count()
            "please setting Docker Running Configures"
          else
            false

        rootURL:rootURL
        user: ->
          Meteor.user()

        dockerImages: ->
          runningImages = DockerInstances.find().fetch().map (x)-> x.imageId
          DockerImages.find({_id:{$nin:runningImages}})
        
        dockerInstances: ->
          DockerInstances.find()
        

        dockerTypes: ->
          user = Meteor.user()
          if Meteor.user() and DockerTypeConfig.find({userId:user._id}).count() > 0

            res = []
            for t in DockerTypes.find().fetch()
              if DockerTypeConfig.find({userId:user._id,typeId:t._id}).count() > 0
                t.currentSettings = DockerTypeConfig.findOne({userId:user._id,typeId:t._id}).env
              res.push t

            res 

          else
            DockerTypes.find()

      waitOn: ->
        userId = Meteor.userId()
        if not userId 
          Router.go "pleaseLogin"

        Meteor.subscribe "allDockerImages"
        Meteor.subscribe "allDockerTypes"
        Meteor.subscribe "userDockerInstances"
        Meteor.subscribe "userDockerTypeConfig"

        
    @route "dockerSetConfig",
      path: "dockerSetConfig/:dockerType"
      template: "dockerSetConfig"
      data: ->
        resData = 
          dockerType: =>
           @params.dockerType
          dockerTypes: ->
            DockerTypes.find()
          env: ->
            DockerTypes.findOne().env

        resData

      waitOn: ->
        userId = Meteor.userId()
        if not userId 
          Router.go "pleaseLogin"

        #Call by [docker.coffee] Template.dockerSetConfig.events "click .submitENV"
        Session.set "dockerType", @params.dockerType

        Meteor.subscribe "oneDockerTypes", @params.dockerType
        Meteor.subscribe "userDockerTypeConfig"


    @route "courses",
      path: "courses/"
      template: "courses"
      data:
        user: ->
          Meteor.user()
        isAdmin: ->
          uid = Meteor.userId()
          Roles.find({userId:uid,role:"admin"}).count()>0
        courses: ->
          Courses.find()

      waitOn: ->
        userId = Meteor.userId()
        if not userId 
          Router.go "pleaseLogin"
        
        Meteor.subscribe "allCourses"
        Meteor.subscribe "myRoles"


    @route "course",
      path: "course/:cid"
      template: "course"
      data: ->
        resData =       
          rootURL:rootURL
          user: ->
            Meteor.user()
          course: =>
            Courses.findOne _id: @params.cid

          docker: =>
            course = Courses.findOne _id:@params.cid
            Session.set "docker", DockerInstances.findOne({imageId:course.dockerImage})
            DockerInstances.findOne({imageId:course.dockerImage})

          chats: ->
            Chat.find {}, {sort: {createAt:-1}}

        resData

      waitOn: -> 
        userId = Meteor.userId()
        if not userId 
          Router.go "pleaseLogin"

        Meteor.subscribe "allCourses"
        Session.set "cid", @params.cid
        Session.set "courseId", @params.cid

        Meteor.call "getCourseDocker", @params.cid, (err, data)->
          if not err
            console.log "data = "
            console.log data
          else
            console.log "err = "
            console.log err
            Router.go "dockers"

        Meteor.subscribe "Chat", @params.cid
        Meteor.subscribe "userDockerInstances"


    @route "ipynb",
      path: "ipynb/"
      template: "analyzer"
      data:
        rootURL:rootURL
        baseImageUrl: "https://registry.hub.docker.com/u/c3h3/oblas-py278-shogun-ipynb/"
        name: "ipynb"

        user: ->
          Meteor.user()

        docker: ->
          courseId = Session.get "courseId"
          course = Courses.findOne _id:courseId
          Session.set "docker", DockerInstances.findOne({imageId:"c3h3/oblas-py278-shogun-ipynb"})
          DockerInstances.findOne({imageId:"c3h3/oblas-py278-shogun-ipynb"})

        chats: ->
          Chat.find {}, {sort: {createAt:-1}}


      waitOn: -> 
        userId = Meteor.userId()
        if not userId 
          Router.go "pleaseLogin"

        Meteor.call "runDocker", "c3h3/oblas-py278-shogun-ipynb", (err, data)->
          if not err
            console.log "data = "
            console.log data

        Session.set "courseId", "ipynbBasic"
        
        Meteor.subscribe "Chat", "ipynbBasic"
        Meteor.subscribe "userDockerInstances"


     @route "rstudio",
      path: "rstudio/"
      template: "analyzer"
      data:
        rootURL:rootURL
        baseImageUrl: "https://registry.hub.docker.com/u/rocker/rstudio/"
        name: "rstudio"
        user: ->
          Meteor.user()

        docker: ->
          courseId = Session.get "courseId"
          course = Courses.findOne _id:courseId
          Session.set "docker", DockerInstances.findOne({imageId:"rocker/rstudio"})
          DockerInstances.findOne({imageId:"rocker/rstudio"})
          
        chats: ->
          Chat.find {}, {sort: {createAt:-1}}


      waitOn: -> 
        userId = Meteor.userId()
        if not userId 
          Router.go "pleaseLogin"

        Meteor.call "runDocker", "rocker/rstudio", (err, data)->
          if not err
            console.log "data = "
            console.log data

        Session.set "courseId", "rstudioBasic"
        Meteor.subscribe "Chat", "rstudioBasic"
        Meteor.subscribe "userDockerInstances"


    @route "pleaseLogin",
      path: "pleaseLogin/"
      template: "pleaseLogin"
      waitOn: -> 
        userId = Meteor.userId()
        if userId 
          Router.go "index"

    @route "settings",
      path: "settings/profile"
      template: "settings"
      data:
        user: ->
          Meteor.user()
      waitOn: ->
        user = Meteor.user()
        if not user
          Router.go "pleaseLogin"