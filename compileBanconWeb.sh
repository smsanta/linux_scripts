cd /opt/work/projects/ar-bancor-omnichannel/web
mvn -T 4C clean install -P dev -Dmaven.test.skip=true -Ddependency-check.skip=true
