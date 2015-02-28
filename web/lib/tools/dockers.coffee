
@DockerTools =
  parseRepoString: (repoString)->
    lastColonIdx = repoString.lastIndexOf ':'

    if lastColonIdx < 0
      res =
        repo: repoString

    tag = repoString.slice lastColonIdx + 1

    if  tag.indexOf('/') is -1
      res =
        repo: repoString.slice(0, lastColonIdx)
        tag: tag

    res

