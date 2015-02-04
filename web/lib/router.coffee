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
        showAdminPage: ->
          userId = Meteor.userId()
          Roles.userIsInRole(userId,"admin","system") or Roles.userIsInRole(userId,"admin","dockers")

      waitOn: ->
          Meteor.subscribe "DevMileStone"
          Meteor.subscribe "WantedFeature"
          Meteor.subscribe "allPublicCourses"
          Meteor.subscribe "allPublicCoursesDockerImages"

    @route "profile",
      path: "profile/"
      template: "profile"
      data:
        rootURL:rootURL
        user: ->
          Meteor.user()
        showAdminPage: ->
          userId = Meteor.userId()
          Roles.userIsInRole(userId,"admin","system") or Roles.userIsInRole(userId,"admin","dockers")

      waitOn: ->
        user = Meteor.user()
        if not user
          Router.go "pleaseLogin"
        Meteor.subscribe "userEnvUserConfigs"


    @route "course",
      path: "course/:courseId"
      template: "course"
      data: ->
        resData =
          rootURL:rootURL
          user: ->
            Meteor.user()
          showAdminPage: ->
            userId = Meteor.userId()
            Roles.userIsInRole(userId,"admin","system") or Roles.userIsInRole(userId,"admin","dockers")

          course: =>
            Courses.findOne _id: @params.courseId

        resData

      waitOn: ->
        userId = Meteor.userId()
        if not userId
          Router.go "pleaseLogin"

        Meteor.subscribe "course", @params.courseId
        Meteor.subscribe "allPublicClassrooms", @params.courseId
        Meteor.subscribe "allPublicClassroomRoles", @params.courseId
        Meteor.subscribe "courseDockerImages", @params.courseId


    @route "classroom",
      path: "classroom/:classroomId"
      template: "classroom"
      data: ->
        resData =
          rootURL:rootURL
          user: ->
            Meteor.user()
          showAdminPage: ->
            userId = Meteor.userId()
            Roles.userIsInRole(userId,"admin","system") or Roles.userIsInRole(userId,"admin","dockers")

          course: =>
            Courses.findOne()

          classroomAndId: =>
            "classroom_" + @params.classroomId

          docker: =>
            classroomDoc = Classrooms.findOne _id:@params.classroomId
            courseData = Courses.findOne _id:classroomDoc.courseId
            imageTag = courseData.dockerImage
            if imageTag.split(":").length is 1
              fullImageTag = imageTag + ":latest"
            else
              fullImageTag = imageTag

            DockerInstances.findOne({imageTag:fullImageTag})

          classroomId: @params.classroomId

          needToSetEnvConfigs: =>
            userId = Meteor.userId()
            # classroomDoc = Classrooms.findOne _id:@params.classroomId
            # courseData = Courses.findOne _id:classroomDoc.courseId
            # imageTag = courseData.dockerImage
            
            # configTypeId = DockerImages.findOne({_id:imageTag}).type
            
            configTypeId = getEnvConfigTypeIdFromClassroomId(@params.classroomId)
            EnvUserConfigs.find({userId:userId, configTypeId:configTypeId}).count() is 0            

          envConfigsSchema: =>
            userId = Meteor.userId()
            # classroomDoc = Classrooms.findOne _id:@params.classroomId
            # courseData = Courses.findOne _id:classroomDoc.courseId
            # imageTag = courseData.dockerImage
            
            # configTypeId = DockerImages.findOne({_id:imageTag}).type
            
            configTypeId = getEnvConfigTypeIdFromClassroomId(@params.classroomId)
            
            envConfigsData = EnvConfigTypes.findOne _id:configTypeId
            schemaSettings = {}

            envConfigsData.configs.envs.map (env)->
              schemaSettings[env.name] = {type: String}
                
              if not env.mustHave
                schemaSettings[env.name].optional = true

              if env.limitValues
                schemaSettings[env.name].allowedValues = env.limitValues

            new SimpleSchema schemaSettings

          # chats: ->
          #   Chat.find {}, {sort: {createAt:-1}}
          # quickFormData: ->
          #   courseId:@params.cid
        resData

      waitOn: ->
        userId = Meteor.userId()
        if not userId
          Router.go "pleaseLogin"

        classroomAndId = "classroom_" + @params.classroomId
        redirectToIndex = not Roles.userIsInRole(userId,"admin",classroomAndId)
        redirectToIndex = redirectToIndex  and not Roles.userIsInRole(userId,"teacher",classroomAndId)
        redirectToIndex = redirectToIndex  and not Roles.userIsInRole(userId,"student",classroomAndId)

        if redirectToIndex
          Router.go "index"          

        Meteor.subscribe "allPublicEnvConfigTypes"
        Meteor.subscribe "userDockerInstances"
        Meteor.subscribe "userEnvUserConfigs"
        Meteor.subscribe "classroom", @params.classroomId
        Meteor.subscribe "classroomCourse", @params.classroomId
        Meteor.subscribe "classroomDockerImages", @params.classroomId
        

        Meteor.call "getClassroomDocker", @params.classroomId, (err, data)->
          if not err
            console.log "data = "
            console.log data
          else
            console.log "err = "
            console.log err
            Router.go "dockers"

        # Meteor.subscribe "Chat", @params.cid

    @route "environments",
      path: "environments/"
      template: "environments"
      data: ->
        resData =
          rootURL:rootURL
          user: ->
            Meteor.user()
          showAdminPage: ->
            userId = Meteor.userId()
            Roles.userIsInRole(userId,"admin","system") or Roles.userIsInRole(userId,"admin","dockers")

      waitOn: ->
        userId = Meteor.userId()
        if not userId
          Router.go "pleaseLogin"

        #TODO: no password! no envs!
        Meteor.subscribe "allPublicEnvs"
    


    @route "learningResources",
      path: "learningResources/"
      template: "learningResourcesPage"
      data:
        rootURL:rootURL
        user: ->
          Meteor.user()
        showAdminPage: ->
          userId = Meteor.userId()
          Roles.userIsInRole(userId,"admin","system") or Roles.userIsInRole(userId,"admin","dockers")

        resourceNodes: ->
          LearningResources.find()


      waitOn: ->
        userId = Meteor.userId()
        if not userId
          Router.go "pleaseLogin"

        else
          if Roles.userIsInRole(userId,"admin","system")
            Meteor.subscribe "queryLearningResources"

    @route "admin",
      path: "admin/"
      template: "AdminPage"
      data:
        rootURL:rootURL
        user: ->
          Meteor.user()
        showAdminPage: ->
          userId = Meteor.userId()
          Roles.userIsInRole(userId,"admin","system") or Roles.userIsInRole(userId,"admin","dockers")

        testEnvTypeData: ->
          EnvTypes.findOne()

        uniqueDockerImageTagsForAutoForm: ->
          values = _.uniq(DockerServerImages.find().fetch().map((xx) -> xx["tag"]))
          res = {}
          values.map (xx) ->
            res[xx] = xx
          res

        uniqueDockerImageTags: ->
          _.uniq(DockerServerImages.find().fetch().map((xx) -> xx["tag"]))
          
      waitOn: ->
        userId = Meteor.userId()
        if not userId
          Router.go "pleaseLogin"

        else
          if Roles.userIsInRole(userId,"admin","system")
            Meteor.subscribe "allUsers"
            Meteor.subscribe "allDockerInstances"
            Meteor.subscribe "allDockerImages"
            Meteor.subscribe "DevMileStone"
            Meteor.subscribe "WantedFeature"
            Meteor.subscribe "allDockerServerImages"
            Meteor.subscribe "allDockerServers"
            Meteor.subscribe "allDockerServerContainers"
            Meteor.subscribe "allEnvTypes"
            Meteor.subscribe "allEnvs"
          else
            if Roles.userIsInRole(userId,"admin","dockers")
              Meteor.subscribe "allDockerInstances"
              Meteor.subscribe "allDockerImages"
              Meteor.subscribe "allDockerServerImages"
              Meteor.subscribe "allDockerServers"
              Meteor.subscribe "allEnvTypes"
              Meteor.subscribe "allEnvs"
            else
              Router.go "index"

    @route "server",
      path: "admin/server/:dockerServerId"
      template: "serverPage"
      data:->
        resData =
          rootURL:rootURL
          user:->
            Meteor.user()
          showAdminPage: ->
            userId = Meteor.userId()
            Roles.userIsInRole(userId,"admin","system") or Roles.userIsInRole(userId,"admin","dockers")
          pullImageData: ->
            "dockerServerId": Router.current().params["dockerServerId"]
        resData
      waitOn: ->
        userId = Meteor.userId()
        if not userId
          Router.go "pleaseLogin"

        else
          if Roles.userIsInRole(userId,"admin","system")
            Meteor.subscribe "allUsers"
            Meteor.subscribe "dockerServerImages", @params.dockerServerId
            # Meteor.subscribe "dockerInstances", @params.dockerServerId
            # Meteor.subscribe "dockerImages", @params.dockerServerId
          else
            if Roles.userIsInRole(userId,"admin","dockers")
              Meteor.subscribe "dockerServerImages", @params.dockerServerId
              # Meteor.subscribe "dockerInstances", @params.dockerServerId
              # Meteor.subscribe "dockerImages", @params.dockerServerId
            else
              Router.go "index"

    @route "about",
      path: "about/"
      template: "about"
      data:
        rootURL:rootURL
        user: ->
          Meteor.user()
        showAdminPage: ->
          userId = Meteor.userId()
          Roles.userIsInRole(userId,"admin","system") or Roles.userIsInRole(userId,"admin","dockers")



    @route "howToUse",
      path: "howToUse/"
      template: "howToUse"
      data:
        rootURL:rootURL
        user: ->
          Meteor.user()
        showAdminPage: ->
          userId = Meteor.userId()
          Roles.userIsInRole(userId,"admin","system") or Roles.userIsInRole(userId,"admin","dockers")



    @route "wishFeatures",
      path: "wishFeatures/"
      template: "wishFeatures/"
      data:
        rootURL:rootURL
        user: ->
          Meteor.user()
        showAdminPage: ->
          userId = Meteor.userId()
          Roles.userIsInRole(userId,"admin","system") or Roles.userIsInRole(userId,"admin","dockers")

      waitOn: ->
        Meteor.subscribe "Chat", "wishFeatures"
        Meteor.subscribe "WantedFeature"
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
        showAdminPage: ->
          userId = Meteor.userId()
          Roles.userIsInRole(userId,"admin","system") or Roles.userIsInRole(userId,"admin","dockers")


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

        Meteor.subscribe "allDockerImagesOld"
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
        showAdminPage: ->
          userId = Meteor.userId()
          Roles.userIsInRole(userId,"admin","system") or Roles.userIsInRole(userId,"admin","dockers")

        isAdmin: ->
          uid = Meteor.userId()
          Roles.find({userId:uid,role:"admin"}).count()>0
        courses: ->
          Courses.find()

      waitOn: ->
        userId = Meteor.userId()
        if not userId
          Router.go "pleaseLogin"

        Meteor.subscribe "allPublicCourses"
        # Meteor.subscribe "myRoles"

    
    # @route "ipynb",
    #   path: "ipynb/"
    #   template: "analyzer"
    #   data:
    #     rootURL:rootURL
    #     baseImageUrl: "https://registry.hub.docker.com/u/c3h3/oblas-py278-shogun-ipynb/"
    #     name: "ipynb"

    #     user: ->
    #       Meteor.user()
    #     showAdminPage: ->
    #       userId = Meteor.userId()
    #       Roles.userIsInRole(userId,"admin","system") or Roles.userIsInRole(userId,"admin","dockers")


    #     docker: ->
    #       courseId = Session.get "courseId"
    #       course = Courses.findOne _id:courseId
    #       Session.set "docker", DockerInstances.findOne({imageId:"c3h3/oblas-py278-shogun-ipynb"})
    #       DockerInstances.findOne({imageId:"c3h3/oblas-py278-shogun-ipynb"})

    #     chats: ->
    #       Chat.find {}, {sort: {createAt:-1}}

    #     quickFormData: ->
    #       courseId:"ipynbBasic"

    #   waitOn: ->
    #     userId = Meteor.userId()
    #     if not userId
    #       Router.go "pleaseLogin"

    #     Meteor.call "runDocker", "c3h3/oblas-py278-shogun-ipynb", (err, data)->
    #       if not err
    #         console.log "data = "
    #         console.log data

    #     Session.set "courseId", "ipynbBasic"

    #     Meteor.subscribe "Chat", "ipynbBasic"
    #     Meteor.subscribe "userDockerInstances"


    #  @route "rstudio",
    #   path: "rstudio/"
    #   template: "analyzer"
    #   data:
    #     rootURL:rootURL
    #     baseImageUrl: "https://registry.hub.docker.com/u/rocker/rstudio/"
    #     name: "rstudio"
    #     user: ->
    #       Meteor.user()
    #     showAdminPage: ->
    #       userId = Meteor.userId()
    #       Roles.userIsInRole(userId,"admin","system") or Roles.userIsInRole(userId,"admin","dockers")


    #     docker: ->
    #       courseId = Session.get "courseId"
    #       course = Courses.findOne _id:courseId
    #       Session.set "docker", DockerInstances.findOne({imageId:"rocker/rstudio"})
    #       DockerInstances.findOne({imageId:"rocker/rstudio"})

    #     chats: ->
    #       Chat.find {}, {sort: {createAt:-1}}

    #     quickFormData: ->
    #       courseId:"rstudioBasic"

    #   waitOn: ->
    #     userId = Meteor.userId()
    #     if not userId
    #       Router.go "pleaseLogin"

    #     Meteor.call "runDocker", "rocker/rstudio", (err, data)->
    #       if not err
    #         console.log "data = "
    #         console.log data

    #     Session.set "courseId", "rstudioBasic"
    #     Meteor.subscribe "Chat", "rstudioBasic"
    #     Meteor.subscribe "userDockerInstances"


    @route "pleaseLogin",
      path: "pleaseLogin/"
      template: "pleaseLogin"
      waitOn: ->
        userId = Meteor.userId()
        if userId
          Router.go "index"

    