
Migration =
  removePrivateCourse: ->
    console.log "[data migration]", "removePrivateCourse"


if ENV.isStaging or ENV.isProduction
  Migration.removePrivateCourse()