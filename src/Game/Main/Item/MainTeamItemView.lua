---
--- Author: anypkvcai
--- DateTime: 2021-04-10 10:57
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderSetProfIcon = require("Binder/UIBinderSetProfIcon")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderSetRenderOpacity = require("Binder/UIBinderSetRenderOpacity")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIAdapterTableViewEx = require("Game/Buff/UIAdapterTableViewEx")
local UIBinderSetBrushTintColorHex = require("Binder/UIBinderSetBrushTintColorHex")
local CommonBoxDefine = require("Game/CommMsg/CommonBoxDefine")
local FriendDefine = require("Game/Social/Friend/FriendDefine")

local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")

local ProtoCS = require("Protocol/ProtoCS")

local EventID = require("Define/EventID")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")

local TeamVM = require("Game/Team/VM/TeamVM")
local MainPanelVM = require("Game/Main/MainPanelVM")

local LocalHpBarAnimProxy = require("Game/Team/LocalHpBarAnimProxy")
local UIBinderSetIsVisiblePred = require("Binder/UIBinderSetIsVisiblePred")
local UIBinderSetImageBrushByResFunc = require("Binder/UIBinderSetImageBrushByResFunc")
local MakeLSTRAttrKey = require("Common/StringTools").MakeLSTRAttrKey
local MakeLSTRDict = require("Common/StringTools").MakeLSTRDict

local LSTR = _G.LSTR
local TeamMgr = _G.TeamMgr
local EventMgr = _G.EventMgr

local function IsSyncSpeakerOn(V)
	return V and (V & 2) ~= 0
end


---@class MainTeamItemView : UIView
---@field ViewModel TeamMemberVM
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnRevive UFButton
---@field ButtonTeam UFButton
---@field EFF_ProBarLight UFImage
---@field IconListen UFImage
---@field IconMicSaying UFCanvasPanel
---@field IconMute UFImage
---@field IconRevive UFImage
---@field IconReviveTime UFImage
---@field ImgCD URadialImage
---@field ImgDie UFImage
---@field ImgHatred UFImage
---@field ImgJob UFImage
---@field ImgJobSelected UFImage
---@field ImgLeader UFImage
---@field ImgMicSaying UFImage
---@field ImgProbar UFImage
---@field ImgServer UFImage
---@field ImgStatus UFImage
---@field ImgTag UFImage
---@field PanelProBar UFCanvasPanel
---@field PanelRevive UFCanvasPanel
---@field PanelReviveTime UFCanvasPanel
---@field PanelSelected UFCanvasPanel
---@field PanelSound UFCanvasPanel
---@field PanelStatus UFCanvasPanel
---@field PanelTeamItem UFCanvasPanel
---@field ProBarBlood UProgressBar
---@field ProBarBloodLimitIncrease UProgressBar
---@field ProBarBloodLimitReduce UProgressBar
---@field ProBarShied UProgressBar
---@field RollItem TeamRollINumbertemView
---@field TableViewBuffer UTableView
---@field TextEnmityOrder UTextBlock
---@field TextPlayerName UFTextBlock
---@field TextReviveTime UFTextBlock
---@field Text_SkillCD UFTextBlock
---@field AnimMicLoop UWidgetAnimation
---@field AnimPanelReviveIn UWidgetAnimation
---@field AnimProBarLightAdd UWidgetAnimation
---@field AnimProBarLightSubtract UWidgetAnimation
---@field AnimProBarResumeFast UWidgetAnimation
---@field AnimProBarResumeSlow UWidgetAnimation
---@field AnimReviveCDFinish UWidgetAnimation
---@field AnimReviveDisable UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainTeamItemView = LuaClass(UIView, true)

function MainTeamItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnRevive = nil
	--self.ButtonTeam = nil
	--self.EFF_ProBarLight = nil
	--self.IconListen = nil
	--self.IconMicSaying = nil
	--self.IconMute = nil
	--self.IconRevive = nil
	--self.IconReviveTime = nil
	--self.ImgCD = nil
	--self.ImgDie = nil
	--self.ImgHatred = nil
	--self.ImgJob = nil
	--self.ImgJobSelected = nil
	--self.ImgLeader = nil
	--self.ImgMicSaying = nil
	--self.ImgProbar = nil
	--self.ImgServer = nil
	--self.ImgStatus = nil
	--self.ImgTag = nil
	--self.PanelProBar = nil
	--self.PanelRevive = nil
	--self.PanelReviveTime = nil
	--self.PanelSelected = nil
	--self.PanelSound = nil
	--self.PanelStatus = nil
	--self.PanelTeamItem = nil
	--self.ProBarBlood = nil
	--self.ProBarBloodLimitIncrease = nil
	--self.ProBarBloodLimitReduce = nil
	--self.ProBarShied = nil
	--self.RollItem = nil
	--self.TableViewBuffer = nil
	--self.TextEnmityOrder = nil
	--self.TextPlayerName = nil
	--self.TextReviveTime = nil
	--self.Text_SkillCD = nil
	--self.AnimMicLoop = nil
	--self.AnimPanelReviveIn = nil
	--self.AnimProBarLightAdd = nil
	--self.AnimProBarLightSubtract = nil
	--self.AnimProBarResumeFast = nil
	--self.AnimProBarResumeSlow = nil
	--self.AnimReviveCDFinish = nil
	--self.AnimReviveDisable = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.ViewModel = nil
end

function MainTeamItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RollItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainTeamItemView:OnInit()
	self.HpBarAnimProxy = LocalHpBarAnimProxy.New(self, self.ProBarBlood, self.AnimProBarLightAdd, self.AnimProBarLightSubtract, 
	self.EFF_ProBarLight, self.EFF_ProBarLight)

	self.AdapterBuffer = UIAdapterTableViewEx.CreateAdapter(self, self.TableViewBuffer)
	self.AdapterBuffer:UpdateSettings(8, nil, false, false, false, true)

	local TeamRecruitUtil = require("Game/TeamRecruit/TeamRecruitUtil")
	self.RoleBinders = {
		{ "IsOnline", 	UIBinderValueChangedCallback.New(self, nil, function(View)
			if View.ViewModel then
				View.ViewModel:TimerUpdate()
			end
		end) },
		-- 刷新是否在同一张地图
		{ "MapResID", 	UIBinderValueChangedCallback.New(self, nil, function(View)
			if View.ViewModel then
				View.ViewModel:UpdateInMajorMap()
			end
		end) },
		{ "CurWorldID", TeamRecruitUtil.NewCrossServerShowBinder(nil, self, self.ImgServer)},
	}
	
	local function IsShowRescureCD(CDPercent)
		return CDPercent > 0
	end

	local BuffBinder <const> = UIBinderSetIsVisiblePred.NewByPred(function()
		if self.ViewModel then
			return (not self.ViewModel.bShowRevicePanel or self.ViewModel.bReviving) and not self.ViewModel:IsInRescureWaiting() and not self.ViewModel.bShowRoll
		end
	end, self, self.TableViewBuffer)

	local RevivePanelBinder <const> = UIBinderSetIsVisiblePred.NewByPred(function()
		if MainPanelVM.bOnPVPMap then
			return false
		end
		if self.ViewModel then
			return self.ViewModel.bShowRevicePanel and (self.ViewModel.RescureRemainTime or 0) <= 0 and not self.ViewModel.bReviving
		end
	end, self, self.PanelRevive)
	-- self.RevivePanelBinder = RevivePanelBinder
	local function IsShowPanelSound()
		if self.ViewModel == nil then
			return false
		end
		return not self.ViewModel.IsSaying and ((self.ViewModel.MicSyncState or 0) & 1 == 0)
	end
	local PanelSoundShowBinder <const> = UIBinderSetIsVisiblePred.NewByPred(IsShowPanelSound, self, self.PanelSound)
	local MicShowBinder <const> = UIBinderSetIsVisiblePred.NewByPred(function()
		if self.ViewModel == nil then
			return false
		end
		return self.ViewModel.IsSaying or ((self.ViewModel.MicSyncState or 0) & 3 == 3)
	end, self, self.IconMicSaying)

	self.ImageEnmityBinder = UIBinderSetImageBrushByResFunc.NewByResFunc(function(V)
		if V == 1 then
			return "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main_Team_Img_Hatred1_png.UI_Main_Team_Img_Hatred1_png'"
		elseif V == 2 then
			return "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main_Team_Img_Hatred2_png.UI_Main_Team_Img_Hatred2_png'"
		end
	end, self, self.ImgHatred)
	self.ShowImageEnmityBinder = UIBinderSetIsVisiblePred.NewByPred(function(V)
		return V == 1 or V == 2
	end, self, self.ImgHatred)

	self.MemBinders = {
		{ "ProfID", 			UIBinderSetProfIcon.New(self, self.ImgJob) },
		{ "BGColor", 			UIBinderSetBrushTintColorHex.New(self, self.ImgProbar) },
		{ "IsSelected", 		UIBinderSetIsVisible.New(self, self.PanelSelected) },
		{ "IsPopUpMenu", 		UIBinderSetIsVisible.New(self, self.ImgJobSelected) },
		{ "IsPopUpMenu", 		UIBinderValueChangedCallback.New(self, nil, function(View, V)
			local VisibleMenu = UIViewMgr:IsViewVisible(UIViewID.TeamMenu)
			if V then
				if not VisibleMenu then
					View:PopupMenu()
				end
			else
				View:CancelSelecedPopup()
			end
		end) },
		{ "HPPercent", 			UIBinderSetPercent.New(self, self.ProBarBlood) },
		{ "IsCaptain", 			UIBinderSetIsVisible.New(self, self.ImgLeader) },
		{ "EnmityOrder", 	UIBinderSetIsVisiblePred.NewByPred(function(V)
			return V  and V ~= 0
		end, self, self.TextEnmityOrder)},
		{ "EnmityOrder", 	UIBinderSetText.New(self, self.TextEnmityOrder, function(Value)
			if Value == 1 then
				return _G.LSTR(1300068)
			else
				return tostring(Value)
			end
		end) },
		{ "EnmityOrder", self.ShowImageEnmityBinder},
		{ "EnmityOrder", self.ImageEnmityBinder},
		{ "ShiedPercent", 		UIBinderSetPercent.New(self, self.ProBarShied) },
		{ "IsShiedVisible", 	UIBinderSetIsVisible.New(self, self.ProBarShied) },
		{ "IncreasedPercent",	UIBinderSetPercent.New(self, self.ProBarBloodLimitIncrease) },
		{ "IsMaxHPIncrease", 	UIBinderSetIsVisible.New(self, self.ProBarBloodLimitIncrease) },
		{ "ReducedPercent", 	UIBinderSetPercent.New(self, self.ProBarBloodLimitReduce) },
		{ "IsMaxHPReduce", 		UIBinderSetIsVisible.New(self, self.ProBarBloodLimitReduce) },
		{ "RenderOpacity", 		UIBinderSetRenderOpacity.New(self, self.PanelTeamItem) },
		{ "NameColor", 			UIBinderSetColorAndOpacityHex.New(self, self.TextPlayerName) },
		{ "BuffVMList", 		UIBinderUpdateBindableList.New(self, self.AdapterBuffer) },
		{ "Name", 		UIBinderSetText.New(self, self.TextPlayerName) },
		{ "bShowRevicePanel", RevivePanelBinder},
		{ "RescureRemainTime", RevivePanelBinder},
		{ "bReviving", RevivePanelBinder},
		{ "RescureRemainTime", UIBinderSetIsVisiblePred.NewByPred(function(V)
			 return V and V > 0
		end, self, self.PanelReviveTime)},
		{ "bShowRevicePanel", UIBinderValueChangedCallback.New(self, nil, function(View, ...)
			View:OnShowPanelValueChange(...)
		end)},
		{ "bShowHPPanel", UIBinderSetIsVisible.New(self, self.PanelProBar)},
		{ "CDPercentRescureSkillRemain", UIBinderSetIsVisiblePred.NewByPred(IsShowRescureCD, self, self.Text_SkillCD)},
		{ "CDRescureSkillRemain", UIBinderSetText.New(self, self.Text_SkillCD, function(V)
			return tostring(V)
		end)},
		{ "CDPercentRescureSkillRemain", UIBinderSetIsVisiblePred.NewByPred(IsShowRescureCD, self, self.ImgCD)},
		{ "CDPercentRescureSkillRemain", UIBinderSetPercent.New(self, self.ImgCD)},
		{ "RescureRemainTime", UIBinderSetText.New(self, self.TextReviveTime, function(V)
			return tostring(V)
		end)},

		-- 在线状态
		{ "HasOLStat", 			UIBinderSetIsVisible.New(self, self.PanelStatus) },
		{ "HasOLStat", 			UIBinderSetIsVisible.New(self, self.ImgJob, true) },
		{ "OLStatIcon",			UIBinderSetBrushFromAssetPath.New(self, self.ImgStatus) },
		{ "bDead",				UIBinderSetIsVisible.New(self, self.ImgDie)},

		{ "bDead", UIBinderValueChangedCallback.New(self, nil, function(_, V)
			UIUtil.TextBlockSetOutlineColorAndOpacityHex(self.TextPlayerName, V and "000000B3" or "187EB999")
			UIUtil.TextBlockSetColorAndOpacityHex(self.TextPlayerName, V and "AFAFAFFF" or "FFFFFFFF")
		end)},

		-- 血条动效相关
		{ "HPPercent", 	UIBinderValueChangedCallback.New(self, nil, function(View)
			View:UpdateHpAnim()
		end) },
		{ "ShiedPercent", 	UIBinderValueChangedCallback.New(self, nil, function(View)
			View:UpdateHpAnim()
		end) },

		-- buff
		{ "bShowRevicePanel", 		BuffBinder },
		{ "RescureRemainTime", 		BuffBinder },
		{ "bShowRoll",				BuffBinder },
		{ "bReviving",				BuffBinder },

		-- 战利品分配掷色子
		{ "IsUpdateRoll", 		UIBinderValueChangedCallback.New(self, nil, self.OnUpdateRollResultChangeCallback) },

		-- voice
		{ "IsSaying", 			UIBinderValueChangedCallback.New(self, nil, function (View)
			View:OnValueChangedIsSaying()
		end) },
		{ "IsSaying", 	PanelSoundShowBinder},
		{ "MicSyncState", 	PanelSoundShowBinder},
		{ "IsSaying", 	MicShowBinder},
		{ "MicSyncState", 	MicShowBinder},
		{ "MicSyncState", UIBinderSetIsVisiblePred.NewByPred(IsSyncSpeakerOn, self, self.IconListen)},
		{ "MicSyncState", UIBinderSetIsVisiblePred.NewByPred(IsSyncSpeakerOn, self, self.IconMute, true)},
	}

	self.EntourageBinders = {
		{ "EntourageProfIcon", 	UIBinderSetBrushFromAssetPath.New(self, self.ImgJob) },
		{ "IsEntourage", 		UIBinderValueChangedCallback.New(self, nil, function(View)
			if View.ViewModel then
				View.ViewModel:UpdateRenderOpacity()
			end
		end) },
	}

	self.MainPanelBinders = {
		{ "IsOnPVPMap", RevivePanelBinder },
	}
end

function MainTeamItemView:OnShow()
	if _G.UIViewMgr:IsViewVisible(UIViewID.TeamRollPanel) then
		self:OnTeamRollItemViewStatus(true)
	else
		self:OnTeamRollItemViewStatus(false)
	end

	self:OnMajorMPChange({ULongParam1=MajorUtil.GetMajorEntityID()})
	self:OnUpdateRollResultChangeCallback()
	self:OnRollAnimSmooth()
end

function MainTeamItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ButtonTeam, self.OnClickButtonTeam)
	UIUtil.AddOnLongClickedEvent(self, self.ButtonTeam, self.PopupMenu)
	UIUtil.AddOnClickedEvent(self, self.BtnRevive, self.Rescure)

	local function SetRenderScale(Widget, Scale)
		Widget:SetRenderScale(_G.UE.FVector2D(1, 1) * Scale)
	end
	do
		
		UIUtil.AddOnPressedEvent(self, self.BtnRevive, function()
			SetRenderScale(self.ImgCD, 0.8)
			SetRenderScale(self.IconRevive, 0.8)
		end)
		UIUtil.AddOnReleasedEvent(self, self.BtnRevive, function()
			SetRenderScale(self.ImgCD, 1)
			SetRenderScale(self.IconRevive, 1)
		end)
	end

	UIUtil.AddOnPressedEvent(self, self.ButtonTeam, function()
		SetRenderScale(self.PanelTeamItem, 1.05)
	end)
	UIUtil.AddOnReleasedEvent(self, self.ButtonTeam, function()
		SetRenderScale(self.PanelTeamItem, 1)
	end)
end

local function IsMajorHealProf()
	local ProtoCommon = require("Protocol/ProtoCommon")
	return MajorUtil.GetMajorProfFunc() == ProtoCommon.function_type.FUNCTION_TYPE_RECOVER
end

function MainTeamItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.TeamMemberShowSelect, self.OnGameEventShowSelect)
	self:RegisterGameEvent(EventID.TeamRollItemViewShowStatus, self.OnTeamRollItemViewStatus)
	self:RegisterGameEvent(EventID.SkillCDUpdateLua, self.OnSkillCDUpdate)
	self:RegisterGameEvent(EventID.MajorSkillCastFailed, self.OnMajorSkillCastFailed)
	self:RegisterGameEvent(EventID.SkillCDGroupUpdateLua, self.OnSkillCDGroupUpdate)

	if IsMajorHealProf() then
		self:RegisterGameEvent(EventID.AttackEffectChange, self.OnTakeAttackEffect)
		self:RegisterGameEvent(EventID.Attr_Change_MP, self.OnMajorMPChange)
	end
	
	self:RegisterGameEvent(EventID.MajorProfSwitch, self.OnMajorProfChanged)
end

function MainTeamItemView:OnTeamRollItemViewStatus(IsOpen)
	if IsOpen then
		self:ShowMutualRightView(2)
	else
		self:ShowMutualRightView(1)
	end
end

function MainTeamItemView:OnGameEventShowSelect()
	self.ViewModel:SetIsPopUpMenu(false)
end

function MainTeamItemView:OnRegisterBinder()
	self.ViewModel = self.Params and self.Params.Data or nil
	if not self.ViewModel then
		return
	end

	self:RegisterBinders(self.ViewModel, self.MemBinders)
	if self.ViewModel.RoleID and self.ViewModel.RoleID ~= 0 then
		self:RegisterBinders(_G.RoleInfoMgr:FindRoleVM(self.ViewModel.RoleID, true), self.RoleBinders)
	elseif self.ViewModel.IsEntourage then
		self:RegisterBinders(self.ViewModel, self.EntourageBinders)
	end

	self:RegisterBinders(MainPanelVM, self.MainPanelBinders)
end

function MainTeamItemView:GetRoleID()
	return self.ViewModel and self.ViewModel.RoleID or nil
end

local TargetLockType <const> = _G.UE.ETargetLockType.Hard

function MainTeamItemView:OnSelectChanged(bSelected)
	local ViewModel = self.ViewModel
	if nil == ViewModel then
		return
	end

	ViewModel:SetIsSelected(bSelected)

	if bSelected and ViewModel.IsSelectSyncScene then
		local EventParams = _G.EventMgr:GetEventParams()
		EventParams.ULongParam1 = ViewModel.EntityID or ActorUtil.GetEntityIDByRoleID(self:GetRoleID())
		EventParams.IntParam2 = TargetLockType
		EventMgr:SendCppEvent(EventID.ManualSelectTarget, EventParams)
		EventMgr:SendEvent(EventID.TeamMemberBeSelected, EventParams)
	end
end

function MainTeamItemView:OnClickButtonTeam()
	local ViewModel = self.ViewModel
	if nil == ViewModel then
		return
	end

	if not ViewModel.IsSelected then
		self.Params.Adapter:SetSelectedIndex(self.Params.Index)
		return
	end

	if not ViewModel.IsEntourage then
		if not ViewModel.IsPopUpMenu then
			self.ViewModel:SetIsPopUpMenu(true)
		else
			self.ViewModel:SetIsPopUpMenu(false)
		end
	end
end

---@param View MainTeamItemView
local function GetMenuItemsTeam(View)
	local Items = {}
	local IsFriend = _G.FriendMgr:IsFriend(View:GetRoleID())
	if TeamMgr:IsCaptain() then
		-- 队长自己点队长
		if View:GetRoleID() == MajorUtil.GetMajorRoleID() then
			table.insert(Items, MakeLSTRDict({ [MakeLSTRAttrKey("Name")] = 1300017, Callback = View.OnDestroyTeam, Object = View }))
		-- 队长自己点其他队员
		else
			table.insert(Items, MakeLSTRDict({ [MakeLSTRAttrKey("Name")] = 1300046, Callback = View.OnSetCaption, Object = View }))
			table.insert(Items, MakeLSTRDict({ [MakeLSTRAttrKey("Name")] = 1300047, Callback = View.OnCheckMemInfo, Object = View }))
			if not IsFriend then
				table.insert(Items, MakeLSTRDict({ [MakeLSTRAttrKey("Name")] = 1300048, Callback = View.OnAddFriend, Object = View }))
			end
			table.insert(Items, MakeLSTRDict({ [MakeLSTRAttrKey("Name")] = 1300049, Callback = View.OnKickMember, Object = View }))
		end
	else
		-- 队员自己点队员自己
		if View:GetRoleID() == MajorUtil.GetMajorRoleID() then
			table.insert(Items, MakeLSTRDict({ [MakeLSTRAttrKey("Name")] = 1300017, Callback = View.OnLeaveTeam, Object = View }))
		-- 队员自己点其他队员
		else
			table.insert(Items, MakeLSTRDict({ [MakeLSTRAttrKey("Name")] = 1300047, Callback = View.OnCheckMemInfo, Object = View }))
			if not IsFriend then
				table.insert(Items, MakeLSTRDict({ [MakeLSTRAttrKey("Name")] = 1300048, Callback = View.OnAddFriend, Object = View }))
			end
		end
	end

	if View:GetRoleID() ~= MajorUtil.GetMajorRoleID() then
		table.insert(Items, MakeLSTRDict({ [MakeLSTRAttrKey("Name")] = 1300075, Callback = View.OnReport, Object = View }))
	end

	return Items
end

---@param View MainTeamItemView
local function GetMenuItemsPWorldTeam(View)
	local Items = {}
	if _G.PWorldTeamMgr:IsCaptain() then
		-- 队长自己点队长
		if View:GetRoleID() == MajorUtil.GetMajorRoleID() then
			--
		else
			table.insert(Items, MakeLSTRDict({ [MakeLSTRAttrKey("Name")] = 1300047, Callback = View.OnCheckMemInfo, Object = View }))
			if not _G.FriendMgr:IsFriend(View:GetRoleID()) then
				table.insert(Items, MakeLSTRDict({ [MakeLSTRAttrKey("Name")] = 1300048, Callback = View.OnAddFriend, Object = View }))
			end
		end
	else
		-- 队员自己点队员自己
		if View:GetRoleID() == MajorUtil.GetMajorRoleID() then
		else
			-- 队员自己点其他队员
			table.insert(Items, MakeLSTRDict({ [MakeLSTRAttrKey("Name")] = 1300047, Callback = View.OnCheckMemInfo, Object = View }))
			if not _G.FriendMgr:IsFriend(View:GetRoleID()) then
				table.insert(Items, MakeLSTRDict({ [MakeLSTRAttrKey("Name")] = 1300048, Callback = View.OnAddFriend, Object = View }))
			end
		end
	end

	if View:GetRoleID() ~= MajorUtil.GetMajorRoleID() then
		table.insert(Items, MakeLSTRDict({ [MakeLSTRAttrKey("Name")] = 1300075, Callback = View.OnReport, Object = View }))
	end

	return Items
end

local function GetMenuItems(self)
	local IsDungeon = _G.PWorldMgr:CurrIsInDungeon() 
	if IsDungeon then
		return GetMenuItemsPWorldTeam(self)
	else
		return GetMenuItemsTeam(self)
	end
end

function MainTeamItemView:PopupMenu()
	local Items = GetMenuItems(self)

	if #Items <= 0 then
		return
	end

	-- 计算位置
	local Size = UIUtil.GetLocalSize(self.ButtonTeam)
	local ViewportPos = UIUtil.WidgetLocalToViewport(self.ButtonTeam)
	local Params = { RoleID = self:GetRoleID(), Items = Items, Pos = _G.UE.FVector2D(ViewportPos.X + Size.X + 10 ,ViewportPos.Y)}
	UIViewMgr:ShowView(UIViewID.TeamMenu, Params)
end

function MainTeamItemView:CancelSelecedPopup()
	local VisibleMenu = UIViewMgr:IsViewVisible(UIViewID.TeamMenu)
	if VisibleMenu then
		UIViewMgr:HideView(UIViewID.TeamMenu)
	end

	self.Params.Adapter:CancelSelected()
	self.ViewModel:SetIsSelected(false)
end

function MainTeamItemView:OnPressButtonTeam()
	self:PlayAnimation(self.AnimInselect)
end

function MainTeamItemView:OnClickButtonIcon()
end

function MainTeamItemView:OnDestroyTeam()
	if not TeamMgr:CheckCanOpTeam(true) then
		return
	end

	local function DestoryAct()
		_G.TeamMgr:DestroyTeamFromUI(self)
	end

	local function LeaveAct()
		_G.TeamMgr:QuitTeamFromUI(self)
	end

	local Params = { MidBtnStyle = CommonBoxDefine.BtnStyleType.Yellow }
	
	local strContent = LSTR(640048)     --确认要退出小队吗？	
	MsgBoxUtil.ShowMsgBoxThreeOp(self, LSTR(640047), strContent,
		DestoryAct, LeaveAct, nil, LSTR(10003), LSTR(10010), LSTR(10012), Params)
end

function MainTeamItemView:OnLeaveTeam()
	if not TeamMgr:CheckCanOpTeam(true) then
		return
	end

	_G.TeamMgr:QuitTeamFromUI(self)
end

function MainTeamItemView:OnSetCaption()
	if not TeamMgr:CheckCanOpTeam(true) then
		return
	end

	TeamMgr:SendSetCaptainReq(TeamMgr.TeamID, self:GetRoleID())
end

function MainTeamItemView:OnKickMember()
	if not TeamMgr:CheckCanOpTeam(true) then
		return
	end

	TeamMgr:SendKickMemberReq(TeamMgr.TeamID, self:GetRoleID())
end

function MainTeamItemView:OnCheckMemInfo()
	_G.PersonInfoMgr:ShowPersonalSimpleInfoView(self:GetRoleID())
end

function MainTeamItemView:OnAddFriend()
	_G.FriendMgr:AddFriend(self:GetRoleID(), FriendDefine.AddSource.MainUITeam)
end

function MainTeamItemView:OnReport()
	_G.TeamVoiceMgr:ReportPlayer(self:GetRoleID())
end

function MainTeamItemView:UpdateRenderOpacity()
	local ViewModel = self.ViewModel
	if nil == ViewModel then
		return
	end

	ViewModel:UpdateRenderOpacity()
end

function MainTeamItemView:UpdateHpAnim()
	if self.ViewModel then
		self.HpBarAnimProxy:Upd(self.ViewModel.HPPercent, self.ViewModel.ShiedPercent)
	end
end

--- 奖励Item变动回调(切换或下发RollResult)
function MainTeamItemView:OnUpdateRollResultChangeCallback()
	local selfRollItem = self.RollItem
	if not UIUtil.IsVisible(self.RollItem) then
		return
	end
	local DecadeTextNumber = selfRollItem.DecadeTextNumber
	local UintTextNumber = selfRollItem.UintTextNumber
	UIUtil.SetIsVisible(DecadeTextNumber, true)
	UIUtil.SetIsVisible(UintTextNumber, true)
	local ViewModel = self.ViewModel
	-- 设置当前玩家底色区别
	if ViewModel.IsMajor then
		ViewModel.IsHasPlayWaitResult = false			-- 当前玩家是否播放等待结果动画
		UIUtil.ImageSetBrushFromAssetPath(self.RollItem.ImgNumberBkgGet, "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main_Team_Roll_Self_png.UI_Main_Team_Roll_Self_png'")
	else
		UIUtil.ImageSetBrushFromAssetPath(self.RollItem.ImgNumberBkgGet, "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main_Team_Roll_Others_png.UI_Main_Team_Roll_Others_png'")
	end
	if ViewModel.NotRollResultNotify then
		-- 没有Roll点结果是设置问号并return
		selfRollItem:StopAllAnimations()
		UIUtil.SetIsVisible(DecadeTextNumber, true)
		UIUtil.SetIsVisible(UintTextNumber, true)
		DecadeTextNumber:SetText("?")
		UintTextNumber:SetText("?")
		self:StopRollTimers()
		UIUtil.SetIsVisible(selfRollItem.ImgNumberBkgGet_1, false)
		UIUtil.SetIsVisible(selfRollItem.ImgNumberBkgGet, true)
		UIUtil.SetIsVisible(selfRollItem.EFF_Sequence_1_Inst_12a, false)
		UIUtil.SetIsVisible(selfRollItem.EFF_Sequence_1_Inst_12, false)
		return
	end

	if ViewModel.IsSwitch then
		selfRollItem:StopAllAnimations()
		UIUtil.SetIsVisible(selfRollItem.EFF_Sequence_1_Inst_12a, false)
		UIUtil.SetIsVisible(selfRollItem.EFF_Sequence_1_Inst_12, false)
		self:OnInitRollItemStatus()
		self:OnCheckIsWin()
		self:StopRollTimers()
		UIUtil.SetIsVisible(UintTextNumber, true)
		UIUtil.SetIsVisible(DecadeTextNumber, true)
		return
	else
		if DecadeTextNumber:GetText() ~= "?" or UintTextNumber:GetText() ~= "?" then
			if ViewModel.IsBelong then
				self:StopAnimShowWaitWinLoop()
			end
			selfRollItem:StopAllAnimations()
			if ViewModel.IsWin then
				selfRollItem:PlayAnimation(selfRollItem.AnimRollendWin, 0, 1)
			end
			UIUtil.SetIsVisible(UintTextNumber, true)
			UIUtil.SetIsVisible(DecadeTextNumber, true)
			return
		end
	end
	-- 是否直接显示点数
	if ViewModel.IsSmooth then
		self:PlayRollAnim({SmoothAnimTimer = true})
	else
		if ViewModel.IsHasShowRollResult then
			self:PlayRollAnim({SmoothAnimTimer = true})
		else
			self:PlayRollAnim({SmoothAnimTimer = false, UnitAnimTimer = true})
		end
	end
end

--- 设置当前Item为未中奖状态
function MainTeamItemView:SwitchToNotWinStatus()
	local selfRollItem = self.RollItem
	selfRollItem:StopAllAnimations()
	selfRollItem:PlayAnimation(selfRollItem.HideAll, 0, 1)
	UIUtil.SetIsVisible(self.RollItem.ImgNumberBkgGet_1, false)
	UIUtil.SetIsVisible(self.RollItem.ImgNumberBkgGet, true)
	if self.ViewModel.IsMajor then
		UIUtil.ImageSetBrushFromAssetPath(self.RollItem.ImgNumberBkgGet, "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main_Team_Roll_Self_png.UI_Main_Team_Roll_Self_png'")
	else
		UIUtil.ImageSetBrushFromAssetPath(self.RollItem.ImgNumberBkgGet, "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main_Team_Roll_Others_png.UI_Main_Team_Roll_Others_png'")
	end
end

--- 播放RollItem动画and设置初始Text ?/0
function MainTeamItemView:PlayRollAnim(Param)
	if self.ViewModel.RollResult == 0 then
		self.RollItem:StopAnimation(self.RollItem.AnimRolling)
		self.RollItem:StopAnimation(self.RollItem.AnimRollend)
		if self.ViewModel.NotRollResultNotify then
			self.RollItem.DecadeTextNumber:SetText("?")
			self.RollItem.UintTextNumber:SetText("?")
		else
			self.RollItem.DecadeTextNumber:SetText("0")
			self.RollItem.UintTextNumber:SetText("0")
		end
		return
	else
		if self.ViewModel.NotRollResultNotify then
			self.RollItem.DecadeTextNumber:SetText("?")
			self.RollItem.UintTextNumber:SetText("?")
		end
	end
	-- UIUtil.SetIsVisible(self.RollItem.DecadeTextNumber, false)
	-- UIUtil.SetIsVisible(self.RollItem.UintTextNumber, false)
	if Param.SmoothAnimTimer then		-- Smooth 一起设置个位十位
		self:OnRollAnimSmooth()
	elseif Param.UnitAnimTimer then
		self:OnRollAnimUnit()
	end
end

--- 一起设置个位十位
function MainTeamItemView:OnRollAnimSmooth()
	local ViewModel = self.ViewModel
	UIUtil.SetIsVisible(self.RollItem.DecadeTextNumber, true)
	UIUtil.SetIsVisible(self.RollItem.UintTextNumber, true)
	if not self.ViewModel.NotRollResultNotify then
		local DecadeNumber = math.floor(ViewModel.RollResult / 10)
		local UintNumber = ViewModel.RollResult % 10
		self.RollItem.DecadeTextNumber:SetText(tostring(DecadeNumber))
		self.RollItem.UintTextNumber:SetText(tostring(UintNumber))
	end
end

--- Rolling-->个位数字-->RollRollend-->十位数字
function MainTeamItemView:OnRollAnimUnit()
	local ViewModel = self.ViewModel
	local selfRollItem = self.RollItem
	local DecadeNumber = math.floor(ViewModel.RollResult / 10)
	local UintNumber = ViewModel.RollResult % 10
	selfRollItem:PlayAnimation(selfRollItem.AnimRolling)
	local UintDelayTime = selfRollItem.AnimRolling:GetEndTime()

	self:StopRollTimers()
	-- 注册Timer 个位动画结束时赋值UintTextNumber
	self.DecadeTimerID = self:RegisterTimer(function()
		selfRollItem.UintTextNumber:SetText(UintNumber)
		selfRollItem:PlayAnimation(selfRollItem.AnimRollend, 0, 1)
		local DecadeDelayTime = selfRollItem.AnimRollend:GetEndTime()
		UIUtil.SetIsVisible(selfRollItem.UintTextNumber, true)
		-- 注册Timer 十位动画结束时赋值DecadeTextNumber
		self.UintTimerID = self:RegisterTimer(function()
			UIUtil.SetIsVisible(selfRollItem.UintTextNumber, true)
			UIUtil.SetIsVisible(selfRollItem.DecadeTextNumber, true)
			UIUtil.SetIsVisible(selfRollItem.EFF_Sequence_1_Inst_12a, false)
			UIUtil.SetIsVisible(selfRollItem.EFF_Sequence_1_Inst_12, false)
			selfRollItem.DecadeTextNumber:SetText(DecadeNumber)
			if not ViewModel.IsBelong and ViewModel.RollResult ~= 0 then
				selfRollItem:PlayAnimation(selfRollItem.AnimShowWaitWinLoop, 0, 0)
			else
				if ViewModel.IsWin then
					selfRollItem:PlayAnimation(selfRollItem.AnimRollendWin, 0, 1)
				end
			end
		end, DecadeDelayTime)

	end, UintDelayTime)
end

function MainTeamItemView:OnTeamWaitResultPlayListenNotify()
	local ViewModel = self.ViewModel
	if not ViewModel.IsHasPlayWaitResult then
		if not ViewModel.IsBelong then
			if TeamVM.IsShowWin and self.RollItem.DecadeTextNumber:GetText() ~= "?" then
				self.RollItem:PlayAnimation(self.RollItem.AnimShowWaitWinLoop, 0, 0)
				ViewModel.IsHasPlayWaitResult = true
			end
		end
	end
end

function MainTeamItemView:StopAnimShowWaitWinLoop()
	self.RollItem:StopAnimation(self.RollItem.AnimShowWaitWinLoop)
	UIUtil.SetColorAndOpacity(self.RollItem.EFF_ADD_Inst_15, 0, 0, 0, 0)
	UIUtil.SetColorAndOpacity(self.RollItem.EFF_ADD_Inst_15a, 0, 0, 0, 0)
	UIUtil.SetColorAndOpacity(self.RollItem.EFF_ADD_Inst_15b, 0, 0, 0, 0)
	UIUtil.SetColorAndOpacity(self.RollItem.EFF_ADD_Inst_15c, 0, 0, 0, 0)
end

-- function MainTeamItemView:AddRoleWinResultListenTimer()
-- 	local UnitAnimationEndTime = tonumber(string.format("%.1f", self.RollItem.AnimRolling:GetEndTime()))
-- 	local DecadeAnimationEndTime = tonumber(string.format("%.1f", self.RollItem.AnimRollend:GetEndTime()))
-- 	local RollAnimFinsishTime = UnitAnimationEndTime * TeamVM.UnitAnimPlayCount + TeamVM.DecadeAnimPlayCount * DecadeAnimationEndTime
-- 	RollMgr:AddTeamWinListenerTimer({AwardID = self.ViewModel.AwardID, ListenTimeLen = RollAnimFinsishTime})
-- end

-- function MainTeamItemView:AddTeamWaitResultPlayAnimListenerTimer()
-- 	local UnitAnimationEndTime = tonumber(string.format("%.1f", self.RollItem.AnimRolling:GetEndTime()))
-- 	local DecadeAnimationEndTime = tonumber(string.format("%.1f", self.RollItem.AnimRollend:GetEndTime()))
-- 	local RollAnimFinsishTime = UnitAnimationEndTime * TeamVM.UnitAnimPlayCount + TeamVM.DecadeAnimPlayCount * DecadeAnimationEndTime
-- 	RollMgr:AddTeamWaitResultPlayAnimListenerTimer({AwardID = self.ViewModel.AwardID, ListenTimeLen = RollAnimFinsishTime, OnTeamWaitResultPlayListenNotify = self.OnTeamWaitResultPlayListenNotify, View = self})
-- end

-- 用于互斥显示右边TableViewBuffer视图和RollItem点
function MainTeamItemView:ShowMutualRightView(ViewID)
	local EnmViewID = {Close = 0, TableViewBuffer = 1, RollItem = 2}
	if ViewID == EnmViewID.TableViewBuffer then
		UIUtil.SetIsVisible(self.RollItem, false)
	elseif ViewID == EnmViewID.RollItem then
		UIUtil.SetIsVisible(self.RollItem, true, true)
		self:OnUpdateRollResultChangeCallback()
	else
		UIUtil.SetIsVisible(self.RollItem, false)
	end

	if self.ViewModel then
		self.ViewModel:SetShowRoll(ViewID == EnmViewID.RollItem)
	end
end

function MainTeamItemView:OnValueChangedIsSaying()
	if nil == self.ViewModel then
		return
	end

	if self.ViewModel.IsSaying then
		self:PlayAnimation(self.AnimMicLoop, 0, 0)

	else
		self:StopAnimation(self.AnimMicLoop)
		UIUtil.ImageSetMaterialScalarParameterValue(self.ImgMicSaying, "Progress", 0)
	end
end

--- 检查当前队伍Item Roll点结果是否获胜(获胜者修改底色)
function MainTeamItemView:OnCheckIsWin()
	if self.ViewModel.IsWin then
		-- 修改获胜者点数底色
		self:StopAnimShowWaitWinLoop()
		UIUtil.SetIsVisible(self.RollItem.EFF_Sequence_1_Inst_12, false, false)
		UIUtil.SetIsVisible(self.RollItem.EFF_Sequence_1_Inst_12a, false, false)
		UIUtil.SetIsVisible(self.RollItem.ImgNumberBkgGet_1, true)
		UIUtil.SetIsVisible(self.RollItem.ImgNumberBkgGet, false)
	else
		if self.ViewModel.IsBelong then
			self:SwitchToNotWinStatus()
		else
			self.RollItem:PlayAnimation(self.RollItem.AnimShowWaitWinLoop, 0, 0)
		end
	end
end

function MainTeamItemView:OnInitRollItemStatus()
	self:SwitchToNotWinStatus()
	local ViewModel = self.ViewModel
	if ViewModel.NotRollResultNotify then
		self.RollItem.DecadeTextNumber:SetText("?")
		self.RollItem.UintTextNumber:SetText("?")
	else
		if ViewModel.RollResult == 0 then
			self.RollItem.DecadeTextNumber:SetText("0")
			self.RollItem.UintTextNumber:SetText("0")
		else
			local DecadeNumber = math.floor(ViewModel.RollResult / 10)
			local UintNumber = ViewModel.RollResult % 10
			self.RollItem.DecadeTextNumber:SetText(tostring(DecadeNumber))
			self.RollItem.UintTextNumber:SetText(tostring(UintNumber))
		end
	end
end

function MainTeamItemView:StopRollTimers()
	if self.DecadeTimerID ~= nil then
		self:UnRegisterTimer(self.DecadeTimerID)
		self.DecadeTimerID = nil
	end

	if self.UintTimerID ~= nil then
		self:UnRegisterTimer(self.UintTimerID)
		self.UintTimerID = nil
	end
end

--- skils BEGIN
function MainTeamItemView:OnShowPanelValueChange(NewValue)
	if NewValue then
		self:PlayAnimation(self.AnimPanelReviveIn)
	end
end

function MainTeamItemView:Rescure()
	if self.ViewModel == nil or self:GetRoleID() == MajorUtil.GetMajorRoleID() or self.Params == nil then
		return
	end

	local Cfg = _G.TeamMgr.GetRescureSkillCfg(MajorUtil.GetMajorProfID())
	if Cfg == nil then
		return
	end
	local InRescureCD = false
	local SkillUtil = require("Utils/SkillUtil")
	local RoleID <const> = self:GetRoleID() or 0
	local EntityID <const> = ActorUtil.GetEntityIDByRoleID(RoleID)

	local TeamHelper = require("Game/Team/TeamHelper")
	if not (TeamHelper.GetTeamMgr():IsTeamMemberByRoleID(RoleID) and ActorUtil.IsDeadState(EntityID)) then
		return
	end

	if self.ViewModel.CDPercentRescureSkillRemain and self.ViewModel.CDPercentRescureSkillRemain > 0 then
		InRescureCD = true
	end

	if InRescureCD then
		self:PlayAnimation(self.AnimReviveDisable)
		return
	end

	if  not InRescureCD then
		self.Params.Adapter:SetSelectedIndex(self.Params.Index)
		SkillUtil.CastSkill(EntityID, self:GetRoleID() or 0, Cfg.SkillID)
	end
end

function MainTeamItemView:OnSkillCDUpdate(Params)
	local Cfg = _G.TeamMgr.GetRescureSkillCfg(MajorUtil.GetMajorProfID())
	if Cfg == nil then
		return
	end

	local SkillID = Params.SkillID
	if SkillID ~= Cfg.SkillID then
		return
	end

	local CurrentCD = Params.SkillCD
	local BaseCD = Params.BaseCD

	if self.ViewModel then
		self.ViewModel:SetRescureSkillRemainCD(math.ceil(CurrentCD))
	end

	if type(CurrentCD) == 'number' and type(BaseCD) == 'number' then
		local CDPercent = BaseCD > 0 and (CurrentCD / BaseCD) or 0
		self.ViewModel:SetRescureSkillRemainCDPercent(CDPercent)
	end

	if CurrentCD == 0 then
		self:PlayAnimation(self.AnimReviveCDFinish)
	end
end

function MainTeamItemView:OnMajorSkillCastFailed(Index)
	if Index == self:GetRoleID() and Index ~= nil and Index ~= 0 then
		self:PlayAnimation(self.AnimReviveDisable)
	end
end

local function GetCDGroupInfo(SkillID, GroupID, SkillCD, BaseCD)
	local SkillMainCfg = require("TableCfg/SkillMainCfg")
	local Cfg = SkillMainCfg:FindCfgByKey(SkillID)
	if Cfg and Cfg.CDGroup == GroupID and GroupID then

		local SkillCDInfo = _G.SkillCDMgr:GetSkillCD(SkillID) or {}
		--当前技能普通CD大于组CD，直接pass
		local CurSkillCD = SkillCDInfo.SkillCD or -0.001
		if CurSkillCD >= SkillCD then
			return nil
		end

		local QuickAttrInvalid = Cfg.QuickAttrInvalid
		if QuickAttrInvalid == 0 then
			local ShortenCDRate = 0
			local AttributeComp = ActorUtil.GetActorAttributeComponent(MajorUtil.GetMajorEntityID())
			if AttributeComp ~= nil then
				local ProtoCommon = require("Protocol/ProtoCommon")
				ShortenCDRate = AttributeComp:GetAttrValue(ProtoCommon.attr_type.attr_shorten_cd_time) / 10000
			end
			BaseCD = BaseCD * (1 - ShortenCDRate)
		end

		return { SkillID = SkillID, BaseCD = BaseCD, SkillCD = SkillCD }
	end
end

function MainTeamItemView:OnSkillCDGroupUpdate(Params)
	local Cfg = _G.TeamMgr.GetRescureSkillCfg(MajorUtil.GetMajorProfID())
	if Cfg == nil then
		return
	end

	local GroupID = Params.GroupID
	local SkillCD = Params.SkillCD
	local BaseCD = Params.BaseCD

	local CDInfo =  GetCDGroupInfo(Cfg.SkillID, GroupID, SkillCD, BaseCD)
	if CDInfo then
		self:OnSkillCDUpdate(CDInfo)
	end
end

function MainTeamItemView:OnMajorMPChange(Params)
	if self:GetRoleID() == MajorUtil.GetMajorRoleID() or Params == nil then
		return
	end

	if Params.ULongParam1 and Params.ULongParam1 ~= MajorUtil.GetMajorEntityID() then
		return
	end

	local Cfg = _G.TeamMgr.GetRescureSkillCfg(MajorUtil.GetMajorProfID())
	if Cfg == nil then
		return
	end

	local LogicData = _G.SkillLogicMgr:GetMajorSkillLogicData()
	if LogicData == nil then
		return
	end

	local SkillCommonDefine = require("Game/Skill/SkillCommonDefine")
	local ProtoCommon = require("Protocol/ProtoCommon")
	local bValid, RequireCost = LogicData:PlayerAttrCheck(SkillCommonDefine.SkillButtonIndexRange.TeamRescure, Cfg.SkillID, ProtoCommon.attr_type.attr_mp)

	local bPassMp = true
	if bValid then
		bPassMp = (MajorUtil.GetMajorCurMp() or 0) >= RequireCost
	end

	local bChanged = self.bRescurePassMp ~= bPassMp
	self.bRescurePassMp = bPassMp
	if bChanged then
		self.IconRevive:SetRenderOpacity(bPassMp and 1 or 0)
	end
end

---skills end

function MainTeamItemView:OnTakeAttackEffect(Param)
	if Param == nil then
		return	
	end

	if self.ViewModel == nil then
		return
	end

	local BehitObjID <const> = Param.BehitObjID
	local AttackObjID <const> = Param.AttackObjID
	local EffectType <const> = Param.EffectType
	local SkillID <const> = Param.MainSkillID or 0

	if not MajorUtil.IsMajor(AttackObjID) or BehitObjID ~= self.ViewModel.EntityID or BehitObjID == nil or BehitObjID == 0 or SkillID <= 0 then
		return
	end

	if EffectType == ProtoCS.CS_ATTACK_EFFECT.CS_ATTACK_EFFECT_HP_HEAL and IsMajorHealProf() then
		self:PlayAnimation(self.AnimProBarResumeFast)
	end
end

function MainTeamItemView:OnMajorProfChanged()
	if IsMajorHealProf() then
		self:RegisterGameEvent(EventID.AttackEffectChange, self.OnTakeAttackEffect)
		self:RegisterGameEvent(EventID.Attr_Change_MP, self.OnMajorMPChange)
	else
		self:UnRegisterGameEvent(EventID.AttackEffectChange, self.OnTakeAttackEffect)
		self:UnRegisterGameEvent(EventID.Attr_Change_MP, self.OnMajorMPChange)
	end

	self.bRescurePassMp = nil
	self:OnMajorMPChange({ULongParam1=MajorUtil.GetMajorEntityID()})
end

return MainTeamItemView