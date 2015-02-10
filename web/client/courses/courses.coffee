
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
      showFilter: true
      fields: [goToClassroomBtnField, "publicStatus"]



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

