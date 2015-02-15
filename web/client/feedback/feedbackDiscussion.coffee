Template.feedbackDiscussion.helpers
  settings: ->
    idField =
      key: "_id"
      label: "id"
      hidden: true
    typeField =
      key: "type"
      label: "Type"
      tmpl: Template.feedbackType
      # TODO: type should be filterable
    titleField =
      key: "title"
      label: "Title"
    descriptionField =
      key: "description"
      label: "Description"
    createdAtField =
      key: "createdAt"
      label: "Created"
      fn: (value) -> moment(value).fromNow()
      sort: 'ascending'
      
    res =
      collection: Feedback.find()
      rowsPerPage: 30
      showFilter: true
      fields:[
        idField
        typeField
        titleField
        descriptionField
        createdAtField
      ]

Template.feedbackType.helpers
  isWish:(type)-> type is "w"