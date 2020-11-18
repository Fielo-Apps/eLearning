# !/bin/bash

# Activate Libraries
sfdx force:apex:execute -f scripts/apex/ActivateLibraries.apex

# Create Program and Members
sfdx force:apex:execute -f scripts/apex/CreateMembers.apex