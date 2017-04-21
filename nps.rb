require 'rubygems'
require 'uri'
require 'net/http'
require 'net/https'
require 'json'

class Nps
  def initialize
    @nps_by_user = {}
  end

  def get_historical_data
    (1..12).each do |month|
      start_ts = (Time.now.to_i - month * 30 * 24 * 60 * 60) * 1000
      query = form_query(30, start_ts)
      results = perform_query(query.to_json)

      break if results == nil

      results.each do |row|
        @nps_by_user["#{row['accountId']}+#{row['visitorId']}"] = {'time' => row['time'], 'response' => row['response']}
      end
    end
  end

  def get_last_month
      start_ts = (Time.now.to_i - 1 * 30 * 24 * 60 * 60) * 1000
      query = form_query(30, start_ts)
      results = perform_query(query.to_json)
      results.each do |row|
        #puts row
        @nps_by_user["#{row['accountId']}+#{row['visitorId']}"] = {'time' => row['time'], 'response' => row['response']}
      end
  end

  def form_query(range, first_ts)
        {
          "response"=> {
            "mimeType"=> "application/json"
          },
          "request"=> {
            "requestId"=> "npsResults",
            "pipeline"=> [
              {
                "source"=> {
                  "pollsSeen"=> {
                     "guideId" => "xNG03TrUPRE0EQK9iahDTNn_Wkg",
                     "pollId" => "qs5cimm4ctnmte29"
                  },
                  "timeSeries"=> {
                    "period"=> "dayRange",
                    "count"=> range,
                    "first"=> "#{first_ts}"
                  }
                }
              },
              {
                "cat"=> nil
              }
            ]
          }
        }
  end

  def perform_query(query_json)
    puts 'Querying Pendo API: ' + query_json
    uri = URI.parse("https://app.pendo.io/api/v1/aggregation")
    https = Net::HTTP.new(uri.host,uri.port)
    https.use_ssl = true
    header = {"X-Pendo-Integration-Key" => ENV["PENDO_API_TOKEN"]}
    req = Net::HTTP::Post.new(uri.path, header)
    req.body = query_json.gsub(/\s+/, "")
    req["Content-Type"] = "application/json"

    begin
      res = https.request(req)
      hashResponse = JSON.parse(res.body)
      puts hashResponse
      hashResponse['results']
    rescue => e
      puts e
    end
  end
end

Nps.new.get_last_month
