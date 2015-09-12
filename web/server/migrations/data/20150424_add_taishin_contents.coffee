
addTaishinContentHandler =
  TODO: (job)->
    console.log "[in addTaishinContentHandler TODO]"
    finishedAtKey = ["finished", job.status, "At"].join "_"

    # set new image for taishin course

    courseId = "TaishinCrawler"

    db.courses.update {_id:courseId}, {$set:dockerImageTag:"c3h3/r-nlp:sftp"}, (err)->
      if err
        console.log "update taishin course fail:", err
      else
        console.log "update taishin course success"


    slides = [
      {_id: courseId + "week1", title: "Week1", url:"http://wudukers.github.io/Taishin_R_Crawler/Week1"}
      {_id: courseId + "week2", title: "Week2", url:"http://wudukers.github.io/Taishin_R_Crawler/Week2"}
      {_id: courseId + "week3", title: "Week3", url:"http://wudukers.github.io/Taishin_R_Crawler/Week3"}
      {_id: courseId + "week4", title: "Week4", url:"http://wudukers.github.io/Taishin_R_Crawler/Week4"}

    ]

    for item in slides
      if db.slides.find(item).count() is 0
        slideId = db.slides.insert item
        db.courseJoinSlides.insert {courseId:courseId, slideId:slideId}


    db.courseJoinDockerImageTags.remove {courseId:courseId, tag:"c3h3/dsc2014tutorial:latest" }, (err)->
      if err
        console.log "remove courseJoinDockerImageTags fail", err
      else
        console.log "remove courseJoinDockerImageTags success"

    db.courseJoinDockerImageTags.insert {courseId:courseId, tag:"c3h3/r-nlp:sftp" }, (err)->
      if err
        console.log "insert courseJoinDockerImageTags fail", err
      else
        console.log "insert courseJoinDockerImageTags success"


    updateData =
      status: "FINISHED"

    updateData[finishedAtKey] = new Date

    job.collection.update {_id:job.id}, {$set:updateData}



  FINISHED: (job)->
    console.log "[in addTaishinContentHandler FINISHED]"


Meteor.startup ->
  migrateJob = new Migration.Job "add new content in Taishin Course", addTaishinContentHandler
  migrateJob.handle