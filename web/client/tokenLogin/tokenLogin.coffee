Template.tokenLogin.helpers
  user: -> Meteor.user()
  token:-> Meteor._localStorage.getItem "Meteor.loginToken"

Template.tokenLogin.events
  "click #login-btn": (e,t) ->
    token = t.$("#token").val()
    Meteor.loginWithToken token

