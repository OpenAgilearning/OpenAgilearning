
Template.courseInfoAdminEditorForm.helpers
  coursesEditSchema: (dockerImagesArray=[], slidesArray=[], VideosArray=[]) ->
    courseId = Router.current().params.courseId
    if courseId
      resSchema = new SimpleSchema
        _id:
          type: String
          defaultValue: courseId
          allowedValues: [courseId]
          autoform:
            type: "hidden"
            label: false

        courseName:
          type: String

        publicStatus:
          type: String
          allowedValues: ["public","semipublic","private"]
          autoform:
            type:"select"
            options: "allowed"

        languages:
          type: [String]
          optional: true
          autoform:
            type: "tags"
            afFieldInput:
              maxChars: 2

        description:
          type: String
          optional: true
          autoform:
            rows: 5

        # bundleServer:
        #   type: [String]
        #   optional: true
        #   autoform:
        #     type: "select-checkbox-inline"
        #     options:->
        #       db.dockerServers.find().fetch().map (xx)-> {label:xx._id,value:xx._id}

        if dockerImagesArray.length > 0
          resSchema.dockerImage =
            type: String
            allowedValues: dockerImagesArray
            optional: true

        if slidesArray.length > 0
          resSchema.slides =
            type: String
            allowedValues: slidesArray
            optional: true

        if VideosArray.length > 0
          resSchema.video =
            type: String
            allowedValues: VideosArray
            optional: true

        # resSchema.courseId =
        #   type: String
        #   defaultValues: [courseId]
          # autoform:
          #   type: "hidden"


        resSchema

Template.allPublicCoursesTable.helpers
  settings: ->
    goToCoursePageBtnsField =
      key: ["_id","courseName", "dockerImage"]
      label: "Learning Immediately"
      tmpl: Template.goToCoursePageBtn

    courseNameAndDescriptionField =
      key: ["courseName", "description"]
      label: "Courses"
      tmpl: Template.courseNameAndDescription


    res =
      collection: Courses
      rowsPerPage: 5
      showFilter: true
      fields: [goToCoursePageBtnsField, courseNameAndDescriptionField]
      # showColumnToggles: true


Template.courseImage.helpers
  getCourseImageURL: (courseDoc) ->
    if courseDoc.imageURL
      resURL = courseDoc.imageURL
    else
      if courseDoc.dockerImage
        dockerImageDoc = DockerImages.findOne({_id:courseDoc.dockerImage})
        if dockerImageDoc?.imageURL
          resURL = dockerImageDoc.imageURL
        else
          if dockerImageDoc?.type is "ipynb"
            resURL = "/images/ipynb_docker_default.png"
          else if dockerImageDoc?.type is "rstudio"
            resURL = "/images/rstudio_docker_default.png"

      else
        dockerImageTagData = db.dockerImageTags.findOne tag: courseDoc.dockerImageTag
        # console.log "dockerImageTagData = ",dockerImageTagData
        if dockerImageTagData?.pictures?.length > 0
          resURL = Random.choice dockerImageTagData.pictures
        else
          if dockerImageTagData.envConfigTypeName is "rstudioBasic"
            resURL = "/images/rstudio_docker_default.png"
          else if dockerImageTagData.envConfigTypeName is "ipynbBasic"
            resURL = "/images/ipynb_docker_default.png"

    resURL

Template.goToClassroomBtn.helpers
  isClassroomMember: ->
    Is.classroom @_id, ["admin","teacher","student"]

Template.goToClassroomBtn.events
  "click .joinClassroomBtn": (e,t) ->
    e.stopPropagation()
    # console.log @
    classroomId = $(e.target).attr "classroomId"

    Meteor.call "joinClassroom", classroomId


Template.courseClassroomsTable.helpers
  settings: ->
    goToClassroomBtnField =
      key: "_id"
      label: "Learning Now!"
      tmpl: Template.goToClassroomBtn

    res =
      collection: Classrooms
      rowsPerPage: 5
      showFilter: false
      showNavigation:'never'
      fields: [goToClassroomBtnField, "name", "description"]

Template.courseMemberTable.helpers
  settings: ->
    courseId = Router.current().params.courseId
    # groupId = RoleTools.getGroupId "course", courseId
    # waitForCheckRoles = Collections.Roles.find({groupId:groupId,role:"waitForCheck"})

    roleIds = db.roleTypes.find({group:{type:"course",id:courseId}}).map (data)-> data._id
    waitForCheckRoles = db.userIsRole.find({roleId:{$in:roleIds}})

    CheckBtnField =
      key: "_id"
      label: "Check"
      tmpl: Template.courseMemberTableCheckBtnField

    RoleTypeField =
      key: "roleId"
      label: "Role Type"
      fn:(value, object) ->
        db.roleTypes.findOne({_id:value}).role

    UserProfileField =
      key: "userId"
      label: "User"
      fn:(value, object) ->
        userData = Meteor.users.findOne({_id:value})
        org = db.publicResume.findOne({userId:value,key:"organization"})?.value
        name = db.publicResume.findOne({userId:value,key:"name"})?.value

        if org
          "["+org+"] "+name

        else
          name


    res =
      collection: waitForCheckRoles
      rowsPerPage: 20
      showFilter: false
      # showNavigation:'never'
      fields: [UserProfileField,  "userId", RoleTypeField, CheckBtnField]


Template.courseMemberTableCheckBtnField.helpers
  roleType: ->
    db.roleTypes.findOne({_id:@roleId}).role
  isWaitForCheck: ->
    db.roleTypes.findOne({_id:@roleId}).role is "waitForCheck"




Template.courseMemberTableCheckBtnField.events
  "click .checkBtn": (e,t) ->
    e.stopPropagation()
    # console.log @
    userIsRoleId = $(e.target).attr "uirid"


    Meteor.call "checkCourseApplication", userIsRoleId, (err, data) ->
      if not err
        console.log data

      else
        console.log err
        if err.error is 401
          Cookies.set "redirectAfterLogin", window.location.href
          Router.go "pleaseLogin"



Template.courses.helpers
  coursesSchema: -> coursesSchema


Template.courses.events
  "click input.createBt": (e,t) ->
    e.stopPropagation()
    data =
      courseName: $("input.courseName").val()
      dockerImage: $("input.dockerImage").val()
      slides: $("input.slides").val()
      description: $("input.description").val()

    Meteor.call "createCourse", data

  "click input.courseDeleteBtn":(e,t)->
    e.stopPropagation()
    courseId = this._id
    console.log "delete course: " + courseId
    Meteor.call "deleteCourse", courseId



# Template.registerHelper "test", (xx, yy) ->
#   xx.abc + " / " + yy.def

# Template.registerHelper "test2", (xx) ->
#   xx*2


# Template.course.helpers
#   xx: ->
#     abc:"123"
#   yy: ->
#     def:"321"


Template.course.rendered = ->
  $("video").map ->
    videojs @, JSON.parse($(@).attr("data-setup"))



Template.course.events
  "click .connectBt": (e, t)->
    e.stopPropagation()
    $("#docker").attr "src", ""

    docker = Session.get "docker"
    url = "http://"+rootURL+":"+docker.servicePort

    $("#docker").attr "src", url
