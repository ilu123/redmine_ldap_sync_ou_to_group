require 'redmine'

require_dependency 'successful_authentication_listener'

Redmine::Plugin.register :redmine_ldap_sync_ou_to_group do
  name 'Redmine LDAP Sync OU To Group plugin'
  author 'Vilppu Vuorinen'
  description 'This is a hook version of redmine_ldap_ou_to_group plugin by Yi Zhang (yzhanginwa). Only the call mechanism has been changed from AuthSourceLdap method hijack to controller_account_success_authentication_after hook. These changes altered the structure so much that I decided to separate the project.'
  version '0.0.1'
  url 'http://github.com/vilppuvuorinen/redmine_ldap_sync_ou_to_group'
end

RedmineApp::Application.config.after_initialize do
  require_dependency 'auth_source_ldap_get_dn_patch'
end
