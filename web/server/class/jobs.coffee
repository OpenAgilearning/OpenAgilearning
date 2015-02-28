
@Class.Job = class Job
  constructor: (@_data)->




@Class.JobStatus = class JobStatus
  constructor: (@_statusName)->






@Class.JobQue = class JobQue
  constructor: (@_collection, @_statusField="status")->


@Class.DockerPullJobQue = class DockerPullJobQue extends Class.JobQue