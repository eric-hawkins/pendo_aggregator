require 'csv'
require_relative 'fetcher'

class Aggregator
  def initialize
    @query_json ='
    {
        "response": {
            "mimeType": "application/json"
        },
        "request": {
            "requestId": "dashboardAccountingHealthBannerClicks",
            "pipeline": [
                {
                    "source": {
                        "featureEvents": {
                            "featureId": "mC9gfnpcXUq5OoDYemj3_OV5I-g"
                        },
                        "timeSeries": {
                            "period": "dayRange",
                            "count": 90,
                            "first": "now() - 90 * 24 * 3600 * 1000"
                        }
                    }
                },
                {
                    "cat": null
                }
            ]
        }
    }'
  end

  def print_day_counts
    results = Fetcher.perform_query(@query_json)
    day_counts = {}
    results.each do |row|
      #date = Time.at(row['day']/1000).strftime('%D')
      date = row['day']/1000
      if !day_counts[date]
        day_counts[date] = 1
      else
        day_counts[date] += 1
      end
    end

    day_counts.sort_by { |k, v| k }.each do |k, v|
      puts "#{k}, #{v}"
    end
  end

  def print_raw_csv
    results = Fetcher.perform_query(@query_json)

    csv_string = CSV.generate(:col_sep => "\\") do |csv|
      csv << results[0].keys

      results.each do |res|
        csv << res.values
      end
    end
    puts csv_string
  end
end
