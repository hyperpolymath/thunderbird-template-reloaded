Command line instructions

You can also upload existing files from your computer using the instructions below.
Configure your Git identity

Get started with Git and learn how to configure it.

    Local
    Global 

Git local setup

Configure your Git identity locally to use it only for this project:

git config --local user.name "Jonathan D.A. Jewell"
git config --local user.email "4616380-hyperpolymath@users.noreply.gitlab.com"

Add files

Push files to this repository using SSH or HTTPS. If you're unsure, we recommend SSH.

    SSH
    HTTPS

How to use SSH keys?
Create a new repository

git clone git@gitlab.com:overarch-underpin/applications/thunderbird-template-reloaded.git
cd thunderbird-template-reloaded
git switch --create main
touch README.md
git add README.md
git commit -m "add README"
git push --set-upstream origin main

Push an existing folder
Go to your folder

cd existing_folder

Configure the Git repository

git init --initial-branch=main --object-format=sha1
git remote add origin git@gitlab.com:overarch-underpin/applications/thunderbird-template-reloaded.git
git add .
git commit -m "Initial commit"
git push --set-upstream origin main

Push an existing Git repository
Go to your repository

cd existing_repo

Configure the Git repository

git remote rename origin old-origin
git remote add origin git@gitlab.com:overarch-underpin/applications/thunderbird-template-reloaded.git
git push --set-upstream origin --all
git push --set-upstream origin --tags

Project information

Invite your team

Add members to this project and start collaborating with your team.

       

    New file
    Add README
    Add LICENSE
    Add CHANGELOG
    Add CONTRIBUTING
    Set up CI/CD
    Add Wiki
    Configure Integrations
    Enable Observability

Created on
November 14, 2025 
