--[[----------------------------------------------------------------------------

ADOBE SYSTEMS INCORPORATED
 Copyright 2007 Adobe Systems Incorporated
 All Rights Reserved.

NOTICE: Adobe permits you to use, modify, and distribute this file in accordance
with the terms of the Adobe license agreement accompanying it. If you have received
this file from a source other than Adobe, then your use, modification, or distribution
of it requires the prior written permission of Adobe.

--------------------------------------------------------------------------------

ExportMenuItem.lua
From the Hello World sample plug-in. Displays a modal dialog and writes debug info.

------------------------------------------------------------------------------]]

local dandelion_app_id = "57270473"
local dandelion_app_key = "0afe6a06bb33bc93119501a88ea64047"

-- Access the Lightroom SDK namespaces.
local LrDialogs = import 'LrDialogs'
local LrTasks = import 'LrTasks'
local LrHttp = import 'LrHttp'
local LrLogger = import 'LrLogger'
local LrPathUtils = import 'LrPathUtils'
local LrProgressScope = import 'LrProgressScope'
local LrExportSession = import 'LrExportSession'
local LrApplication = import 'LrApplication'
local catalog = LrApplication.activeCatalog()

-- Create the logger and enable the print function.
local myLogger = LrLogger( 'exportLogger' )
myLogger:enable( "logfile" ) -- Pass either a string or a table of actions.

--------------------------------------------------------------------------------
-- Write trace information to the logger.

local function outputToLog( message )
	myLogger:trace( message )	
end

local function handleJPEGThumbnail(data, error)
	
	if(data) then
		outputToLog( data )
		local file = io.open(LrPathUtils.child(_PLUGIN.path, "test.jpeg"),'w+')
		file:write(data)
		file:close()
	end
end


local function applypreset(photo, setting, value)
	local pre = {}
	pre[setting] = value
	catalog:withWriteAccessDo( 'setPreset', function()
		local preset = LrApplication.addDevelopPresetForPlugin( _PLUGIN, "___Dummy___", pre )
		photo:applyDevelopPreset(preset, _PLUGIN)
	end)
	
end
--------------------------------------------------------------------------------
-- Display a modal information dialog.

local function showModalDialog()

	local testphoto = catalog:getTargetPhoto()
	applypreset(testphoto, "Exposure2012", 1)
	
	if(testphoto) then
		--local makejpeg = testphoto:requestJpegThumbnail(1000, 1000, handleJPEGThumbnail)
		local exportSettings = {  
                    LR_format = "JPEG",  
                    LR_export_colorSpace = "sRGB",  
                    LR_jpeg_quality = 80,  
                    LR_jpeg_useLimitSize = false,  
                    LR_size_doConstrain = true,  
                    LR_size_maxHeight = 900,  
                    LR_size_maxWidth = 900,  
                    LR_size_units = "pixels",  
                    LR_size_resizeType = "wh",  
                    LR_size_resolution = 72,  
                    LR_size_resolutionUnits = "inch",  
                    LR_outputSharpeningOn = false,  
                    LR_minimizeEmbeddedMetadata = true,  
                    LR_useWatermark = false,  
					LR_export_destinationType = "specificFolder",
					LR_export_destinationPathSuffix = "export",
					LR_collisionHandling = "overwrite",
                    LR_export_destinationPathPrefix = _PLUGIN.path,
                    LR_renamingTokensOn = true, 
                    LR_extensionCase = "lowercase", 
                    LR_tokens = "export", 
     	}  
       
     	local params =  {  
                              photosToExport = { testphoto  },  
                              exportSettings =  exportSettings   
                          }  
       
     	local exportSession = LrExportSession(params) 
     	exportSession:doExportOnCurrentTask()
     	
     	--[[for i, rendition in exportSession:renditions{ stopIfCanceled = true } do
     		local s = rendition.destinationPath
     	end]]
     	
	end
	LrDialogs.message( "Success", "JPEG created ", "info" );
	
end



--------------------------------------------------------------------------------
-- Display a dialog.
LrTasks.startAsyncTask (showModalDialog)


