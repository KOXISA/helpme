--[[
The MIT License (MIT)
Copyright (c) 2017 Graham Ranson - www.grahamranson.co.uk / @GrahamRanson

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial
portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]

--- Middleclass library.
local class = require( "puggle.ext.middleclass" )

--- Class creation.
local Camera = class( "Camera" )

--- Required libraries.

--- Localised functions.
local insert = table.insert
local huge = math.huge
local sort = table.sort

--- Initiates a new Camera object.
-- @param params Paramater table for the object.
-- @return The new object.
function Camera:initialize( params )

	-- Set the name of this manager
	self.name = "camera"

	-- Create the new view
	self:reset()

end

function Camera:postInit()

	-- Ensure puggle has been created
	if puggle then

		-- Generate an id
		self._id = puggle.utils:generateUUID()

		-- Create a shaker object
		self._shaker = puggle.Shaker:new()

		-- Create a fake shakerStage
		self._shakerStage = { x = self.x, y = self.y }

		-- Set the stage of the shaker to our fake one
		self._shaker:setStage( self._shakerStage )

	end
end

--- Creates a new layer for the camera view.
-- @param params An optional table containing a list of layer params named parallaxFactor, blurFactor, scaleFactor, fadeFactor, index, name
function Camera:createLayer( params )

	local layer = display.newGroup()
	self._view.group:insert( layer )

	local params = params or {}

	layer.parallaxFactor = params.parallaxFactor or 1
	layer.blurFactor = params.blurFactor or 0
	layer.scaleFactor = params.scaleFactor or 1
	layer.fadeFactor = params.fadeFactor or 1
	layer.index = params.index or #self._layers + 1
	layer.name = params.name

	-- Was an index passed in that already belongs to another layer
	if layer.index and self._layers[ layer.index ] then

		-- Bump up all layers and insert this one
		for i = layer.index + 1, #self._layers, 1 do
			self._layers[ i ].index = self._layers[ i ].index + 1
			insert( self._layers, layer.index, layer )
		end

	else
		self._layers[ #self._layers + 1 ] = layer
	end

	-- Scale this layer based on its scale factor, if it has one
	layer.xScale, layer.yScale = layer.scaleFactor or 1, layer.scaleFactor or 1

	-- Alpha this layer based on its fade factor, if it has one
	layer.alpha = layer.fadeFactor or 1

	-- Make sure layers are all properly layered
	self:_sortLayers()

end

--- Translates the camera view.
-- @param x The amount to translate along the x axis.
-- @param y The amount to translate along the y axis.
function Camera:translate( x, y )

	-- Store out the values
	--self:_setTranslationVector( x, y )
	self.x = self.x + ( x or 0 )
	self.y = self.y + ( y or x or 0 )

end

--- Inserts an object into the camera's view.
-- @param object The object to insert.
-- @param layer The index of the layer to insert it into. Can also be a name if insterting into a named layer. Optional, defaults to 1.
function Camera:insert( object, layer )

	-- Was a name passed in?
	if layer and type( layer ) == "string" then

		-- Loop through all layers to see if we have a layer with that name
		for i = 1, #self._layers, 1 do

			-- When found store out the index and break
			if self._layers[ i ].name == layer then
				layer = i
				break
			end
		end
	elseif not layer then -- No layer was passed in so default to 1
		layer = 1
	end

	-- Get the layer with that index or name?
	local layer = self._layers[ layer ]

	if not layer and #self._layers == 0 then
		self:createLayer()
		layer = self._layers[ 1 ]
	end

	-- Assuming we have a layer
	if layer then

		-- Insert the object
		layer:insert( object )

		-- And apply some blur to it based on the layer's blur factor
		if layer.blurFactor ~= 0 then

			object.fill.effect = "filter.blurGaussian"

			object.fill.effect.horizontal.blurSize = 20 * layer.blurFactor
			object.fill.effect.horizontal.sigma = 140 * layer.blurFactor
			object.fill.effect.vertical.blurSize = 20 * layer.blurFactor
			object.fill.effect.vertical.sigma = 140 * layer.blurFactor

		end

	end

end

--- Sets the target position for the camera.
-- @param object The position to move to. Can be any table value with x and y properties. Set to nil to stop tracking.
function Camera:setTarget( position, offset )

	self._target = position

	self:setTargetOffset( offset )

	if self:getTarget() then
		self._trackPosition0 = { x = self:getTarget().x, y = self:getTarget().y }
	end

end

--- Gets the target position for the camera.
-- @return The position.
function Camera:getTarget()
	if self._target and not self._target.x and not self._target.y then
		self._target = nil
	end
	return self._target
end

--- Sets the target offset for the camera tracking.
-- @param offset Table containing the x and y properties.
function Camera:setTargetOffset( offset )
	self._targetOffset = offset or { x = 0, y = 0 }
end

--- Gets the target offset for the camera tracking.
-- @return The target offset.
function Camera:getTargetOffset()
	return self._targetOffset
end

--- Gets the distance to the target.
-- @return The distance.
function Camera:getDistanceToTarget()

	-- Get the target
	local target = { x = self:getTarget().x, y = self:getTarget().y }

	if target.x and target.y then

		-- Get the offset
		local offset = self:getTargetOffset() or { x = 0, y = 0 }

		-- Combine the two
		target.x = target.x + offset.x
		target.y = target.y + offset.y

	end

	-- And return it, naturally
	return puggle.maths:distanceBetweenVectors( self, target )

end

--- Sets the bounds for the camera view.
-- @param x1 The minimum x bounds.
-- @param x2 The maximum x bounds.
-- @param y1 The minimum y bounds.
-- @param y2 The maximum y bounds.
function Camera:setBounds( x1, x2, y1, y2 )

	self._bounds.xMin = x1 or -huge
	self._bounds.xMax = x2 or huge
	self._bounds.yMin = y1 or -huge
	self._bounds.yMax = y2 or huge

end

--- Gets the bounds for the camera view.
-- @return The bounds.
function Camera:getBounds()
	return self._bounds
end

--- Sets the position for the camera view.
-- @param x The x position.
-- @param y The y position.
function Camera:setPosition( x, y )
	self.x, self.y = x, y
end

--- Gets the position for the camera view.
-- @return The x and y positions.
function Camera:getPosition()
	return self.x, self.y
end

--- Gets the main camera view.
-- @return The view object.
function Camera:getView()
	return self._view
end

--- Applies an effect to the camera view.
-- @param name The name of the effect.
-- @param params The paramaters for the effect. Optional.
function Camera:applyEffect( name, params )

	local view = self:getView()

	self:getView().fill.effect = name

	for k, v in pairs( params or {} ) do
		self:getView().fill.effect[ k ] = v
	end

end

--- Sets the damping of the camera movement.
-- @param value The damping value.
function Camera:setDamping( value )
	self._damping = value
end

--- Gets the damping of the camera movement.
-- @return The camera damping.
function Camera:getDamping()
	return self._damping
end

--- Shows the camera view.
-- @param layerIndex Index of the layer to show. Optional, defaults to none.
function Camera:show( layerIndex )
	if layerIndex then
		layerIndex = self:getLayerIndexFromName( layerIndex )
		if self._layers[ layerIndex ] then
			self._layers[ layerIndex ].isVisible = true
		end
	else
		self._view.isVisible = true
	end
end

--- Hides the camera view.
-- @param layerIndex Index of the layer to hide. Optional, defaults to none.
function Camera:hide( layerIndex )
	if layerIndex then
		layerIndex = self:getLayerIndexFromName( layerIndex )
		if self._layers[ layerIndex ] then
			self._layers[ layerIndex ].isVisible = false
		end
	else
		self._view.isVisible = false
	end
end

--- Checks if the camera view is currently visible.
-- @param layerIndex Index of the layer to check. Optional, defaults to none.
-- @return True if it is, false otherwise.
function Camera:isVisible( layerIndex )

	if layerIndex then
		layerIndex = self:getLayerIndexFromName( layerIndex )
		if self._layers[ layerIndex ] then
			return self._layers[ layerIndex ].isVisible
		end
	else
		return self._view.isVisible
	end

end

--- Toggles the camera between hidden and shown.
function Camera:toggleVisibility( layerIndex )
	if self:isVisible( layerIndex ) then
		self:hide( layerIndex )
	else
		self:show( layerIndex )
	end
end

--- Fades the camera view.
-- @param params Table of paramaters for the transition.
-- @param capture Pass in a capture of the scene if you want to transition that rather than the actual scene.
function Camera:fade( params, capture )

	puggle.transition:cancel( "camera-" .. self._id .. "-fade" )

	local onComplete = function()

		if params.cachedOnComplete and type( params.cachedOnComplete ) == "function" then
			params.cachedOnComplete()
		end

		if capture then
			display.remove( capture )
			capture = nil
		end

	end

	params.cachedOnComplete = params.onComplete
	params.onComplete = onComplete

	-- Transition the view or capture object
	puggle.transition:to( capture or self._view, params, "camera-" .. self._id .. "-fade" )

end

--- Fades out the camera view.
-- @param params Table of paramaters for the transition. Alpha will default to 0.
-- @param useCapture Set this to true to use a still capture of the scene in the fade rather than the true scene. Optional, defaults to false.
function Camera:fadeOut( params, useCapture )

	local params = params or {}
	params.alpha = params.alpha or 0

	-- Pre-declare the capture variable
	local capture

	-- If a capture was used then immediately show the real scene
	if useCapture then

		self:show()

		-- If we're using a capture then take it and centre it
		capture = self:capture()
		capture.x = self._view.x + self._view.contentWidth * 0.25
		capture.y = self._view.y + self._view.contentHeight * 0.25

		self:setAlpha( params.alpha )
		self:hide()

	end

	self:fade( params, capture )

end

--- Fades out the camera in.
-- @param params Table of paramaters for the transition. Alpha will default to 1.
-- @param useCapture Set this to true to use a still capture of the scene in the fade rather than the true scene. Optional, defaults to false.
function Camera:fadeIn( params, useCapture )

	local params = params or {}
	params.alpha = params.alpha or 1

	-- Pre-declare the capture variable
	local capture

	-- If a capture was used then immediately show the real scene
	if useCapture then

		-- If we're using a capture then take it and centre it
		capture = self:capture()
		capture.x = self._view.x + self._view.contentWidth * 0.25
		capture.y = self._view.y + self._view.contentHeight * 0.25

		self:setAlpha( params.alpha )
		self:hide()

	end

	self:fade( params, capture )

end

--- Performs a cross fade transition between this camera and a second camera.
-- @param otherCamera The other camera to use.
-- @param time The duration of the transition.
-- @param onComplete On complete handler for the completed transiton.
-- @param useCapture Setting this to true will mean a static capture is used for both scenes during the transition, false means the actual scenes will be transitioned. Optional, defaults to false.
function Camera:crossFade( otherCamera, time, onComplete, useCapture )

	-- If we're not using a capture then we need to alpha out the other scene
	if not useCapture then
		otherCamera:setAlpha( 0 )
	end

	-- Fade in the other camera
	otherCamera:fadeIn( { time = time }, useCapture )

	-- Make sure the primary camera is in front
	puggle.camera:getView():toFront()

	local onFadeComplete = function()

		-- If we're not using a capture then it's time to destroy the primary camera
		if not useCapture then
			puggle.camera:destroy()
		end

		-- Set the other camera as the primary one
		puggle:setPrimaryCamera( otherCamera )

		-- If we used a capture then we'll need to show the primary camera now
		if useCapture then
			puggle.camera:show()
		end

		-- Were we given an onComplete function?
		if onComplete and type( onComplete ) == "function" then
			onComplete()
		end

	end

	-- Fade out the primary camera
	self:fadeOut( { time = time, onComplete = onFadeComplete }, useCapture )

	-- If we're using a capture then we can destroy the primary camera already
	if useCapture then
		puggle.camera:destroy()
	end

end

--- Sets the alpha of the camera view.
-- @param value The alpha value.
function Camera:setAlpha( value )
	self._view.alpha = value
end

--- Gets the alpha of the camera view.
-- @return The alpha.
function Camera:getAlpha()
	return self._view.alpha
end

--- Sets the refresh rate of the camera view.
-- @param rate The rate to set.
function Camera:setRefreshRate( rate )
	self._refreshRate = rate
end

--- Gets the refresh rate of the camera view.
-- @return The rate.
function Camera:getRefreshRate()
	return self._refreshRate or 1
end

--- Captures the view and returns it as a display object.
-- @return The captured image.
function Camera:capture()
	return display.capture( self._view )
end

--- Gets the camera view object.
-- @return The view.
function Camera:getView()
	return self._view
end

--- Flashes a colour across the whole camera view.
-- @param duration The duration of the flash. Optional, defaults to 100.
-- @param colour The colour of the flash. Optional, defaults to { 1, 1, 1, 1 }.
-- @param fadeParams Transition paramaters for fading the flash out after its duration. Optional.
function Camera:flash( duration, colour, fadeParams )

	-- Destroy any existing flashes
	display.remove( self._flash )
	self._flash = nil

	-- Cancel any existing flash timer
	puggle.timer:cancel( "camera-" .. self._id .. "-flash" )

	-- Cancel any existing flash fade
	puggle.transition:cancel( "camera-" .. self._id .. "-flashFade" )

	-- Define the paramaters if there aren't any passed in
	local duration = duration or 100
	local colour = colour or { 1, 1, 1, 1 }

	-- Create the flash object
	self._flash = display.newRect( self._view.x, self._view.y, self._view.contentWidth, self._view.contentHeight )
	self._flash:setFillColor( colour[ 1 ], colour[ 2 ], colour[ 3 ], colour[ 4 ] or 1 )

	-- Destroy the flash when completed
	local onComplete = function()

		local destroy = function()

			-- Destroy the flash
			display.remove( self._flash )
			self._flash = nil

			-- Call a cached onComplete listener if there was one
			if fadeParams and fadeParams.cachedOnComplete and type( fadeParams.cachedOnComplete ) == "function" then
				fadeParams.cachedOnComplete()
			end

		end

		-- Do we have some paramaters for a fade out?
		if fadeParams then

			-- Define some paramaters in case they haven't been and cache the onComplete listener
			fadeParams.cachedOnComplete = fadeParams.onComplete
			fadeParams.onComplete = destroy
			fadeParams.alpha = fadeParams.alpha or 0

			-- Fade out the flash
			puggle.transition:to( self._flash, fadeParams, "camera-" .. self._id .. "-flashFade" )

		else
			-- No paramaters so just destroy immediately
			destroy()
		end

	end

	-- Perform the actual flash
	puggle.timer:performWithDelay( duration, onComplete, 1, "camera-" .. self._id .. "-flash" )

end

--- Shake the screen
-- @param duration The duration of the shake. Optional, defaults to 100.
-- @param power The power of the shake, can be a single value or a table with x and y values. Optional, defaults to 20.
-- @param period The period of the shake. Optional, defaults to 2.
-- @return The converted x and y positions.
function Camera:shake( duration, power, period )

	-- Was a power value passed in?
	if power then

		-- If it was just a single number then convert it into an x/y table
		if type( power ) == "number" then
			power = { x = power, y = power }
		end

		self._shaker:setPower( power.x, power.y )

	end

	-- Was a period value passed in?
	if period then
		self._shaker:setPeriod( period )
	end

	-- Do the actual shake, passing in the duration or a default value
	self._shaker:start( duration or 100 )

end

--- Converts screen coordinates to world coordinates.
-- @param x The x position.
-- @param y The y position.
-- @param layerIndex The layer index to base the conversion on. Optional, defaults to 1.
-- @return The converted x and y positions.
function Camera:screenToWorld( x, y, layerIndex )
	return self._layers[ self:getLayerIndexFromName( layerIndex ) or 1 ]:contentToLocal( x, y )
end

--- Converts world coordinates to screen coordinates.
-- @param x The x position.
-- @param y The y position.
-- @param layerIndex The layer index to base the conversion on. Optional, defaults to 1.
-- @return The converted x and y positions.
function Camera:worldToScreen( x, y, layerIndex )
	return self._layers[ self:getLayerIndexFromName( layerIndex ) or 1 ]:localToContent( x, y )
end

--- Instantly jump to a new position.
-- @param x The x position.
-- @param y The y position.
-- @param dontClearTarget If set to true then the current target, if any, won't be cleared on snap. Optional, defaults to false.
function Camera:snapTo( x, y, dontClearTarget )
	self:setPosition( x, y )
	if not dontClearTarget then
		self:setTarget( nil )
	end
end

--- Cuts the camera to a new position using a fade out and then in.
-- @param x The x position.
-- @param y The y position.
-- @param fadeTime The time it takes for each fade ( out and in ). Optional, defaults to 100.
-- @param duration The duration between fade out is complete and the fade in starts. Optional, defaults to 0.
-- @param onFadeOut Callback function for when the fade out is completed. Optional.
-- @param onFadeIn Callback function for when the fade in is completed. Optional.
-- @param dontClearTarget If set to true then the current target, if any, won't be cleared on snap. Optional, defaults to false.
function Camera:cutTo( x, y, fadeTime, duration, onFadeOut, onFadeIn, dontClearTarget )

	-- Called when the camera has faded back in
	local onInternalFadeIn = function()

		-- Do we have a fade in callback?
		if onFadeIn and type( onFadeIn ) == "function" then
			onFadeIn()
		end

	end

	-- Called when the camera has faded out
	local onInternalFadeOut = function()

		-- Set the new position
		self:setPosition( x, y )

		-- Should we clear the tracking target?
		if not dontClearTarget then
			self:setTarget( nil )
		end

		-- Do we have a fade out callback?
		if onFadeOut and type( onFadeOut ) == "function" then
			onFadeOut()
		end

		-- Do the fade in
		self:fadeIn( { time = fadeTime or 100, delay = duration, onComplete = onInternalFadeIn } )

	end

	-- Do the fade out
	self:fadeOut( { time = fadeTime or 100, onComplete = onInternalFadeOut } )

end

--- Tracks to a new position.
-- @param x The x position.
-- @param y The y position.
-- @param onComplete A callback function when the camera gets close enough its tracking target, based on the current tracking accuracy level. Optional.
function Camera:trackTo( x, y, onComplete )
	self:setTarget{ x = x, y = y }
	self:setTargetListener( onComplete )
end

--- Sets a listener to be called when the camera reaches its target.
-- @return The listener function, or nil if there isn't one.
function Camera:setTargetListener( listener )
	self._targetListener = listener
end

-- Tracks to a new position.
function Camera:getTargetListener()
	return self._targetListener
end

--- Gets the layer index of a named layer.
-- @param name The name of the layer.
-- @return The layer index.
function Camera:getLayerIndexFromName( name )

	local layer = name

	-- Was a name passed in?
	if layer and type( layer ) == "string" then

		-- Loop through all layers to see if we have a layer with that name
		for i = 1, #self._layers, 1 do

			-- When found store out the index and break
			if self._layers[ i ].name == layer then
				layer = self._layers[ i ].index
				break
			end
		end

	end

	-- Return the index
	return layer

end

--- Gets a specific layer in this camera.
-- @param index The index of the layer.
-- @return The layer.
function Camera:getLayer( index )
	return self._layers[ self:getLayerIndexFromName( index ) ]
end

--- Gets all layers in this camera.
-- @return The layers.
function Camera:getLayers()
	return self._layers
end

--- Disables the automatic sorting of objects by their z-values.
function Camera:disableZSorting()
	self._zSortingDisabled = true
end

--- Enables the automatic sorting of objects by their z-values.
function Camera:enableZSorting()
	self._zSortingDisabled = false
end

--- Checks if the automatic z sorting for objects has been disabled.
-- @return True if it has, false otherwise.
function Camera:isZSortingDisabled()
	return self._zSortingDisabled
end

--- Destroys all visual elements and layers, then recreates a blank view.
function Camera:reset()

	-- Destroy all visual elements and layers
	self:clear()

	-- Create the main view group for the camera
	self._view = display.newSnapshot( display.contentWidth * 2, display.contentHeight * 2 )

	-- Set up the default bounds
	self._bounds =
	{
		xMin = -huge,
		xMax = huge,
		yMin = -huge,
		yMax = huge
	}

	-- Store the position of the view
	self.x = 0
	self.y = 0

	-- Create the table to store all layers
	self._layers = {}

end

--- Gets the tracking accuracy of the camera.
-- @return The accuracy.
function Camera:getTrackingAccuracy()
	return self._trackingAccuracy or 1
end

--- Sets the tracking accuracy of the camera.
-- @param v The accuracy value.
function Camera:setTrackingAccuracy( value )
	self._trackingAccuracy = value
end

--- Tracks the camera movement to a target position.
function Camera:_track()

	-- Do we have a target position
	if self:getTarget() then

		-- Get the current target position
		local targetX = self:getTarget().x
		local targetY = self:getTarget().y

		if targetX and targetY then

			-- Adjust the target based on the shaker stage
			if self._shakerStage and self._shakerStage.x and self._shakerStage.y then
				targetX = targetX + self._shakerStage.x
				targetY = targetY + self._shakerStage.y
			end

			-- If we have a target offset then apply it
			if self:getTargetOffset() then
				targetX = targetX + self:getTargetOffset().x
				targetY = targetY + self:getTargetOffset().y
			end

			-- Do we have some damping?
			if self:getDamping() then

				-- Set the x and y positions based on the damping value using lerp
				self.x = puggle.maths:lerp( self.x, targetX, self:getDamping() )
				self.y = puggle.maths:lerp( self.y, targetY, self:getDamping() )

			else

				-- Set the x and y values directly
				self.x = targetX
				self.y = targetY

			end

		end

	end

end

--- Make sure all layers are in the correct z order.
function Camera:_sortLayers()

	for i = #self._layers, 1, -1 do
		self._view.group:insert( self._layers[ i ] )
	end

end

--- Sort all the objects on each layer by their z depth.
function Camera:_sortObjectsByZ()

	-- Function for comparing the z depths
	local compare = function( a, b )
		return ( a.z or 1 ) < ( b.z or 1 )
	end

	for i = #self._layers, 1, -1 do

		-- Table to hold the objects for sorting
		local objects = {}

		-- Grab all the objects from the layer
		for j = self._layers[ i ].numChildren, 1, -1 do
			objects[ j ] = self._layers[ i ][ j ]
		end

		-- Do the actual sorting
		sort( objects, compare )

		-- Bring all the objects back to the front in the new z order
		for j = 1, #objects, 1 do
			objects[ j ]:toFront()
		end

	end

end

--- Sets the translation vector for the camera.
-- @param x The x value for the translation.
-- @param y The y value for the translation.
function Camera:_setTranslationVector( x, y )
	self._translationVector = { x = x, y = y }
end

--- Gets the translation vector for the camera.
-- @return The vector.
function Camera:_getTranslationVector()
	return self._translationVector or { x = 0, y = 0 }
end

--- Updates the positions for all layers.
function Camera:_updateLayerPositions()

	-- Get the current view position
	local viewX, viewY = self:getPosition()

	-- Adjust the position based on the translation values
	viewX = display.contentCenterX - ( viewX + self:_getTranslationVector().x )
	viewY = display.contentCenterY - ( viewY + self:_getTranslationVector().y )

	-- If we have some bounds then clamp the position
	if self:getBounds() then
		viewX, viewY = self:_clampPosition( viewX, viewY, self:getBounds() )
	end

	-- Update each layers position based on its parallax factor
	for i = 1, #self._layers, 1 do

		-- Ensure that every layer has a parallax factor, even if it's just 1 for both x and y
		self._layers[ i ].parallaxFactor = self._layers[ i ].parallaxFactor or { x = 1, y = 1 }

		-- If the factor is just a number then convert it into a table, with it set to both x and y
		if type( self._layers[ i ].parallaxFactor ) == "number" then
			self._layers[ i ].parallaxFactor = { x = self._layers[ i ].parallaxFactor, y = self._layers[ i ].parallaxFactor }
		end

		-- Apply the actual parallax factor
		self._layers[ i ].x = viewX * ( self._layers[ i ].parallaxFactor.x or 1 )
		self._layers[ i ].y = viewY * ( self._layers[ i ].parallaxFactor.y or 1 )

	end

end

--- Sets the translation vector for the camera.
-- @param x The x value for the translation.
-- @param y The y value for the translation.
-- @param bounds The bounds to use for the clamping.
-- @return The clamped x and y positions.
function Camera:_clampPosition( x, y, bounds )

	x = puggle.maths:clamp( x, bounds.xMin, bounds.xMax )
	y = puggle.maths:clamp( y, bounds.yMin, bounds.yMax )

	-- Return the values
	return x, y

end

--- Update handler for this system.
-- @param dt The delta time of the game.
function Camera:update( dt )

	-- Tracks to target position
	self:_track()

	-- Do we have a shaker stage? If so, adjust the camera position to take into account any shake
	if self._shakerStage and not self:getTarget() then
		self:setPosition( self.x + self._shakerStage.x, self.y + self._shakerStage.y )
	end

	-- Check if we should invalidate based on the refresh rate
	if self._lifetimeFrames % self:getRefreshRate() == 0 then

		-- Invalidate the view to make sure changes are updated
		self._view:invalidate()

	end

	-- Update the positions of all the layers
	self:_updateLayerPositions()

	-- Make sure we always have an id
	self._id = self._id or puggle.utils:generateUUID()

	-- If we're close enough to the target, and we have a listener, then call it and remove the listener
	if self:getTarget() and self:getDistanceToTarget() <= self:getTrackingAccuracy() and self:getTargetListener() and type( self:getTargetListener() ) == "function" then
		self:getTargetListener()
		self:setTargetListener( nil )
	end

	-- Sort all objects in the camera by their z depths
	if not self:isZSortingDisabled() then
		self:_sortObjectsByZ()
	end

end

--- Clears all visual parts of this camera
function Camera:clear()

	-- Destroy all the layers
	for i = #( self._layers or {} ), 1, -1 do
		display.remove( self._layers[ i ] )
		self._layers[ i ] = nil
	end

	-- Remove the current target if there is one
	self:setTarget( nil )

	-- Destroy a flash, if there is one
	display.remove( self._flash )
	self._flash = nil

	-- Destroy the main view
	display.remove( self._view )
	self._view = nil

end

--- Destroys this Camera object.
function Camera:destroy()

	-- Clears all visual parts of this camera
	self:clear()

	-- Mark this camera as destroyed
	self._destroyed = true

end

--- Return the Camera class definition.
return Camera
