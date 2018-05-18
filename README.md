# Firmidable Git Shell Scripts
A set of scripts to make it easier to do development using git for our teams.

This is developed for websites where a development site is accesible at dev.example.com, which serves from a /dev/ directory underneath the main index directory.

Many scripts require git.

## Description
This is a custom shell script that contains 9 functions:


1. **custom.sh**: a simple echo code to ensure the script is installed correctly.
1. **create_dev_site**: a simple copy script. It places a copy of the main index directory into a directory named /dev/.
1. **roll_live**: a simple copy script. It moves all files up one level, effectively rolling a dev site live.
1. **git_start**: a git init script. It adds a .gitignore, and shows a git status, awaiting any needed changes and an initial commit.
1. **db_dev**: a script to pull the current live database and place it into a database named example_z_database and makes changes to WordPress and ExpressionEngine 2 config files. It requires .database.sh to be in the main index directory and a development database to be already created.
1. **git_dev**: a script to create dev sites using git. If .database.sh is present, it will run **db_dev**. It creates a branch "dev" in its own worktree, and makes some edits to the WordPress or ExpressionEngine 2 config files. It updates .database.sh to use to dev database. It also adds .htaccess, wp-config.php/database.php, and .database.sh to the git "skip-worktree" list.
1. **db_pull**: a script to pull the most commonly changed database tables for WordPress and ExpressionEngine 2 into a file. This allows the database to be tracked in git.
1. **git_roll_live**: a script to push the db.sql file to the live database, merge the dev branch to the master branch, and if the site is WordPress, update the live database's site and home options automatically.
1. **git_nuke_dev**: a script to remove the dev site. This drops all tables in the dev database, removes the git worktree, deletes the dev branch, and removes the entire /dev/ directory.

For database-driven sites, it's recommended to add a shell file called .database.sh to your main index directory.

## Installation
Place this file in /etc/profile.d in your server root.

For database-driven sites, add a .database.sh file to your index directory.
