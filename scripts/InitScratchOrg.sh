# Install FieloPLT
sfdx force:package:install --package 04t2J000000MBdn -w 60

# Push Source
sfdx force:source:push -w 60

# Assign the permission set to the user
sfdx force:user:permset:assign --permsetname FieloELRAdmin
