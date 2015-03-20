module Refinery
  module Elasticsearch
    class SearchController < ::ApplicationController

      # Display search results given the query supplied
      def show
        @query = sanitize_query(params[:q])
        @results = Elasticsearch.search(@query, per_page: (params[:per_page] || '10').to_i, page: (params[:page] || '1').to_i)
      rescue Faraday::ConnectionFailed,
             ::Elasticsearch::Transport::Transport::Errors::ServiceUnavailable
        flash[:alert] = ::I18n.t('refinery.elasticsearch.search.error.unavailable')
      ensure
        @results ||= Results.new
        present(@page = Refinery::Page.find_by_link_url("/search"))
      end

      def sanitize_query(str)
        # Escape special characters
        # http://lucene.apache.org/core/old_versioned_docs/versions/2_9_1/queryparsersyntax.html#Escaping Special Characters
        escaped_characters = Regexp.escape('\\/+-&|!(){}[]^~*?:')
        str.sub!(/https\:\/\//, '') if str.include? "https://"
        str.sub!(/https\/\//, '') if str.include? "https//"
        str.sub!(/http\:\/\//, '') if str.include? "http://"
        str.sub!(/http\/\//, '') if str.include? "http//"
        str.sub!(/www./, '') if str.include? "www."
        str = str.gsub(/([#{escaped_characters}])/, '') # Paste it instead 2nd param if smth. wrong: \\\\\1

        # AND, OR and NOT are used by lucene as logical operators. We need
        # to escape them
        ['AND', 'OR', 'NOT'].each do |word|
          escaped_word = word.split('').map { |char| "\\#{char}" }.join('')
          str = str.gsub(/\s*\b(#{word.upcase})\b\s*/, " #{escaped_word} ")
        end

        # Escape odd quotes
        quote_count = str.count '"'
        str = str.gsub(/(.*)"(.*)/, '\1\"\3') if quote_count % 2 == 1
        # str = str.gsub(/\//, '\/')
        str
      end

    end
  end
end