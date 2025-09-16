---
--- Author: eddardchen
--- DateTime: 2021-04-02 15:39
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local GMMgr = require("Game/GM/GMMgr")

---@class GMPlayAudioView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AreaID UEditableText
---@field AreaPriority UEditableText
---@field AreaSceneID UEditableText
---@field BGMChannelString UComboBoxString
---@field BGMID UEditableText
---@field BGMSceneID UEditableText
---@field BackGroundImg UImage
---@field ChangeTimeSlotButton UFButton
---@field CloseButton UFButton
---@field EnterAreaButton UFButton
---@field EventName UEditableText
---@field ExitAreaButton UFButton
---@field IsDummy UCheckBox
---@field PlayBGMButton UFButton
---@field PlayButton UFButton
---@field PlaySceneBGMButton UFButton
---@field PlayingIDToStop UEditableText
---@field PostEventButton UButton
---@field StateGroup UEditableText
---@field StateName UEditableText
---@field StopBGMButton UFButton
---@field StopSceneBGMButton UFButton
---@field TimeSlotString UComboBoxString
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GMPlayAudioView = LuaClass(UIView, true)

function GMPlayAudioView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AreaID = nil
	--self.AreaPriority = nil
	--self.AreaSceneID = nil
	--self.BGMChannelString = nil
	--self.BGMID = nil
	--self.BGMSceneID = nil
	--self.BackGroundImg = nil
	--self.ChangeTimeSlotButton = nil
	--self.CloseButton = nil
	--self.EnterAreaButton = nil
	--self.EventName = nil
	--self.ExitAreaButton = nil
	--self.IsDummy = nil
	--self.PlayBGMButton = nil
	--self.PlayButton = nil
	--self.PlaySceneBGMButton = nil
	--self.PlayingIDToStop = nil
	--self.PostEventButton = nil
	--self.StateGroup = nil
	--self.StateName = nil
	--self.StopBGMButton = nil
	--self.StopSceneBGMButton = nil
	--self.TimeSlotString = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GMPlayAudioView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GMPlayAudioView:OnInit()

end

function GMPlayAudioView:OnDestroy()

end

function GMPlayAudioView:OnShow()

end

function GMPlayAudioView:OnHide()

end

function GMPlayAudioView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.PlayButton, self.OnClickPlayButton)
	UIUtil.AddOnClickedEvent(self, self.PostEventButton, self.OnClickPostEventButton)
	UIUtil.AddOnClickedEvent(self, self.CloseButton, self.OnClickCloseButton)
	UIUtil.AddOnClickedEvent(self, self.PlayBGMButton, self.OnClickPlayBGMButton)
	UIUtil.AddOnClickedEvent(self, self.PlaySceneBGMButton, self.OnClickPlaySceneBGMButton)
	UIUtil.AddOnClickedEvent(self, self.StopSceneBGMButton, self.OnClickStopSceneBGMButton)
	UIUtil.AddOnClickedEvent(self, self.StopBGMButton, self.OnClickStopBGMButton)
	UIUtil.AddOnClickedEvent(self, self.ChangeTimeSlotButton, self.OnClickChangeTimeSlotButton)
	UIUtil.AddOnClickedEvent(self, self.EnterAreaButton, self.OnClickEnterAreaButton)
	UIUtil.AddOnClickedEvent(self, self.ExitAreaButton, self.OnClickExitAreaButton)
end

function GMPlayAudioView:OnRegisterGameEvent()

end

function GMPlayAudioView:OnRegisterTimer()

end

function GMPlayAudioView:OnRegisterBinder()

end

function GMPlayAudioView:OnClickPostEventButton()
	local UAudioMgr = _G.UE.UAudioMgr.Get()
	local EventPath = self.EventName:GetText()   --"Play_Music"
	local bIsDummyContext  = self.IsDummy:IsChecked()
	local GMProxy = UAudioMgr:GetAudioProxy()
	if bIsDummyContext then
		GMProxy = nil
	end
	UAudioMgr:LoadAndPostEvent(EventPath, GMProxy, true)
end

function GMPlayAudioView:OnClickPlayButton()
	local UAudioMgr = _G.UE.UAudioMgr.Get()
	local EventPath = self.EventName:GetText()   --"Play_Music"
	local stategroup = self.StateGroup:GetText()  -- "Music"
	local statename = self.StateName:GetText() -- "BG_P2"
	local MyMajor = MajorUtil.GetMajor()
	local MajorLocation = MyMajor:FGetActorLocation()
	local bIsDummyContext  = self.IsDummy:IsChecked()
	local GMProxy = UAudioMgr:GetAudioProxy()
	if bIsDummyContext then
		GMProxy = nil
	end
	UAudioMgr:LoadAndPostEventByState(GMProxy, EventPath, stategroup, statename, true)

	--if(eventname == "") then
	--	_G.UE.UFlibShaderPipelineCacheHelper.EnableShaderPipelineCache(true)
	--	_G.UE.UFlibShaderPipelineCacheHelper.LoadShaderPipelineCache(statename);
	--end
end

function GMPlayAudioView:OnClickCloseButton()
	UIUtil.SetIsVisible(self, false)
end

function GMPlayAudioView:OnClickPlayBGMButton()
	local BGMID = tonumber(self.BGMID:GetText())
	if not BGMID then
		return
	end
	local ChannelString = self.BGMChannelString:GetSelectedOption()
	local Channel = _G.UE.EBGMChannel[ChannelString]
	local UAudioMgr = _G.UE.UAudioMgr.Get()
	local PlayingID = UAudioMgr:PlayBGM(BGMID, Channel)
	GMMgr.GMHistoryRecord = table.concat(
		{GMMgr.GMHistoryRecord, "Play BGM (BGMID=", BGMID, ") at channel ", ChannelString, ", PlayingID: ", PlayingID, "\n"})

	self.PlayingIDToStop:SetText(tostring(PlayingID))
	local GMMainView = _G.UIViewMgr:ShowView(_G.UIViewID.GMMain)
    GMMainView.GMMain_UIBP:UpdateGMHistory()
end

function GMPlayAudioView:OnClickPlaySceneBGMButton()
	local SceneID = tonumber(self.BGMSceneID:GetText())
	local UAudioMgr = _G.UE.UAudioMgr.Get()

	if SceneID == nil or UAudioMgr == nil then
		return
	end

	local PlayingID = UAudioMgr:PlaySceneBGM(SceneID)
	GMMgr.GMHistoryRecord = table.concat(
		{GMMgr.GMHistoryRecord, "Play scene BGM ", SceneID, ", PlayingID: ", PlayingID, "\n"})
	
	self.PlayingIDToStop:SetText(tostring(PlayingID))
	local GMMainView = _G.UIViewMgr:ShowView(_G.UIViewID.GMMain)
    GMMainView.GMMain_UIBP:UpdateGMHistory()
end

function GMPlayAudioView:OnClickStopSceneBGMButton()
	local UAudioMgr = _G.UE.UAudioMgr.Get()
	if UAudioMgr == nil then
		return
	end

	UAudioMgr:StopSceneBGM()
end

function GMPlayAudioView:OnClickStopBGMButton()
	local PlayingIDToStop = tonumber(self.PlayingIDToStop:GetText())
	local UAudioMgr = _G.UE.UAudioMgr.Get()
	
	UAudioMgr:StopBGM(PlayingIDToStop)
end

function GMPlayAudioView:OnClickChangeTimeSlotButton()
	local TimeSlotText = self.TimeSlotString:GetSelectedOption()
	local TargetTimeSlot = _G.UE.ETimeSlotType[TimeSlotText]
	local EventMgr = _G.EventMgr
	local EventID = _G.EventID

	local Params = EventMgr:GetEventParams()
	Params.IntParam1 = TargetTimeSlot
	EventMgr:SendCppEvent(EventID.TimeSlotChange, Params)
end

function GMPlayAudioView:OnClickEnterAreaButton()
	local UBGMAreaMgr = _G.UE.UBGMAreaMgr.Get()

	local AreaID = tonumber(self.AreaID:GetText())
	local Priority = tonumber(self.AreaPriority:GetText())
	local SceneID = tonumber(self.AreaSceneID:GetText())

	UBGMAreaMgr:EnterArea(Priority, AreaID, SceneID, false)
end

function GMPlayAudioView:OnClickExitAreaButton()
	local UBGMAreaMgr = _G.UE.UBGMAreaMgr.Get()
	local AreaID = tonumber(self.AreaID:GetText())
	UBGMAreaMgr:ExitArea(AreaID)
end

return GMPlayAudioView