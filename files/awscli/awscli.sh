#aws [\$AWS_USER]auto complete
#complete -C '/usr/local/aws/bin/aws_completer' aws

aws-conf()
	#configure aws cli and add alias
	{
	echo  "setting up aws cli config for Auth access"
	aws configure set profile.Auth.region us-west-2
	aws configure --profile Auth
	echo  "setting up aws alias, cf ~/.aws/cli/alias"
	mkdir -p ~/.aws/cli
	if [ -z "$1" ]
		then
		aliasdir="/usr/local/aws/alias"
		else
		aliasdir=$1
		fi
	ln -s $aliasdir ~/.aws/cli/alias
	git config --global credential.helper '!security delete-internet-password -l "git-codecommit.us-west-2.amazonaws.com"; aws codecommit credential-helper $@'
	git config --global credential.UseHttpPath true
	}


aws-mfa()
	{
		profile=Auth
		if [ $# -eq 1 ]
			then
				profile=$1
			fi
		read -p "please enter 6 digit  otp for aws $profile account: " awsotp
		eval `aws mfacli $profile $awsotp`
		aws-set-account $profile
	}

aws-set-account()
	{
	if [ -z "$1" ]
		then
		account="default"
		else
		account=$1
	fi
	eval `aws setcred $account`
	export AWS_ACCOUNT=$account
	export AWS_USER=`aws cwu`
	}

# assume role into account
# aws-arole ucpathbuild  awsauth/AccountAdmin
aws-arole()
	{
	aws-set-account Auth && aws-set-token $1  $2 && aws-set-account $1
	}

# assume admin role into account
# aws-set-token ppersdev  awsauth/AccountAdmin && aws-set-account ppersdev
aws-admin()
	{
	aws-arole $1  awsauth/AccountAdmin
	}

# assume role into account
# aws-set-token ppersdev  awsauth/AccountAdmin && aws-set-account ppersdev
aws-role()
	{
	aws-arole $1  $2
	}

# assume role into OrgMaster master account
# aws-set-token ppersdev  awsauth/AccountAdmin && aws-set-account ppersdev
aws-org()
	{
	aws-set-account Auth && aws-arole OrgMaster awsauth/OrgAdmin && aws-set-account OrgMaster
	}

aws-set-token()
	{
		account=$1
		role=$2
		eval `aws gettoken $account $role`
	}

aws-set-tokens()
	{
	#become default aws user
	account=$AWS_ACCOUNT
	aws-set-account default
	#iterate over accounts and cache tokens in memory
	eval `aws setronincreds roam`
	aws-set-account $account
	}

aws-date-token()
	#report token expriration for account
	{
	echo -ne "Token for $i account expires "
	eval date -d `aws datecred $1`
	}

aws-loop()
	#report token expriration for account
	{
	for i in `aws accountnames`;
		do
		accountname=$i
		echo -e "executing  \033[7m $@ \033[0m  in account $accountname";
		echo
		aws-set-account $i
		$@
		echo
		done
	}

aws-pub-key()
	{
	openssl rsa -in $1 -pubout|grep -v "PUBLIC KEY"
	}


aws-import-key()
	#upload pub key to aws
	# aws ec2 import-key-pair --key-name my-key --public-key-material MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuhrGNglwb2Zz/Qcz1zV+l12fJOnWmJxC2GMwQOjAX/L7p01o9vcLRoHXxOtcHBx0TmwMo+i85HWMUE7aJtYclVWPMOeepFmDqR1AxFhaIc9jDe88iLA07VK96wY4oNpp8+lICtgCFkuXyunsk4+KhuasN6kOpk7B2w5cUWveooVrhmJprR90FOHQB2Uhe9MkRkFjnbsA/hvZ/Ay0Cflc2CRZm/NG00lbLrV4l/SQnZmP63DJx194T6pI3vAev2+6UMWSwptNmtRZPMNADjmo50KiG2c3uiUIltiQtqdbSBMh9ztL/98AHtn88JG0s8u2uSRTNEHjG55tyuMbLD40QEXAMPLE
	{
	aws ec2 import-key-pair --key-name $1 --public-key-material "`aws-pub-key $2`"
	}

export PS1="[\$AWS_USER] \h:\w "
