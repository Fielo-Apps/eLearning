# !/bin/bash
function removeFolder {
    rm -R ../FieloELR && echo 'Folder FieloELR removed'
}

function convertMetadata {
    echo 'Converting Source'
    sfdx force:source:convert --outputdir ../FieloELR --packagename FieloELR
    echo 'Adding PostInstallClass'
    gsed -i '$i  <postInstallClass>PackageInstallation</postInstallClass>' ../FieloELR/package.xml
}

function deployMetadata {
    echo 'Deploying Converted Source to org'
    sfdx force:mdapi:deploy --deploydir ../FieloELR --targetusername patch-elr-1.76 -w -1
}

function runAllTests {
    echo 'Running all test on org'
    sfdx force:apex:test:run --resultformat human --synchronous --loglevel error -w 60 -l RunLocalTests -u patch-elr-1.76 > .local/AllTestsResults.txt && code -r .local/AllTestsResults.txt
}

removeFolder && convertMetadata && deployMetadata && runAllTests