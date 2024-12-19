# Disable HTTPS in Keycloak
docker exec -it --user root keycloak bash

cd /opt/bitnami/keycloak/bin/

./kcadm.sh config credentials --server http://localhost:18080/auth --realm master --user admin
Logging into http://localhost:8080/auth as user admin of realm master
Enter password: admin

./kcadm.sh update realms/master -s sslRequired=NONE
