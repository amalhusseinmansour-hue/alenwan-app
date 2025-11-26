<?php
$zip = new ZipArchive;
$res = $zip->open('update.zip');
if ($res === TRUE) {
  $zip->extractTo(__DIR__);
  $zip->close();
  echo '✅ Extracted update.zip successfully!';
  unlink('update.zip'); // Delete zip after extraction
  unlink(__FILE__); // Delete self
} else {
  echo '❌ Failed to open update.zip';
}
?>
