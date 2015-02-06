
Template.studentListTableAdmin.helpers
  settings: ->
    idField =
      key: "_id"
      label: "id"
      hidden: true
    
    picField =
      key: "profile.photo.thumb_link"
      label: "Pic"
      tmpl: Template.studentPhoto
      sortable: false
    
    nameField =
      key: "profile.name"
      label: "Name"
    
    rolesField =
      key: "roles." + @classroomAndId()
      label:"Roles"
      fn: (value) -> value.sort().join "/"
      sortByValue:true

    setTeacherBtnField =
      key: "_id"
      label: "Set Teacher"
      tmpl: Template.setClassroomTeacher
      sortable: false
      
    setAdminBtnField =
      key: "_id"
      label: "Set Administrator"
      tmpl: Template.setClassroomAdmin
      sortable: false
      
    res =
      collection: Roles.getUsersInRole [
        "student"
        "teacher"
        "admin"
      ], @classroomAndId()
      rowsPerPage: 30
      showFilter: true
      fields:[
        idField
        picField
        nameField
        rolesField
        setTeacherBtnField
        setAdminBtnField
      ]


Template.studentListTableAdmin.events
  "click .setRole": (e, t)->
    e.stopPropagation()
    userId = $(e.target).attr "user_id"
    role = $(e.target).attr "role"
    action = $(e.target).attr "action"
    classroomAndId = "classroom_" + Router.current().params.classroomId
    
    Meteor.call "setClassroomRole", classroomAndId, action, role, userId
