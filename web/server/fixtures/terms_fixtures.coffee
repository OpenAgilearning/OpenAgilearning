@Fixture.terms =
  data: ->
    [{
      _id: "toc_main"
      title:"Terms of Service for Environment"
      content: Assets.getText "toc1.md"
      version: "0.0.1"
      publishedAt:new Date()
    }
    ]

  set: ->
    if db.terms.find().count() is 0

      db.terms.insert term for term in @data()

  clear: ->
    db.terms.remove term for term in @data()

  reset: ->
    @clear()
    @set()
