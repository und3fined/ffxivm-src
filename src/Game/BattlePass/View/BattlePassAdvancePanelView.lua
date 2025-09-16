---
--- Author: Administrator
--- DateTime: 2024-12-17 17:05
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local BattlePassAdvanceVM = require("Game/BattlePass/VM/BattlePassAdvanceVM")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local BattlePassMgr = require("Game/BattlePass/BattlePassMgr")
local BattlePassDefine = require("Game/BattlePass/BattlePassDefine")
local BattlepassBigrewardCfg = require("TableCfg/BattlepassBigrewardCfg")
local BattepassSeasonCfg = require("TableCfg/BattepassSeasonCfg")
local RechargeCfg = require("TableCfg/RechargeCfg")
local CommonUtil = require("Utils/CommonUtil")
local ProtoRes = require("Protocol/ProtoRes")
local RechargingMgr = require("Game/Recharging/RechargingMgr")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local DataReportUtil = require("Utils/DataReportUtil")

---@class BattlePassAdvancePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBuy CommBtnMView
---@field BtnBuy02 CommBtnLView
---@field BtnClose CommonCloseBtnView
---@field BtnView UFButton
---@field BtnView_1 UFButton
---@field CommonBkg02 CommonBkg02View
---@field CommonBkgMask CommonBkgMaskView
---@field ImgDeluxeReward UFImage
---@field ImgGrandPrize UFImage
---@field TableViewDeluxeReward UTableView
---@field TableViewReward UTableView
---@field TextAdvancePass UFTextBlock
---@field TextGet UFTextBlock
---@field TextName UFTextBlock
---@field TextName_1 UFTextBlock
---@field TextPrivilege UFTextBlock
---@field TextPrivilege01 UFTextBlock
---@field TextPrivilege01_1 UFTextBlock
---@field TextPrivilege02 UFTextBlock
---@field TextPrivilege02_1 UFTextBlock
---@field TextPrivilege03 UFTextBlock
---@field TextPrivilege03_1 UFTextBlock
---@field Textdeluxe UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BattlePassAdvancePanelView = LuaClass(UIView, true)

function BattlePassAdvancePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBuy = nil
	--self.BtnBuy02 = nil
	--self.BtnClose = nil
	--self.BtnView = nil
	--self.BtnView_1 = nil
	--self.CommonBkg02 = nil
	--self.CommonBkgMask = nil
	--self.ImgDeluxeReward = nil
	--self.ImgGrandPrize = nil
	--self.TableViewDeluxeReward = nil
	--self.TableViewReward = nil
	--self.TextAdvancePass = nil
	--self.TextGet = nil
	--self.TextName = nil
	--self.TextName_1 = nil
	--self.TextPrivilege = nil
	--self.TextPrivilege01 = nil
	--self.TextPrivilege01_1 = nil
	--self.TextPrivilege02 = nil
	--self.TextPrivilege02_1 = nil
	--self.TextPrivilege03 = nil
	--self.TextPrivilege03_1 = nil
	--self.Textdeluxe = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BattlePassAdvancePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBuy)
	self:AddSubView(self.BtnBuy02)
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.CommonBkg02)
	self:AddSubView(self.CommonBkgMask)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BattlePassAdvancePanelView:OnInit()
	self.ViewModel = BattlePassAdvanceVM.New()
	self.TableViewRewardAdapter1 = UIAdapterTableView.CreateAdapter(self, self.TableViewReward, self.OnClickedItem, true)
	self.TableViewRewardAdapter2 = UIAdapterTableView.CreateAdapter(self, self.TableViewDeluxeReward, self.OnClickedItem, true)
	self.Binders = {
		{ "BigRewardList", UIBinderUpdateBindableList.New(self, self.TableViewRewardAdapter1)},
		{ "BigRewardList2", UIBinderUpdateBindableList.New(self, self.TableViewRewardAdapter2)},
		{ "Privilege1", UIBinderSetText.New(self, self.TextPrivilege01)},
		{ "Privilege2", UIBinderSetText.New(self, self.TextPrivilege02)},
		{ "Privilege3", UIBinderSetText.New(self, self.TextPrivilege03)},
		{ "FormerPrice1Text", UIBinderSetText.New(self, self.BtnBuy)},
		{ "FormerPrice2Text", UIBinderSetText.New(self, self.BtnBuy02)},
		{ "GrandPrizeImg", UIBinderSetBrushFromAssetPath.New(self, self.ImgGrandPrize)},
		{ "GrandPrizeName", UIBinderSetText.New(self, self.TextName)},
		{ "DeluxeRewardName", UIBinderSetText.New(self, self.TextName_1)},
		{ "DeluxeRewardImg", UIBinderSetBrushFromAssetPath.New(self, self.ImgDeluxeReward)},
		{ "BattlePassState", UIBinderValueChangedCallback.New(self, nil, self.OnBattlePassStateChanged)},
	}


end

function BattlePassAdvancePanelView:OnDestroy()

end

function BattlePassAdvancePanelView:OnShow()
	self:InitText()
	self.ViewModel:UpdateBaseInfo()

	self:RegisterTimer(function ()
		self:OnBattlePassStateChanged()
	end, 0.03)
	self.ViewModel:UpdateRewardList()
	self.ViewModel:UpdatePrivilegeList()
	self.BtnClose:SetCallback(self, function ()  BattlePassMgr:DoDelayCloseOpenRewardPanel()   end)


	DataReportUtil.ReportBattlePassData(tostring(BattlePassDefine.ScanDest.AdvancePanel))

end

function BattlePassAdvancePanelView:OnHide()

end

function BattlePassAdvancePanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnView, self.OnClickedBtnView)
	UIUtil.AddOnClickedEvent(self, self.BtnView_1, self.OnClickedBtnView1)
	UIUtil.AddOnClickedEvent(self, self.BtnBuy, self.OnClickedBuyBetterGrade)
	UIUtil.AddOnClickedEvent(self, self.BtnBuy02, self.OnClickedBuyBestGrade)
end

function BattlePassAdvancePanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.BattlePassBaseInfoUpdate, self.OnBattlePassBaseInfoUpdate)
end

function BattlePassAdvancePanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function BattlePassAdvancePanelView:InitText()
	self.TextAdvancePass:SetText(_G.LSTR(850022))
	self.Textdeluxe:SetText(_G.LSTR(850029))
	self.TextGet:SetText(_G.LSTR(850039))
	self.TextPrivilege:SetText(_G.LSTR(850031))
end

function BattlePassAdvancePanelView:OnBattlePassBaseInfoUpdate()
	if self.ViewModel == nil then
		return 
	end
	self.ViewModel:UpdateBaseInfo()
end

function BattlePassAdvancePanelView:OnBattlePassStateChanged()
	local Grade = BattlePassMgr:GetBattlePassGrade()
	if Grade > BattlePassDefine.GradeType.Basic then
		self.BtnBuy:SetIsDoneState(true, _G.LSTR(850028))
	else
		self.BtnBuy:SetIsRecommendState(true)
	end

	if Grade == BattlePassDefine.GradeType.Best then
		self.BtnBuy02:SetIsDoneState(true, _G.LSTR(850028))
	else
		self.BtnBuy02:SetIsRecommendState(true)
	end
end

function BattlePassAdvancePanelView:OnClickedBuyBetterGrade()
	local SeasonID = BattlePassMgr:GetSeasonID()
    local Cfg = BattepassSeasonCfg:FindCfgByKey(SeasonID)
	if Cfg == nil then
        return false
    end
	local Grade = BattlePassMgr:GetBattlePassGrade()
	if Grade > BattlePassDefine.GradeType.Basic then
		return
	end

	local Money = tonumber(Cfg.BasicToMiddlePrice)
	local Platform = ProtoRes.DevicePlatform.DEVICE_PLATFORM_ANDROID
	if CommonUtil.GetPlatformName() == "Android" then
		Platform = ProtoRes.DevicePlatform.DEVICE_PLATFORM_ANDROID
	elseif CommonUtil.GetPlatformName() == "IOS" then
		Platform = ProtoRes.DevicePlatform.DEVICE_PLATFORM_IOS
	end
	local Type = ProtoRes.RechargeType.RECHARGE_TYPE_BATTLE_PASS
	local Data = RechargeCfg:FindAllCfg(string.format("Type == %d AND Platform == %d AND Amount == %d ", Type, Platform, Money))
	if not table.empty(Data) then
		BattlePassMgr:Recharge(Data[1].DisplayOrder, Data[1].Fund, Data[1].Bonus, self)
	end		
end

function BattlePassAdvancePanelView:OnClickedBuyBestGrade()
	local SeasonID = BattlePassMgr:GetSeasonID()
    local Cfg = BattepassSeasonCfg:FindCfgByKey(SeasonID)

    if Cfg == nil then
        return false
    end

	local Grade = BattlePassMgr:GetBattlePassGrade()
	if Grade == BattlePassDefine.GradeType.Best then
		return
	end

	local Cost = BattlePassMgr:GetBattlePassGrade() > BattlePassDefine.GradeType.Basic and tonumber(Cfg.MiddleToUltimatePrice) or tonumber(Cfg.BasicToUltimatePrice)

	local Platform = ProtoRes.DevicePlatform.DEVICE_PLATFORM_ANDROID
	if CommonUtil.GetPlatformName() == "Android" then
		Platform = ProtoRes.DevicePlatform.DEVICE_PLATFORM_ANDROID
	elseif CommonUtil.GetPlatformName() == "IOS" then
		Platform = ProtoRes.DevicePlatform.DEVICE_PLATFORM_IOS
	end
	local Type = ProtoRes.RechargeType.RECHARGE_TYPE_BATTLE_PASS
	local Data = RechargeCfg:FindAllCfg(string.format("Type == %d AND Platform == %d AND Amount == %d ", Type, Platform, Cost))
	
	if not table.empty(Data) then
		BattlePassMgr:Recharge(Data[1].DisplayOrder, Data[1].Fund, Data[1].Bonus, self)
	end
end

function BattlePassAdvancePanelView:OnClickedBtnView()
	self:OnClickedBtnView1()
end

function BattlePassAdvancePanelView:OnClickedBtnView1()
	if self.ViewModel == nil or self.ViewModel.GrandPrizeJumpID == nil then
		return
	end

	_G.PreviewMgr:OpenPreviewView(self.ViewModel.GrandPrizeJumpID)
end

function BattlePassAdvancePanelView:OnClickedItem(Index, ItemData, ItemView)
	if ItemView  == nil or ItemData == nil then
		return
	end

	ItemTipsUtil.ShowTipsByResID(ItemData.ResID, ItemView)
end

return BattlePassAdvancePanelView