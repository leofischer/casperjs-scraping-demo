spawn = require('child_process').spawn

shspawn = (command) ->
  spawn "sh", [
    "-c"
    command
  ],
    stdio: "inherit"


filters = ['paid', 'refunded', 'pending']
spawn_scraper = (filter)->
  scraper = spawn "casperjs", ["--ssl-protocol=TLSv1", "src/admin.coffee", filter]

  scraper.stdout.on 'data', (data)->
    console.log data.toString()

  scraper.stderr.on 'data', (data)->
    console.log data.toString()
    console.log 'uh oh, retrying'
    spawn_scraper(filter)

  scraper.on 'exit', (code)->
    console.log 'done, spawning another'
    if filters.length > 0
      filter = filters.pop()
      spawn_scraper(filter)


spawn_scraper(filters.pop())
