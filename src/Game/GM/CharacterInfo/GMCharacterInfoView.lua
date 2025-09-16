---
--- Author: zimuyi
--- DateTime: 2023-09-19 16:42
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local TimeUtil = require("Utils/TimeUtil")

---@class GMCharacterInfoView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose CommonCloseBtnView
---@field BtnRecord UFButton
---@field TextLocation UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GMCharacterInfoView = LuaClass(UIView, true)

function GMCharacterInfoView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.BtnRecord = nil
	--self.TextLocation = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GMCharacterInfoView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GMCharacterInfoView:OnInit()
	self.Locations = UE.TArray(UE.FString)
	self.RecordFileName = TimeUtil.GetTimeFormat("LocationRecords_%Y_%m_%d_%H_%M.txt", TimeUtil.GetLocalTime())
end

function GMCharacterInfoView:OnDestroy()

end

function GMCharacterInfoView:OnShow()

end

function GMCharacterInfoView:OnHide()

end

function GMCharacterInfoView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnRecord, self.OnRecordClicked)

end

function GMCharacterInfoView:OnRegisterGameEvent()

end

function GMCharacterInfoView:OnRegisterBinder()

end

function GMCharacterInfoView:OnRegisterTimer()
	self:RegisterTimer(self.OnTimer, 0, 0.03, 0)
end

function GMCharacterInfoView:OnTimer()
	local Major = MajorUtil.GetMajor()
	if nil == Major then
		return
	end
	self.TextLocation:SetText(tostring(Major:FGetActorLocation()))
end

function GMCharacterInfoView:OnRecordClicked()
	self.Locations:Add(self.TextLocation:GetText())
	_G.UE.USaveMgr.SaveTextFile(self.Locations, self.RecordFileName)
end

return GMCharacterInfoView