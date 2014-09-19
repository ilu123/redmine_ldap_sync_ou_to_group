class SuccessfulAuthenticationListener
  class Hooks < Redmine::Hook::ViewListener
    def controller_account_success_authentication_after(context = {})
      user = context[:user]
      AuthSourceLdap.all.each do |source|
        attrs = source.ignore_ldap_account_get_user_dn(user.login)
        ous = parse_ou_from_dn(attrs[:dn])
        sync_ou_to_group(user, ous)
      end
    end

    def parse_ou_from_dn(str)
      str.split(/,\s*/).select{|i| i =~ /^OU=.+$/i}.map{|s| s[3, s.size]}
    end

    def sync_ou_to_group(user, ous)
      member_of_groups = user.groups.map{|g|g.name}
      ous.each do |ou|
        next if member_of_groups.include?(ou)
        group = try_to_create_group_from_ou(ou)
        user.groups << group 
      end
    end

    def try_to_create_group_from_ou(ou)
      unless (g = Group.find_by_lastname(ou))
        g = Group.new
        g.lastname = ou
        g.auth_source_id = self.id
        g.save!
      end
      g
    end
  end
end
