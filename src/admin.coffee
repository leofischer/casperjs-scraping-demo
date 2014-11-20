base_path = "/home/jack/api/casperjs-scraping-demo"
base_url = "https://admin.conekta.io"
secrets = require "#{base_path}/config/secrets"
paid_charges = []

xpath = require('casper').selectXPath
casper = require("casper").create
  timeout: 110000
  waitTimeout: 100000

j = 0
fs = require('fs')
utils = require('utils')

casper.start("#{base_url}/users/sign_in")

casper.userAgent('Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:32.0) Gecko/20100101 Firefox/32.0')
casper.viewport(1366, 768)
filter = casper.cli.get(0)

casper.wait 1000, ->
  #do nothing

casper.then ->
  @echo "filling login form"
  @fill "form#new_user",
      'user[email]': secrets.conekta.username
      'user[password]': secrets.conekta.password
    , true
  @echo 'done'

casper.waitForSelector 'form.content_filters', ->
casper.wait 3000, ->
  @echo "selecting #{filter} charges"
  @click "form.content_filters input[data-filter='#{filter}']"

for i in [0..1]
  casper.wait 5000, ->
    j += 1
    @echo "looping through data rows. index: #{j}"
    dates = @getElementsInfo '#charges tbody tr td:nth-child(1)'
    types = @getElementsInfo '#charges tbody tr td:nth-child(2)'
    messages = @getElementsInfo '#charges tbody tr td:nth-child(4)'
    amounts = @getElementsInfo '#charges tbody tr td:nth-child(5)'

    for i in [0..dates.length - 1]
      paid_charges.push
        date: dates[i].text
        type: types[i].text
        message: messages[i].text
        amount: amounts[i].text

    @click '#charges_next'

casper.then ->
  utils.dump paid_charges
  fs.write "#{base_path}/data/#{filter}.json", JSON.stringify(paid_charges), 'w'

  @echo 'done'

#casper.wait 100000, ->
#do nothing and keep slimer alive

casper.run()
