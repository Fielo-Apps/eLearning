# !/bin/bash

# Open on Deployment Page
sfdx force:org:open -p /lightning/setup/DeployStatus/home &&

# Install FieloPLT
sfdx force:package:install --package 04t2J000000AlpD -w 60 &&

# Push Source
sfdx force:source:push -w 60 &&

# Assign the permission set to the user
sfdx force:user:permset:assign --permsetname FieloELRAdmin &&

# DEPLOY Unpackaged folder
sfdx force:source:deploy -p ./unpackaged/