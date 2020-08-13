# !/bin/bash

# Activate Libraries
sfdx force:apex:execute -f scripts/ActivateLibraries.apex

# Create Program and Members
sfdx force:apex:execute -f scripts/CreateMembers.apex

# Create Sample Course
sfdx force:apex:execute -f scripts/createSmokeTestCourse.apex