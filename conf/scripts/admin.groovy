#!groovy
import hudson.security.*
import jenkins.model.*

def instance = Jenkins.getInstance()
def env = System.getenv()

println "--> Checking if security has been set already"

if (!instance.isUseSecurity()) {
    println "--> creating local user 'admin'"

    def hudsonRealm = new HudsonPrivateSecurityRealm(false)
    hudsonRealm.createAccount(env['JENKINS_ADMIN_USERNAME'], env['JENKINS_ADMIN_PASSWORD'])
    instance.setSecurityRealm(hudsonRealm)

    def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
    instance.setAuthorizationStrategy(strategy)
    instance.save()
}
