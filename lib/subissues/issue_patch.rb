module Subissues
  module IssuePatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable

        belongs_to :parent, :class_name => 'Issue', :foreign_key => 'parent_id'
        has_many :children, :class_name => 'Issue', :foreign_key => 'parent_id'

        validates_each :parent_id do |record, attr, value|
          @valid = lambda do |issue|
            return false if issue.id == value
            this_valid = true
            issue.children.each do |child|
              this_valid = false if !@valid.call(child)
            end
            this_valid
          end
          record.errors.add attr, 'invalid' unless record.parent.nil? || @valid.call(record)
          record.errors.add attr, 'project invalid' unless record.parent.nil? || record.parent.project_id == record.project_id
          record.errors.add attr, 'too deep hierarchy' unless record.parent.nil? || record.parent.hierarchy_level < 4 || record.id == value
        end

        alias_method_chain :create_journal, :subissues
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def build_materialized_path(do_save = true)
        write_attribute(:materialized_path, (parent ? "#{parent.materialized_path}-" : '') + '%016x' % id)
        save if do_save
        children.each do |child|
          child.parent = self
          child.build_materialized_path
          child.save
        end
      end

      def hierarchy_level
        materialized_path.split('-').size - 1
      end

      def root
        self.class.find(materialized_path.split('-').first.to_i)
      end

      def leaf?
        children.empty?
      end

      def despedants
        self.class.scoped(:conditions => ['materialized_path LIKE ?', materialized_path + '-%'])
      end

      def self_and_despedants
        self.class.scoped(:conditions => ['materialized_path LIKE ?', materialized_path + '%'])
      end

      def spent_hours_with_despedants
        @hours = 0.0
        self_and_despedants.each { |issue| @hours += issue.spent_hours }
        @hours
      end

      def estimated_hours_with_despedants
        @hours = 0.0
        self_and_despedants.each { |issue| @hours += (issue.estimated_hours || 0.0) }
        @hours
      end

      def build_done_ratio
        if self.children
          total_planned_hours = 0.0
          total_actual_hours = 0.0
          self.children.each do |child|
            planned_hours = child.estimated_hours_with_despedants
            actual_hours = child.done_ratio ? planned_hours * child.done_ratio / 100 : 0.0
            total_planned_hours += planned_hours
            total_actual_hours += actual_hours
          end
          total_done_ratio = total_planned_hours != 0 ? (total_actual_hours * 100 / total_planned_hours).floor : 0
          self.done_ratio = total_done_ratio
          self.save
          self.parent.build_done_ratio if self.parent
        end
      end

      # Saves the changes in a Journal
      # Called after_save
      def create_journal_with_subissues
        if @current_journal
          # attributes changes
          (Issue.column_names - %w(id description lock_version created_on updated_on parent_id materialized_path)).each {|c|
            @current_journal.details << JournalDetail.new(:property => 'attr',
                                                          :prop_key => c,
                                                          :old_value => @issue_before_change.send(c),
                                                          :value => send(c)) unless send(c)==@issue_before_change.send(c)
          }
          # custom fields changes
          custom_values.each {|c|
            next if (@custom_values_before_change[c.custom_field_id]==c.value ||
                      (@custom_values_before_change[c.custom_field_id].blank? && c.value.blank?))
            @current_journal.details << JournalDetail.new(:property => 'cf', 
                                                          :prop_key => c.custom_field_id,
                                                          :old_value => @custom_values_before_change[c.custom_field_id],
                                                          :value => c.value)
          }      
          @current_journal.save
        end
      end
    end
  end
end
