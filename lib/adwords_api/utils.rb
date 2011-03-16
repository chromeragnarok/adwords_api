#!/usr/bin/ruby
#
# Author:: sgomes@google.com (Sérgio Gomes)
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
# Contains global utility methods.

module AdwordsApi
  module Utils

    public

    # Gets a map from an array of map entries. A map entry is any object that
    # has a key and value field.
    #
    # Args:
    # - entries: list of map entries
    #
    # Returns:
    # - hash constructed from map entries
    #
    def self.map(entries)
      map = {}
      entries.each do |entry|
        map[entry[:key]] = entry[:value]
      end
      return map
    end

    # Returns the source operation index for an error
    #
    # Args:
    # - error: the error to be analyzed
    #
    # Returns:
    # - index for the source operation, nil if none
    #
    def self.operation_index_for_error(error)
      if error and error[:field_path]
        parts = error[:field_path].split('.')
        if parts.length > 0
          match = parts.first.match(/operations\[(\d)\]/)
          return match ? match[1].to_i : nil
        end
      end
      return nil
    end

    # Auxiliary method to format an ID to the pattern ###-###-####.
    #
    # Args:
    # - id: ID in unformatted form
    #
    # Returns:
    # - string containing the formatted ID
    #
    def self.format_id(id)
      str_id = id.to_s.gsub(/\D/, '')
      if str_id.size >= 7
        str_array = str_id.scan(/(\d{3})(\d{3})(\d+)/)
        str_id = str_array.join('-') unless str_array.empty?
      end
      return str_id
    end
  end
end
