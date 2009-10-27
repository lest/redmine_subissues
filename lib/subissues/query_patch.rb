module Subissues
  module QueryPatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable

        alias_method_chain :available_filters, :subissues
        alias_method_chain :sql_for_field, :subissues
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def available_filters_with_subissues
        @available_filters = available_filters_without_subissues
        @available_filters['is_root'] = {:type => :list,
                                         :order => 99,
                                         :values => [[l(:field_is_root_true), 'true'],
                                                     [l(:field_is_root_false), 'false']]}
        @available_filters
      end

      def sql_for_field_with_subissues(field, operator, v, db_table, db_field, is_custom_filter = false)
        if field == 'is_root'
          sql = v.collect { |val| (val == 'true') ?
                                  "#{db_table}.parent_id IS NULL" :
                                  "#{db_table}.parent_id IS NOT NULL" }.join(' OR ')
          sql = "NOT(#{sql})" if operator != '='
          sql
        else
          sql_for_field_without_subissues(field, operator, v, db_table, db_field, is_custom_filter)
        end
      end
    end
  end
end
