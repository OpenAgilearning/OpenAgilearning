Template.adminPageDockerServersTable.helpers
  settings: ->
    dockerServerNameField =
      key: "serverId"
      label: "Server Name"

    res=
      collection:db.dockerServersMonitor
      rowsPerPage:5
      showFilter: true
      fields:[dockerServerNameField, "active", "lastInfoMonitorAt"]


Template.adminPageDockerServerImagesTable.helpers
  settings: ->
    res =
      collection: db.dockerImageTagsMonitor
      rowsPerPage: 10
      showFilter: true
      fields: ["serverId","tag","lastUpdatedAt"]


Template.adminPageDockerServerContainersTable.helpers
  settings: ->
    portsField =
      key: "Ports"
      label: "Ports"
      tmpl: Template.adminPageDockerServerContainersTablePortsField

    removeContainerBtnField =
      key: "Id"
      label: "Remove Container"
      tmpl: Template.adminPageDockerServerContainersTableRemoveContainerBtnField


    res =
      collection: db.dockerContainersMonitor
      rowsPerPage: 10
      showFilter: true
      fields: ["serverId","Image",portsField,"alive","running","Status","lastUpdatedAt", removeContainerBtnField]


Template.adminPageDockerServerContainersTableRemoveContainerBtnField.events
  "click .removeContainerBtn": (e, t)->
    containerId = $(e.target).attr "container_id"
    $(e.target).html "Stopping"
    # FIXME with delete container job queu
    Meteor.call "removeDockerServerContainer", containerId
