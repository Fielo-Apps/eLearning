# !/bin/bash
function removeFolder {
    rm -R ../FieloELR && echo 'Folder FieloELR removed'
}

function convertMetadata {
    sfdx force:source:convert --outputdir ../FieloELR --packagename FieloELR
}

function deployMetadata {
    sfdx force:mdapi:deploy --deploydir ../FieloELR --targetusername master-elr -w -1
}

function runAllTests {
    sfdx force:apex:test:run --resultformat human --synchronous --loglevel error -w 60 -l RunLocalTests -u master-elr > .local/AllTestsResults.txt && code -r .local/AllTestsResults.txt
}

removeFolder && convertMetadata && deployMetadata && runAllTests