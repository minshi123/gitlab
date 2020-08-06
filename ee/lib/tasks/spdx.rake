# frozen_string_literal: true

require 'net/http'
require 'gitlab/json'

namespace :spdx do
  desc 'SPDX | Import copy of the catalogue to store it offline'
  task :import do
    spdx_url = 'https://spdx.org/licenses/licenses.json'
    resp = Net::HTTP.get_response(URI.parse(spdx_url))
    data = Gitlab::Json.parse(resp.body)

    File.open('vendor/spdx.json', 'w') do |f|
      f.write(data.to_json)
    end
  end
end
