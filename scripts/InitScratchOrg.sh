# !/bin/bash

# Open on Deployment Page
sfdx force:org:open -p /lightning/setup/DeployStatus/home &&

# Install FieloPLT
sfdx force:package:install --package 04t2J000000ExfH -w 60 &&

# ADD Unpackaged into folder
# ln -s ../../unpackaged ./force-app/main/unpackaged &&

# Push Source
sfdx force:source:push -w 60 &&

# Assign the permission set to the user
sfdx force:user:permset:assign --permsetname FieloELRAdmin &&

# REMOVE Unpackaged from folder
# rm ./force-app/main/unpackaged

# DEPLOY Unpackaged folder
sfdx force:source:deploy -f ./unpackaged/