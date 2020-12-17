#!/usr/bin/env python
# This script is meant to be used in conjunction with the JSON formatted
# output of `https://github.com/cjmatta/cp-poc-terraform
# Usage: terraform output -json` | ./create_ansible_inventory.py
import json
import argparse
from jinja2 import Template
import sys

template = Template("""all:
  vars:
    ansible_connection: ssh
    ansible_user: centos
    ansible_become: true

    #### Setting Proxy Environment variables ####
    ## To set proxy env vars for the duration of playbook run, uncomment below block and set as necessary
    # proxy_env:
    #   http_proxy: http://proxy.example.com:8080
    #   https_proxy: http://proxy.example.com:8080
    ## Note: You must use Hostnames or IPs to define your no_proxy server addresses, CIDR ranges are not supported.
    #   no_proxy: http://proxy.example.com:8080

    #### SASL Authentication Configuration ####
    ## By default there will be no SASL Authentication
    ## For SASL/PLAIN uncomment this line:
    # sasl_protocol: plain
    ## For SASL/SCRAM uncomment this line:
    # sasl_protocol: scram
    ## For SASL/GSSAPI uncomment this line and see Kerberos Configuration properties below
    # sasl_protocol: kerberos

    # sasl_plain_users:
    #   user1:
    #     principal: user1
    #     password: secret
    #   user2:
    #     principal: user2
    #     password: secret
    #   user3:
    #     principal: user3
    #     password: secret

    #### Zookeeper SASL Authentication ####
    ## Zookeeper can have Kerberos (GSSAPI) or Digest-MD5 SASL Authentication
    ## By default when sasl_protocol = kerberos, zookeeper will also use sasl kerberos. It can  be configured with:
    ## When a mechanism is selected, zookeeper.set.acl=true is added to kafka's server.properties. Note: property not added when using mTLS, set manually with Custom Properties
    # zookeeper_sasl_protocol: <none/kerberos/digest>

    #### Kerberos Configuration ####
    ## Applicable when sasl_protocol is kerberos
    # kerberos_kafka_broker_primary: <Name of the primary set on the kafka brokers' principal eg. kafka>
    ## REQUIRED: Under each host set keytab file path and principal name, see below
    # kerberos_configure: <Boolean for ansible to install kerberos packages and configure this file: /etc/krb5.conf, defaults to true>
    # kerberos:
    #   realm: <KDC server realm eg. confluent.example.com>
    #   kdc_hostname: <hostname of machine with KDC running eg. ip-172-31-45-82.us-east-2.compute.internal>
    #   admin_hostname: <hostname of machine with KDC running eg. ip-172-31-45-82.us-east-2.compute.internal>

    #### TLS Configuration ####
    ## By default, data will NOT be encrypted. To turn on TLS encryption, uncomment this line
    # ssl_enabled: true
    ## By default, the components will be configured with One-Way TLS, to turn on TLS mutual auth, uncomment this line:
    # ssl_mutual_auth_enabled: true
    ## By default, the certs for this configuration will be self signed, to deploy custom certificates there are two options.
    ## Option 1: Custom Certs
    ## You will need to provide the path to the Certificate Authority Cert used to sign each hosts' certs
    ## As well as the signed certificate path and the key for that certificate for each host.
    ## These will need to be set for the correct host
    # ssl_custom_certs: true
    # ssl_custom_certs_remote_src: true # set to true if key crt and ca file already on hosts, file paths must still be set
    # ssl_ca_cert_filepath: "/tmp/certs/ca.crt" # Can be a bundle of ca certs to be included in truststore
    # ssl_signed_cert_filepath: "/tmp/certs/{{inventory_hostname}}-signed.crt" # Can be a full chain of certs
    # ssl_key_filepath: "/tmp/certs/{{inventory_hostname}}-key.pem"
    # ssl_key_password: <password for key for each host, will be inputting in the form -passin pass:{{ssl_key_password}} >
    ## Option 2: Custom Keystores and Truststores
    ## CP-Ansible can move keystores/truststores to their corresponding hosts and configure the components to use them. Set These vars
    # ssl_provided_keystore_and_truststore: true
    # ssl_keystore_filepath: "/tmp/certs/{{inventory_hostname}}-keystore.jks"
    # ssl_keystore_key_password: mystorepassword
    # ssl_keystore_store_password: mystorepassword
    # ssl_truststore_filepath: "/tmp/certs/truststore.jks"
    # ssl_truststore_password: truststorepass
    # ssl_truststore_ca_cert_alias: <alias to the ca certificate in the truststore eg. CARoot>

    #### Zookeeper TLS Configuration ####
    ## Zookeeper can also have TLS Encryption and mTLS Authentication
    ## For backwards compatibility both will be turned off by default, even if ssl_enabled is set to true
    ## To enable TLS encryption and mTLS authentication uncomment these respectively
    # zookeeper_ssl_enabled: true
    # zookeeper_ssl_mutual_auth_enabled: true

    #### Certificate Regeneration ####
    ## When using self signed certificates, each playbook run will regenerate the CA, to turn this off, uncomment this line:
    # regenerate_ca: false
    ## By default, the playbook will recreate them keystores and truststores on each run,
    ## To prevent this, uncomment this line:
    # regenerate_keystore_and_truststore: false

    #### Monitoring Configuration ####
    ## Jolokia is enabled by default. The Jolokia jar gets pulled from the internet and enabled on all the components
    ## If you plan to use the upgrade playbooks, it is recommended to leave jolokia enabled because kafka broker health checks depend on jolokias metrics
    ## To disable, uncomment this line:
    # jolokia_enabled: false
    ## During setup, the hosts will download the jolokia agent jar from Maven. To update that jar download set this var
    # jolokia_jar_url: http://<inteneral-server>/jolokia-jvm-1.6.2-agent.jar
    ## JMX Exporter is disabled by default. When enabled, JMX Exporter jar will be pulled from the Internet and enabled on the broker and zookeeper *only*.
    ## To enable, uncomment this line:
    # jmxexporter_enabled: true
    ## To update that jar download set this var
    # jmxexporter_jar_url: http://<internal-server>/jmx_prometheus_javaagent-0.12.0.jar

    #### Custom Yum Repo File (Rhel/Centos) ####
    ## If you are using your own yum repo server to host the packages, in the case of an air-gapped environment,
    ## use the below variables to distribute a custom .repo file to the hosts and skip our repo setup.
    ## Note, your repo server must host all confluent packages
    # repository_configuration: custom
    # custom_yum_repofile_filepath: /tmp/my-repo.repo

    #### Custom Apt Repo File (Ubuntu/Debian) ####
    ## If you are using your own apt repo server to host the packages, in the case of an air-gapped environment,
    ## use the below variables to distribute a custom .repo file to the hosts and skip our repo setup.
    ## Note, your repo server must host all confluent packages
    # repository_configuration: custom
    # custom_apt_repo_filepath: "/tmp/my-source.list"

    #### Confluent Server vs Confluent Kafka ####
    ## Confluent Server will be installed by default, to install confluent-kafka instead, uncomment the below
    # confluent_server_enabled: false

    #### Schema Validation ####
    ## Schema Validation with the kafka configuration is disabled by default. To enable uncomment this line:
    ## Schema Validation only works with confluent_server_enabled: true
    # kafka_broker_schema_validation_enabled: true

    #### Fips Security ####
    ## To enable Fips for added security, uncomment the below line.
    ## Fips only works with ssl_enabled: true and confluent_server_enabled: true
    # fips_enabled: true

    #### Configuring Multiple Listeners ####
    ## CP-Ansible will configure two listeners on the broker: a broker listener for the broker to communicate and an internal for the components and other clients.
    ## If you only need one listener uncomment this line:
    # kafka_broker_configure_multiple_listeners: false
    ## By default both of these listeners will follow whatever you set for ssl_enabled and sasl_protocol.
    ## To configure different security settings on the internal and external listeners set the following variables:
    # kafka_broker_custom_listeners:
    #   broker:
    #     name: BROKER
    #     port: 9091
    #     ssl_enabled: false
    #     ssl_mutual_auth_enabled: false
    #     sasl_protocol: none
    #   internal:
    #     name: INTERNAL
    #     port: 9092
    #     ssl_enabled: true
    #     ssl_mutual_auth_enabled: false
    #     sasl_protocol: scram
    ## You can even add additional listeners, make sure name and port are unique
    #   client_listener:
    #     name: CLIENT
    #     port: 9093
    #     ssl_enabled: true
    #     ssl_mutual_auth_enabled: true
    #     sasl_protocol: scram

    #### Creating Connectors ####
    ## To manage the connector configs from Ansible, set the following list of connector objects:
    ## one per connector, must have `name` and `config` properties
    ## make sure to provide the numeric values as strings
    # kafka_connect_connectors:
    #   - name: sample-connector
    #     config:
    #       connector.class: "FileStreamSinkConnector"
    #       tasks.max: "1"
    #       file: "path/to/file.txt"
    #       topics: "test_topic"

    #### Configuring Role Based Access Control ####
    ## To have CP-Ansible configure Components for RBAC and create necessary role bindings, set these mandatory variables:
    ## Note: Confluent components will be configured to connect to the "internal" listener automatically
    ## DO NOT UPDATE the internal listener
    ## Note: It is recommended to create an additional listener for external clients, but the interbroker listener would also work
    ## Note: An authentication mode must be selected on all listeners, for example (ssl_enabled=false and ssl_mutual_auth_enabled=false) or sasl_protocol=none is not supported.
    # rbac_enabled: true
    ##
    ## LDAP Users
    ## Note: Below users must already exist in your LDAP environment.  See kafka_broker vars, for LDAP connection details.
    # mds_super_user: <Your mds super user which has the ability to bootstrap RBAC roles and permissions>
    # mds_super_user_password: <ldap password>
    # kafka_broker_ldap_user: <Your Embedded Rest Proxy username in LDAP>
    # kafka_broker_ldap_password: <Your Embedded Rest Proxy user's LDAP password>
    # schema_registry_ldap_user: <Your Schema Registry username in LDAP>
    # schema_registry_ldap_password <Your schema registry user's LDAP password>
    # kafka_connect_ldap_user: <Your Connect username in LDAP>
    # kafka_connect_ldap_password: <Your Connect user's password in LDAP>
    # ksql_ldap_user: <Your KSQL username in LDAP>
    # ksql_ldap_password: <Your KSQL user's password in LDAP>
    # kafka_rest_ldap_user: <Your REST Proxy's username in LDAP>
    # kafka_rest_ldap_password: <Your REST Proxy's password in LDAP>
    # control_center_ldap_user: <Your Control Center username in LDAP>
    # control_center_ldap_password: <Your Control Center password in LDAP>
    ## Below are optional variables
    # create_mds_certs: false # To provide your own MDS Certs set this variable and the next two
    # token_services_public_pem_file: /path/to/public.pem
    # token_services_private_pem_file: /path/to/tokenKeypair.pem
    # mds_acls_enabled: false #to turn off mds based acls, they are on by default if rbac is on
    # kafka_broker_rest_ssl_enabled: true/false #defaults to whatever ssl_enabled var is set to
    ## Allow the playbooks to configure additional users as system admins on the platform, set the list below
    # rbac_component_additional_system_admins:
    #   - user1
    #   - user2
    ##
    ####  Configuring Role Based Access Control with a remote MDS ####
    ## To have CP-Ansible configure Brokers and Components for RBAC with the MDS on a remote Kafka cluster, set these mandatory variables in addition to those listed above:
    # rbac_enabled: true
    # external_mds_enabled: true
    ## The URL for the MDS REST API on your Kafka Cluster hosting MDS
    # mds_bootstrap_server_urls: http(s)://<mds-broker-hostname>:8090,http(s)://<mds-broker-hostname>:8090
    ## The URL and Port for the listener on your Kafka Cluster hosting the MDS that you wish to connect to
    # mds_broker_bootstrap_servers: <mds-broker-hostname><port>,<mds-broker-hostname><port>
    ## Configure the security settings to match the same listener as defined in the mds_broker_bootstrap_servers
    # mds_broker_listener:
    #   ssl_enabled: true <set to false if remote MDS does not use TLS>
    #   ssl_mutual_auth_enabled: true <set to false if remote MDS doe not use MTLS>
    #   sasl_protocol: none <set protocol for remote MDS, options are: kerberos, sasl_plain, sasl_scram>
    ##
    ## By default the Confluent CLI will be installed on each host *when rbac is enabled*, to stop this download set:
    # confluent_cli_download_enabled: false
    ## CLI will be downloaded from Confluent's webservers, to customize the location of the binary set:
    # confluent_cli_custom_download_url: <URL to custom webserver hosting for confluent cli>

    ## Configuring Telemetry
    ## Set the below required variables
    # telemetry_enabled: false
    # telemetry_api_key: XXXXXX
    # telemetry_api_secret: YYYYYYYYY

    ## To set custom properties for each service
    ## Find property options in the Confluent Documentation
    # zookeeper_custom_properties:
    #   initLimit: 6
    #   syncLimit: 3
    # kafka_broker_custom_properties:
    #   num.io.threads: 15
    # schema_registry_custom_properties:
    #   key: val
    # control_center_custom_properties:
    #   key: val
    # kafka_connect_custom_properties:
    #   key: val
    # kafka_rest_custom_properties:
    #   key: val
    # ksql_custom_properties:
    #   key: val

zookeeper:
  ## To set variables on all zookeeper hosts, use the vars block here
  # vars:
  #   ## To configure Zookeeper to run as a custom user, uncomment below
  #   zookeeper_user: custom-user
  #   zookeeper_group: custom-group
  #
  #   ## To copy files to zookeeper hosts, set this list below
  #   zookeeper_copy_files:
  #     - source_path: /path/to/file.txt
  #       destination_path: /tmp/file.txt
  hosts:
{%- for broker in broker_dns.value %}
    {{broker}}:
{%- endfor %}

kafka_broker:
  ## To set variables on all kafka_broker hosts, use the vars block here
  # vars:
  #   ## To configure Kafka to run as a custom user, uncomment below
  #   kafka_broker_user: custom-user
  #   kafka_broker_group: custom-group
  #   # To update the log.dirs property within the kafka server.properties, uncomment below
  #   # By default the log directory is /var/lib/kafka/data
  #   kafka_broker:
  #     datadir:
  #       - /var/lib/kafka/my-data
  #
  #   ## To enabled Self Balancing Kafka Brokers, uncomment the below lines
  #   kafka_broker_custom_properties:
  #     confluent.balancer.enable: "true"
  #
  #   ## To configure LDAP for RBAC enablement, you will need to provide the appropiate properties to connect to your LDAP server
  #   ## using the kafka_broker_custom_properties: varible under the vars block.  The following is an example:
  #   ## Note: If connecting to a remote MDS, do not set these parameters. LDAP is handled by the remote MDS.
  #   kafka_broker_custom_properties:
  #     ldap.java.naming.factory.initial: com.sun.jndi.ldap.LdapCtxFactory
  #     ldap.com.sun.jndi.ldap.read.timeout: 3000
  #     ldap.java.naming.provider.url: ldap://ldap1:389
  #     ldap.java.naming.security.principal: uid=mds,OU=rbac,DC=example,DC=com
  #     ldap.java.naming.security.credentials: password
  #     ldap.java.naming.security.authentication: simple
  #     ldap.user.search.base: OU=rbac,DC=example,DC=com
  #     ldap.group.search.base: OU=rbac,DC=example,DC=com
  #     ldap.user.name.attribute: uid
  #     ldap.user.memberof.attribute.pattern: CN=(.*),OU=rbac,DC=example,DC=com
  #     ldap.group.name.attribute: cn
  #     ldap.group.member.attribute.pattern: CN=(.*),OU=rbac,DC=example,DC=com
  #     ldap.user.object.class: account
  #
  #   ## To copy files to kafka broker hosts, set this list below
  #   kafka_broker_copy_files:
  #     - source_path: /path/to/file.txt
  #       destination_path: /tmp/file.txt
  hosts:
{%- for broker in broker_dns.value %}
    {{broker}}:
      broker_id: {{loop.index}}
{%- endfor %}

schema_registry:
  hosts:
{%- for worker in worker_dns.value %}
    {{worker}}:
{%- endfor %}

control_center:
  hosts:
    {{worker_dns.value[0]}}:
      confluent.controlcenter.connect.cluster: {% for worker in worker_dns.value -%}
        {{worker}}:8083
        {%- if not loop.last %},{% endif %}
        {%- endfor %}

kafka_connect:
  ## To set variables on all kafka_connect hosts, use the vars block here
  # vars:
  #   ## To configure Connect to run as a custom user, uncomment below
  #   kafka_connect_user: custom-user
  #   kafka_connect_group: custom-group
  #
  #   ## To copy files to kafka_connect hosts, set this list below
  #   kafka_connect_copy_files:
  #     - source_path: /path/to/file.txt
  #       destination_path: /tmp/file.txt
  #
  #   ### Connectors and the Confluent Hub
  #   # Adding Connector Paths.
  #   # NOTE: This variable is mapped to the `plugin.path` Kafka Connect property.
  #   kafka_connect_plugins_path:
  #   - /usr/share/java
  #   - /my/connectors/dir
  #
  #   ## Installing Connectors From Confluent Hub
  #   kafka_connect_confluent_hub_plugins:
  #   - jcustenborder/kafka-connect-spooldir:2.0.43
  #
  #   ## Installing Connectors from Archive files local to Ansible host
  #   kafka_connect_plugins:
  #   - local/path/to/connect_archive.zip
  #
  #   ## Installing Connectors from Archive files in remote server (ie Nexus)
  #   kafka_connect_plugins_remote:
  #   - http://myhost.com/connect_archive.zip
  #
  #   ### RBAC with Connect Secret Registry
  #   # By default the secret registry will be enabled when RBAC is on. To customize the key set this var:
  #   kafka_connect_secret_registry_key: <your own key>
  #   # To disable the feature:
  #   kafka_connect_secret_registry_enabled: false
  hosts:
{%- for worker in worker_dns.value %}
    {{worker}}:
{%- endfor %}

kafka_rest:
  hosts:
{%- for worker in worker_dns.value %}
    {{worker}}:
{%- endfor %}

ksql:
  hosts:
{%- for worker in worker_dns.value %}
    {{worker}}:
{%- endfor %}

""")

def read_stdin_json():
    try:
        input_json = json.loads(sys.stdin.read())
        return input_json
    except ValueError as e:
        print("Error: STDIN is not JSON")
        sys.exit(1)

input = read_stdin_json()

# construct the argument parser and parse the arguments
ap = argparse.ArgumentParser()
ap.add_argument("-p", "--public", action="store_true",
  help="Use public DNS from terraform, default is private")
args = ap.parse_args()

if args.public:
    dns_type = 'public'
else:
    dns_type = 'private'
template_params = {
    "worker_dns": input['worker_'+dns_type+'_dns'], 
    "broker_dns": input['broker_'+dns_type+'_dns']
}
print(template.render(template_params))