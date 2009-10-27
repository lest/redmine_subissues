class UpdateIssueMaterializedPath < ActiveRecord::Migration
  def self.up
    Issue.find_in_batches do |issues|
      issues.each do |issue|
        issue.build_materialized_path
      end
    end
  end
end
