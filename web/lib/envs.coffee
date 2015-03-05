@ENV = {}

if Meteor.isClient
  handsOnApis =
    isProduction:
      desc:
        get: ->
          Meteor.settings.public.environment is "production"

    isStaging:
      desc:
        get: ->
          Meteor.settings.public.environment is "staging"

    isDev:
      desc:
        get: ->
          Meteor.settings.public.environment is "development"

  for api in Object.keys(handsOnApis)
    Object.defineProperty ENV, api, handsOnApis[api].desc



if Meteor.isServer
  handsOnApis =
    isProduction:
      desc:
        get: ->
          Meteor.settings.environment is "production"

    isStaging:
      desc:
        get: ->
          Meteor.settings.environment is "staging"

    isDev:
      desc:
        get: ->
          Meteor.settings.environment is "development"

  for api in Object.keys(handsOnApis)
    Object.defineProperty ENV, api, handsOnApis[api].desc
