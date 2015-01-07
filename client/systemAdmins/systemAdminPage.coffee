
Template.systemAdminPageUsersTable.helpers
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
      fields: [userIdField, userNameField, userRolesField, setSystemAdminBtnsField, setCourseManagerBtnField, setTeacherBtnField, setStudentBtnField]


Template.setSystemAdminBtns.events
  "click .setAsSystemAdminBtn": (e, t)->
    e.stopPropagation()
    userId = $(e.target).attr "userId"
    Meteor.call "setSystemAdmin", userId

  "click .removeSystemAdminBtn": (e, t)->
    e.stopPropagation()
    userId = $(e.target).attr "userId"
    Meteor.call "removeSystemAdmin", userId


Template.setCourseManagerBtns.events
  "click .setAsCourseManagerBtn": (e, t)->
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