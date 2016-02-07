require 'rubygems'
require 'uri'
require 'net/http'
require 'net/https'
require 'json'

class Fetcher
  def self.perform_query(query_json)
    uri = URI.parse("https://app.pendo.io/api/v1/aggregation")
    https = Net::HTTP.new(uri.host,uri.port)
    https.use_ssl = true
    header = {"X-Pendo-Integration-Key" => ENV["PENDO_KEY"]}
    req = Net::HTTP::Post.new(uri.path, header)
    req.body = query_json.gsub(/\s+/, "")
    req["Content-Type"] = "application/json"

    begin
      res = https.request(req)
      hashResponse = JSON.parse(res.body)
      hashResponse['results']
    rescue => e
      puts e
    end
  end
end
