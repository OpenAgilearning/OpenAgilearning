Blaze.Template.registerHelper "mathdown", new Template "mathdown", ->
  content = Blaze._toText @templateContentBlock, HTML.TEXTMODE.STRING
  t = Spacebars.include @lookupTemplate "markdown", -> Blaze.View -> Spacebars.mustache content
  debugger
  console.log t._render()
  #console.log Blaze._toText @templateContentBlock, HTML.TEXTMODE.STRING
  #console.log @lookupTemplate "markdown"
  #console.log @lookupTemplate "mathjax"
