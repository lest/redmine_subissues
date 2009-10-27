require_dependency 'issues_controller'

class IssuesController < ApplicationController
  unloadable

  skip_before_filter :authorize, :only => [:parent_info]

  def parent_info
    @issue = params[:id] ? Issue.find(params[:id]) : Issue.new
    if (params[:parent_id])
      @issue.parent_id = params[:parent_id]
    end
    @issue.valid?
    render :partial => 'parent_info'
  end
end
