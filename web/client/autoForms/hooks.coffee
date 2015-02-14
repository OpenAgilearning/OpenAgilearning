AutoForm.hooks 
  profileUpdate:
    onSuccess: (updateProfile, result, template) ->
      $(".show-profile").toggle()
      $(".profile-editor").toggle()

AutoForm.hooks
  setEnvUserConfigs: 
    onSuccess: (operation, result, template)->
      Session.set "userConfigId", ""
      Session.set "envConfigTypeId", ""

AutoForm.hooks
  courseInfoAdminEditor:
    onSuccess: (operation, result, template)->
      $("#courseInfoAdminEditorModal").modal "hide"