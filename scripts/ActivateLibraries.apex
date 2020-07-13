/**
 * @brief       Script to create Activate Local Develop and FieloPLT Library
 *             
 * @details     Only works after pushing the code to the org
 */
List<StaticResource> sr = [SELECT Id, Name, NamespacePrefix, SystemModStamp, Body FROM StaticResource WHERE Name = 'FieloPLT' AND Description Like '%FieloPLT-Library%' LIMIT 1];

if (!sr.isEmpty()) {
    FieloPLT.LibraryLandingController.activate(sr[0].Id + '-' + 'FieloLocal');
    FieloPLT.LibraryLandingController.activate(sr[0].Id + '-' + 'FieloPLT');
}

sr = [SELECT Id, Name, NamespacePrefix, SystemModStamp, Body FROM StaticResource WHERE Name = 'FieloELR' AND Description Like '%FieloPLT-Library%' LIMIT 1];

if (!sr.isEmpty()) {
    FieloPLT.LibraryLandingController.activate(sr[0].Id + '-' + 'FieloELR');
}