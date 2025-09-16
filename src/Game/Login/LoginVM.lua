---
--- Author: anypkvcai
--- DateTime: 2021-1-04 14:29
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local LoginMgr = require("Game/Login/LoginMgr")

---@class LoginVM : UIViewModel
local LoginVM = LuaClass(UIViewModel)

---Ctor
---@field OpenID number
---@field WorldID number
---@field AgreeProtocol boolean
function LoginVM:Ctor()
	self.OpenID = nil
	self.WorldID = nil
	self.WorldState = nil
	self.AgreeProtocol = false
	self.DevLogin = false
	self.LoginStep1 = true
	self.ShowBtnResearch = not UE.UCommonUtil.IsShipping()
	self.IsMapleDataRequiring = true
end

function LoginVM:OnInit()
end

function LoginVM:OnBegin()
end

function LoginVM:OnEnd()
end

function LoginVM:OnShutdown()
end

---SetOpenID
---@param OpenID number
function LoginVM:SetOpenID(OpenID)
	self.OpenID = OpenID
end

---GetOpenID
---@return number
function LoginVM:GetOpenID()
	return self.OpenID
end

---SetWorldID
---@param WorldID number
function LoginVM:SetWorldID(WorldID)
	self.WorldID = WorldID
end

---GetWorldID
---@return number
function LoginVM:GetWorldID()
	return self.WorldID
end

---SetAgreeProtocol
---@param AgreeProtocol boolean
function LoginVM:SetAgreeProtocol(AgreeProtocol)

	self.AgreeProtocol = AgreeProtocol

	if AgreeProtocol then
		_G.UE.UAccountMgr.Get():SetCouldCollectSensitiveInfo(true)
		_G.UE.UAccountMgr.Get():SetSensitiveInfo(string.format("{\"Model\" :\"%s\"}", _G.UE.UCommonUtil.GetDeviceModel()))
	else
		_G.UE.UAccountMgr.Get():SetCouldCollectSensitiveInfo(false)
	end
end

---GetAgreeProtocol
---@return boolean
function LoginVM:GetAgreeProtocol()
	return self.AgreeProtocol
end

function LoginVM:GetCurWorldName()
	--return ServerDirCfg:FindValue(self.WorldID, "Name")
	return LoginMgr:GetMapleNodeName(self.WorldID)
end

function LoginVM:GeServerName( WorldID )
	--return ServerDirCfg:FindValue(WorldID, "Name")
	return LoginMgr:GetMapleNodeName(WorldID)
end

return LoginVM