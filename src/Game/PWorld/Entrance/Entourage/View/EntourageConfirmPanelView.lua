---
--- Author: Administrator
--- DateTime: 2024-01-02 19:34
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local AudioUtil = require("Utils/AudioUtil")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetText = require("Binder/UIBinderSetText")
local SidebarDefine = require("Game/Sidebar/SidebarDefine")
local ProtoCommon = require("Protocol/ProtoCommon")
local SceneMode = ProtoCommon.SceneMode
local PWorldQuestUtil = require("Game/PWorld/Quest/PWorldQuestUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromMaterial = require("Binder/UIBinderSetBrushFromMaterial")


---@class EntourageConfirmPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AfterJobSlot CommPlayerSimpleJobSlotView
---@field BtnKeep CommBtnLView
---@field BtnReady CommBtnLView
---@field BtnRefuse CommBtnLView
---@field BtnTransform CommBtnLView
---@field CurrentJobSlot CommPlayerSimpleJobSlotView
---@field FinderSlot CommSceneModeSlotView
---@field ImgBkg UFImage
---@field ImgFrame UFImage
---@field ImgFrameLight UFImage
---@field ImgPworldIcon UFImage
---@field JobSlot CommPlayerSimpleJobSlotView
---@field PanelMatchFailed UFCanvasPanel
---@field PanelProBar UFCanvasPanel
---@field PanelTitle UHorizontalBox
---@field PanelTransformTips UFCanvasPanel
---@field ProgressBarLoading UProgressBar
---@field TableMem UTableView
---@field TableMem_2 UTableView
---@field TextAfterJob UFTextBlock
---@field TextCurrentJob UFTextBlock
---@field TextJob UFTextBlock
---@field TextMatchFailed UFTextBlock
---@field TextPworldLevel UFTextBlock
---@field TextPworldName UFTextBlock
---@field TextType UFTextBlock
---@field VerticaBoxMember UFVerticalBox
---@field VerticaBoxMember_1 UFVerticalBox
---@field AnimChangeJob UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimProgress UWidgetAnimation
---@field AnimShowAgain UWidgetAnimation
---@field AnimShowFirst UWidgetAnimation
---@field backupAnimIn UWidgetAnimation
---@field SoundEvent_Enter SoftObjectPath
---@field SoundEvent_CountDown SoftObjectPath
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EntourageConfirmPanelView = LuaClass(UIView, true)

function EntourageConfirmPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AfterJobSlot = nil
	--self.BtnKeep = nil
	--self.BtnReady = nil
	--self.BtnRefuse = nil
	--self.BtnTransform = nil
	--self.CurrentJobSlot = nil
	--self.FinderSlot = nil
	--self.ImgBkg = nil
	--self.ImgFrame = nil
	--self.ImgFrameLight = nil
	--self.ImgPworldIcon = nil
	--self.JobSlot = nil
	--self.PanelMatchFailed = nil
	--self.PanelProBar = nil
	--self.PanelTitle = nil
	--self.PanelTransformTips = nil
	--self.ProgressBarLoading = nil
	--self.TableMem = nil
	--self.TableMem_2 = nil
	--self.TextAfterJob = nil
	--self.TextCurrentJob = nil
	--self.TextJob = nil
	--self.TextMatchFailed = nil
	--self.TextPworldLevel = nil
	--self.TextPworldName = nil
	--self.TextType = nil
	--self.VerticaBoxMember = nil
	--self.VerticaBoxMember_1 = nil
	--self.AnimChangeJob = nil
	--self.AnimLoop = nil
	--self.AnimProgress = nil
	--self.AnimShowAgain = nil
	--self.AnimShowFirst = nil
	--self.backupAnimIn = nil
	--self.SoundEvent_Enter = nil
	--self.SoundEvent_CountDown = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EntourageConfirmPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.AfterJobSlot)
	self:AddSubView(self.BtnKeep)
	self:AddSubView(self.BtnReady)
	self:AddSubView(self.BtnRefuse)
	self:AddSubView(self.BtnTransform)
	self:AddSubView(self.CurrentJobSlot)
	self:AddSubView(self.FinderSlot)
	self:AddSubView(self.JobSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EntourageConfirmPanelView:OnInit()
	self.AdaMem4 = UIAdapterTableView.CreateAdapter(self, self.TableMem)
	self.AdaMem8 = UIAdapterTableView.CreateAdapter(self, self.TableMem_2)
	-- self.ReadyTextNow = MemCnt <= 4 and self.TextGetReady or self.TextGetReady_1

	self.Binders = {
		-- Scene
		{ "ConfirmViewBG", 				UIBinderSetBrushFromAssetPath.New(self, self.ImgBkg) },
		{ "PWorldIcon", 				UIBinderSetBrushFromMaterial.New(self, self.ImgPworldIcon) },
		{ "PWorldName", 				UIBinderSetText.New(self, self.TextPworldName) },
		{ "ConfirmViewLevelDesc", 		UIBinderSetText.New(self, self.TextPworldLevel) },
		-- { "ConfirmIsMajorReady", 		UIBinderValueChangedCallback.New(self, nil, self.OnBinderIsMajorReady) },
		-- { "Model", 				UIBinderValueChangedCallback.New(self, nil, self.OnBinderModel) },
		-- MemListVisible
		{ "IsMem4",        				UIBinderSetIsVisible.New(self, self.VerticaBoxMember, false) },
		{ "IsMem4",        				UIBinderSetIsVisible.New(self, self.VerticaBoxMember_1, true) },
	}
	--UIView复用的情况下这里不一定会重复调用, 绑定可能有问题
	self.Member4Binders = {
		-- Member
		{ "ConfirmMemList", 			UIBinderUpdateBindableList.New(self, self.AdaMem4) },
	}
	self.Member8Binders = {
		-- Member
		{ "ConfirmMemList", 			UIBinderUpdateBindableList.New(self, self.AdaMem8) },
	}
	self.BtnRefuse:SetText(_G.LSTR(1320150))
	self.BtnKeep:SetText(_G.LSTR(1320151))
	self.BtnReady:SetText(_G.LSTR(1320152))
	self.TextType:SetText(LSTR(1320071))
end

function EntourageConfirmPanelView:OnShow()
	self.bDestoryed = false

	AudioUtil.LoadAndPlayUISound(self.SoundEvent_Enter:ToString())
	self.SoundID = AudioUtil.SyncLoadAndPlayUISound(self.SoundEvent_CountDown:ToString())

	local Icon = PWorldQuestUtil.GetSceneModeIcon(SceneMode.SceneModeNormal) or ""
	UIUtil.ImageSetBrushFromAssetPath(self.FinderSlot.ImgIcon, Icon)

	self:SetSideBar(false)

	local Duration = _G.PWorldEntourageMgr:GetExpireDuration()
	local RemainTime = _G.PWorldEntourageMgr:StartConfirm(function ()
		self:HideAndClear()
	end)
	self:PlayAnimation(self.AnimProgress, math.clamp( (Duration - RemainTime) / Duration , 0, 1) , 1, _G.UE.EUMGSequencePlayMode.Forward, self.AnimProgress:GetEndTime() / Duration)
end

function EntourageConfirmPanelView:OnHide()
	if nil ~= self.SoundID then
		AudioUtil.StopSound(self.SoundID)
	end

	_G.PWorldMatchMgr:NtfUpdateMatch()
	_G.SidebarMgr:TryOpenSidebarMainWin()
end

function EntourageConfirmPanelView:OnActive()
	AudioUtil.LoadAndPlayUISound(self.SoundEvent_Enter:ToString())
end

function EntourageConfirmPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnRefuse.Button, 		self.OnClickButtonCancel)
	UIUtil.AddOnClickedEvent(self, self.BtnReady.Button, 		self.OnClickButtonOK)
	UIUtil.AddOnClickedEvent(self, self.BtnKeep.Button, 		self.OnClickButtonRetain)
end

function EntourageConfirmPanelView:OnRegisterBinder()
	self:RegisterBinders(_G.PWorldEntourageVM, self.Binders)
	local MemCnt = _G.PWorldEntourageVM.ConfirmMemCnt
	if MemCnt <= 4 then
		self:RegisterBinders(_G.PWorldEntourageVM, self.Member4Binders)
	else
		self:RegisterBinders(_G.PWorldEntourageVM, self.Member8Binders)
	end
end

function EntourageConfirmPanelView:OnClickButtonCancel()
	self:HideAndClear()
end

function EntourageConfirmPanelView:OnClickButtonOK()
	if _G.TeamMgr:IsInTeam() then
		_G.MsgTipsUtil.ShowErrorTips(LSTR(1320084))
		return
	end

	_G.PWorldEntourageMgr:ReqEnterSceneEntourage()
	self:HideAndClear()
end

function EntourageConfirmPanelView:OnClickButtonRetain()
	self:HideAndTryOpenBar()
end

function EntourageConfirmPanelView:HideAndClear()
	_G.PWorldEntourageMgr:EndConfirm()
	self:SetSideBar(false)
	if self.bDestoryed then
		return
	end
	self:Hide()
end

function EntourageConfirmPanelView:HideAndTryOpenBar()
	self:Hide()

	if _G.PWorldEntourageMgr:IsConfirmExpired() then
		self:SetSideBar(false)	
	else
		self:SetSideBar(true)
		_G.PWorldEntourageMgr:StartConfirm(function ()
			self:SetSideBar(false)
		end)
	end
end

local ConfirmSideBarType = SidebarDefine.SidebarType.EntourageEnterConfirm
function EntourageConfirmPanelView:SetSideBar(bShow)
    if bShow then
        if _G.SidebarMgr:GetSidebarItemVM(ConfirmSideBarType) ~= nil then
			_G.SidebarMgr:TryOpenSidebarMainWin()
            return
        end
		
        _G.SidebarMgr:AddSidebarItem(ConfirmSideBarType, _G.PWorldEntourageMgr:GetConfirmStartTime(), _G.PWorldEntourageMgr:GetExpireDuration(), nil, true, _G.LSTR(1320085))
    else
        _G.SidebarMgr:RemoveSidebarItem(ConfirmSideBarType)
    end
end

function EntourageConfirmPanelView:OnDestroy()
	self.bDestoryed = true
end


return EntourageConfirmPanelView