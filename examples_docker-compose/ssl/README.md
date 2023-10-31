# SSL

Options:
* Let's Encrypt (Recomended!)
  * [acme.sh](https://github.com/acmesh-official/acme.sh)
  * [getssl](https://github.com/srvrco/getssl)
  * [certbot](https://certbot.eff.org/)
  * or with Proxy (e.g. Traefik, NginxProxyManager)
* easy-rsa (CA for self signed certificates)
  * [easy-rsa](https://github.com/OpenVPN/easy-rsa)
  * Docker Image & Example: https://github.com/Tob1as/docker-tools#easy-rsa
* self signed certificate: `openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes -subj "/C=/ST=/L=/O=Container\ Group/CN=Linux-Community" -keyout ./ssl.key -out ./ssl.crt -addext 'subjectAltName=DNS:example.com,DNS:www.example.com'`  
(`--addtext` with subjectAltName is optional)

If you need a cacerts.jks (TrustStore) for Java, then see in comments in this [file](https://github.com/Tob1as/docker-kubernetes-collection/blob/master/examples_k8s/ca-jks-files-secret.yaml#L8-L23).  
For KeyStore read [stackoverflow.com/questions/906402](https://stackoverflow.com/questions/906402/how-to-import-an-existing-x-509-certificate-and-private-key-in-java-keystore-to).
