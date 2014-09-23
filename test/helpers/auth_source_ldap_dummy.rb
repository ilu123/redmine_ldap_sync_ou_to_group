#require File.expand_path(File.dirname(__FILE__) + '/../../../../app/models/auth_source_ldap')
require File.expand_path(File.dirname(__FILE__) + '/../../test/test_helper')

module AuthSourceLdapDummy
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.send(:alias_method, :ignore_ldap_account_get_user_dn, :ignore_ldap_account_get_user_dn_dummy)
  end

  module InstanceMethods
    def ignore_ldap_account_get_user_dn_dummy(str)
      return nil if str.eql? "invalid_user"
      "CN=#{str},OU=ou1,OU=ou2,ou=,DC=example,DC=com"
    end
  end
end
