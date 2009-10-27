require_dependency 'issues_helper'

module IssuesHelper
  def issues_hierarchy(issue)
    root = issue.materialized_path.split('-').first
    Issue.find(:all,
               :conditions => ['materialized_path LIKE ?', root + '%'],
               :order => 'materialized_path')
  end
end
