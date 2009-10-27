module Subissues
  class IssueHook < Redmine::Hook::ViewListener
    def view_issues_show_description_bottom(context = {})
      context[:controller].send(:render, :partial => 'subissues_list')
    end
  end
end
