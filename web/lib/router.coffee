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

    @route "envs",
      path: "envs/"
      template: "envs"
      data: ->
        resData =
          rootURL:rootURL
          user: ->
            Meteor.user()
          showAdminPage: ->
            userId = Meteor.userId()
            Roles.userIsInRole(userId,"admin","system") or Roles.userIsInRole(userId,"admin","dockers")

          envConfigTypeId: ->
            if Session.get("envConfigTypeId") isnt ""
              Session.get "envConfigTypeId"

          userConfigId: ->
            if Session.get("userConfigId") isnt ""
              Session.get "userConfigId"

          hasEnvUserConfigs: ->
            EnvUserConfigs.find().count() > 0

          hasUnsettingEnvUserConfigs: -> 
            (EnvConfigTypes.find().count() - EnvUserConfigs.find().count() )> 0

          filteredEnvConfigTypes: ->
            filteringConfigTypeIds = EnvUserConfigs.find().fetch().map (xx)-> xx.configTypeId            
            EnvConfigTypes.find _id:{$nin:filteringConfigTypeIds}            

      waitOn: ->
        userId = Meteor.userId()
        if not userId
          Router.go "pleaseLogin"

        #TODO: no password! no envs!
        Meteor.subscribe "userEnvUserConfigs"
        Meteor.subscribe "userDockerInstances"
        Meteor.subscribe "userEnvUserConfigs"

        Meteor.subscribe "allPublicEnvConfigTypes"
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

        userConfigId: ->
          if Session.get("userConfigId") isnt ""
            Session.get "userConfigId"

      waitOn: ->
        user = Meteor.user()
        if not user
          Router.go "pleaseLogin"
        Meteor.subscribe "userEnvUserConfigs"
        Meteor.subscribe "userDockerInstances"
        Meteor.subscribe "userEnvUserConfigs"

        Meteor.subscribe "allPublicEnvConfigTypes"

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
        Meteor.subscribe "allPublicCoursesDockerImages"
 

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
        Meteor.subscribe "userEnvUserConfigs"
        Meteor.subscribe "userDockerInstances"
        Meteor.subscribe "classroom", @params.classroomId
        Meteor.subscribe "classroomCourse", @params.classroomId
        Meteor.subscribe "classroomDockerImages", @params.classroomId
        Meteor.subscribe "classChatroom", @params.classroomId
        Meteor.subscribe "classChatroomMessages", @params.classroomId
        # Meteor.subscribe "userDockerInstances", @params.classroomId

        Meteor.call "getClassroomDocker", @params.classroomId, (err, data)->
          if not err
            console.log "get env successfully!"
          else
            console.log "get env failed!"

        Meteor.subscribe "classChatroom", @params.classroomId
        Meteor.subscribe "usersOfClassroom", @params.classroomId
        Meteor.subscribe "classExercises", @params.classroomId


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
            # Meteor.subscribe "allDockerInstances"
            # Meteor.subscribe "allDockerImages"
            # Meteor.subscribe "DevMileStone"
            # Meteor.subscribe "WantedFeature"
            
            Meteor.subscribe "allDockerServers"
            Meteor.subscribe "allDockerServerImages"
            Meteor.subscribe "allDockerServerContainers"

            # Meteor.subscribe "allEnvTypes"
            Meteor.subscribe "allEnvs"

          else
            if Roles.userIsInRole(userId,"admin","dockers")
              # Meteor.subscribe "allDockerInstances"
              # Meteor.subscribe "allDockerImages"
              
              Meteor.subscribe "allDockerServers"
              Meteor.subscribe "allDockerServerImages"
              Meteor.subscribe "allDockerServerContainers"
            
              # Meteor.subscribe "allEnvTypes"
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

    # @route "wishFeatures",
    #   path: "wishFeatures/"
    #   template: "wishFeatures/"
    #   data:
    #     rootURL:rootURL
    #     user: ->
    #       Meteor.user()
    #     showAdminPage: ->
    #       userId = Meteor.userId()
    #       Roles.userIsInRole(userId,"admin","system") or Roles.userIsInRole(userId,"admin","dockers")

    #   waitOn: ->
    #     Meteor.subscribe "Chat", "wishFeatures"
    #     Meteor.subscribe "WantedFeature"
    #     Session.set "courseId", "wishFeatures"


    @route "discussions", 
      path: "discuss/"
      template: "discussions"
      data:
        user: -> Meteor.user()
        showAdminPage: ->
          userId = Meteor.userId()
          Roles.userIsInRole(userId, "admin", "system") or Roles.userIsInRole(userId, "admin", "dockers")

      waitOn: ->
        userId = Meteor.userId()
        if not userId
          Router.go "pleaseLogin"

        Meteor.subscribe "chatroomsWithoutClassChatroom"
        Meteor.subscribe "userJoinsChatroom"


    @route "pleaseLogin",
      path: "pleaseLogin/"
      template: "pleaseLogin"
      waitOn: ->
        userId = Meteor.userId()
        if userId
          Router.go "index"

    
