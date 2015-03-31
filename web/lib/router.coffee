Router.configure
  layoutTemplate: 'layout'
  loadingTemplate: 'loading'

Meteor.startup ->
  Router.map ->

    @route "index",
      path: "/"
      template: "landing"
      waitOn: ->
        user = Meteor.user()
        if user
          Router.go "courses"


    @route "courses",
      path: "/courses"
      template: "index"
      data:
        user: ->
          Meteor.user()
        showAdminPage: ->
          userId = Meteor.userId()
          Roles.userIsInRole(userId,"admin","system") or Roles.userIsInRole(userId,"admin","dockers")

      waitOn: ->
        Session.set "nodesListRendered", false

        userId = Meteor.userId()

        redirectAfterLogin = Cookies.get "redirectAfterLogin"
        if redirectAfterLogin and userId
          Cookies.expire "redirectAfterLogin"
          window.location = redirectAfterLogin

        Meteor.subscribe "DevMileStone"
        Meteor.subscribe "WantedFeature"
        # Meteor.subscribe "allPublicCourses"

        Meteor.subscribe "allPublicCoursesDockerImages"

        Meteor.subscribe "allPublicAndSemipublicCourses"
        Meteor.subscribe "userRoles", ["course", "agilearning.io"]
        Meteor.subscribe "registeredCourse"

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
        Meteor.subscribe "allPublicAndSemipublicCourses"
        Meteor.subscribe "allPublicCoursesDockerImages"

        Meteor.subscribe "userRoles", ["agilearning.io"]

#    @route "profile",
#      path: "profile/"
#      template: "profile"


    @route "userSettings",
      path: "userSettings/"
      template: "userSettings"
      data:
        rootURL:rootURL
        user: ->
          Meteor.user()
        resume: ->
          db.publicResume.find()
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
        user = Meteor.user()
        if not user
          Router.go "pleaseLogin"
        #TODO: no password! no envs!
        Meteor.subscribe "userEnvUserConfigs"
        Meteor.subscribe "userDockerInstances"
        Meteor.subscribe "userEnvUserConfigs"

        Meteor.subscribe "allPublicEnvConfigTypes"
        Meteor.subscribe "allPublicCourses"
        Meteor.subscribe "allPublicCoursesDockerImages"

        Meteor.subscribe "userRoles", ["agilearning.io"]
        Meteor.subscribe "userResume"

    #@route "courses",
    #  path: "courses/"
    #  template: "courses"
    #  data:
    #    user: ->
    #      Meteor.user()
    #    showAdminPage: ->
    #      userId = Meteor.userId()
    #      Roles.userIsInRole(userId,"admin","system") or Roles.userIsInRole(userId,"admin","dockers")

    #    isAdmin: ->
    #      uid = Meteor.userId()
    #      Roles.find({userId:uid,role:"admin"}).count()>0
    #    courses: ->
    #      Courses.find()

    #  waitOn: ->
    #    # userId = Meteor.userId()
    #    # if not userId
    #    #   Router.go "pleaseLogin"

    #    Meteor.subscribe "allPublicAndSemipublicCourses"
    #    Meteor.subscribe "allPublicCoursesDockerImages"

    #    Meteor.subscribe "userRoles", ["course", "agilearning.io"]

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

          courseAndId: =>
            "course_" + @params.courseId

          # coursesEditSchema: =>
          #   console.log "@params.courseId = "
          #   console.log @params.courseId
          #   getCoursesEditSchema(@params.courseId)



        resData

      waitOn: ->
        # userId = Meteor.userId()
        # if not userId
        #   Router.go "pleaseLogin"

        CoursesSubHandler = Meteor.subscribe "course", @params.courseId
        RolesHandler = Meteor.subscribe "userRoles", ["course", "agilearning.io"]

        Meteor.autorun =>
          if CoursesSubHandler.ready() and RolesHandler.ready()
            if Courses.findOne().publicStatus isnt "public"
              console.log 'RoleTools.isRole(["admin","member"],"course",@params.courseId)'
              console.log RoleTools.isRole(["admin","member"],"course",@params.courseId)
              if not RoleTools.isRole(["admin","member"],"course",@params.courseId)
                Router.go "index"

        # Meteor.subscribe "allPublicClassrooms", @params.courseId
        # Meteor.subscribe "allPublicClassroomRoles", @params.courseId
        Meteor.subscribe "courseDockerImages", @params.courseId

        # FIXME BUG!!!! for demo 2015-03-06 taishin
        Meteor.subscribe "allClassroomRoles", @params.courseId
        Meteor.subscribe "allClassrooms", @params.courseId

        # Meteor.subscribe "relateClassrooms", @params.courseId
        # Meteor.subscribe "relateClassroomRoles", @params.courseId

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
            if courseData.dockerImage
              imageTag = courseData.dockerImage
            else
              imageTag = courseData.dockerImageTag

            if imageTag.split(":").length is 1
              fullImageTag = imageTag + ":latest"
            else
              fullImageTag = imageTag

            DockerInstances.findOne({imageTag:fullImageTag})

          dockerHasHTTP: ->
            # docker = @docker()
            # httpPorts = docker?.portDataArray?.filter (portData)-> portData.type is "http"
            # httpPorts?.length > 0

            course = @course()
            ports = db.dockerImageTags.findOne({tag:course.dockerImageTag}).servicePorts.filter (portData)-> portData.type is "http"
            ports?.length > 0


          dockerHasSFTP: ->
            # docker = @docker()
            # httpPorts = docker?.portDataArray?.filter (portData)-> portData.type is "http"
            # httpPorts?.length > 0

            course = @course()
            ports = db.dockerImageTags.findOne({tag:course.dockerImageTag}).servicePorts.filter (portData)-> portData.type is "sftp"
            ports?.length > 0

          sftp: ->
            docker = @docker()
            httpPorts = docker?.portDataArray?.filter (portData)-> portData.type is "sftp"
            if httpPorts?.length > 0
              resData =
                ip: docker.ip
                port: httpPorts[0].hostPort
                envs: docker.containerConfigs.Env


          SFTPPort: ->
            docker = @docker()
            httpPorts = docker?.portDataArray?.filter (portData)-> portData.type is "sftp"
            httpPorts[0].hostPort

          classroomId: @params.classroomId

          needToSetEnvConfigs: =>
            userId = Meteor.userId()
            # classroomDoc = Classrooms.findOne _id:@params.classroomId
            # courseData = Courses.findOne _id:classroomDoc.courseId
            # imageTag = courseData.dockerImage

            # configTypeId = DockerImages.findOne({_id:imageTag}).type

            # configTypeId = getEnvConfigTypeIdFromClassroomId(@params.classroomId)
            # if configTypeId
            #   EnvUserConfigs.find({userId:userId, configTypeId:configTypeId}).count() is 0
            classroomDoc = Classrooms.findOne _id:@params.classroomId
            courseData = Courses.findOne _id:classroomDoc.courseId

            if courseData.dockerImage
              imageTag = courseData.dockerImage
            else
              imageTag = courseData.dockerImageTag

            if imageTag.split(":").length is 1
              fullImageTag = imageTag + ":latest"
            else
              fullImageTag = imageTag

            DockerInstances.find({imageTag:fullImageTag}).count() is 0

          terms:->
            db.terms.findOne _id:"toc_main"

          # envConfigsSchema: =>
          #   userId = Meteor.userId()
          #   # classroomDoc = Classrooms.findOne _id:@params.classroomId
          #   # courseData = Courses.findOne _id:classroomDoc.courseId
          #   # imageTag = courseData.dockerImage

          #   # configTypeId = DockerImages.findOne({_id:imageTag}).type

          #   configTypeId = getEnvConfigTypeIdFromClassroomId(@params.classroomId)

          #   envConfigsData = EnvConfigTypes.findOne _id:configTypeId
          #   schemaSettings = {}

          #   envConfigsData.configs.envs.map (env)->
          #     schemaSettings[env.name] = {type: String}

          #     if not env.mustHave
          #       schemaSettings[env.name].optional = true

          #     if env.limitValues
          #       schemaSettings[env.name].allowedValues = env.limitValues

          #   new SimpleSchema schemaSettings

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

        # FIXME expensive query
        userData = Meteor.user()
        if userData?.roles
          # Get registered classrooms data
          keyArr = Object.keys userData.roles
          classIdArr = []
          keyArr.map (xx)->
            if xx isnt "system"
              classIdArr.push xx.split("_")[1]
        if not (@params.classroomId in classIdArr)
          Router.go "index"
        else
          Meteor.subscribe "allPublicEnvConfigTypes"
          Meteor.subscribe "userEnvUserConfigs"
          Meteor.subscribe "userDockerInstances"
          Meteor.subscribe "classroom", @params.classroomId
          Meteor.subscribe "classroomCourse", @params.classroomId
          Meteor.subscribe "classroomDockerImages", @params.classroomId
          Meteor.subscribe "classChatroom", @params.classroomId
          Meteor.subscribe "classChatroomMessages", @params.classroomId
          # Meteor.subscribe "userDockerInstances", @params.classroomId
          Meteor.subscribe "usersOfClassroom", @params.classroomId
          Meteor.subscribe "classExercises", @params.classroomId

          Meteor.subscribe "terms"
          Meteor.subscribe "userRoles", ["agilearning.io"]

      # onAfterAction: ->
        # Meteor.call "getClassroomDocker", @params.classroomId, (err, data)->
        #   if not err
        #     console.log "get env successfully!"
        #   else
        #     console.log "get env failed!"


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

        youtubeVideoId: ->
          if LearningResources.find().count() > 0
            LearningResources.findOne().youtubeVideoId
          else
            "CdMzHLrmpi8"

      waitOn: ->
        # userId = Meteor.userId()
        # if not userId
        #   Router.go "pleaseLogin"
        Session.set "resourcesListRendered", false
        Meteor.subscribe "allLearningResources"

        Meteor.subscribe "userRoles", ["agilearning.io"]
        Meteor.subscribe "votes", "LearningResources"

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

        Meteor.subscribe "userRoles", ["agilearning.io"]

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
            # Meteor.subscribe "allEnvs"

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

        if userId
          Meteor.subscribe "chatrooms"
          Meteor.subscribe "userJoinsChatroom"

        Meteor.subscribe "userRoles", ["agilearning.io"]
        Meteor.subscribe "feedback"
        Meteor.subscribe "votes", ["Feedback"]

    @route "forumPost",
      path: "forums/:postId"
      template: "forumPost"

      data:
        user: -> Meteor.user()
        showAdminPage: ->
          userId = Meteor.userId()
          Roles.userIsInRole(userId, "admin", "system") or Roles.userIsInRole(userId, "admin", "dockers")
        post: =>
          db.forumPosts.findOne(_id: @current().params.postId)


      waitOn: ->
        Meteor.subscribe "forumPost", @params.postId


    @route "resume",
      path: "resume/:userId"
      template: "resume"

      data:
        user: -> Meteor.user()
        showAdminPage: ->
          userId = Meteor.userId()
          Roles.userIsInRole(userId, "admin", "system") or Roles.userIsInRole(userId, "admin", "dockers")
        resume: ->
          db.publicResume.find()

      waitOn: ->
        Meteor.subscribe "userResume"

    @route "termsOfConditions",
      path: "toc/:tocId"
      template: "terms"
      data:
        terms:=>db.terms.findOne _id:@current().params.tocId
      waitOn:->
        Meteor.subscribe "terms"

    @route "communitiesList",
      path: "communitiesList/"
      template: "communitiesList"

      data:
        user: -> Meteor.user()
        showAdminPage: ->
          userId = Meteor.userId()
          Roles.userIsInRole(userId, "admin", "system") or Roles.userIsInRole(userId, "admin", "dockers")


      waitOn: ->
        Meteor.subscribe "communities"

    @route "community",
      path: "community/:communityId"
      template: "communityPage"

      data:
        user: -> Meteor.user()
        showAdminPage: ->
          userId = Meteor.userId()
          Roles.userIsInRole(userId, "admin", "system") or Roles.userIsInRole(userId, "admin", "dockers")
        community:->
            db.communities.findOne()
      waitOn: ->
        Meteor.subscribe "communities" , @params.communityId



    @route "pleaseLogin",
      path: "becomeAgilearner/"
      template: "becomeAgilearner"

      waitOn: ->
        userId = Meteor.userId()
        if userId
          Router.go "index"

        Meteor.subscribe "userRoles", ["agilearning.io"]

    @route "about",
      path: "about/"
      template: "aboutUs"

      # Add these code so when admin route to about us,
      # his/her admin nav won't disappear strangely.
      data:
        user: -> Meteor.user()
        showAdminPage: ->
          userId = Meteor.userId()
          Roles.userIsInRole(userId, "admin", "system") or Roles.userIsInRole(userId, "admin", "dockers")
        waitOn: ->
          Meteor.subscribe "userRoles", ["agilearning.io"]
