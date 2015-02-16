
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
      courseDoc.imageURL
    else
      dockerImageDoc = DockerImages.findOne({_id:courseDoc.dockerImage})
      if dockerImageDoc.imageURL
        dockerImageDoc.imageURL
      else
        if dockerImageDoc.type is "ipynb"
          "/images/ipynb_docker_default.png"
        else if dockerImageDoc.type is "rstudio"
          "/images/rstudio_docker_default.png"


Template.goToClassroomBtn.helpers
  isClassroomMember: ->
    userId = Meteor.userId()
    classroomId = @_id
    classroomAndId = "classroom_" + classroomId

    isClassroomMember = Roles.userIsInRole(userId,"admin",classroomAndId)
    isClassroomMember = isClassroomMember  or Roles.userIsInRole(userId,"teacher",classroomAndId)
    isClassroomMember = isClassroomMember  or Roles.userIsInRole(userId,"student",classroomAndId)

Template.goToClassroomBtn.events
  "click .joinClassroomBtn": (e,t) ->
    e.stopPropagation()
    # console.log @
    classroomId = $(e.target).attr "classroomId"

    Meteor.call "joinClassroom", classroomId, (err, data) ->
      if not err
        console.log data
      else
        console.log err
        if err.error is 401
          Cookies.set "redirectAfterLogin", window.location.href
          Router.go "pleaseLogin"

  
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

Template.courseApplicationsTable.helpers
  settings: ->
    courseId = Router.current().params.courseId
    # groupId = RoleTools.getGroupId "course", courseId
    # waitForCheckRoles = Collections.Roles.find({groupId:groupId,role:"waitForCheck"})

    waitForCheckRoles = RoleTools.getRoles("waitForCheck","course",courseId)

    CheckBtnField =
      key: "_id"
      label: "Check"
      tmpl: Template.courseApplicationsTableCheckBtnField
      
    res =
      collection: waitForCheckRoles
      rowsPerPage: 5
      showFilter: false
      showNavigation:'never'
      fields: [CheckBtnField,"userId", "role"]

Template.courseApplicationsTableCheckBtnField.events
  "click .checkBtn": (e,t) ->
    e.stopPropagation()
    # console.log @
    roleId = $(e.target).attr "roleId"

    Meteor.call "checkCourseApplication", roleId, (err, data) ->
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

