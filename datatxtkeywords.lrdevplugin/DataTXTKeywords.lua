local dandelion_app_id = "57270473"
local dandelion_app_key = "0afe6a06bb33bc93119501a88ea64047"

-- Access the Lightroom SDK namespaces.
local LrDialogs = import 'LrDialogs'
local LrTasks = import 'LrTasks'
local LrHttp = import 'LrHttp'
local LrLogger = import 'LrLogger'
local LrPathUtils = import 'LrPathUtils'
local LrProgressScope = import 'LrProgressScope'
local LrApplication = import 'LrApplication'
local catalog = LrApplication.activeCatalog()

local JSON = (loadfile(LrPathUtils.child(_PLUGIN.path, "JSON.lua")))() -- one-time load of Json parsing


-- Create the logger and enable the print function.
local myLogger = LrLogger( 'exportLogger' )
myLogger:enable( "logfile" )

--------------------------------------------------------------------------------
-- Write trace information to the logger.

local function outputToLog( message )
	myLogger:trace( message )	
end

local function recurseFolder(folder)
	local foldertable = {}
	
	local subfolders = folder:getChildren()
	
	for j, subfolder in ipairs(subfolders) do
		table.insert(foldertable, subfolder)
		
		local temp = recurseFolder(subfolder)
		
		for i, tf in ipairs(temp) do
			table.insert(foldertable, tf)
		end
	end

	
	return foldertable
end
--------------------------------------------------------------------------------
-- Display a modal information dialog.

local function addKeywords()

	local s = ""
	local folderlist = {}
	
	local progressScope = LrProgressScope {
		title = 'Scanning Folders'
	}
		
	local folders = catalog:getFolders()
	
	for j, subfolder in ipairs(folders) do
		local temp = recurseFolder(subfolder)
		
		for j, tf in ipairs(temp) do
			local fold = {}
			fold["name"] = tf:getName()
			fold["folder"] = tf
			fold["tags"] = {}
			
			table.insert(folderlist, fold)
			s = s .. "\n" .. tf:getName()
		end
	end
	
	progressScope:done()
	
	s = string.gsub(s, "([&=+%c])", function (c)
	    return string.format("%%%02X", string.byte(c))
	  end)
	s = string.gsub(s, " ", "+")
     
	local progressScope = LrProgressScope {
		title = 'Querying DataTXT Servers'
	}
	
	local result, hdrs = LrHttp.get( "https://api.dandelion.eu/datatxt/nex/v1/?lang=en&min_confidence=0.6&social.parse_hashtag=False&text="..s.."&include=image%2Cabstract%2Ctypes%2Ccategories%2Clod&country=GB&$app_id="..dandelion_app_id.."&$app_key="..dandelion_app_key.."")
	
	local json = JSON:decode(result)
	outputToLog( "Call successful" )
	progressScope:done()
	
	local out = ""
	
	local i = 1
	
	local progressScope = LrProgressScope {
		title = 'Adding Keywords'
	}
	local numfolders = #folderlist
	progressScope:setPortionComplete( 0, numfolders )
	
	for j, folder in ipairs(folderlist) do
		local annotation = json.annotations[i]
	  	out = out .. "\n\n" .. folder.name
	  	progressScope:setCaption(folder.name)
		while annotation and string.find(folder.name, annotation.spot) do
	  		out = out .. "\n  --- " .. annotation.label .. " (" .. annotation.confidence .. ")"
			table.insert(folder.tags, annotation.label)
			local photos = folder.folder:getPhotos(true)
	   		catalog:withWriteAccessDo("Adding keywords", function ()  
	   			local keyword = catalog:createKeyword(annotation.label, {}, true, nil, true)
				for k, photo in ipairs(photos) do
					photo:addKeyword(keyword)
				end
			end)
			i = i + 1
			annotation = json.annotations[i]
		end
		progressScope:setPortionComplete( j, numfolders )
		
	end
	progressScope:done()
	
	LrDialogs.message( "Success", "Keywords have been added", "info" );
	
end



--------------------------------------------------------------------------------
-- Display a dialog.
LrTasks.startAsyncTask (addKeywords)


