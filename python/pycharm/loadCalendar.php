<!DOCTYPE html>
<html>
<body>

<?php
// Load XML file
$xml = new DOMDocument;
$xml->load('dataManager.xml');

// Load XSL file
$xsl = new DOMDocument;
$xsl->load('dataManager.xsl');

// Configure the transformer
$proc = new XSLTProcessor;

// Attach the xsl rules
$proc->importStyleSheet($xsl);

echo $proc->transformToXML($xml);
?>

</body>
</html>