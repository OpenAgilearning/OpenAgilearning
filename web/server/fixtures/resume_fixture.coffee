@Fixture.publicResume =
  data: ->
    data = []
    for user in Meteor.users.find().fetch()
      for key in Object.keys user.profile
        value = user.profile[key]
        switch typeof value
          when "string" then data.push
            userId: user._id
            type: "profile"
            key: key
            value: value
            isPublic: true

    data
  set: ->
    if db.publicResume.find().count() is 0

      db.publicResume.insert resume for resume in @data()

  clear: ->
    db.publicResume.remove resume for resume in @data()

  reset: ->
    @clear()
    @set()
