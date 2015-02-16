Template.forums.helpers
  
  rtSettings: ->
    questionField =
      key: "title"
      label: "Question"
      tmpl: Template.questionRow

    res =
      fields: [questionField]
      collection: db.forumPosts


Template.questionRow.helpers
  
  partOf: (content) ->
    if content.length < 300
      content
    else
      content[..300] + "....."