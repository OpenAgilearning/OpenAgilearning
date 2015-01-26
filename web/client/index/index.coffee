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

Template.goToCoursePageBtn.helpers
  getDockerImagePictureURL: (dockerImageId) ->
    DockerImages.findOne({_id:dockerImageId}).imageURL