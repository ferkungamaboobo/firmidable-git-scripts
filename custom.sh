#!/bin/bash
#lives at /etc/profile.d

#sets umask to right setting
umask 002

#prints the input
function custom_sh() {
	echo 'Your input: ' $1
	echo 'custom.sh is probably loaded'
}

#copy site into dev directory
function create_dev_site() {
	echo -e '\e[33mCreating dev site...\e[0m'
	echo -e '\e[92mrsync -r --exclude="'"/dev/"'" * dev/\e[0m'
	rsync -r --exclude='/dev/' * dev/
	echo -e '\e[33mLive site copied to /dev!\e[0m'
}

#basic roll site live up one level
function roll_live() {
	echo -e '\e[33mRolling dev site live...\e[0m'
	echo -e '\e[92mcp -pur * ../\e[0m'
	cp -pur * ../
	echo -e '\e[33mDev site rolled live!\e[0m'
}

#Custom git init
function git_start() {
	echo -e '\e[33mCreating git...\e[0m'
	echo -e '\e[92git init\e[0m'
	git init
	echo -e '\e[33mCreating gitignore file...\e[0m'
	echo -e '\e[92mtouch .gitignore\e[0m'
	touch .gitignore
	echo -e '\e[33mAdding what files to ignore to .gitignore...\e[0m'
	echo -e '\e[92mecho $"'".well-known/\n.well-known/**\ndev/\ndev/**\nnew/\nnew/**\nold/\nold/**\ncgi-bin/\ncgi-bin/**\n.ftpquota\n.database.sh\n.htaccess\n*.key\nerror_log\nwp-config.php\ncms/expressionengine/config/database.php"'" > .gitignore\e[0m'
	echo $'.well-known/\n.well-known/**\ndev/\ndev/**\nnew/\nnew/**\nold/\nold/**\ncgi-bin/\ncgi-bin/**\n.ftpquota\n.database.sh\n.htaccess\n*.key\nerror_log\nwp-config.php\ncms/expressionengine/config/database.php' > .gitignore
	echo -e '\e[33mShowing git status...\e[0m'
	echo -e '\e[92mgit status\e[0m'
	git status
	echo -e '\e[93mPlease run the following commands:\e[0m'
	echo -e '\t\e[92mgit add --all\e[0m'
	echo -e '\t\e[92mgit commit -m "Initial commit"\e[0m'
}

#pull live database and push to dev
function db_dev() {
	if [ -f ".database.sh" ]
	then
		source .database.sh
		DDNAME=$(echo "$DBNAME" | sed "s/_/&z_/g");
		SITEIM=$(echo "$SITEHM" | sed "s/\/\//\/\/dev./g");
		SITEDM=$(echo "$SITEIM" | sed "s/dev.www./dev./g");
		DBEXST=$(mysqlshow -u "$DBUSER" -p"$DBPASS" "$DDNAME" | grep -v Wildcard | grep -o "$DDNAME");
		if [ "$DBEXST" == "$DDNAME" ]
		then
			echo -e '\e[33mDumping live database to temporary file...\e[0m'
			echo -e '\e[92mmysql -u '"$DBUSER"' -p\x27'"$DBPASS"'\x27 '"$DBNAME"' > dev/db_upload.sql\e[0m'
			mysqldump -u "$DBUSER" -p"$DBPASS" "$DBNAME" > dev/db_upload.sql
			echo -e '\e[33mTemp file created!\e[0m'
			echo -e '\e[33mUploading temp file as table...\e[0m'
			echo -e '\e[92mmysql -u '"$DBUSER"' -p\x27'"$DBPASS"'\x27 '"$DDNAME"' < dev/db_upload.sql\e[0m'
			mysql -u "$DBUSER" -p"$DBPASS" "$DDNAME" < dev/db_upload.sql
			echo -e '\e[33mRemoving temp file...\e[0m'
			echo -e '\e[92mrm dev/db_upload.sql\e[0m'
			rm dev/db_upload.sql
			echo -e '\e[33mCreating dev .database.sh file...\e[0m'
			echo -e '\e[92mtouch dev/.database.sh\e[0m'
			touch dev/.database.sh
			echo -e '\e[33mAdding variables to dev .database.sh file...\e[0m'
			echo -e "DBUSER=\x27$DBUSER\x27\nDBPASS=\x27$DBPASS\x27\nDBNAME=\x27$DDNAME\x27\nDBPRFX=\x27$DBPRFX\x27\nSITEHM=\x27$SITEDM\x27" > dev/.database.sh
			echo -e '\e[33mDev .database.sh created!\e[0m'
			echo -e '\e[33mChanging permissions on dev .database.sh file...\e[0m'
			echo -e '\e[92mchmod 0660 dev/.database.sh\e[0m'
			chmod 0660 dev/.database.sh
			if [ -f "wp-config.php" ]
			then 
				echo -e '\e[33mUpdating WordPress _options table to match the dev site url...\e[0m'
				echo -e '\e[92mysql -u '"$DBUSER"' -p\x27'"$DBPASS"'\x27 '"$DDNAME"' -e \x22UPDATE '"$DBPRFX"'options SET option_name=\x27siteurl\x27, option_value=\x27'"$SITEDM"'\x27 WHERE option_id = 1;\x22\e[0m'
				mysql -u "$DBUSER" -p"$DBPASS" "$DDNAME" -e "UPDATE "$DBPRFX"options SET option_name='siteurl', option_value='$SITEDM' WHERE option_id = 1;"
				echo -e '\e[92mysql -u '"$DBUSER"' -p\x27'"$DBPASS"'\x27 '"$DDNAME"' -e \x22UPDATE '"$DBPRFX"'options SET option_name=\x27home\x27, option_value=\x27'"$SITEDM"'\x27 WHERE option_id = 2;\x22\e[0m'
				mysql -u "$DBUSER" -p"$DBPASS" "$DDNAME" -e "UPDATE "$DBPRFX"options SET option_name='home', option_value='$SITEDM' WHERE option_id = 2;"
			elif  [ -f "cms/expressionengine/config/database.php" ]
			then
				echo -e '\e[93mPlease log into the dev site ExpressionEngine backend and update the site url! \e[0m'
			fi
		else
			echo -e '\e[91mDatabase not found!\e[0m'
			echo -e '\e[93mPlease create using cPanel, then run db_dev again.\e[0m'
		fi
	else
		echo -e '\e[93mPlease add a .database.sh file if this site requires a database!\e[0m'
	fi
}

#Git version of pulling dev
function git_dev() {
	echo -e '\e[33mCreating new git branch for dev site...\e[0m'
	echo -e '\e[92mgit worktree add -b dev dev/\e[0m'
	git worktree add -b dev dev/
	echo -e '\e[33mChanging permissions on dev directory...\e[0m'
	echo -e '\e[92mchmod chmod 0775 dev/\e[0m'
	chmod 0775 dev/
	echo -e '\e[33mEnsuring permissions on index.php is correct...\e[0m'
	echo -e '\e[92mchmod 0664 dev/index.php\e[0m'
	chmod 0664 dev/index.php
	echo -e '\e[33mCopying .htaccess...\e[0m'
	echo -e '\e[92mcp -p .htaccess dev/\e[0m'
	cp -p .htaccess dev/
	if [ -f ".database.sh" ]
	then
		db_dev
	else
		echo -e '\e[91m.database.sh not detected.\e[0m'
		echo -e '\e[33mYou can run db_dev to create the dev database outside of this script.\e[0m'
	fi
	if [ -f "wp-config.php" ]
		then 
			echo -e '\e[33mCopying wp-config.php...\e[0m'
			echo -e '\e[92mcp -p wp-config.php dev/\e[0m'
			cp -p wp-config.php dev/
			echo -e '\e[33mReplacing the live database with the dev database in wp-config.php...\e[0m'
			echo -e '\e[92msed -i "s/'"$DBNAME"'/'"$DDNAME"'/g" dev/wp-config.php\e[0m'
			sed -i "s/$DBNAME/$DDNAME/g" dev/wp-config.php
	elif [ -f "cms/expressionengine/config/database.php" ]
		then
			echo -e '\e[33mCopying database.php...\e[0m'
			echo -e '\e[92mcp -p cms/expressionengine/config/database.php wp-config.php dev/cms/expressionengine/config/\e[0m'
			cp -p cms/expressionengine/config/database.php dev/cms/expressionengine/config/
			echo -e '\e[33mReplacing the live database with the dev database in database.php...\e[0m'
			echo -e '\e[92msed -i "s/'"$DBNAME"'/'"$DDNAME"'/g" dev/cms/expressionengine/config/database.php\e[0m'
			sed -i "s/$DBNAME/$DDNAME/g" dev/cms/expressionengine/config/database.php
			echo -e '\e[93mPlease log into the dev site ExpressionEngine backend and update the site url!\e[0m'
	fi
	echo -e '\e[93mPlease check the .htaccess to ensure the dev site resolves\e[0m'
}

#Pull Database for committing
function db_pull() {
	if [ -f ".database.sh" ]
	then
		source .database.sh
		if [ -f "wp-config.php" ] 
		then
			echo -e '\e[33mDumping main WordPress tables to db.sql file...\e[0m'
			echo -e '\e[92mmysqldump -u '"$DBUSER"' -p'"$DBPASS"' '"$DBNAME"' '"$DBPRFX"'postmeta '"$DBPRFX"'posts '"$DBPRFX"'terms '"$DBPRFX"'termmeta '"$DBPRFX"'term_relationships '"$DBPRFX"'term_taxonomy '"$DBPRFX"'options > db.sql\e[0m'
			mysqldump -u "$DBUSER" -p"$DBPASS" "$DBNAME" "$DBPRFX"postmeta "$DBPRFX"posts "$DBPRFX"terms "$DBPRFX"termmeta "$DBPRFX"term_relationships "$DBPRFX"term_taxonomy "$DBPRFX"options > db.sql
		elif [ -f "cms/expressionengine/config/database.php" ]
		then
			echo -e '\e[33mDumping main ExpressionEngine tables to db.sql file...\e[0m'
			echo -e '\e[92mmysqldump -u '"$DBUSER"' -p'"$DBPASS"' '"$DBNAME"' exp_channels exp_channel_data exp_channel_fields exp_channel_titles exp_seolite_content exp_sites exp_snippets exp_structure exp_templates exp_template_groups > db.sql\e[0m'
			mysqldump -u "$DBUSER" -p"$DBPASS" "$DBNAME" exp_channels exp_channel_data exp_channel_fields exp_channel_titles exp_seolite_content exp_sites exp_snippets exp_structure exp_templates exp_template_groups > db.sql
		fi
	else
		echo -e '\e[91m.database.sh file not found!\e[0m'
		echo -e '\e[93mPlease create the file\e[0m'
	fi
}

#Git version of rolling live
function git_roll_live() {
	echo -e '\e[33mMoving to main directory...\e[0m'
	echo -e '\e[92mcd ~/public_html\e[0m'
	cd ~/public_html
	echo -e '\e[33mMerging dev up to live!\e[0m'
	echo -e '\e[92mgit merge dev\e[0m'
	git merge dev
	if [ -f ".database.sh" ]
	then
		source .database.sh
		echo -e '\e[33mPushing db.sql file to the live database...\e[0m'
		echo -e '\e[92mmysql -u '"$DBUSER"' -p'"$DBPASS"' '"$DBNAME"' < db.sql\e[0m'
		mysql -u "$DBUSER" -p"$DBPASS" "$DBNAME" < db.sql
		if [ -f "wp-config.php" ]
		then
			echo -e '\e[33mUpdating WordPress _options table to match the live site url...\e[0m'
			echo -e '\e[92mmysql -u '"$DBUSER"' -p\x27'"$DBPASS"'\x27 '"$DBNAME"' -e \x22UPDATE '"$DBPRFX"'options SET option_name=\x27siteurl\x27, option_value=\x27'"$SITEHM"'\x27 WHERE option_id = 1;\x22\e[0m'
			mysql -u "$DBUSER" -p"$DBPASS" "$DBNAME" -e "UPDATE "$DBPRFX"options SET option_name='siteurl', option_value='$SITEHM' WHERE option_id = 1;"
			echo -e '\e[92mmysql -u '"$DBUSER"' -p\x27'"$DBPASS"'\x27 '"$DBNAME"' -e \x22UPDATE '"$DBPRFX"'options SET option_name=\x27home\x27, option_value=\x27'"$SITEHM"'\x27 WHERE option_id = 2;\x22\e[0m'
			mysql -u "$DBUSER" -p"$DBPASS" "$DBNAME" -e "UPDATE "$DBPRFX"options SET option_name='home', option_value='$SITEHM' WHERE option_id = 2;"
		elif  [ -f "cms/expressionengine/config/database.php" ]
		then
			echo -e '\e[93mPlease log into the live site ExpressionEngine backend and update the site url! \e[0m'
		fi
	fi
}

#destroy dev directory & git repo
function git_nuke_dev() {
	echo -e '\e[41mOh no!\e[0m'
	echo -e '\e[33mMoving to main directory...\e[0m'
	echo -e '\e[92mcd ~/public_html\e[0m'
	cd ~/public_html
	source dev/.database.sh
	echo -e '\e[33mDropping all tables in dev database...\e[0m'
	echo -e '\e[92mmysqldump -u '"$DBUSER"' -p\x27'"$DBPASS"'\x27 '"$DBNAME"' | grep ^DROP | mysql -u '"$DBUSER"' -p\x27'"$DBPASS"'\x27 '"$DBNAME"'\e[0m'
	mysqldump -u "$DBUSER" -p"$DBPASS" --add-drop-table --no-data "$DBNAME" | grep ^DROP | mysql -u "$DBUSER" -p"$DBPASS" "$DBNAME"
	echo -e '\e[33mListing all worktrees...\e[0m'
	echo -e '\e[92mgit worktree list\e[0m'
	git worktree list
	echo -e '\e[33mRemoving the dev directory with prejudice...\e[0m'
	echo -e '\e[92mrm -rf dev/\e[0m'
	rm -rf dev/
	echo -e '\e[33mClearing worktrees without directories...\e[0m'
	echo -e '\e[92mgit worktree prune\e[0m'
	git worktree prune
	echo -e '\e[33mRemove the dev branch...\e[0m'
	echo -e '\e[92mgit branch -D dev\e[0m'
	git branch -D dev
	echo -e '\e[93mPlease run git_dev again to create the dev site.\e[0m'
}
