--
-- Author: anypkvcai
-- Date: 2020-08-10 15:08:20
-- Description:
--
-- 已经废弃了

--[=[
local GameMgrConfig = require("Define/GameMgrConfig")

---@class GameMgr
local GameMgr = {
	Mgrs = nil
}

function GameMgr:PrevInitMgrs()
	if nil == self.Mgrs then
		return
	end

	for _, v in ipairs(GameMgrConfig) do
		local Mgr = self.Mgrs[v.MgrID]
		if nil ~= Mgr and nil ~= Mgr.PrevInit then
			FLOG_INFO("luamodule PrevInit: %s", v.Path)
			Mgr:PrevInit()
		end
	end
end

function GameMgr:InitMgrs()
	if nil == self.Mgrs then
		return
	end

	for _, v in ipairs(GameMgrConfig) do
		local Mgr = self.Mgrs[v.MgrID]
		if nil ~= Mgr and nil ~= Mgr.Init then
			FLOG_INFO("luamodule Init: %s", v.Path)
			Mgr:Init()
		end
	end
end

function GameMgr:ShutdownMgrs()
	if nil == self.Mgrs then
		return
	end

	for i = #GameMgrConfig, 1, -1 do
		local Config = GameMgrConfig[i]
		local Mgr = self.Mgrs[Config.MgrID]
		if nil ~= Mgr and nil ~= Mgr.Shutdown then
			FLOG_INFO("luamodule Shutdown: %s", Config.Path)
			Mgr:Shutdown()
		end
	end

	self.Mgrs = nil
end

---AddMgr
---@param MgrID number @GameMgrID
---@param Mgr table @MgrBase
function GameMgr:AddMgr(MgrID, Mgr)
	if nil == self.Mgrs then
		return
	end

	if nil == Mgr then
		FLOG_ERROR("GameMgr:AddMgr error: Mgr is nil!")
		return
	end

	if nil ~= self.Mgrs[MgrID] then
		FLOG_ERROR("GameMgr:AddMgr error: Mgr is already registered")
		return
	end

	self.Mgrs[MgrID] = Mgr
end

function GameMgr:GetMgr(MgrID)
	if nil == self.Mgrs then
		return
	end

	local Mgr = self.Mgrs[MgrID]
	if nil == Mgr then
		FLOG_ERROR("GameMgr:GetMgr error: Mgr is nil!")
		return
	end

	return Mgr
end

function GameMgr:CreateMgrs()
	self.Mgrs = {}

	for _, v in ipairs(GameMgrConfig) do
		--local MgrClass = require(v.Path)
		--[[
		local Mgr
		if nil ~= MgrClass.New then
			Mgr = MgrClass.New()
		else
			Mgr = MgrClass
		end
		--]]

		local Mgr = require(v.Path)


		if nil == Mgr then
			FLOG_ERROR("GameMgr:CreateMgrs Mgr is nil", v.Path)
		else
			Mgr:StaticConstructor()
			Mgr.MgrID = v.MgrID
			local Name = string.match(v.Path, "(%w+)$")
			_G[Name] = Mgr
			self:AddMgr(v.MgrID, Mgr)
		end
	end
end

return GameMgr
--]=]