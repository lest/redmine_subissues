require_dependency 'application_helper'

module ApplicationHelper
  def link_to_if_authorized_with_subissues(name, options = {}, html_options = nil, *parameters_for_method_reference)
    result = ''
    if options[:controller] == 'issues' && options[:action] == 'edit' && options[:id]
      result += link_to_if_authorized(l(:button_add_subissue),
                                      {:controller => 'issues', :action => 'new', :project_id => @project, 'issue[parent_id]' => @issue.id},
                                      :class => 'icon icon-add', :accesskey => accesskey(:add)) + "\n"
    end
    result += link_to_if_authorized_without_subissues(name, options, html_options, *parameters_for_method_reference)
    result
  end

  alias_method_chain :link_to_if_authorized, :subissues
end
