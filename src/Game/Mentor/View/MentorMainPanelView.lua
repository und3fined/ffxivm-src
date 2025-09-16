---
--- Author: Administrator
--- DateTime: 2023-03-30 16:47
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local PhotoCameraUtil = require("Game/Photo/Util/PhotoCameraUtil")

local MentorMgr = require("Game/Mentor/MentorMgr")
local MentorMainPanelVM = require("Game/Mentor/MentorMainPanelVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetText =  require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath =  require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ActorUtil = require("Utils/ActorUtil")
local MentorDefine = require("Game/Mentor/MentorDefine")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")

local SpeechBubbleMgr = _G.SpeechBubbleMgr
local OnlineStatusMgr = _G.OnlineStatusMgr
local OnlineStatusIdentify = ProtoRes.OnlineStatusIdentify
local GUIDE_TYPE = ProtoCommon.GUIDE_TYPE

local LSTR = _G.LSTR

---@class MentorMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnConfirm CommBtnLView
---@field CloseBtn CommonCloseBtnView
---@field HorizontalDate UFHorizontalBox
---@field ImgAttitude UFImage
---@field ImgMentorIcon UFImage
---@field PopUpBG CommonPopUpBGView
---@field TableViewConditions UTableView
---@field TextTime UFTextBlock
---@field TextTips UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimResultFail UWidgetAnimation
---@field AnimResultPass UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MentorMainPanelView = LuaClass(UIView, true)

function MentorMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnConfirm = nil
	--self.CloseBtn = nil
	--self.HorizontalDate = nil
	--self.ImgAttitude = nil
	--self.ImgMentorIcon = nil
	--self.PopUpBG = nil
	--self.TableViewConditions = nil
	--self.TextTime = nil
	--self.TextTips = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AnimResultFail = nil
	--self.AnimResultPass = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MentorMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnConfirm)
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MentorMainPanelView:OnInit()
	self.TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewConditions, nil, false)

	self.Binders = {
		{ "ConditionsVMList", UIBinderUpdateBindableList.New(self, self.TableViewAdapter) },
		{ "TextTitle", UIBinderSetText.New(self, self.TextTitle) },
		{ "TextTips", UIBinderSetText.New(self, self.TextTips) },
		{ "ImgMentorIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgMentorIcon) },
		{ "ImgAttitude", UIBinderSetBrushFromAssetPath.New(self, self.ImgAttitude) },
		{ "ExpirationVisible", UIBinderSetIsVisible.New(self, self.HorizontalDate) },
		{ "ExpirationDayNum", UIBinderSetTextFormat.New(self, self.TextTime, LSTR(760001)) },
	}

	self.PopUpBG:SetHideOnClick(false)
end

function MentorMainPanelView:OnRegisterBinder()
	self:RegisterBinders(MentorMainPanelVM, self.Binders)
end

function MentorMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnConfirm, self.OnClickBtnConfirm)
end

function MentorMainPanelView:OnRegisterGameEvent()

end

function MentorMainPanelView:OnShow()
	self.BubbleTimerID = nil
	self.IsSelectConfirm = false
	local Params = self.Params or {}
	local NPCEntityID = _G.InteractiveMgr.CurInteractEntityID
	self.NPCEntityID = NPCEntityID
	local ShowType = Params.ShowType or 0
	PhotoCameraUtil.SetOffset(200,0)
	local IsConfirm = Params.IsConfirm
	if not self:CheckCutIdentity(ShowType) then
		self.BtnConfirm:SetIsEnabled(IsConfirm and (not Params.IsCD))
	end
	local NpcEmotionID
	if IsConfirm then
		self:PlayAnimation(self.AnimResultPass)
		NpcEmotionID = MentorDefine.NPCEmotionID.YES
		SpeechBubbleMgr:ShowBubbleSingle(NPCEntityID, MentorDefine.FinishTabs[ShowType].TextTips) 
		self.BubbleTimerID = self:RegisterTimer(function() _G.SpeechBubbleMgr:HideBubbleSingle(NPCEntityID) self.BubbleTimerID = nil end, 3)
	else
		self:PlayAnimation(self.AnimResultFail)
		NpcEmotionID = MentorDefine.NPCEmotionID.NO
		SpeechBubbleMgr:ShowBubbleSingle(NPCEntityID, MentorDefine.ProceedTabs[ShowType].TextTips)
		self.BubbleTimerID = self:RegisterTimer(function() _G.SpeechBubbleMgr:HideBubbleSingle(NPCEntityID) self.BubbleTimerID = nil end, 3)
	end
	
	local NpcActor = ActorUtil.GetActorByEntityID(NPCEntityID)
	if NpcActor then
		_G.EmotionMgr:PlayEmotionIDFromEntityID( NpcEmotionID, NPCEntityID, false)
	end
end

function MentorMainPanelView:OnHide()
	if not self.IsSelectConfirm then 
		PhotoCameraUtil.SetOffset(0,0)
	end
	if self.BubbleTimerID ~= nil then
		_G.SpeechBubbleMgr:HideBubbleSingle(self.NPCEntityID)
	end
end

function MentorMainPanelView:OnDestroy()

end

function MentorMainPanelView:OnClickBtnCancel()
	self:Hide()
end

function MentorMainPanelView:OnClickBtnConfirm()
	self.IsSelectConfirm = true
	self:Hide()
	MentorMgr:OpenMentorAuthenticationUI(self.Params.ShowType)
end

---@return IsOwnIdentity bool   @true已经拥有相关身份 false 暂未拥有相关身份
function MentorMainPanelView:CheckCutIdentity(ShowType)
	if (ShowType == GUIDE_TYPE.GUIDE_TYPE_FIGHT and OnlineStatusMgr:MajorHasIdentity(OnlineStatusIdentify.OnlineStatusIdentifyBattleMentor)) or
	(ShowType == GUIDE_TYPE.GUIDE_TYPE_GATHER and OnlineStatusMgr:MajorHasIdentity(OnlineStatusIdentify.OnlineStatusIdentifyMakeMentor)) or
	(ShowType == GUIDE_TYPE.GUIDE_TYPE_SENIOR and OnlineStatusMgr:MajorHasIdentity(OnlineStatusIdentify.OnlineStatusIdentifyMentor)) then 
		self.BtnConfirm:SetIsEnabled( false, false)
		self.BtnConfirm:SetText(LSTR(760014))
		return true
	else
		self.BtnConfirm:SetIsEnabled( true, true)
		self.BtnConfirm:SetText(LSTR(760016))
		return false
	end
end

return MentorMainPanelView