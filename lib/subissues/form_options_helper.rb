module ActionView
  module Helpers
    module FormOptionsHelper
      def select_with_subissues(object, method, choices, options = {}, html_options = {})
        if object == :issue && method == :done_ratio && options[:object].children.any?
          "#{options[:object].done_ratio}%"
        else
          select_without_subissues(object, method, choices, options, html_options)
        end
      end

      alias_method_chain :select, :subissues
    end
  end
end
