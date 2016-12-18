## Getting started

1. ```mvn clean install spring-boot:repackage```
2. ```ssh-keygen -t rsa -C "insecure-deployer" -P '' -f insecure-deployer```
3. ```$ export AWS_ACCESS_KEY_ID="anaccesskey"```
   ```$ export AWS_SECRET_ACCESS_KEY="asecretkey"```
4. ```packer build packer-ami.json```
4. ```terraform plan```
5. ```terraform apply```