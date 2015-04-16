
new Mongo.Collection "migrationJobs"

@Migration =
  Job: class MigrationJob extends Class.Job
    collection: db.migrationJobs

  removePrivateCourse: ->
    console.log "[data migration]", "removePrivateCourse"


if ENV.isStaging or ENV.isProduction
  Migration.removePrivateCourse()