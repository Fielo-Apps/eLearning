# !/bin/bash
if [ $# -eq 1 ]
then
    echo 'Deleting existing folder'
    rm -R ../FieloELR
    echo 'Converting source to metadata api'
    sfdx force:source:convert --outputdir ../FieloELR --packagename FieloELR
    echo 'Deploying to org'
    sfdx force:mdapi:deploy --deploydir ../FieloELR --targetusername $1
else
    echo 'Missing username parameter'
fi

