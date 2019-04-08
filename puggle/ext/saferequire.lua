-- cache the real require function
local cachedRequire = require

-- override the require function
require = function( path )

    -- pre-declare the loaded code
	local code

    -- do a protected call to make sure the code/plugin exists
	local success, err = pcall( cachedRequire, path )

    -- if it was a success the code must exist
	if success then
	    code = cachedRequire( path )
	end

    -- return the loaded module
	return code

end
