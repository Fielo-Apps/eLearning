# !/bin/bash

# Open on Deployment Page
sfdx force:org:open -p /lightning/setup/DeployStatus/home &&

# Install FieloPLT
sfdx force:package:install --package 04t2J000000ExfH -w 60 &&

# Push Source
sfdx force:source:push -w 60 &&

# DEPLOY Unpackaged folder
sfdx force:source:deploy -p ./unpackaged/ &&

# Assign the permission set to the user
sfdx force:user:permset:assign --permsetname FieloELRAdmin &&

# Push Again to sync
sfdx force:source:push -w 60 -f