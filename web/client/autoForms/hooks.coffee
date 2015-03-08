AutoForm.hooks
  profileUpdate:
    onSuccess: (updateProfile, result, template) ->
      $(".show-profile").toggle()
      $(".profile-editor").toggle()

  setEnvUserConfigs:
    onSuccess: (operation, result, template)->
      Session.set "userConfigId", ""
      Session.set "envConfigTypeId", ""

  courseInfoAdminEditor:
    onSuccess: (operation, result, template)->
      $("#courseInfoAdminEditorModal").modal "hide"

  feedbackForm:
    onSuccess: (operation, result, template)->
      Session.set "feedbackFormSubmitted", yes

  createCommunityForm:
    after:
      createCommunity:(error, result, template)->
        unless error
          console.log "on onSuccess"
        else
          console.log "onError",error

        $("#createCommunityModal").modal "hide"