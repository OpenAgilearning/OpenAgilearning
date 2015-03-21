Template.landing.rendered = ->
  $ "body"
    .addClass "landing-page"

Template.landing.destroyed = ->
  $ "body"
    .removeClass "landing-page"

Template.landing.events
  "click #signup": (event, template) ->
    Meteor.loginWithMeetup (error) ->
      if not error
        Router.go "courses"
