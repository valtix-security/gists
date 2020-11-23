# Root CA

```
openssl genrsa -out myca.key 2048
# password protect key: openssl genrsa -out myca.key -des3 2048
openssl req -x509 -new -key myca.key -sha256 -days 1825 -out myca.crt \
  -subj "/C=US/ST=CA/L=Santa Clara/O=Org1/OU=Eng/CN=org1.com/emailAddress=services@org1.com"
```

Install the root CA on your device as a trusted root CA

# Domain/App Certficate signed using the Root CA

```
openssl genrsa -out app1.key 2048
# password protect key: openssl genrsa -out -des3 app1.key 2048
openssl req -new -key app1.key -out app1.csr \
  -subj "/C=US/ST=CA/L=Santa Clara/O=Org1/OU=Eng/CN=app1.org1.com/emailAddress=app1@org1.com"
openssl x509 -req -in app1.csr -CA myca.crt -CAkey myca.key -out app1.crt -sha256 \
  -days 3650 -CAcreateserial -extensions SAN \
  -extfile <(printf "[SAN]\nsubjectAltName=DNS:app1.dns.com,DNS:app2.dns.com,IP:192.168.10.21,IP:192.168.10.21")
```

# Intermediate CA

If you don't want to use the root CA to sign app certs, then create an intermediate CA signed by the root CA, then sign the app certs using the intermediate CA. Append the intermediate cert to the app cert. At this point the app crt has 2 certs (as a chain)

```
openssl genrsa -out interca.key 2048
# password protect key: openssl genrsa -out -des3 interca.key 2048
openssl req -new -key interca.key -out interca.csr \
  -subj "/C=US/ST=CA/L=Santa Clara/O=Org1/OU=EngInter/CN=ca1.org1.com/emailAddress=ca1@org1.com"
openssl x509 -req -in interca.csr -CA myca.crt -CAkey myca.key -out interca.crt -sha256 \
  -days 3650 -CAcreateserial -extensions SAN \
  -extfile <(printf "[SAN]\nbasicConstraints=CA:true")
```

# Domain/App Certficate signed using the Intermediate CA

```
openssl genrsa -out app1.key 2048
# password protect key: openssl genrsa -out -des3 app1.key 2048
openssl req -new -key app1.key -out app1.csr \
  -subj "/C=US/ST=CA/L=Santa Clara/O=Org1/OU=Eng/CN=app1.org1.com/emailAddress=app1@org1.com"
openssl x509 -req -in app1.csr -CA interca.crt -CAkey interca.key -out app1.crt -sha256 \
  -days 3650 -CAcreateserial -extensions SAN \
  -extfile <(printf "[SAN]\nsubjectAltName=DNS:app1.dns.com,DNS:app2.dns.com,IP:192.168.10.21,IP:192.168.10.21")
```

Append files interca.crt and app1.crt to make a combined certificate and use the combined certificate in your application. The root CA must be installed as a trusted root CA on your client machines


|OS|Command|
|-|-|
|Ubuntu| Copy crt file to `/usr/local/share/ca-certificates`, Run command `sudo update-ca-certificates`|
|CentOS| Copy crt file to `/etc/pki/ca-trust/source/anchors`, Run command `sudo update-ca-trust extract`|
|Windows| Double click the file and add the cert to Trusted Root, or Run command `certutil -addstore "Root" <crt-file>`|
