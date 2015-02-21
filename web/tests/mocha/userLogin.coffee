if Meteor.isClient
  MochaWeb?.testOnly ->
    describe "Meetup Login (Client)", ->
      before ->
        meetupServiceData = Package['service-configuration'].ServiceConfiguration.configurations.findOne({service:"meetup"})
        
        if not meetupServiceData
          configuration = { "service" : "meetup", "clientId" : "YOUR_OWN_ID", "secret" : "YOUR_SECRET", "loginStyle" : "redirect" }
          serviceName = "meetup"
          loginButtonsSession = Accounts._loginButtonsSession
        
          Accounts.connection.call "configureLoginService", configuration, (error, result)->
            if error
              Meteor._debug "Error configuring login service " + serviceName, error
            else
              loginButtonsSession.set 'configureLoginServiceDialogVisible', false 
        

      
      it "service-configuration has meetup data", ->
        meetupServiceData = Package['service-configuration'].ServiceConfiguration.configurations.findOne({service:"meetup"})
        chai.expect(meetupServiceData).not.to.be.null



# if Meteor.isServer
#   MochaWeb?.testOnly ->
#     Package['service-configuration'].ServiceConfiguration.configurations.remove({service:"meetup"})
