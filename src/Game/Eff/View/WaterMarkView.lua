---
--- Author: skysong
--- DateTime: 2023-01-09 09:47
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CommonUtil = require("Utils/CommonUtil")

---@class WaterMarkView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ID1 UFTextBlock
---@field ID2 UFTextBlock
---@field ID3 UFTextBlock
---@field ID4 UFTextBlock
---@field ID5 UFTextBlock
---@field ID6 UFTextBlock
---@field RecordID UFTextBlock
---@field Time UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WaterMarkView = LuaClass(UIView, true)

function WaterMarkView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ID1 = nil
	--self.ID2 = nil
	--self.ID3 = nil
	--self.ID4 = nil
	--self.ID5 = nil
	--self.ID6 = nil
	--self.RecordID = nil
	--self.Time = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WaterMarkView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WaterMarkView:OnInit()
	self.TimerID=_G.TimerMgr:AddTimer(self, self.ShowTimeNow, 0, 1, 0)
	self.bShowTimeNow = true
end

function WaterMarkView:OnDestroy()

end

function WaterMarkView:OnShow()
    self:SetID()
end

function WaterMarkView:OnHide()

end

function WaterMarkView:OnRegisterUIEvent()

end

function WaterMarkView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.GMShowTimeNow, self.OnGMShowTimeNow)
end

function WaterMarkView:OnRegisterBinder()

end

function WaterMarkView:SetID()
    local ID = self.Params.Data
    self.ID1:SetText(ID)
    self.ID2:SetText(ID)
    self.ID3:SetText(ID)
    self.ID4:SetText(ID)
    self.ID5:SetText(ID)
    self.ID6:SetText(ID)

	if _G.LevelRecordMgr then
		self.LogName =_G.LevelRecordMgr:GetLogName()
		self.LogNameWithFix =_G.LevelRecordMgr:GetLogName().."-"
		local CurrentRecordID=_G.LevelRecordMgr.CurrentRecordID
		UIUtil.SetIsVisible(self.RecordID,CurrentRecordID >0)
		self.RecordID:SetText(CurrentRecordID)
	end
end

function WaterMarkView:ShowTimeNow()
	local _ <close> = CommonUtil.MakeProfileTag("WaterMarkView:ShowTimeNow")
    if self.LogNameWithFix ~= nil then
        self.Time:SetText(self.LogNameWithFix .. _G.DateTimeTools.GetOutputTime(-1, "-", 3))
    end
end

function WaterMarkView:OnGMShowTimeNow()
	if self.bShowTimeNow and self.TimerID then
		_G.TimerMgr:CancelTimer(self.TimerID)
		self.Time:SetText(self.LogName)
	else
		self.TimerID=_G.TimerMgr:AddTimer(self, self.ShowTimeNow, 0, 1, 0)
	end
	self.bShowTimeNow = not self.bShowTimeNow
end




return WaterMarkView