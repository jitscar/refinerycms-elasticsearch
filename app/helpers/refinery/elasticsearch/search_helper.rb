module Refinery
  module Elasticsearch
    module SearchHelper
      def result_type(result)
        result.klass.name
      end

      def result_icon(result)
        icon = case result.klass.name
        when 'Refinery::Image' then 'photo'
        when 'Refinery::Resource' then 'save'
        else 'page'
        end
        "<i class=\"fi-#{icon}\"></i>".html_safe
      end

      def result_title(result)
        return result.display_title if result.respond_to?(:display_title)
        return result.fullname if result.respond_to?(:fullname)
        return result.title if result.respond_to?(:title)
        result.record.title || result.record.to_s
      end

      def result_url(result)
        return result.url if result.respond_to?(:url)
        return nil if result.record.nil?
        refinery.send(Refinery.route_for_model(result.klass, :admin => false), result.record)
      end

      def result_highlight(result)
        content_tag :div, class:'preview' do
          result.highlight.collect do |field, highlights|
            content_tag :span, class:field do
              highlights.join(' … ').html_safe
            end
          end.join(', ').html_safe
        end if result.has_highlight?
      end
    end
  end
end
