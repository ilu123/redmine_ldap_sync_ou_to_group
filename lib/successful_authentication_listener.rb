class SuccessfulAuthenticationListener
    def self.parse_ou_from_dn(str)
      return [] if str.nil?
      str.split(/,\s*/).select{|i| i =~ /^OU=.+$/i}.map{|s| s[3, s.size]}
    end

    def self.sync_ou_to_group(user, ous, source)
      member_of_groups = user.groups.map{|g|g.name}
      ous.each do |ou|
        next if ou.nil? || member_of_groups.include?(ou) 
        group = try_to_create_group_from_ou(ou, source)
        user.groups << group 
      end
    end

    def self.try_to_create_group_from_ou(ou, source)
      unless (g = Group.find_by_lastname(ou))
        g = Group.new
        g.lastname = ou
        g.auth_source_id = source.id
        g.save!
      end
      g
    end

  class Hooks < Redmine::Hook::ViewListener
    def controller_account_success_authentication_after(context = {})
      user = context[:user]
      source = AuthSourceLdap.find(user.auth_source_id)
      attrs = source.ignore_ldap_account_get_user_dn(user.login)
      unless attrs.nil?
        ous = SuccessfulAuthenticationListener.parse_ou_from_dn(attrs[:dn])
        SuccessfulAuthenticationListener.sync_ou_to_group(user, ous, source)
      end
    end
  end
end
