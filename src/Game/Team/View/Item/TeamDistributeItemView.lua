
local UIView = require("UI/UIView")
local UIUtil = require("Utils/UIUtil")
local LuaClass = require("Core/LuaClass")
local TimeUtil = require("Utils/TimeUtil")
local ProtoCS = require("Protocol/ProtoCS")
local RollMgr = require("Game/Roll/RollMgr")
local ProtoRes = require("Protocol/ProtoRes")
local GlobalCfg = require("TableCfg/GlobalCfg")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local TeamRollItemVM = require("Game/Team/VM/TeamRollItemVM")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local RichTextUtil = require("Utils/RichTextUtil")
local AudioUtil = require("Utils/AudioUtil")
local MajorUtil = require("Utils/MajorUtil")

local ROLL_OPERATE = ProtoCS.ROLL_OPERATE
local LSTR = _G.LSTR
local SoundPath = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/New/Play_FM_Dice.Play_FM_Dice'"

---@class TeamDistributeItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGiveUp UFButton
---@field BtnRandom UFButton
---@field Comm96Slot CommBackpack96SlotView
---@field CommRewardsSlot_UIBP CommRewardsSlotView
---@field EFF_1 UFCanvasPanel
---@field ImgCheck UFImage
---@field ImgJob UFImage
---@field ImgNeed UFImage
---@field ImgSelect UFImage
---@field ImgWaiting UFImage
---@field MI_DX_Transform_Market_2 UFImage
---@field PanelBtn UFCanvasPanel
---@field PanelBtnRandom UFCanvasPanel
---@field PanelFunction UFCanvasPanel
---@field PanelProbar UFCanvasPanel
---@field ProBarCountDown UProgressBar
---@field RichTextDescribe URichTextBox
---@field RichTextName URichTextBox
---@field TextResult UFTextBlock
---@field AnimBtnRollLoop UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimProBarLight UWidgetAnimation
---@field AnimValuables UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TeamDistributeItemView = LuaClass(UIView, true)

function TeamDistributeItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGiveUp = nil
	--self.BtnRandom = nil
	--self.Comm96Slot = nil
	--self.CommRewardsSlot_UIBP = nil
	--self.EFF_1 = nil
	--self.ImgCheck = nil
	--self.ImgJob = nil
	--self.ImgNeed = nil
	--self.ImgSelect = nil
	--self.ImgWaiting = nil
	--self.MI_DX_Transform_Market_2 = nil
	--self.PanelBtn = nil
	--self.PanelBtnRandom = nil
	--self.PanelFunction = nil
	--self.PanelProbar = nil
	--self.ProBarCountDown = nil
	--self.RichTextDescribe = nil
	--self.RichTextName = nil
	--self.TextResult = nil
	--self.AnimBtnRollLoop = nil
	--self.AnimIn = nil
	--self.AnimProBarLight = nil
	--self.AnimValuables = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TeamDistributeItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm96Slot)
	self:AddSubView(self.CommRewardsSlot_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TeamDistributeItemView:OnInit()
	self.Binders = {
		{ "RichTextDescribe", 	UIBinderSetText.New(self, self.RichTextDescribe) },
		{ "IsShowPanelBtn", 	UIBinderSetIsVisible.New(self, self.PanelBtn) },
		{ "IsHighValue", 		UIBinderSetIsVisible.New(self, self.EFF_1) },
		{ "IsHighValue", 		UIBinderSetIsVisible.New(self, self.MI_DX_Transform_Market_2) },
		{ "IsBtnRondomEnable", 	UIBinderValueChangedCallback.New(self, nil, self.OnUpdateBtnRandomState) },
		{ "IsBtnGiveUpEnable", 	UIBinderValueChangedCallback.New(self, nil, self.OnUpdateBtnGiveUpState) },
		{ "IsShowPanelProbar", 	UIBinderSetIsVisible.New(self, self.PanelProbar) },

		{ "TextDes", 			UIBinderSetText.New(self, self.TextResult) },
		{ "IsWait", 			UIBinderValueChangedCallback.New(self, nil, self.OnAwardValueChangeCallback) },
		{ "IsSelected", 		UIBinderValueChangedCallback.New(self, nil, self.OnChangeSecelted) },
		{ "Obtained", 			UIBinderValueChangedCallback.New(self, nil, self.OnAwardValueChangeCallback) },
		{ "NotObtained", 		UIBinderValueChangedCallback.New(self, nil, self.OnAwardValueChangeCallback) },
		{ "IsOperated", 		UIBinderValueChangedCallback.New(self, nil, self.OnAwardValueChangeCallback) },
		{ "ItemName", 	        UIBinderSetText.New(self, self.RichTextName) },
	}
	self.IsSecelted = true
end

function TeamDistributeItemView:OnDestroy()
end

function TeamDistributeItemView:OnShow()
	UIUtil.SetIsVisible(self.Comm96Slot.RichTextLevel, false)
	UIUtil.SetIsVisible(self.Comm96Slot.IconChoose, false)
	UIUtil.SetIsVisible(self.Comm96Slot.ImgSelect, false)
	self:PlayAnimation(self.AnimBtnRollLoop, RollMgr.BoxRollAnimationTime, 0)


	UIUtil.SetIsVisible(self.EFF_1, self.ViewModel.IsHighValue)
	UIUtil.SetIsVisible(self.MI_DX_Transform_Market_2, self.ViewModel.IsHighValue)
	if self.ViewModel.IsHighValue then
		self:PlayAnimation(self.AnimValuables, 0, 1)
	end

	--- 操作后未下发归属时重连，会导致还可以操作，这里重置下按钮状态
	if RollMgr.IsQuery then
		--- 重连后第一次打开需要设置按钮
		local IsOperated = RollMgr:GetRollResult(self.ViewModel.TeamID, self.ViewModel.AwardID)
		self.ViewModel.IsBtnRondomEnable = table.is_nil_empty(IsOperated)
		self.ViewModel.IsBtnGiveUpEnable = table.is_nil_empty(IsOperated)
	end
end

function TeamDistributeItemView:OnHide()
	self:StopAllAnimations()
	UIUtil.SetIsVisible(self.MI_DX_Transform_Market_2, false)
	UIUtil.SetIsVisible(self.EFF_1, false)
end

function TeamDistributeItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnGiveUp, self.OnClickedBtnGiveUpBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnRandom, self.OnClickedBtnRandomBtn)
end

function TeamDistributeItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.TeamRollItemUpdateTick, self.OnAwardListUpdate)
end

function TeamDistributeItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	self.ViewModel = self.Params.Data
	if nil == self.ViewModel then
		return
	end

	self:RegisterBinders(self.ViewModel, self.Binders)
end

function TeamDistributeItemView:OnClickedBtnGiveUpBtn()
	if nil == self.ViewModel then
		_G.FLOG_ERROR("TeamDistributeItemView OnClickedBtnGiveUpBtn self.ViewModel is nil")
		return
	end

	self.ViewModel.IsGiveUp = true
	self.ViewModel.TextDes = LSTR(480005)	--- "放弃"
	self.ViewModel.IsOperated = true
	self.ViewModel.IsMask = true
	self.ViewModel.IsQualify = false
	-- 发协议放弃
	local TeamID = self.ViewModel.TeamID
	RollMgr:SendMsgOperateReq(TeamID, self.ViewModel.AwardID, ROLL_OPERATE.GIVE_UP)
	local RoleID = MajorUtil.GetMajorRoleID()
	RollMgr:CheckIsNeedChangeResult(RoleID, self.ViewModel.AwardID, TeamID)

	self.ViewModel.IsBtnGiveUpEnable = false
	self.ViewModel.IsBtnRondomEnable = false
	TeamRollItemVM:OnCheckAwardsIsOperated()
	TeamRollItemVM:CheckForUnoperatedValuables()
end

function TeamDistributeItemView:OnClickedBtnRandomBtn()
	AudioUtil.LoadAndPlayUISound(SoundPath)
	FLOG_INFO("TeamRoll PlayUISound  Item Path ==  " .. SoundPath)
	if nil == self.ViewModel then
		_G.FLOG_ERROR("TeamDistributeItemView OnClickedBtnRandomBtn self.ViewModel is nil")
		return
	end
	local ViewModel = self.ViewModel

	if ViewModel ~= nil then
		--- 无资格
		if not ViewModel.IsHaveEligibility then
			MsgTipsUtil.ShowTipsByID(10027, nil, ViewModel.ItemName)	--- 无法进行需求，你没有资格获得+物品名
		else
			local TeamID = ViewModel.TeamID
			ViewModel.IsGiveUp = false
			local bIsPossesses = RollMgr:CheckIsPossesses(ViewModel)
			if bIsPossesses then --穿上的不判断
				-- 已拥有不需求
				if ViewModel.IsUnique then --是否是唯一拥有
					MsgTipsUtil.ShowTipsByID(10028, nil, ViewModel.ItemName)	--- 无法进行需求，你无法持有更多+物品名
					ViewModel.IsAlreadyPossessed = true
					ViewModel.TextDes = LSTR(480007)	--- "已拥有"
					ViewModel.IsMask = true
					--self.ViewModel:UpdateParams({SelectedMode = self.ViewModel.SelectMode.Select})
					-- ViewModel[ViewModel.SelectMode.Select] = true
					TeamRollItemVM:UpdateRollItemInfo(TeamID)
				else
					-- 发协议需求
					ViewModel.IsWait = true
					ViewModel.IsOperated = true
					RollMgr:SendMsgOperateReq(TeamID, ViewModel.AwardID, ROLL_OPERATE.DEMAND)
					ViewModel.IsBtnGiveUpEnable = false
				end
			elseif not ViewModel.Obtained then
				-- 发协议需求
				ViewModel.IsWait = true
				ViewModel.IsOperated = true
				RollMgr:SendMsgOperateReq(TeamID, ViewModel.AwardID, ROLL_OPERATE.DEMAND)
				TeamRollItemVM:UpdateRollItemInfo(TeamID)
				ViewModel.IsBtnGiveUpEnable = false
			end
		end
		ViewModel.IsBtnRondomEnable = false
		ViewModel.IsQualify = false
		ViewModel.IsMask = true
		TeamRollItemVM:OnCheckAwardsIsOperated()
		TeamRollItemVM:CheckForUnoperatedValuables()
		_G.EventMgr:SendEvent(_G.EventID.TeamRollCheckIsAllOperated)
	end
end

function TeamDistributeItemView:OnAwardListUpdate()
	local TempExpireTime = self.ViewModel.RollExpireTime

	local AwardExpireTime = GlobalCfg:FindValue(ProtoRes.global_cfg_id.GLOBAL_CFG_ECTYPE_ROLL_COUNT_DOWN, "Value")[1]

	local selfAnimProBarLight = self.AnimProBarLight
	local PlaySpeed = selfAnimProBarLight:GetEndTime() / AwardExpireTime
	local AnimationEndTime = tonumber(string.format("%.1f", selfAnimProBarLight:GetEndTime()))

	local ExpireTime = TempExpireTime * 1000 - TimeUtil.GetServerTimeMS()
	ExpireTime = ExpireTime / 1000

	if ExpireTime > 0 then
		local PlayStartTime = AnimationEndTime * ExpireTime / AwardExpireTime
		PlayStartTime = AnimationEndTime - PlayStartTime
		self:PlayAnimation(selfAnimProBarLight, PlayStartTime, -1, _G.UE.EUMGSequencePlayMode.Reverse, PlaySpeed, false)--, 0, 1, _G.UE.EUMGSequencePlayMode.Forward, PlaySpeed, false)
	end
end

function TeamDistributeItemView:OnChangeSecelted(NewValue)
	UIUtil.SetIsVisible(self.ImgSelect, NewValue, false)
end

function TeamDistributeItemView:OnUpdateBtnRandomState(NewValue)
	UIUtil.SetIsVisible(self.ImgNeed, not NewValue)
	UIUtil.SetIsVisible(self.PanelBtnRandom, NewValue)
	local TempBrush = ""
	if NewValue then
		self:PlayAnimation(self.AnimBtnRollLoop, RollMgr.BoxRollAnimationTime, 0)
		TempBrush = "PaperSprite'/Game/UI/Atlas/Team/Frames/UI_Team_Roll_Btn_Need01_png.UI_Team_Roll_Btn_Need01_png'"
	else
		self:StopAnimation(self.AnimBtnRollLoop)
		TempBrush = "PaperSprite'/Game/UI/Atlas/Team/Frames/UI_Team_Roll_Btn_Need02_png.UI_Team_Roll_Btn_Need02_png'"
	end
	UIUtil.ImageSetBrushFromAssetPath(self.ImgNeed, TempBrush)
	-- self.BtnRandom:SetIsEnabled(NewValue)
	UIUtil.SetIsVisible(self.BtnRandom, true, NewValue)
end

function TeamDistributeItemView:OnUpdateBtnGiveUpState(NewValue)
	self.BtnGiveUp:SetIsEnabled(NewValue)
end

function TeamDistributeItemView:OnAwardValueChangeCallback()
	local ViewModel = self.ViewModel
	if nil == ViewModel then
		return
	end
	UIUtil.SetIsVisible(self.TextResult, true)
	if ViewModel.IsWait then
		UIUtil.SetIsVisible(self.ImgWaiting, true)
		-- UIUtil.SetIsVisible(self.ImgMask, true)
		-- self:PlayAnimation(self.AnimRollWaiting)
	else
		UIUtil.SetIsVisible(self.ImgWaiting, false)
		-- self:StopAnimation(self.AnimRollWaiting)
	end
	local shouldShowPanel = ViewModel.IsRecommend and not ViewModel.IsOperated
	UIUtil.SetIsVisible(self.PanelFunction, shouldShowPanel)
	
	if shouldShowPanel and ViewModel.FuncImg then
		UIUtil.ImageSetBrushFromAssetPath(self.ImgJob, ViewModel.FuncImg)
	end

	if ViewModel.Obtained then					-- 已获得
		UIUtil.SetIsVisible(self.Comm96Slot.IconReceived, true)
		-- UIUtil.SetIsVisible(self.Comm96Slot.ImgMask, true)
		-- UIUtil.SetIsVisible(self.TextResult, false)
		-- self:PlayAnimation(self.AnimGot)
	else
		UIUtil.SetIsVisible(self.Comm96Slot.IconReceived, false)
	end
	if ViewModel.NotObtained then				-- 未获得
		-- self:PlayAnimation(self.AnimResult)
	else
		-- self:StopAnimation(self.AnimResult)
	end
end

return TeamDistributeItemView