fs = Meteor.npmRequire "fs"

@Fixture.terms =
  data: ->
    [{
      _id: "toc1"
      title:"Terms of Conditions for Environment"
      content: fs.readFileSync("assets/app/toc1.md").toString()
      version: "0.0.1"
      publishedAt:new Date()
    }
    ]

  set: ->
    if db.terms.find().count() is 0 and Meteor.settings.public.environment isnt "production"

      db.terms.insert term for term in @data()

  clear: ->
    db.terms.remove term for term in @data()

  reset: ->
    @clear()
    @set()

@Fixture.terms.set()
