default: vault-server

.PHONY: vault-server
vault-server:
	cd vault-server && \
	terraform init && \
	terraform apply -auto-approve
	###############################################
	# Vault server is ready. Now, grab the root
	# token from the container output and store it:
	# docker logs vault_demo_ns | grep Token
	# export VAULT_TOKEN=$(docker logs $(docker ps -aqf "name=vault") 2>&1 | grep Token | awk '{print $3}')
	# ldapadd -cxD "cn=admin,dc=hashidemos,dc=com" -f learn-vault-example.ldif -w 1LearnVault
	# cd ../vault-setup && terraform apply -auto-approve
	# vault login -method=ldap -path=ldap/ username=jlundberg password=thispasswordsucks 
	#
	# Then, to configure Vault, run:
	#
	# make vault-setup
	###############################################

.PHONY: vault-setup
vault-setup:
	cd vault-setup && \
	terraform init && \
	terraform apply -auto-approve
	###############################################
	# Vault configured. Now, to generate a QR code
	# to use with Google Authenticator, run:
	#
	# vault list auth/userpass/users
	# vault list identity/entity-alias/id
	# vault read /identity/entity-alias/id/e4e7fff0-617e-0b0a-f15f-05201cba0a57
	# 
	# vault list /identity/mfa/method/totp
	# vault read /identity/mfa/method/totp/fdaaab3d-cc57-8dda-186e-5b525cd99b02
	#
	# vault list /identity/mfa/login-enforcement
	# vault read /identity/mfa/login-enforcement/totp_enforcement
	#
	#
	# make qrcode
	###############################################

qrcode: qrcode.png

qrcode.png:
	cd vault-setup && \
	./generate-qr-code.sh
	###############################################
	# Scan this code with Google Authenticator to
	# finish setting up TOTP MFA for the test user.
	# 
	# Now you can test the login script like so:
	# 
	# ./login.sh <one_time_passcode>
	###############################################
	

clean: clean-vault-setup clean-vault-server
	rm -f vault-setup/qrcode.png

clean-vault-setup:
	cd vault-setup && \
	terraform destroy -auto-approve

clean-vault-server:
	cd vault-server && \
	terraform destroy -auto-approve