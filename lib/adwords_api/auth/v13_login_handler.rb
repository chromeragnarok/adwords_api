#!/usr/bin/ruby
#
# Authors:: api.sgomes@gmail.com (Sérgio Gomes)
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
# Handles v13 authentication.

require 'ads_common/auth/base_handler'

module AdwordsApi
  module Auth
    class V13LoginHandler < AdsCommon::Auth::BaseHandler

      # Ensure that clientEmail and clientCustomerId are always present
      def header_list(credentials)
        creds = credentials.keys.dup
        creds << :clientEmail unless creds.include? :clientEmail
        creds << :clientCustomerId unless creds.include? :clientCustomerId
      end
    end
  end
end
