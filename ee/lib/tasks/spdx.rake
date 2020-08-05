# frozen_string_literal: true

require 'net/http'

namespace :spdx do
  desc 'SPDX | Import copy of the catalogue to store it offline'
  task :import do
    resp = Net::HTTP.get_response(URI.parse('https://spdx.org/licenses/licenses.json'))
    data = resp.body

    fJson = File.open("vendor/spdx.json","w")
    fJson.write(data)
    fJson.close
  end
end
