# jenkins-rancher
Rancher and docker compose templates for launching Jenkins cluster

## Jenkins Core Configuration

* *Jenkins root url* (variable JENKINS\_ROOT\_URL) is the URL with which this Jenkins instance is reachable
* *Time Zone* (variable JENKINS\_TIMEZONE) is the Time Zone for this Jenkins instance
* *Plugins* (variable JENKINS\_PLUGINS) is the list of Plugins installed in addition to the base ones used by this template
* *Node Labels* (variable NODE\_LABELS) specific labels to use on the Jenkins slaves created by this template
* *Slave executors* (variable SLAVE\_EXECUTORS) number of executors to have on the slaves created by this template
* *Slave username used to join* (variable JENKINS\_SWARM\_USERNAME) the username the slaves will use to register to the Jenkins Master
* *Slave password used to join* (variable JENKINS\_SWARM\_PASSWORD) the password the slaves will use to register to the Jenkins Master
* *Shared Pipeline Library Repository* (variable JENKINS\_PIPELINE\_LIB\_REPO) Repository of the Groovy Shared Library (see the [Jenkins Shared Library](#Jenkins-Shared-Library) section)
* *Custom configuration repository* (variable JENKINS\_GITHUB\_CONFIG\_REPO) Repository for the Teams configurations (and others to come), should be private and only accessible with the *Github Token* (see the [Github Integration](#Github-Integration) section)
* *Shared Pipeline Library Name* (variable JENKINS\_PIPELINE\_LIB\_NAME) Name of the shared Library (see the [Jenkins Shared Library](#Jenkins-Shared-Library) section)
* *Initial dsl repo* (variable JENKINS\_INITIAL\_DSL\_REPO) The Repository containing the helpers (see the [Github Integration](#Github-Integration) section)
* *The branch of the repository containing the initial dsl script* (variable JENKINS\_INITIAL\_DSL\_BRANCH) The branch to use in the *Initial dsl repo* (see the [Github Integration](#Github-Integration) section)
* *Docker Volume Driver for jenkins master data* (variable JENKINS\_MASTER\_DATA\_VOLUME\_DRIVER) The Docker Volume driver to use for the JENKINS\_HOME of the Jenkins Master.

The flow is as follows:
1. The template is started, creates the sidekick *master-conf*
2. The container *master-conf* will download the plugins defined in *Plugins* (if a specific version of the dependencies is needed, it should be placed in the list too)
3. The container *master* is then started using the volume where *master-conf* downloaded the plugins (in addition to other volumes including a permanent named volume)
4. The startup of the *master* container, will copy the plugins downloaded in *master-conf* to the final location (inside the named volume) (note this is racy with the download of plugins, if the jenkins master is not setup with all *Plugins*, restart it)
5. The Jenkins master instance is then started and configured
6. The [Authentication](#Authentication) is setup
7. The [Github Integration](#Github-Integration) is setup
8. The [Jenkins Shared Library](#Jenkins-Shared-Library) is setup
9. Slaves are started and use the credentials *Slave username used to join* and *Slave password used to join* to connect to the master

## Authentication<a name="Authentication"></a>

Authentication is performed against an LDAP server.

* *LDAP Servers* (variable JENKINS\_LDAP\_SERVER) is used to point to the appropriate LDAP server for authentication
* *LDAP CA Certificate* (variable JENKINS\_LDAP\_CA\_CRT) is used to verify the LDAP SSL/TLS Certificate (if the CA is trusted by debian jessie, there is no need to setup this value)
* *LDAP Root DN* (variable JENKINS\_LDAP\_ROOT\_DN) is the root of every LDAP search performed by Jenkins
* *LDAP User Search Base* (variable JENKINS\_LDAP\_USER\_SEARCH\_BASE) is prefixed to *LDAP Root DN* and the result is the complete BaseDN for User Search
* *LDAP Group Search Base* (variable JENKINS\_LDAP\_GROUP\_SEARCH\_BASE) is prefixed to *LDAP Root DN* and the result is the complete BaseDN for Group Search
* *LDAP User Search Base Filter* (variable JENKINS\_LDAP\_USER\_SEARCH\_FILTER) is used to filter elements in the User Search BaseDN and also find the DN of the username given in authentication.
* *LDAP Group Search Base Filter* (variable JENKINS\_LDAP\_GROUP\_SEARCH\_FILTER) is used to filter elements in the Group Search BaseDN and also find the DN of a group name.
* *LDAP Manager User* (variable JENKINS\_LDAP\_MANAGER\_USER\_DN) is the DN for the Service Account, used to find the UserDN when a user tries to login
* *LDAP Manager User Password* (variable JENKINS\_LDAP\_MANAGER\_USER\_PASSWORD) is the password of the Service Account
* *Admin Groupname (LDAP)* (variable JENKINS\_ADMIN\_GROUPNAME) is the LDAP group to identify the Jenkins Administrators

The flow is as follows:

1. A user tries to login, provides his username and password.
2. Jenkins uses the Service Account to find the UserDN, inside the *LDAP User Search Base* + *LDAP Root DN* baseDN using the *LDAP User Search Base Filter*
3. If a UserDN is found with the request, the password is used in conjunction with the UserDN to authenticate the user
4. The groups the user is member of (an ldap server requiring memberOf attribute is necessary), are found, and the GroupDN is queried with *LDAP Group Search Base* + *LDAP Root DN* as baseDN and using *LDAP Group Search Base Filter*
5. All groups matchin the previous request are added to the profile of the user
6. If the user is member of *Admin Groupname (LDAP)* he is granted administrative rights on the Jenkins Instance

## GitHub Integration<a name="Github-Integration"></a>

This Jenkins instance will be setup for github integration. All integration steps are performed using the initial groovy script.
The script is fetched from the repository defined in *Initial Groovy DSL Repository* (variable JENKINS\_INITIAL\_DSL\_REPO).

To help github integration, some questions are mandatory:

* *Github Organisation* (variable JENKINS\_GITHUB\_ORG) is the organisation that owns the repositories Jenkins will operate on (fetch the code from)
* *Github User* (variable JENKINS\_GITHUB\_USER) is used to list all the repositories of the *Github Organisation* and check if they contain a Jenkinsfile
* *Github Token* (variable JENKINS\_GITHUB\_TOKEN) is the GitHub token used to authenticate the *Github User*
* *Github Pipeline Token* (variable JENKINS\_GITHUB\_PIPELINE\_TOKEN) is used to authenticate the *Github User* for actions on the repository (clone and write build state)
* *Github SSH private key* (variable JENKINS\_GITHUB\_SSH\_PRIVATE\_KEY) SSH Key to be used to checkout repositories via SSH.

The flow is as follows:

1. Jenkins starts normally
2. At startup, Jenkins adds a initial Job visible only to Jenkins Admins to execute the Initial Groovy DSL script for teams configuration.
3. An Admin user login and executes the job "admin/00\_initial\_dsl\_job"
4. The "admin/00\_initial\_dsl\_job" Job clones the repository from *Custom configuration repository* containing the List of Teams and uses the teams.list file to create the Teams in Jenkins
5. The "admin/00\_initial\_dsl\_job" Job creates a Job for each Team (Job is *Team Name*/Auto-Generate Pipelines)
6. The "admin/00\_initial\_dsl\_job" Job creates the Job "admins/01\_team\_credentials\_and\_allocated\_slaves".
7. The Admin user executes the job "admin/01\_team\_credentials\_and\_allocated\_slaves". This will configure teams credentials and slaves allocations.
8. A Team member logs-in and executes *Team Name*/Auto-Generate Pipelines
9. The job scans the organisation using the Team token defined in the teams.list file, and adds a job for each repository containing a Jenkinsfile
10. The Team member configures the github service to notify the jenkins instance of changes in the repository (using the *Jenkins (github)* service not the *Jenkins (git)* one)

## Jenkins Shared Library<a name="Jenkins-Shared-Library"></a>

To help the creation of pipelines, some parts can be factored out using shared libraries, to have secrets outside the scope of these libraries, these secrets are put into the [Credentials plugin](https://wiki.jenkins-ci.org/display/JENKINS/Credentials+Plugin).

These secrets are the following:

For email sending:

* *Jenkins Mail User* (variable JENKINS\_MAIL\_USER)
* *Jenkins Mail Password* (variable JENKINS\_MAIL\_PASSWORD)
* *Jenkins Mail Adress* (variable JENKINS\_MAIL\_ADDRESS)
* *Jenkins Mail Smtp Host* (variable JENKINS\_MAIL\_SMTP\_HOST)
* *Jenkins Mail Smtp Port* (variable JENKINS\_MAIL\_SMTP\_PORT)
* *Jenkins Mail Smtp SSL* (variable JENKINS\_MAIL\_SMTP\_SSL)

For HipChat integration:

* *HipChat token* (variable JENKINS\_HIPCHAT\_TOKEN)

## Upgrade Notes

### Upgrading from version prior to "v2.32.3-11"
Please note that the volume for the Jenkins master's JENKINS\_HOME changed scope. When doing a stack upgrade, the new Jenkins Master container will not have the previous data.
To recover the data, one can go on the host and find the old volume (which is called "jenkins-home") and copy this data to the new volume which can be found in rancher-ui (the name is generated from a template: *stack\_name* + "\_jenkins-home\_" + *random\_number*).
