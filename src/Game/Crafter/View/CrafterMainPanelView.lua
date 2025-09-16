---
--- Author: chriswang
--- DateTime: 2023-08-31 16:49
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CommonUtil = require("Utils/CommonUtil")
local UIViewMgr = _G.UIViewMgr
local LoginMgr = require("Game/Login/LoginMgr")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local UIViewID = _G.UIViewID
local CrafterSidebarPanelVM = require("Game/Crafter/CrafterSidebarPanelVM")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local LSTR = _G.LSTR
local MainPanelVM = require("Game/Main/MainPanelVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetProfIcon = require("Binder/UIBinderSetProfIcon")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local MajorUtil = require("Utils/MajorUtil")
local HPBarLikeAnimProxyFactory = require("Game/Main/HPBarLikeAnimProxyFactory")
local UIAdapterTableViewEx = require("Game/Buff/UIAdapterTableViewEx")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local TipsUtil = require("Utils/TipsUtil")

local FLOG_ERROR = _G.FLOG_ERROR

---@class CrafterMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBuff UFButton
---@field BtnBuffMore UFButton
---@field BtnClose CommonCloseBtnView
---@field BuffMore UFCanvasPanel
---@field BuffPanel UCanvasPanel
---@field ButtonGM UFButton
---@field DX_Black_In UImage
---@field EFF_ProBarMP_Blue UFImage
---@field EFF_ProBarMP_Yellow UFImage
---@field FTextBlock_67 UFTextBlock
---@field MainLBottomPanel MainLBottomPanelView
---@field MajorBuffInfoTips MainBuffInfoTipsNewView
---@field PlayerJobSlot CommPlayerJobSlotView
---@field ProBarMP UProgressBar
---@field SidebarPanelNew CrafterSidebarPanelNewView
---@field SkillPanel CrafterSkillPanelView
---@field TableViewBuff UTableView
---@field TableViewBuffBig UTableView
---@field TextBuffMore UFTextBlock
---@field TextMP UFTextBlock
---@field TextMP2 UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimIn_1 UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimOut_1 UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CrafterMainPanelView = LuaClass(UIView, true)

function CrafterMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBuff = nil
	--self.BtnBuffMore = nil
	--self.BtnClose = nil
	--self.BuffMore = nil
	--self.BuffPanel = nil
	--self.ButtonGM = nil
	--self.DX_Black_In = nil
	--self.EFF_ProBarMP_Blue = nil
	--self.EFF_ProBarMP_Yellow = nil
	--self.FTextBlock_67 = nil
	--self.MainLBottomPanel = nil
	--self.MajorBuffInfoTips = nil
	--self.PlayerJobSlot = nil
	--self.ProBarMP = nil
	--self.SidebarPanelNew = nil
	--self.SkillPanel = nil
	--self.TableViewBuff = nil
	--self.TableViewBuffBig = nil
	--self.TextBuffMore = nil
	--self.TextMP = nil
	--self.TextMP2 = nil
	--self.AnimIn = nil
	--self.AnimIn_1 = nil
	--self.AnimOut = nil
	--self.AnimOut_1 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CrafterMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.MainLBottomPanel)
	self:AddSubView(self.MajorBuffInfoTips)
	self:AddSubView(self.PlayerJobSlot)
	self:AddSubView(self.SidebarPanelNew)
	self:AddSubView(self.SkillPanel)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CrafterMainPanelView:OnInit()
	self.TextBuffMore:SetText("...")
	
	self.RoleBinders = {
		{ "PWorldLevel", UIBinderSetText.New(self, self.PlayerJobSlot.Text_PlayerLevel) },
		{ "Prof", UIBinderSetProfIcon.New(self, self.PlayerJobSlot.Icon_Prof) },
	}

	self.AdapterBuff = UIAdapterTableViewEx.CreateAdapter(self, self.TableViewBuff, self.OnBuffSelect, true)
	self.AdapterBuff:UpdateSettings(5, function(_, IsLimited) UIUtil.SetIsVisible(self.BuffMore, IsLimited) end, false, true)
	self.AdapterBuffBig = UIAdapterTableViewEx.CreateAdapter(self, self.TableViewBuffBig, self.OnBuffBigSelect, true)
	self.AdapterBuffBig:UpdateSettings(999, function(IsEmpty, _) if IsEmpty then self:HideBuffDetails() end end, true, true)

	self.ActorBinders = {
		{ "BufferVMList", UIBinderUpdateBindableList.New(self, self.AdapterBuff) },
		{ "BufferVMList", UIBinderUpdateBindableList.New(self, self.AdapterBuffBig) },
		{ "CurMK", UIBinderValueChangedCallback.New(self, nil, self.UpdateMajorMK) },
		{ "MaxMK", UIBinderValueChangedCallback.New(self, nil, self.UpdateMajorMK) },
	}

	self.MpBarAnimProxy = HPBarLikeAnimProxyFactory.CreateMatProxy(
		self, self.ProBarMP,
		self.AnimMPBlue, self.AnimMPYellow,  -- 这俩动画待接入
		self.EFF_ProBarMP_Blue, self.EFF_ProBarMP_Yellow
	)

	self.TextMP2:SetText(ProtoEnumAlias.GetAlias(ProtoCommon.attr_type, ProtoCommon.attr_type.attr_mk_max))
end

function CrafterMainPanelView:OnDestroy()

end

function CrafterMainPanelView:OnShow()
	-- 防止网络不好用户一直点关闭, 限制一下
	self.bCanCloseBtnClick = true
	UIUtil.SetIsVisible(self.ButtonGM, false)

	self.BtnClose:SetCallback(self, self.OnBtnCloseClick)
	-- self.MainLBottomPanel:SetButtonEmotionVisible(false)
	UIUtil.SetIsVisible(self.SidebarPanelNew.MajorInfo.PlayerExp, false)
	
	CrafterSidebarPanelVM:UpdateStartMakeRsp(self.Params)

	CommonUtil.DisableShowJoyStick(true)
	CommonUtil.HideJoyStick()
	
    self.TopRightUIVisible = MainPanelVM:GetPanelTopRightVisible()
    if self.TopRightUIVisible then
        MainPanelVM:SetPanelTopRightVisible(false)
    end

	self:HideBuffDetails()
end

function CrafterMainPanelView:OnHide()
	CommonUtil.DisableShowJoyStick(false)
	CommonUtil.ShowJoyStick()

    if self.TopRightUIVisible then
        MainPanelVM:SetPanelTopRightVisible(true)
    end

	self:HideBuffDetails()
end

function CrafterMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnBuffMore, function() self.AdapterBuff:SelectLastItem() end)
end

function CrafterMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)
	UIUtil.AddOnClickedEvent(self, self.BtnBuff, self.OnShowCrafterTips)
end

function CrafterMainPanelView:OnRegisterBinder()
	--子蓝图的绑定
	self.PlayerJobSlot:SetParams(nil)
	self.SidebarPanelNew:SetParams({ Data = CrafterSidebarPanelVM })

	local MajorRoleVM = _G.RoleInfoMgr:FindRoleVM(MajorUtil.GetMajorRoleID())
	self:RegisterBinders(MajorRoleVM, self.RoleBinders)

	local MajorActorVM = _G.ActorMgr:FindActorVM(MajorUtil.GetMajorEntityID())
	if MajorActorVM then
		self.MajorActorVM = MajorActorVM
		self:RegisterBinders(MajorActorVM, self.ActorBinders)
	else
		FLOG_ERROR("[CrafterMainPanelView:OnRegisterBinder] MajorActorVM is nil")
	end
end

function CrafterMainPanelView:OnBtnCloseClick()
	if not self.bCanCloseBtnClick then
		return
	end
	self.bCanCloseBtnClick = false
	
	local function CallBack()
		_G.CrafterMgr:QuitMake()
	end

	local function CancelCallBack()
		self.bCanCloseBtnClick = true
	end

	local CrafterMgr = _G.CrafterMgr
	if CrafterMgr:IsInTrain() then
		-- 练习制作不需要弹确认
		CrafterMgr:QuitMake()
	else
		-- 是否中止作业？ 确认 取消
		MsgBoxUtil.MessageBox(LSTR(150070), LSTR(10002), LSTR(10003), CallBack, CancelCallBack)
	end

end

function CrafterMainPanelView:OnBuffSelect(Idx, ItemVM)
	self:ShowBuffDetails(ItemVM)
end

function CrafterMainPanelView:OnBuffBigSelect(Idx, ItemVM)
	self.MajorBuffInfoTips:ChangeVMAndUpdate(ItemVM)
end

function CrafterMainPanelView:OnPreprocessedMouseButtonDown(MouseEvent)
	if not self.AdapterBuffBig:GetSelectedIndex() then return end

	local MousePosition = UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
	if not UIUtil.IsUnderLocation(self.MajorBuffInfoTips, MousePosition) and
    not UIUtil.IsUnderLocation(self.TableViewBuffBig, MousePosition) then
		self:HideBuffDetails()
    end
end

function CrafterMainPanelView:ShowBuffDetails(ItemVM)
	if not ItemVM then return end

	UIUtil.SetIsVisible(self.BuffPanel, false)
	UIUtil.SetIsVisible(self.TableViewBuffBig, true)
	UIUtil.SetIsVisible(self.MajorBuffInfoTips, true)
	self.AdapterBuffBig:SetSelectedItem(ItemVM)
	local DisplayIndex = self.AdapterBuffBig:GetItemDataDisplayIndex(ItemVM) 
	self.AdapterBuffBig:ScrollIndexIntoView(DisplayIndex)
end

function CrafterMainPanelView:HideBuffDetails()
	UIUtil.SetIsVisible(self.BuffPanel, true)
	UIUtil.SetIsVisible(self.TableViewBuffBig, false)
	UIUtil.SetIsVisible(self.MajorBuffInfoTips, false)
	self.AdapterBuff:CancelSelected()
	self.AdapterBuffBig:CancelSelected()
	self.MajorBuffInfoTips:ChangeVMAndUpdate(nil)
end

function CrafterMainPanelView:OnShowCrafterTips()
	local OffsetY = UIUtil.GetLocalSize(self.BtnBuff).Y
	TipsUtil.ShowSimpleTipsView({Title = _G.LSTR(150080), Content = _G.LSTR(150084)},
	self.BtnBuff, _G.UE.FVector2D(0, OffsetY), _G.UE.FVector2D(1, 0), true)
end

-- 复用MainMajorInfoPanel的逻辑

local MainMajorInfoPanelView = require("Game/Main/MainMajorInfoPanelView")
CrafterMainPanelView.UpdateMajorMK = MainMajorInfoPanelView.UpdateMajorMK
CrafterMainPanelView.UpdateMPBar = MainMajorInfoPanelView.UpdateMPBar
CrafterMainPanelView.SetMPBarConfig = MainMajorInfoPanelView.SetMPBarConfig

return CrafterMainPanelView