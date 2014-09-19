require 'auth_source_ldap'

module AuthSourceLdapGetDnPatch
  def self.included(base)
    base.send(:include, InstanceMethods)
  end

  module InstanceMethods
    def ignore_ldap_account_get_user_dn(login)
      return nil if self.account && self.account.include?("$login")
      get_user_dn(login, nil)
    end
  end
end

AuthSourceLdap.send(:include, AuthSourceLdapGetDnPatch)
