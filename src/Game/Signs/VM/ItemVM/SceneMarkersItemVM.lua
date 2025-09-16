---
--- Author: ds_tianjiateng
--- DateTime: 2024-03-21 9:21
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local TimeUtil = require("Utils/TimeUtil")
local PworldCfg = require("TableCfg/PworldCfg")

---@class SceneMarkersItemVM : UIViewModel
local SceneMarkersItemVM = LuaClass(UIViewModel)


function SceneMarkersItemVM:Ctor()
	self.Index = nil
	self.PworldID = 0
	self.TittleText = nil
	self.UTCTime = 0
	self.IsEmpty = nil
	self.BtnBtnCoverVisible = false			--- 覆盖
	self.BtnBtnDeleteVisible = false		--- 删除
	self.BtnBtnAddVisible = false			--- 添加
	self.IsSelected = false
	self.IsEnable = true
	self.TextColor = "#d5d5d5"
end

function SceneMarkersItemVM:UpdateVM(Value)
	self.Index = Value.Index
	local TittleText = Value.TittleText
	if TittleText == nil and Value.PworldID ~= nil then
		local TempPworldCfg = PworldCfg:FindCfgByKey(Value.PworldID)
		self.PworldID = Value.PworldID
		self.IsEnable = self.PworldID == _G.PWorldMgr:GetCurrPWorldResID()
		self.TittleText = TempPworldCfg.PWorldName
	else
		self.PworldID = 0
		self.IsEnable = true
		self.TittleText = TittleText
	end
	self.UTCTime = Value.UTCTime
	self.IsEmpty = Value.IsEmpty

	self.BtnBtnCoverVisible = not self.IsEmpty
	self.BtnBtnDeleteVisible = not self.IsEmpty
	self.BtnBtnAddVisible = self.IsEmpty
	self.TextColor = self.IsEnable and "#d5d5d5" or "#828282"
end

function SceneMarkersItemVM:OnShutdown()

end

function SceneMarkersItemVM:OnShutdown()
	
end

function SceneMarkersItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.Index == self.Index
end

return SceneMarkersItemVM