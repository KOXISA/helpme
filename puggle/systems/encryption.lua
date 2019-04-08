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
local Encryption = class( "Encryption" )

--- Required libraries.
local openssl
pcall( function() openssl = require( "plugin.openssl" ) end )

local mime = require( "mime" )

--- Localised functions.

--- Initiates a new Encryption object.
-- @param params Paramater table for the object.
-- @return The new object.
function Encryption:initialize( params )

	-- Set the name of this manager
	self.name = "encryption"

	self._ciperSuite = "aes-256-cbc"

	self:setCipherSuite( self._ciperSuite )

end

--- Sets the cipher suite for the system to use.
-- @param type The suite to set. Possibles can be found here https://www.openssl.org/docs/manmaster/apps/ciphers.html
function Encryption:setCipherSuite( type )

	self._ciperSuite = type

	if openssl then
		self._cipher = openssl.get_cipher( self._ciperSuite )
	end

end

--- Gets the cipher suite that the system is using.
-- @return The name of the suite.
function Encryption:getCipherSuite()
	return self._ciperSuite
end

--- Encrypts some data.
-- @param data The data to encrypt.
-- @param key The encryption key to use.
-- @return The encrypted data.
function Encryption:encrypt( data, key )

    if type( data ) == "table" then
        data = puggle.utils:jsonEncode( data )
    end

    return puggle.utils:b64Encode( self._cipher:encrypt ( data, key ) )

end

--- Decrypts some data.
-- @param data The data to decrypt.
-- @param key The encryption key to use.
-- @return The decrypted data.
function Encryption:decrypt( data, key )
     return self._cipher:decrypt( puggle.utils:b64Decode( data ), key )
end

--- Return the Encryption class definition.
return Encryption
