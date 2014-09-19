Redmine LDAP Sync OU to Group
=============================

This is a hook version of redmine_ldap_ou_to_group plugin by Yi Zhang (yzhanginwa). Only the call mechanism has been changed from AuthSourceLdap method hijack to controller_account_success_authentication_after hook. These changes altered the structure so much that I decided to separate the project.

Adding the groups in the controller_account_success_authentication_after hook also ensures that the user is always created when the groups are processed from LDAP. This solves issue in the original plugin where groups are not synced on the first login (on-the-fly registration). However, the account used for LDAP access does not work as Redmine user account.
