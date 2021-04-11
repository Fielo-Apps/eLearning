# !/bin/bash

# Open on Deployment Page
sfdx force:org:open -p /lightning/setup/DeployStatus/home &&

# Install FieloPLT
sfdx force:package:install --package 04t2J000000gggI -w 60 &&

# Push Source
sfdx force:source:push -w 60 &&

# Assign the FieloPLT permission set to the user
sfdx force:user:permset:assign --permsetname FieloPLTAdmin &&

# Assign the FieloELR permission set to the user
sfdx force:user:permset:assign --permsetname FieloELRAdmin &&

# DEPLOY Unpackaged folder
sfdx force:source:deploy -p ./unpackaged/ &&

# Push Source again to refresh org reference
sfdx force:source:push -w 60