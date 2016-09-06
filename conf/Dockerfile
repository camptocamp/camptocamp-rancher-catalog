FROM alpine

VOLUME ["/usr/share/jenkins/ref/init.groovy.d"]

ADD scripts/* /usr/share/jenkins/ref/init.groovy.d/

ENTRYPOINT [ "/bin/true" ]
