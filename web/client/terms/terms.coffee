# Template.pleaseSignTerms.events
#   "click #i-agree":->
#     Meteor.call "agreeToTerms",
Template.pleaseSignTerms.rendered = ->
  $.material?.init()

Template.pleaseSignTerms.helpers
  doc: ->{tocId:"toc_main"}

Template.terms.helpers
  terms:-> Router.current().data().terms()
