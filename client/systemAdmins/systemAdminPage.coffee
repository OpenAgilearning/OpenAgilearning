
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

    res = 
      collection: Meteor.users
      rowsPerPage: 10
      showFilter: true
      fields: [userIdField, userNameField, userRolesField]