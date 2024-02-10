#!/bin/sh

set -eu

# Variables
CA_URL="http://ca.example.com"
CA_FILENAME_PREFIX="myorganization-"
CA_CN_PREFIX="My Organization" # need for checks

CA_ROOT_URL="${CA_URL}/pki/ca.crt"
CA_ROOT_FILENAME="${CA_FILENAME_PREFIX}ca.crt"
CA_INTERMEDIATE_URL="${CA_URL}/pki/intermediate-ca.crt"
CA_INTERMEDIATE_FILENAME="${CA_FILENAME_PREFIX}intermediate-ca.crt"
CA_TARGET_PATH="/usr/local/share/ca-certificates" # DO NOT CHANGE !

# check root permission
if [ "$(id -u)" -ne 0 ]; then echo "Please run as root!" >&2; exit 1; fi

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Download certificates using curl or wget
if [ ! -f "${CA_TARGET_PATH}/${CA_ROOT_FILENAME}" ] && [ ! -f "${CA_TARGET_PATH}/${CA_INTERMEDIATE_FILENAME}" ]; then
    if command_exists wget; then
        echo ">> Download CA Files with wget"
        wget -q --no-check-certificate ${CA_ROOT_URL} -O ${CA_TARGET_PATH}/${CA_ROOT_FILENAME}
        wget -q --no-check-certificate ${CA_INTERMEDIATE_URL} -O ${CA_TARGET_PATH}/${CA_INTERMEDIATE_FILENAME}
    elif command_exists curl; then
        echo ">> Download CA Files with curl"
        curl -sS ${CA_ROOT_URL} -o ${CA_TARGET_PATH}/${CA_ROOT_FILENAME}
        curl -sS ${CA_INTERMEDIATE_URL} -o ${CA_TARGET_PATH}/${CA_INTERMEDIATE_FILENAME}
    else
        echo ">> Neither wget nor curl is installed. Please install one of them."
        exit 1
    fi
else
    echo ">> CA files exists."
    exit 1
fi

# Update the certificate store (/etc/ssl/certs/ca-certificates.crt)
echo ">> Update Linux certificate store"
update-ca-certificates

# Check the certificate store
if command_exists openssl; then
    echo ">> Check certificate store"
    awk -v decoder='openssl x509 -noout -subject -enddate 2>/dev/null' '/BEGIN/{close(decoder)};{print | decoder}' < /etc/ssl/certs/ca-certificates.crt | grep -i "subject=CN = ${CA_CN_PREFIX}"
else
    echo ">> Check certificate store failed. Please install OpenSSL."
fi

# Update Java TrustStore
if command_exists keytool; then
    JAVA_TRUSTSTORE_PATH="${JAVA_HOME}/lib/security/cacerts"
    JAVA_TRUSTSTORE_PASSWORD="changeit"
    # When Warning message, replace "-keystore ${JAVA_TRUSTSTORE_PATH}" with "-trustcacerts -cacerts" for default Java TrustStore.
    echo ">> Update Java TrustStore"
    ${JAVA_HOME}/bin/keytool -keystore ${JAVA_TRUSTSTORE_PATH} -storepass ${JAVA_TRUSTSTORE_PASSWORD} -importcert -file ${CA_TARGET_PATH}/${CA_ROOT_FILENAME} -alias "${CA_ROOT_FILENAME%.crt}" -noprompt 2>/dev/null
    ${JAVA_HOME}/bin/keytool -keystore ${JAVA_TRUSTSTORE_PATH} -storepass ${JAVA_TRUSTSTORE_PASSWORD} -importcert -file ${CA_TARGET_PATH}/${CA_INTERMEDIATE_FILENAME} -alias "${CA_INTERMEDIATE_FILENAME%.crt}" -noprompt 2>/dev/null
    
    # Check Java TrustStore
    echo ">> Check Java TrustStore"
    ${JAVA_HOME}/bin/keytool -keystore ${JAVA_TRUSTSTORE_PATH} -storepass ${JAVA_TRUSTSTORE_PASSWORD} -list -v  2>/dev/null | grep -i "Owner: CN=${CA_CN_PREFIX}"
fi
