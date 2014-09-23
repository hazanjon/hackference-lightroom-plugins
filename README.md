# Hackference 2014

These two lightroom plugins were created at the Hackfrerence event on 20th Sept 2014

## DataTxt Keywords

This plugin uses the DataTXT API provided by Dandelion to add keywords to your photos based on the folder names. The longer the folder name the more effective the plugin.

To use add the plugin through the plugin manager, then goto Library > Plug-in Extras > Add Keywords using DataTXT.

## Remote Control

This is a Proof of Concept hack. By adding the plugin to lightroom and running the nodejs server in the ./web folder you will be able to remotely control lightroom to change the Exposure & Contrast values of the current active photo in lightroom and then see the result in the browser.

Due to the processing time Lightroom needs to export a photo it can take a couple of seconds to see the resulting photo.