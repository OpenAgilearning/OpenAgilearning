
Template.studentListTableTeacher.helpers
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
      ]