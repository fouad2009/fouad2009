# plugins/restrict_cf/init.rb
require 'redmine'

Rails.configuration.to_prepare do
  require_dependency 'issues_controller'
  require_dependency File.join(File.dirname(__FILE__), 'app/controllers/issues_controller_patch')
  IssuesController.include IssuesControllerPatch
end

Redmine::Plugin.register :restrict_cf do
  name 'Restrict Custom Fields Plugin'
  author 'Cielo Fouad'
  description 'Empêche les utilisateurs non-admin de modifier certains champs personnalisés'
  version '0.1.0'
  requires_redmine version_or_higher: '5.1.0'
end

