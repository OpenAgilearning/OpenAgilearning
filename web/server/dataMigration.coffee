
new Mongo.Collection "migrationJobs"


@Migration =
  Job: class MigrationJob extends Class.Job
    collection: db.migrationJobs

