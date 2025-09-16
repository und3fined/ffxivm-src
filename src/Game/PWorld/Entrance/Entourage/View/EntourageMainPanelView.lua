---
--- Author: Administrator
--- DateTime: 2023-12-17 13:12
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local ProfUtil = require("Game/Profession/ProfUtil")
local PWorldEntourageUIUtil = require("Game/PWorld/Entrance/Entourage/PWorldEntourageUIUtil")
local ProtoRes = require("Protocol/ProtoRes")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView =  require("UI/Adapter/UIAdapterTableView")
local UIBinderSetSelectedIndex = require("Binder/UIBinderSetSelectedIndex")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local RoleInitCfg = require("TableCfg/RoleInitCfg")

local PWorldEntourageVM

---@class EntourageMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBack CommBackBtnView
---@field BtnChangeJob UFButton
---@field BtnCommMask UFButton
---@field BtnEquipmentUP UFButton
---@field BtnItem01 PWorldDetailsBtnItemView
---@field BtnItem02 PWorldDetailsBtnItemView
---@field BtnJoin CommBtnLView
---@field BtnLeveUP UFButton
---@field CommonPlayerPortraitItem CommonPlayerPortraitItemView
---@field CommonTitle CommonTitleView
---@field ImgBG UFImage
---@field ImgColor UFImage
---@field ImgLock UFImage
---@field ImgLock_1 UFImage
---@field ImgLock_3 UFImage
---@field ImgPlayerJob UFImage
---@field PanelEquipmentClass UFCanvasPanel
---@field PanelJoin UFCanvasPanel
---@field PanelLevelRequire UFCanvasPanel
---@field PanelTips UFCanvasPanel
---@field RichTextEquipmentClass URichTextBox
---@field RichTextLevelRequire URichTextBox
---@field SummaryTips PWorldSummaryTipsView
---@field TableViewNPCMember UTableView
---@field TableViewPWorlds UTableView
---@field TableViewRewards UTableView
---@field TextEquipScore UFTextBlock
---@field TextEquipmentClass UFTextBlock
---@field TextForbid UFTextBlock
---@field TextLevelRequire UFTextBlock
---@field TextPWorldName UFTextBlock
---@field TextPlayerInfo UFTextBlock
---@field TextPlayerName UFTextBlock
---@field AnimChangePWorld UWidgetAnimation
---@field AnimEffcetBtnLeveUP1 UWidgetAnimation
---@field AnimEffcetBtnLeveUP2 UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimTipsIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EntourageMainPanelView = LuaClass(UIView, true)

function EntourageMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBack = nil
	--self.BtnChangeJob = nil
	--self.BtnCommMask = nil
	--self.BtnEquipmentUP = nil
	--self.BtnItem01 = nil
	--self.BtnItem02 = nil
	--self.BtnJoin = nil
	--self.BtnLeveUP = nil
	--self.CommonPlayerPortraitItem = nil
	--self.CommonTitle = nil
	--self.ImgBG = nil
	--self.ImgColor = nil
	--self.ImgLock = nil
	--self.ImgLock_1 = nil
	--self.ImgLock_3 = nil
	--self.ImgPlayerJob = nil
	--self.PanelEquipmentClass = nil
	--self.PanelJoin = nil
	--self.PanelLevelRequire = nil
	--self.PanelTips = nil
	--self.RichTextEquipmentClass = nil
	--self.RichTextLevelRequire = nil
	--self.SummaryTips = nil
	--self.TableViewNPCMember = nil
	--self.TableViewPWorlds = nil
	--self.TableViewRewards = nil
	--self.TextEquipScore = nil
	--self.TextEquipmentClass = nil
	--self.TextForbid = nil
	--self.TextLevelRequire = nil
	--self.TextPWorldName = nil
	--self.TextPlayerInfo = nil
	--self.TextPlayerName = nil
	--self.AnimChangePWorld = nil
	--self.AnimEffcetBtnLeveUP1 = nil
	--self.AnimEffcetBtnLeveUP2 = nil
	--self.AnimIn = nil
	--self.AnimTipsIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EntourageMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBack)
	self:AddSubView(self.BtnItem01)
	self:AddSubView(self.BtnItem02)
	self:AddSubView(self.BtnJoin)
	self:AddSubView(self.CommonPlayerPortraitItem)
	self:AddSubView(self.CommonTitle)
	self:AddSubView(self.SummaryTips)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EntourageMainPanelView:OnInit()
	PWorldEntourageVM = require("Game/PWorld/Entrance/Entourage/PWorldEntourageVM")

	self.AdpTableViewPWorld = UIAdapterTableView.CreateAdapter(self, self.TableViewPWorlds, self.OnSeltChgEnt, true)
	self.AdpTableViewReward = UIAdapterTableView.CreateAdapter(self, self.TableViewRewards, self.OnSeltChgReward, true, nil, true)
	self.AdpTableViewMem 	= UIAdapterTableView.CreateAdapter(self, self.TableViewNPCMember, nil, true, nil, true)

	self.Binders =
	{
		{ "EntList",    				UIBinderUpdateBindableList.New(self, self.AdpTableViewPWorld) },
		{ "RewardList",    				UIBinderUpdateBindableList.New(self, self.AdpTableViewReward) },
		{ "MemList",    				UIBinderUpdateBindableList.New(self, self.AdpTableViewMem) },
        { "CurEntIdx", 					UIBinderSetSelectedIndex.New(self, self.AdpTableViewPWorld)},
		----------------------------------------------------------------------------------
		{ "PWorldName", 				UIBinderSetText.New(self, self.TextPWorldName) },
		{ "PWorldIcon", 				UIBinderSetBrushFromAssetPath.New(self, self.ImgPWorldType) },
		{ "BG",                    		UIBinderSetBrushFromAssetPath.New(self, self.ImgBG) },
		----------------------------------------------------------------------------------
		-- { "Infor",     					UIBinderSetText.New(self, self.InforTips.ExplainText) },
		{ "Summary",     				UIBinderSetText.New(self, self.SummaryTips.SummaryText) },
		----------------------------------------------------------------------------------

		{ "LvTips",  					UIBinderSetText.New(self, self.RichTextLevelRequire) },
		{ "EquipTips",  				UIBinderSetText.New(self, self.RichTextEquipmentClass) },
		{ "bPassLv", 					UIBinderSetIsVisible.New(self, self.ImgLock, true)},
		{ "bPassLv", 					UIBinderSetIsVisible.New(self, self.BtnLeveUP, true, true)},
		{ "bPassEquip",					UIBinderSetIsVisible.New(self, self.ImgLock_1, true)},
		{ "bPassEquip",					UIBinderSetIsVisible.New(self, self.BtnEquipmentUP, true, true)},
		----------------------------------------------------------------------------------
		{ "IsShowCommMask",        		UIBinderSetIsVisible.New(self, self.BtnCommMask, nil, true) },
		-- { "IsShowInfor",        		UIBinderSetIsVisible.New(self, self.InforTips, nil) },
		{ "IsShowSummary",        		UIBinderSetIsVisible.New(self, self.SummaryTips, nil) },
		----------------------------------------------------------------------------------
		{ "CanJoin",					UIBinderValueChangedCallback.New(self, nil, self.OnCanJoinChanged)},
		{ "ForbidText",     			UIBinderSetText.New(self, self.TextForbid) },
	}

	self.MajorBinders =
	{
		{ "EquipScore",                   		UIBinderSetText.New(self, self.TextEquipScore) },
		{ "Name",                   			UIBinderSetText.New(self, self.TextPlayerName) },
		{ "Level",								UIBinderValueChangedCallback.New(self, nil, self.OnMajorLevelChanged)},
		{ "Prof",								UIBinderValueChangedCallback.New(self, nil, self.OnMajorProfChanged)},
	}

	self.IsDestroyed = false

	self.BtnJoin:SetBtnName(_G.LSTR(1320009))
	self.TextLevelRequire:SetText(LSTR(1320140))
	self.TextEquipmentClass:SetText(LSTR(1320141))
end

function EntourageMainPanelView:OnPostInit()
	UIUtil.SetIsVisible(self.SummaryTips.RichTextContent, false)

	self.BtnItem01:SetIcon("PaperSprite'/Game/UI/Atlas/PWorld/Frames/UI_PWorld_Btn_Details_Introduction_png.UI_PWorld_Btn_Details_Introduction_png'")
	self.BtnItem01:SetText(_G.LSTR(1320238))

	self.BtnItem02:SetIcon("PaperSprite'/Game/UI/Atlas/PWorld/Frames/UI_PWorld_Btn_Details_Summary_png.UI_PWorld_Btn_Details_Summary_png'")
	self.BtnItem02:SetText(_G.LSTR(1320247))
	self.BtnItem02:SetCallback(function()
		self:OnBtnSummary()
	end)

	-- 临时屏蔽攻略
	UIUtil.SetIsVisible(self.BtnItem01, false)
end

function EntourageMainPanelView:OnDestroy()
	self.IsDestroyed = true
end

function EntourageMainPanelView:OnShow()
	local EntID = nil
	if self.Params then
		EntID = self.Params[2]
	end
	_G.PWorldEntourageVM:OnMainPanelShow(EntID)

	self.CommonPlayerPortraitItem:SetParams({Data = MajorUtil.GetMajorRoleVM(true)})
	self.CommonTitle:SetTextTitleName(_G.LSTR(1320155))
end

function EntourageMainPanelView:OnHide()
	_G.EventMgr:SendEvent(_G.EventID.PWorldEntourageViewClosed)
end

function EntourageMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnJoin, 			self.OnBtnJoin)
	UIUtil.AddOnClickedEvent(self, self.BtnBack.Button, 	self.OnBtnClose)
	UIUtil.AddOnClickedEvent(self, self.BtnCommMask, 		self.OnBtnCommMask)
	UIUtil.AddOnClickedEvent(self, self.BtnChangeJob, 		self.OnBtnSwtichProf)
	UIUtil.AddOnClickedEvent(self, self.BtnLeveUP, 			self.OnBtnLeveUP)
	UIUtil.AddOnClickedEvent(self, self.BtnEquipmentUP, 	self.OnBtnEquipmentUP)
end

function EntourageMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.MajorProfSwitch ,            self.OnEveProf)
	self:RegisterGameEvent(EventID.TeamInfoUpdate, function()
		PWorldEntourageVM:UpdateJoinInfo()
	end)
	self:RegisterGameEvent(_G.EventID.PWorldMapEnter, function()
		self:Hide()
	end)
end

function EntourageMainPanelView:OnRegisterBinder()
	self:RegisterBinders(_G.PWorldEntourageVM, self.Binders)

	local MajorVM = MajorUtil.GetMajorRoleVM(false)
	if MajorVM then
		self:RegisterBinders(MajorVM, self.MajorBinders)
	end
end

function EntourageMainPanelView:OnEveProf()
	PWorldEntourageVM:UpdateVM()
end

function EntourageMainPanelView:OnMajorLevelChanged(NewValue)
	self.TextPlayerInfo:SetText(tostring(NewValue))
end

function EntourageMainPanelView:OnMajorProfChanged(NewProf)
	PWorldEntourageVM:UpdateMemList()
	PWorldEntourageVM:UpdateJoinInfo()

	-- 刷新ProfIcon
	local ProfIcon = RoleInitCfg:FindRoleInitProfIcon(NewProf)
	UIUtil.ImageSetBrushFromAssetPath(self.ImgPlayerJob, ProfIcon)

	local ProtoCommon = require("Protocol/ProtoCommon")
	local ProfImgBg = "Texture2D'/Game/UI/Texture/Entourage/UI_Entourage_Img_SelfMask_04.UI_Entourage_Img_SelfMask_04'"
	local ProfFunc = ProfUtil.Prof2Func(NewProf)
	if ProfFunc == ProtoCommon.function_type.FUNCTION_TYPE_GUARD then
		ProfImgBg = "Texture2D'/Game/UI/Texture/Entourage/UI_Entourage_Img_SelfMask_01.UI_Entourage_Img_SelfMask_01'"
	elseif ProfFunc ==  ProtoCommon.function_type.FUNCTION_TYPE_RECOVER then
		ProfImgBg = "Texture2D'/Game/UI/Texture/Entourage/UI_Entourage_Img_SelfMask_03.UI_Entourage_Img_SelfMask_03'"
	elseif ProfFunc ==  ProtoCommon.function_type.FUNCTION_TYPE_ATTACK then
		ProfImgBg = "Texture2D'/Game/UI/Texture/Entourage/UI_Entourage_Img_SelfMask_02.UI_Entourage_Img_SelfMask_02'"
	end
	
	UIUtil.ImageSetBrushFromAssetPath(self.ImgColor, ProfImgBg)
end

function EntourageMainPanelView:OnCanJoinChanged(NewValue, OldValue)
	UIUtil.SetIsVisible(self.TextForbid, not NewValue)
	if self.BtnJoin then
		self.BtnJoin:SetIsEnabled(NewValue, true)
	end
end

-------------------------------------------------------------------------------------------------------
---@see UIEveHandle

function EntourageMainPanelView:OnSeltChgEnt(Idx, ItemData)
	if Idx ~= PWorldEntourageVM.CurEntIdx then
		self:PlayAnimation(self.AnimChangePWorld)
	end
	PWorldEntourageVM:SetEntIdx(Idx, ItemData)
end

function EntourageMainPanelView:OnSeltChgReward(_, ItemVM, ItemView)
	local ItemTipsUtil = require("Utils/ItemTipsUtil")
	ItemTipsUtil.ShowTipsByResID(ItemVM.ID, ItemView)
end

function EntourageMainPanelView:OnBtnInfor()
	self:PlayAnimation(self.AnimTipsIn)
	PWorldEntourageVM:SetIsShowInfor(true)
end

function EntourageMainPanelView:OnBtnSummary()
	self:PlayAnimation(self.AnimTipsIn)
	PWorldEntourageVM:SetIsShowSummary(true)
end

local NavToConfirm = function ()
	_G.UIViewMgr:ShowView(_G.UIViewID.EntourageConfirm)
end

function EntourageMainPanelView:OnBtnJoin()
	if _G.PWorldMgr:CurrIsInDungeon() then
		_G.MsgTipsUtil.ShowTipsByID(101091)
		return
	end	

	if PWorldEntourageVM.CanJoin then
		if _G.PWorldMatchMgr:IsMatching() then
			_G.MsgTipsUtil.ShowTipsByID(307008)
			return
		end

		if _G.PWorldVoteMgr:IsVoteEnterScenePending() then
			_G.MsgTipsUtil.ShowTipsByID(307009)
			return
		end

		if _G.TeamRecruitMgr:IsRecruiting() then
			_G.MsgBoxUtil.ShowMsgBoxTwoOp(self ,_G.LSTR(1320037), _G.LSTR(1320086), NavToConfirm)
		else
			NavToConfirm()
		end
	else
		_G.MsgTipsUtil.ShowTips(PWorldEntourageVM.JoinTips)
		local Params = {}
		if PWorldEntourageVM.RltInfo ~= nil and false == PWorldEntourageVM.RltInfo.IsPassMem then
			--生产职业提升途径暂不使用 5.2版本才考虑
			print("[EntourageMainPanelView] 目前这里进不来")
		elseif false == PWorldEntourageVM.bPassLv then
			--若战职等级不够 则打开职业等级提升途径界面
			Params.TypeNum = ProtoRes.promote_type.PROMOTE_TYPE_COMBAT
			_G.EventMgr:SendEvent(_G.EventID.ShowPromoteMainPanel, Params)
		elseif false == PWorldEntourageVM.bPassEquip then
			--若装备品级不够 则打开装备品级提升途径界面
			Params.TypeNum = ProtoRes.promote_type.PROMOTE_TYPE_EQUIP
			_G.EventMgr:SendEvent(_G.EventID.ShowPromoteMainPanel, Params)
		end
	end
end

function EntourageMainPanelView:OnBtnClose()
	self:Hide()
end

function EntourageMainPanelView:OnBtnCommMask()
	PWorldEntourageVM:SetIsShowCommMask(false)
end

function EntourageMainPanelView:OnBtnSwtichProf()
	_G.UIViewMgr:ShowView(_G.UIViewID.ProfessionToggleJobTab)
end

function EntourageMainPanelView:OnLvChanged()
	if false == PWorldEntourageVM.bPassLv then
		self:PlayAnimation(self.AnimEffcetBtnLeveUP1)
		UIUtil.SetIsVisible(self.BtnLeveUP, true, true, true)
	else
		UIUtil.SetIsVisible(self.BtnLeveUP, false)
	end
end

function EntourageMainPanelView:OnEquipChanged()
	if false == PWorldEntourageVM.bPassEquip then
		self:PlayAnimation(self.AnimEffcetBtnLeveUP2)
		UIUtil.SetIsVisible(self.BtnEquipmentUP, true, true, true)
	else
		UIUtil.SetIsVisible(self.BtnEquipmentUP, false)
	end
end

function EntourageMainPanelView:OnBtnLeveUP()
	if false == PWorldEntourageVM.RltInfo.IsPassMem then
		--生产职业提升途径暂不使用 5.2版本才考虑
		_G.MsgTipsUtil.ShowTips(PWorldEntourageVM.JoinTips)
		return
	end

	local Params = {}
	Params.TypeNum = ProtoRes.promote_type.PROMOTE_TYPE_COMBAT
	_G.EventMgr:SendEvent(_G.EventID.ShowPromoteMainPanel, Params)
end

function EntourageMainPanelView:OnBtnEquipmentUP()
	local Params = {}
	Params.TypeNum = ProtoRes.promote_type.PROMOTE_TYPE_EQUIP
	_G.EventMgr:SendEvent(_G.EventID.ShowPromoteMainPanel, Params)
end

return EntourageMainPanelView