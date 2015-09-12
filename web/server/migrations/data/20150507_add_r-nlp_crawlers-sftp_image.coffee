
addNewImageHandler =
  TODO: (job)->
    console.log "[in addNewImageHandler TODO]"
    finishedAtKey = ["finished", job.status, "At"].join "_"

    # set new image for taishin course

    courseId = "TaishinCrawler"

    db.courses.update {_id:courseId}, {$set:dockerImageTag:"c3h3/r-nlp:crawlers-sftp"}, (err)->
      if err
        console.log "update taishin course fail:", err
      else
        console.log "update taishin course success"


    db.courseJoinDockerImageTags.insert {courseId:courseId, tag:"c3h3/r-nlp:crawlers-sftp" }, (err)->
      if err
        console.log "insert courseJoinDockerImageTags fail", err
      else
        console.log "insert courseJoinDockerImageTags success"

    slideId = "2015_r_crawler_for_taishin"

    db.slides.insert {_id: slideId, title: "2015 R Crawler For Taishin", url:"https://docs.google.com/presentation/d/1o0gDvQBbdGrXSkb3bqAUmor07CmxCiIZMiVJWv8iqco/embed?start=false&loop=false&delayms=3000"}

    db.courseJoinSlides.insert {courseId:courseId, slideId:slideId}

    db.courseJoinSlides.remove {courseId:courseId, slideId:$in:["TaishinCrawlerweek1","TaishinCrawlerweek2","TaishinCrawlerweek3","TaishinCrawlerweek4"]}

    updateData =
      status: "FINISHED"

    updateData[finishedAtKey] = new Date

    job.collection.update {_id:job.id}, {$set:updateData}



  FINISHED: (job)->
    console.log "[in addNewImageHandler FINISHED]"


Meteor.startup ->
  migrateJob = new Migration.Job "add new image tag in Taishin Course", addNewImageHandler
  migrateJob.handle