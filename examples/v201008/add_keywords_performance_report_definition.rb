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
# This example adds a keywords performance report. To get ad groups, run
# get_all_ad_groups.rb. To get report fields, run get_report_fields.rb.
#
# Tags: ReportDefinitionService.mutate

require 'rubygems'
gem 'google-adwords-api'
require 'adwords_api'

API_VERSION = :v201008

def add_keywords_performance_report_definition()
  # AdwordsApi::Api will read a config file from ENV['HOME']/adwords_api.yml
  # when called without parameters.
  adwords = AdwordsApi::Api.new
  report_def_srv = adwords.service(:ReportDefinitionService, API_VERSION)

  ad_group_id = 'INSERT_AD_GROUP_ID_HERE'.to_i
  start_date = 'INSERT_START_DATE_HERE'
  end_date = 'INSERT_END_DATE_HERE'

  # Prepare for adding report definition.
  operation = {
    :operator => 'ADD',
    :operand => {
      :selector => {
        :fields => ['AdGroupId', 'Id', 'KeywordText', 'KeywordMatchType',
                    'Impressions', 'Clicks', 'Cost'],
        :predicates => [{
          :operator => 'EQUALS',
          :field => 'AdGroupId',
          :values => [ad_group_id]
        }],
        :date_range => {
          :min => start_date,
          :max => end_date
        }
      },
      :report_name => 'Keywords performance report #%s' %
          (Time.new.to_f * 1000).to_i,
      :report_type => 'KEYWORDS_PERFORMANCE_REPORT',
      :date_range_type => 'CUSTOM_DATE',
      :download_format => 'XML'
    }
  }

  # Add report definition.
  response = report_def_srv.mutate([operation])
  if response
    response.each do |report_definition|
      puts 'Report definition with name \'%s\' and id \'%s\' was added' %
          [report_definition[:report_name], report_definition[:id]]
    end
  end
end

if __FILE__ == $0
  # To enable logging of SOAP requests, set the ADWORDSAPI_DEBUG environment
  # variable to 'true'. This can be done either from your operating system
  # environment or via code, as done below.
  ENV['ADWORDSAPI_DEBUG'] = 'false'

  begin
    add_keywords_performance_report_definition()

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
