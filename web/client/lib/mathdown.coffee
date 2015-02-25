Blaze.Template.registerHelper "mathdown", new Template "mathdown", ->
  content = Blaze._toText @templateContentBlock, HTML.TEXTMODE.STRING
  t = Spacebars.include @lookupTemplate "markdown", -> Blaze.View -> ""
  t.templateContentBlock = content
  console.log t._render()
  return t._render()
