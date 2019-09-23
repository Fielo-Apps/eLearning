# Install FieloPLT
sfdx force:package:install --package 04t2J000000MBdn

# Push Source
sfdx force:source:push

# Assign the permission set to the user
sfdx force:user:permset:assign --permsetname FieloPRPAdmin
