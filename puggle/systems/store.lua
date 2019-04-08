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
local Store = class( "Store" )

--- Required libraries.
local store

--- Localised functions.

--- Initiates a new Store object.
-- @param params Paramater table for the object.
-- @return The new object.
function Store:initialize( params )

	-- Set the name of this manager
	self.name = "store"

	-- Table to store registered products
	self._products = {}

end

--- Automatically called after the main puggle system is initiated.
function Store:postInit()

	-- Table to store all transactions
	self._transactions = puggle.data:get( "puggle-store-transactions" ) or {}

	local transactionListener = function( event )

		local transaction = event.transaction
		local state = transaction.state
		local isError = event.isError
		local productIdentifier = transaction.productIdentifier

		if state == "failed" or isError then
			local errorType = transaction.errorType
			local errorString = transaction.errorString
		elseif state == "purchased" then
			self._transactions[ productIdentifier ] = transaction
		elseif state == "restored" then
			self._transactions[ productIdentifier ] = transaction
		elseif state == "cancelled" then

		end

	    -- Tell the store that the transaction has finished
	    if puggle.system:isIOS() or puggle.system:isKindle() then
			store.finishTransaction( event.transaction )
		end

		-- Ensure the updated transaction table is stored out
		puggle.data:set( "puggle-store-transactions", self._transactions )

	end

	-- Load up the correct plugin
	if puggle.system:getTargetStore() == "apple" then
		store = require( "store" )
	elseif puggle.system:getTargetStore() == "amazon" then
		store = require( "plugin.amazon.iap" )
	elseif puggle.system:getTargetStore() == "google" then
		store = require( "plugin.google.iap.v3" )
	end

	-- Initiate the store plugin
	if store then
		store.init( transactionListener )
	end

end

--- Adds a product to the system.
-- @param name The name of the product.
-- @param ids Table of service specific ids for stores.
function Store:add( name, ids )
	self._products[ name ] = self._products[ name ] or {}
	for k, v in pairs( ids or {} ) do
		self._products[ name ][ k ] = v
	end
end

--- Gets the service specific name of a registered product.
-- @param name The registered name of the product.
-- @param store The name of the store. Optional, defaults to the current one.
function Store:get( name, store )
	if self._products[ name ] then
		return self._products[ name ][ store or puggle.system:getTargetStore() ]
	end
end

--- Tell the store to load all the registered products.
function Store:loadProducts()

	local productListener = function( event )

		for i = 1, #event.products, 1 do

		end

		for i = 1, #event.invalidProducts, 1 do

		end

	end

	if store then

		local productIdentifiers = {}

		-- Get all the store specific product codes
		for k, _ in pairs( self._products ) do
			productIdentifiers[ #productIdentifiers + 1 ] = self:get( k )
		end

		-- Load them!
		store.loadProducts( productIdentifiers, productListener )

	end

end

--- Restores all previous purchases.
function Store:restorePurchases()
	if store then
		store.restore()
	end
end

--- Purchase a registered product.
-- @param product The registered name of the product. Or a list of them.
function Store:purchase( name )
	if store then
		if name then
			local product
			if type( name ) == "table" then
				product = {}
				for i = 1, #name, 1 do
					product[ i ] = self:get( name[ i ] )
				end
			else
				product = self:get( name )
			end
			store.purchase( product )
		end
	end
end

--- Checks if a product has been purchased.
-- @param name The registered name of the product.
function Store:hasBeenPurchased( name )
	return self._transactions[ self:get( name ) ]
end

--- Destroys this Store object.
function Store:destroy()

end

--- Return the Store class definition.
return Store
