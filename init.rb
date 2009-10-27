require 'redmine'
require 'subissues/issue_patch'
require 'subissues/issue_hook'
require 'subissues/query_patch'
require 'subissues/form_options_helper'

Redmine::Plugin.register :redmine_subissues do
  name 'Subissues plugin'
  author 'Just Lest'
  description ''
  version '0.0.1'
end

Dispatcher.to_prepare do
  Issue.send(:include, Subissues::IssuePatch) unless Issue.included_modules.include?(Subissues::IssuePatch)
  Query.send(:include, Subissues::QueryPatch) unless Query.included_modules.include?(Subissues::QueryPatch)
end

ActiveRecord::Base.observers << :issue_subissues_observer
