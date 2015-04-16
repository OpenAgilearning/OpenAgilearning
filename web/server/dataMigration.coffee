
new Mongo.Collection "migrationJobs"

@Migration =
  Job: class MigrationJob extends Class.Job
    collection: db.migrationJobs



migrationHandlers =
  TODO: (job)->
    console.log "[in migrationHandlers TODO]"

    finishedAtKey = ["finished", job.status, "At"].join "_"

    updateData =
      status: "FINISHED"

    updateData[finishedAtKey] = new Date

    job.collection.update {_id:job.id}, {$set:updateData}

  FINISHED: (job)->
    console.log "[in migrationHandlers FINISHED]"


testMigrationJob = new Migration.Job "testMigration", migrationHandlers
# testMigrationJob.remove

testMigrationJob = new Migration.Job "testMigration", migrationHandlers
testMigrationJob.handle