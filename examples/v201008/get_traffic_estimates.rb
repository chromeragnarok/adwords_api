#!/usr/bin/ruby
#
# Author:: api.sgomes@gmail.com (Sérgio Gomes)
#
# Copyright:: Copyright 2011, Google Inc. All Rights Reserved.
#
# License:: Licensed under the Apache License, Version 2.0 (the "License");
#           you may not use this file except in compliance with the License.
#           You may obtain a copy of the License at
#
#           http://www.apache.org/licenses/LICENSE-2.0
#
#           Unless required by applicable law or agreed to in writing, software
#           distributed under the License is distributed on an "AS IS" BASIS,
#           WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
#           implied.
#           See the License for the specific language governing permissions and
#           limitations under the License.
#
# This example gets keyword traffic estimates.
#
# Tags: TrafficEstimatorService.get

require 'rubygems'
gem 'google-adwords-api'
require 'adwords_api'
require 'pp'

API_VERSION = :v201008

def get_traffic_estimates()
  # AdwordsApi::Api will read a config file from ENV['HOME']/adwords_api.yml
  # when called without parameters.
  adwords = AdwordsApi::Api.new
  traffic_estimator_srv = adwords.service(:TrafficEstimatorService, API_VERSION)

  # Create keywords. Up to 2000 keywords can be passed in a single request.
  keywords = [
    {
      # The 'xsi_type' field allows you to specify the xsi:type of the object
      # being created. It's only necessary when you must provide an explicit
      # type that the client library can't infer.
      :xsi_type => 'Keyword',
      :text => 'mars cruise',
      :match_type => 'BROAD'
    },
    {
      :xsi_type => 'Keyword',
      :text => 'cheap cruise',
      :match_type => 'PHRASE'
    },
    {
      :xsi_type => 'Keyword',
      :text => 'cruise',
      :match_type => 'EXACT'
    }
  ]

  # Create a keyword estimate request for each keyword.
  keyword_requests = []
  keywords.each do |keyword|
    request = {
      :keyword => keyword
    }
    keyword_requests << request
  end

  # Create ad group estimate requests.
  ad_group_request = {
    :keyword_estimate_requests => keyword_requests,
    :max_cpc => {
      :micro_amount => 1000000
    }
  }

  # Create campaign estimate requests.
  campaign_request = {
    :ad_group_estimate_requests => [ad_group_request],
    :targets => [
      {
        :xsi_type => 'CountryTarget',
        :country_code => 'US'
      },
      {
        :xsi_type => 'LanguageTarget',
        :language_code => 'en'
      }
    ]
  }

  # Create selector and retrieve reults.
  selector = {
    :campaign_estimate_requests => [campaign_request]
  }
  response = traffic_estimator_srv.get(selector)
  if response and response[:campaign_estimates]
    campaign_estimates = response[:campaign_estimates]
    keyword_estimates =
        campaign_estimates.first[:ad_group_estimates].first[:keyword_estimates]
    keyword_estimates.each_with_index do |estimate, index|
      keyword = keyword_requests[index][:keyword]

      # Find the mean of the min and max values.
      mean_avg_cpc = (estimate[:min][:average_cpc][:micro_amount] +
                      estimate[:max][:average_cpc][:micro_amount]) / 2
      mean_avg_position = (estimate[:min][:average_position] +
                           estimate[:max][:average_position]) / 2
      mean_clicks = (estimate[:min][:clicks] + estimate[:max][:clicks]) / 2
      mean_total_cost = (estimate[:min][:total_cost][:micro_amount] +
                         estimate[:max][:total_cost][:micro_amount]) / 2

      puts "Results for the keyword with text #{keyword[:text]} and match " +
          "type #{keyword[:match_type]}:"
      puts "  Estimated average CPC: %d" % mean_avg_cpc
      puts "  Estimated ad position: %.2f" % mean_avg_position
      puts "  Estimated daily clicks: %d" % mean_clicks
      puts "  Estimated daily cost: %d" % mean_total_cost
    end
  else
    puts "No traffic estimates were returned."
  end
end

if __FILE__ == $0
  # To enable logging of SOAP requests, set the ADWORDSAPI_DEBUG environment
  # variable to 'true'. This can be done either from your operating system
  # environment or via code, as done below.
  ENV['ADWORDSAPI_DEBUG'] = 'false'

  begin
    get_traffic_estimates()

  # Connection error. Likely transitory.
  rescue Errno::ECONNRESET, SOAP::HTTPStreamError, SocketError => e
    puts 'Connection Error: %s' % e
    puts 'Source: %s' % e.backtrace.first

  # API Error.
  rescue AdwordsApi::Errors::ApiException => e
    puts 'API Exception caught.'
    puts 'Message: %s' % e.message
    puts 'Code: %d' % e.code if e.code
    puts 'Trigger: %s' % e.trigger if e.trigger
    puts 'Errors:'
    if e.errors
      e.errors.each_with_index do |error, index|
        puts ' %d. Error type is %s. Fields:' % [index + 1, error[:xsi_type]]
        error.each_pair do |field, value|
          if field != :xsi_type
            puts '     %s: %s' % [field, value]
          end
        end
      end
    end
  end
end
