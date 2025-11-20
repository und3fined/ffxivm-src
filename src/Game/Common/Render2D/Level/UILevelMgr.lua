---
--- Author: zimuyi
--- DateTime: 2024-09-02
--- Description: UI关卡管理
---

local EventID = require("Define/EventID")
local LuaClass = require("Core/LuaClass")
local MajorUtil = require("Utils/MajorUtil")
local MgrBase = require("Common/MgrBase")

local UE = _G.UE
local FLOG_ERROR = _G.FLOG_ERROR
local FLOG_INFO = _G.FLOG_INFO
local FLOG_WARNING = _G.FLOG_WARNING

---@class UILevelMgr : MgrBase
local UILevelMgr = LuaClass(MgrBase)

function UILevelMgr:OnInit()
end

function UILevelMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.CameraSwitch, self.OnGameEventCameraSwitch)
end

function UILevelMgr:OnGameEventCameraSwitch()
	local WorldMgr = UE.UWorldMgr.Get()
	local CameraMgr = UE.UCameraMgr.Get()
	if nil == WorldMgr and nil == CameraMgr then
		FLOG_ERROR("[UILevelMgr:OnGameEventCameraSwitch] WorldMgr or CameraMgr is nil")
		return
	end
	local ViewTarget = CameraMgr:GetCurrentCameraOwner()
	if nil == ViewTarget or nil == ViewTarget:Get() then
		FLOG_WARNING("[UILevelMgr:OnGameEventCameraSwitch] View target is nil")
		return
	end
	local bIsViewingMajor = ViewTarget:Get() == MajorUtil.GetMajor()
	FLOG_INFO("[UILevelMgr:OnGameEventCameraSwitch] Switch " .. (bIsViewingMajor and "on" or "off") .. " level streaming ")
	WorldMgr:SwitchLevelStreaming(bIsViewingMajor)
end

return UILevelMgr