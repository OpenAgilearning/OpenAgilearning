Template.adminPageDockerServersTable.helpers
  settings: ->
    dockerServerNameField = 
      key: "name"
      label: "Server Name"
      
    dockerServerIPField =
      key: "connect.host"
      label: "Server IP"
     
    res=
      collection:DockerServers
      rowsPerPage:5
      showFilter: true
      fields:[dockerServerNameField, dockerServerIPField, "active", "lastUpdateAt"]


Template.adminPageDockerServerImagesTable.helpers
  settings: ->
    res =
      collection: DockerServerImages
      rowsPerPage: 10
      showFilter: true
      fields: ["serverName","tag","lastUpdateAt"]


Template.adminPageDockerServerContainersTable.helpers
  settings: ->
    portsField =
      key: "Ports"
      label: "Ports"
      tmpl: Template.adminPageDockerServerContainersTablePortsField

    res =
      collection: DockerServerContainers
      rowsPerPage: 10
      showFilter: true
      fields: ["serverName","Image",portsField,"Status","lastUpdateAt"]






