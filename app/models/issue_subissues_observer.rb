class IssueSubissuesObserver < ActiveRecord::Observer
  unloadable

  observe :issue

  def after_create(issue)
    issue.build_materialized_path
  end

  def before_save(issue)
    issue.build_materialized_path(false) if !issue.new_record? && issue.parent_id_was != issue.parent_id
  end

  def after_save(issue)
    issue.parent.build_done_ratio if issue.parent
  end

  def before_destory(issue)
    issue.children.each do |child|
      child.parent = issue.parent
      child.build_materialized_path
    end
  end
end
