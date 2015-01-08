
Template.adminPageDockerInstancesTable.helpers
  settings: ->
    removeDockerInstanceBtnsField =
      key: "containerId"
      label: "Remove Instance"
      tmpl: Template.setDockerInstanceBtns
    

    res = 
      collection: DockerInstances
      rowsPerPage: 10
      showFilter: true
      fields: [removeDockerInstanceBtnsField, "_id", "userId", "imageId", "imageType", "servicePort", "createAt", "containerId"]


Template.setDockerInstanceBtns.events
  "click .removeDockerInstanceBtn": (e, t)->
    e.stopPropagation()
    containerId = $(e.target).attr "containerId"
    Meteor.call "removeDocker", containerId, (err, res)->
      if not err
        console.log "res = "
        console.log res

  


Template.adminPageDockerImagesTable.helpers
  settings: ->
    res = 
      collection: DockerImages
      rowsPerPage: 10
      showFilter: true
      fields: ["_id", "type"]


Template.adminPageUsersTable.helpers
  settings: ->
    userIdField =
      key: "_id"
      label: "uid"
    
    userNameField =
      key: "profile.name"
      label: "name"

    userRolesField =
      key: "roles"
      label: "roles"
      fn: (value) ->
        allRoles = []
        Object.keys(value).map (xx) ->
          Object.keys(value[xx]).map (yy)->
            allRoles.push value[xx][yy] + "." + xx

        allRoles.join " / "

    setSystemAdminBtnsField =
      key: "_id"
      label: "Set System Admin"
      tmpl: Template.setSystemAdminBtns
    

    setDockerAdminBtnsField =
      key: "_id"
      label: "Set Docker Admin"
      tmpl: Template.setDockerAdminBtns
    


    setCourseManagerBtnField =
      key: "_id"
      label: "Set Course Manager"
      tmpl: Template.setCourseManagerBtns
    

    setTeacherBtnField =
      key: "_id"
      label: "Set Teacher"
      tmpl: Template.setTeacherBtns
    
    setStudentBtnField =
      key: "_id"
      label: "Set Student"
      tmpl: Template.setStudentBtns
    


    res = 
      collection: Meteor.users
      rowsPerPage: 10
      showFilter: true
      fields: [userIdField, userNameField, userRolesField, setSystemAdminBtnsField, setDockerAdminBtnsField, setCourseManagerBtnField, setTeacherBtnField, setStudentBtnField]


Template.setSystemAdminBtns.events
  "click .setSystemAdminBtn": (e, t)->
    e.stopPropagation()
    userId = $(e.target).attr "userId"
    Meteor.call "setSystemAdmin", userId

  "click .removeSystemAdminBtn": (e, t)->
    e.stopPropagation()
    userId = $(e.target).attr "userId"
    Meteor.call "removeSystemAdmin", userId


Template.setCourseManagerBtns.events
  "click .setCourseManagerBtn": (e, t)->
    e.stopPropagation()
    userId = $(e.target).attr "userId"
    Meteor.call "setCourseManager", userId

  "click .removeCourseManagerBtn": (e, t)->
    e.stopPropagation()
    userId = $(e.target).attr "userId"
    Meteor.call "removeCourseManager", userId


Template.setTeacherBtns.events
  "click .setTeacherBtn": (e, t)->
    e.stopPropagation()
    userId = $(e.target).attr "userId"
    Meteor.call "setTeacher", userId

  "click .removeTeacherBtn": (e, t)->
    e.stopPropagation()
    userId = $(e.target).attr "userId"
    Meteor.call "removeTeacher", userId


Template.setStudentBtns.events
  "click .setStudentBtn": (e, t)->
    e.stopPropagation()
    userId = $(e.target).attr "userId"
    Meteor.call "setStudent", userId

  "click .removeStudentBtn": (e, t)->
    e.stopPropagation()
    userId = $(e.target).attr "userId"
    Meteor.call "removeStudent", userId



Template.setDockerAdminBtns.events
  "click .setDockerAdminBtn": (e, t)->
    e.stopPropagation()
    userId = $(e.target).attr "userId"
    Meteor.call "setDockerAdmin", userId

  "click .removeDockerAdminBtn": (e, t)->
    e.stopPropagation()
    userId = $(e.target).attr "userId"
    Meteor.call "removeDockerAdmin", userId