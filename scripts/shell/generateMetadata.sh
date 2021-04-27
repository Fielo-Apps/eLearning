# !/bin/bash
echo 'Removing FieloELR folder'
rm -R ../FieloELR
echo 'Converting Source to Metadata format'
sfdx force:source:convert --outputdir ../FieloELR --packagename FieloELR
echo 'Adding PostInstallClass'
gsed -i '$i  <postInstallClass>PackageInstallation</postInstallClass>' ../FieloELR/package.xml
code ../FieloELR/package.xml