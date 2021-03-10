import xml.etree.ElementTree as ET

tree = ET.parse('force-app/main/default/labels/CustomLabels.labels-meta.xml')
root = tree.getroot()
labels = []
for label in root.findall("{http://soap.sforce.com/2006/04/metadata}labels"):
    fullname = label.find("{http://soap.sforce.com/2006/04/metadata}fullName")
    labels.append(fullname.text)

labels.sort()

classFile = open('force-app/main/default/classes/LightningComponentLabels.cls','w')

classFile.write("public with sharing class LightningComponentLabels {\n")
classFile.write("    public List<String> ELR_LABELS;\n")
classFile.write("\n")
classFile.write( "    public LightningComponentLabels() {\n")
classFile.write( "        // necessary to add labels to the package\n")
classFile.write("\n")
classFile.write( "        // There are {0} labels in FieloELR\n".format(len(labels)))
classFile.write( "        ELR_LABELS = new List<String>{\n")

for index, label in enumerate(labels):
    classFile.write("            Label.{0}{1}\n".format(label, ',' if index < len(labels) -1 else ''))

classFile.write( "        };\n")
classFile.write( "    }\n")
classFile.write( "}")
classFile.close
