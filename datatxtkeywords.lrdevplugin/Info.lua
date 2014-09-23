return {
	
	LrSdkVersion = 3.0,
	LrSdkMinimumVersion = 1.3, -- minimum SDK version required by this plug-in

	LrToolkitIdentifier = 'com.hazanjon.lightroom.datatxtkeywords',

	LrPluginName = LOC "$$$/dataTXTKeywords/PluginName=DataTXT Keywords",
	
	-- Add the menu item to the File menu.
	
	LrLibraryMenuItems = {
		title = "Add Keywords using dataTXT",
		file = "DataTXTKeywords.lua",
	},
	VERSION = { major=0, minor=1, revision=0, build=0, },

}


	