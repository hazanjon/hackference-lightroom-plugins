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
          
local function applypreset(photo, setting, value)
     local pre = {}
     pre[setting] = value
     catalog:withWriteAccessDo( 'setPreset', function()
          local preset = LrApplication.addDevelopPresetForPlugin( _PLUGIN, "___Dummy___", pre )
          photo:applyDevelopPreset(preset, _PLUGIN)
     end)
     
end

local function exportImage(args)

     local testphoto = catalog:getTargetPhoto()
     
     applypreset(testphoto, args.set, tonumber(args.val))
     
     if(testphoto) then
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
                         LR_export_destinationPathSuffix = "web/export",
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
          
          local result, hdrs = LrHttp.get("http://localhost:7076/lightroom")
               
     end
     
end

return {
     URLHandler = function(url)
        if url:sub( 1, 1 ) == '"' then -- double-quote wrapped format.
           url = url:sub( 2, -2 )
        end
      
        local args = {}
          
        local theStart = 1
        local inSplitPattern = '&'
        local outResults = {}
        local theSplitStart, theSplitEnd = string.find( url, inSplitPattern, theStart )
        while theSplitStart do
           table.insert( outResults, string.sub( url, theStart, theSplitStart-1 ) )
           theStart = theSplitEnd + 1
           theSplitStart, theSplitEnd = string.find( url, inSplitPattern, theStart )
        end
        table.insert( outResults, string.sub( url, theStart ) )
   
          for i, v in ipairs( outResults ) do
             local theStart = 1
             local inSplitPattern = '='
             local nv = {}
             local theSplitStart, theSplitEnd = string.find( v, inSplitPattern, theStart )
             while theSplitStart do
                table.insert( nv, string.sub( v, theStart, theSplitStart-1 ) )
                theStart = theSplitEnd + 1
                theSplitStart, theSplitEnd = string.find( v, inSplitPattern, theStart )
             end
             table.insert( nv, string.sub( v, theStart ) )
               
               args[nv[1]] = nv[2]
          end
          
          LrTasks.startAsyncTask(function ()  
               exportImage(args)  
          end)
     end
}