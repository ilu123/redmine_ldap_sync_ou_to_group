# Load the Redmine helper
require File.expand_path(File.dirname(__FILE__) + '/../../test/test_helper')
ActiveRecord::Fixtures.create_fixtures(File.dirname(__FILE__) + '/../fixtures/',
                                       [:auth_sources])

#class SuccessfulAuthenticationListenerTest < ActionController::TestCase
class SuccessfulAuthenticationListenerTest < ActiveSupport::TestCase
  fixtures  :users, :members, :projects, :roles, :member_roles, :auth_sources, 
            :trackers, :issue_statuses,
            :projects_trackers,
            :watchers,
            :issue_categories, :enumerations, :issues,
            :journals, :journal_details,
            :groups_users,
            :enabled_modules

  def setup
    @auth_listener = SuccessfulAuthenticationListener.new
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

    @auth_listener.try_to_create_group_from_ou(Group.find_by_lastname("A Team"), AuthSourceLdap.find(6))
    assert_equal(1, Group.find_by_lastname("A Team").auth_source_id)

    all_grps = Group.all
    @auth_listener.try_to_create_group_from_ou(nil, AuthSourceLdap.find(1))
    assert_equal(all_grps, Group.all)
  end
end
