Blaze.Template.registerHelper "mathdown", new Template "mathdown", ->
  view = @
  content = Blaze._toText @templateContentBlock, HTML.TEXTMODE.STRING
  t = Spacebars.include @lookupTemplate "markdown"
  t.templateContentBlock = content
  resHtml = $("<div></div>").append t._render().value
  resHtml.find "code"
    .not ".mathjax"
    .filter ->
      _.isEqual @textContent.match(/^\$.+\$$/), [@textContent]
    .addClass "mathjax-inline"
  (toHtmlJs = (elements) ->
    elements.map ->
      v = @
      $v = $ @
      if @wholeText
        @wholeText
      else if @tagName is "PRE" and @children.length is 1 and @children[0].className is "mathjax"
        Spacebars.include view.lookupTemplate("mathjax"), ->
          Blaze.Template "(contentBlock)", ->
            HTML.P "$$#{v.children[0].textContent}$$"
      else if @className is "mathjax-inline"
        Spacebars.include view.lookupTemplate("mathjax"), ->
          Blaze.Template "(contentBlock)", ->
            HTML.SPAN v.textContent
      else if $v.find(".mathjax, .mathjax-inline").length
        HTML[@tagName].apply undefined, toHtmlJs $v.contents()
      else
        HTML.Raw @outerHTML
    .toArray()
  ) resHtml.children()
