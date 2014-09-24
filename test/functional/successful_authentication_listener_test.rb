# Load the Redmine helpers
require File.expand_path(File.dirname(__FILE__) + '/../helpers/auth_source_ldap_dummy')
require File.expand_path(File.dirname(__FILE__) + '/../../test/test_helper')
ActiveRecord::Fixtures.create_fixtures(File.dirname(__FILE__) + '/../fixtures/',
                                       [:auth_sources])

#class SuccessfulAuthenticationListenerTest < ActionController::TestCase
#class SuccessfulAuthenticationListenerTest < ActiveSupport::TestCase
class Redmine::Hook::SuccessfulAuthenticationListenerTest < ActionView::TestCase
  fixtures  :users, :members, :projects, :roles, :member_roles, :auth_sources, 
            :trackers, :issue_statuses,
            :projects_trackers,
            :watchers,
            :issue_categories, :enumerations, :issues,
            :journals, :journal_details,
            :groups_users,
            :enabled_modules

  class TestHookHelperController < ActionController::Base
    include Redmine::Hook::Helper
  end

  Redmine::Hook.clear_listeners

  def setup
    @hook_module = Redmine::Hook
    @auth_listener = SuccessfulAuthenticationListener
    @hook_module.add_listener(SuccessfulAuthenticationListener::Hooks)
    AuthSourceLdap.send(:include, AuthSourceLdapDummy)
  end

  def teardown
    Redmine::Hook.clear_listeners
  end

  def test_parse_ou_from_dn
    assert_equal([], @auth_listener.parse_ou_from_dn(nil))
    assert_equal([], @auth_listener.parse_ou_from_dn("asd"))
    assert_equal(["orgunit"], @auth_listener.parse_ou_from_dn("OU=orgunit"))
    assert_equal(["ou1", "ou2", "ou3", "ou4", "ou5"], @auth_listener.parse_ou_from_dn("CN=user,OU=ou1,OU=ou2,ou=ou3,oU=ou4,Ou=ou5,DC=example,DC=com"))
  end

  def test_try_to_create_group
    @auth_listener.try_to_create_group_from_ou("tst_grp_001", AuthSourceLdap.find(6))
    assert_equal("tst_grp_001", Group.find_by_lastname("tst_grp_001").lastname)
    assert_equal(6, Group.find_by_lastname("tst_grp_001").auth_source_id)

    @auth_listener.try_to_create_group_from_ou("A Team", AuthSourceLdap.find(6))
    assert_equal(nil, Group.find_by_lastname("A Team").auth_source_id)
  end

  def test_sync_ou_to_group
    @auth_listener.sync_ou_to_group(User.find(1), ["ou1-1", "ou2-1", nil], AuthSourceLdap.find(6))
    assert_equal(["ou1-1", "ou2-1"], Group.last(2).map{|g|g.name})
    assert_equal(["ou1-1", "ou2-1"], User.find(1).groups.map{|g|g.name})
  end

  def test_controller_account_success_authentication_after
    user = User.find(2)
    user.auth_source_id = AuthSourceLdap.find(6).id
    user.save!
    assert_equal(6, user.auth_source_id)
    hook_helper.call_hook(:controller_account_success_authentication_after, :user => user)
    assert_equal(["ou1", "ou2"], Group.last(2).map{|g|g.name})
    assert_equal(["ou1", "ou2"], User.find(2).groups.map{|g|g.name})

    user = User.new
    user.login = "invalid_user"
    user.firstname = "fn"
    user.lastname = "ln"
    user.mail = "mail@mail.mail"
    user.auth_source_id = 6
    user.save!
    old_groups = Group.all.map{|g|g.name}
    hook_helper.call_hook(:controller_account_success_authentication_after, :user => user)
    assert_equal(old_groups, Group.all.map{|g|g.name})
  end

  def hook_helper
    @hook_helper ||= TestHookHelperController.new
  end
end
