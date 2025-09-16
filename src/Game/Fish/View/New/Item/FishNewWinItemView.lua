---
--- Author: Administrator
--- DateTime: 2024-01-24 17:20
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoCommon = require("Protocol/ProtoCommon")

local FishVM = require("Game/Fish/FishVM")
local FishBaitPanelVM = require("Game/Fish/ItemVM/FishBaitPanelVM")
local FishMgr = require("Game/Fish/FishMgr")
local FishBaitCfg = require("TableCfg/FishBaitCfg")

local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

local UKismetInputLibrary = UE.UKismetInputLibrary
local MsgTipsUtil = _G.MsgTipsUtil

local ProtoRes = require("Protocol/ProtoRes")
local ItemUtil = require("Utils/ItemUtil")
local SystemEntranceMgr = require("Game/Common/Tips/SystemEntranceMgr")
local CommBtnLView = require("Game/Common/Btn/CommBtnLView")
local FishDefine = require("Game/Fish/FishDefine")
local ProfFisher = ProtoCommon.prof_type.PROF_TYPE_FISHER

local DefaultBaitID = 1

---@class FishNewWinItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameLView
---@field Btn UFButton
---@field BtnUse CommBtnLView
---@field BtnUsing UFCanvasPanel
---@field ClickArea UFCanvasPanel
---@field FishingBaitTipsFrame ItemFishingBaitTipsFrameView
---@field MedicineTip NewBagMedicineTipsView
---@field TableViewThing UTableView
---@field TextBtn UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishNewWinItemView = LuaClass(UIView, true)

function FishNewWinItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.Btn = nil
	--self.BtnUse = nil
	--self.BtnUsing = nil
	--self.ClickArea = nil
	--self.FishingBaitTipsFrame = nil
	--self.MedicineTip = nil
	--self.TableViewThing = nil
	--self.TextBtn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishNewWinItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnUse)
	self:AddSubView(self.FishingBaitTipsFrame)
	self:AddSubView(self.MedicineTip)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishNewWinItemView:OnInit()
	self.FishBaitPanelVM = FishBaitPanelVM.New()
	self.TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewThing, self.OnTableViewSelectChanged, false, true)
	self.SelectBaitID = 0
	self.SelectIndex = 0
	self.InUseBaitID = 0
	self.GetWayCache = nil
	self.FishBaitPanelVMBinders = {
		{ "IsUse",UIBinderSetIsVisible.New(self, self.BtnUse, false, true)},
		{ "IsUnUse",UIBinderSetIsVisible.New(self, self.BtnUsing, false, true)},
	}
	self.FishVMBinders = {
		{ "FishBaitItemList", UIBinderUpdateBindableList.New(self, self.TableViewAdapter) },
	}
	self:OnSetText()
end

function FishNewWinItemView:OnDestroy()

end

local function StrToNum(Numstr)
	local num = 0
	if Numstr and Numstr ~= "" then
		-- 如果数量超过999， 获取到的Num就是“1,000”的形式，无法直接用tonumber转化，需要去除逗号
		local str = string.gsub(Numstr,',','')
		num = tonumber(str)
	end
	return num
end

function FishNewWinItemView:OnShow()
	local Parmas = self.Params
	if Parmas then
		local BaitID = Parmas.BaitID
		local Num = Parmas.Num
		if BaitID ~= 0 then
			self.FishBaitPanelVM:SetUseBaitID(BaitID)
			local Numres = StrToNum(Num)
			self.FishBaitPanelVM:UpdateBaitInfo(BaitID,Numres)
			local Item ,BaitIndex = FishVM:GetFishBaitItemByResID(BaitID)
			self.FishingBaitTipsFrame:UpdateUI(Item)
			FishVM:SetItemUseState(BaitID,true)
			self.TableViewAdapter:SetSelectedIndex(BaitIndex)
			self.SelectIndex = BaitIndex
			self.SelectBaitID = BaitID
			self.InUseBaitID = BaitID
		else
			self.FishBaitPanelVM:UpdateBaitInfo(BaitID,0)
			local Item ,BaitIndex = FishVM:GetFishBaitItemByResID(DefaultBaitID)
			self.FishingBaitTipsFrame:UpdateUI(Item)
			self.TableViewAdapter:SetSelectedIndex(BaitIndex)
			self.SelectIndex = BaitIndex
			self.SelectBaitID = DefaultBaitID
			self:OnUpdateBtnText(false)
		end
	end
end

function FishNewWinItemView:OnHide()
	-- 关闭界面的时候清理鱼饵Item的使用状态和选中状态，防止出现选中状态错误的问腿
	if self.InUseBaitID ~= 0 then
		FishVM:SetItemUseState(self.InUseBaitID,false)
	end
	self.TableViewAdapter:ClearSelectedItem()
	self.SelectBaitID = 0
	self.SelectIndex = 0
	self.InUseBaitID = 0
end

function FishNewWinItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self,self.BtnUse,self.OnBtnUseClick)
end

function FishNewWinItemView:OnRegisterGameEvent()
	local EventID = _G.EventID
	self:RegisterGameEvent(EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)
	self:RegisterGameEvent(EventID.MajorLevelUpdate, self.OnMajorLevelUpdate)
end

function FishNewWinItemView:OnRegisterBinder()
	self:RegisterBinders(self.FishBaitPanelVM,self.FishBaitPanelVMBinders)
	self:RegisterBinders(FishVM, self.FishVMBinders)
end

function FishNewWinItemView:OnSetText()
	local FishNewWinItemText = FishDefine.FishNewWinItemText
	self.BG.FText_Title:SetText(FishNewWinItemText.Title)
	self.BtnUse.TextContent:SetText(FishNewWinItemText.TextUse)
	self.TextBtn:SetText(FishNewWinItemText.TextUsing)
	self.FishingBaitTipsFrame.TextToGet:SetText(FishNewWinItemText.TextToGet)
	self.FishingBaitTipsFrame.TextOwn:SetText(FishNewWinItemText.TextOwn)
end

function FishNewWinItemView:OnUpdateBtnText(bUse)
	local FishNewWinItemText = FishDefine.FishNewWinItemText
	if bUse then
		self.BtnUse.TextContent:SetText(FishNewWinItemText.TextUse)
	else
		self.BtnUse.TextContent:SetText(FishNewWinItemText.TextBuy)
	end
end

function FishNewWinItemView:OnTableViewSelectChanged(Index, ItemData,_)
	local BaitID = FishVM:GetSelectedBait(Index)
	-- 如果数量超过999， 获取到的Num就是“1,000”的形式，无法直接用tonumber转化，需要去除逗号
	local Numres = StrToNum(ItemData.Num)
	self.FishBaitPanelVM:UpdateBaitInfo(BaitID,Numres)
	self:CheckBtnState(BaitID)
	self:OnUpdateBtnText(Numres > 0)
	self.SelectBaitID = BaitID
	self.FishingBaitTipsFrame:UpdateUI(ItemData)
	if self.SelectIndex ~= 0 and self.SelectIndex ~= Index then
		FishVM:SetItemSelected(self.SelectIndex,false)
	end
	FishVM:SetItemSelected(Index,true)
	self.SelectIndex = Index
end

-- 按钮点击改为动态逻辑，根据当前选中的鱼饵ID触发相应的逻辑
function FishNewWinItemView:OnBtnUseClick()
	local SelectID = self.FishBaitPanelVM.SelectedBaitID
	if self.FishBaitPanelVM.SelectedBaitNum > 0 then
		self:OnBtnUse(SelectID)
	else
		self:OnBtnBuy(SelectID)
	end
end

-- 使用鱼饵逻辑
function FishNewWinItemView:OnBtnUse(SelectID)
	local IsLimit = self.FishBaitPanelVM:IsLimitLevel(SelectID)
	local IsFishing = FishMgr:CanSetFishBait()
	if IsFishing then
		MsgTipsUtil.ShowTipsByID(FishDefine.FishErrorCode[FishDefine.ClientFishReason.DisableSetBait])
		return
	end
	if IsLimit then
		MsgTipsUtil.ShowTips(FishDefine.FishNewWinItemText.LevelText)
	else
		-- 鱼饵的选中状态现在只在鱼饵背包界面打开的时候管理，关闭界面就全部清理，否则可能会因鱼饵变动导致选中状态的问题
		FishMgr:SetFishBaitItemSelected(SelectID)
		self.FishBaitPanelVM:SetUseBaitID(SelectID)
		self.InUseBaitID = SelectID
	end
end

-- 购买鱼饵逻辑
function FishNewWinItemView:OnBtnBuy(SelectID)
	local GetWayItem = self.GetWayCache
	local TransferData = {}
	local Cfg = FishBaitCfg:FindCfgByKey(SelectID)
	local ItemID = Cfg.ItemID

	-- 判定商店未解锁则不进行跳转
	if not GetWayItem.IsUnLock then
		if GetWayItem.UnLockTipsID and GetWayItem.UnLockTipsID > 0 then
			MsgTipsUtil.ShowTipsByID(GetWayItem.UnLockTipsID)
		end
		return
	end

	SystemEntranceMgr:ShowShopEntrance(GetWayItem.FunValue, ItemID, TransferData)
	FishMgr:OnRegisterReturnToBaitbag()
end

function FishNewWinItemView:OnPreprocessedMouseButtonDown(MouseEvent)
	local UIViewMgr = _G.UIViewMgr
	local UIViewID = _G.UIViewID
	if UIViewMgr:IsViewVisible(UIViewID.FishBiteBagPanel) then
		local View = UIViewMgr:FindVisibleView(UIViewID.FishBiteBagPanel)
		local MousePosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
		if UIUtil.IsUnderLocation(View.ClickArea, MousePosition) == false then
		    self:Hide(self.ViewID)
	    end
	end
end

-- 检查当前按钮可用性
function FishNewWinItemView:CheckBtnState(BaitID)
	if self.FishBaitPanelVM.SelectedBaitNum == 0 then
		self:CheckBaitCanJump(BaitID)
	else
		self:CheckBaitLimitLevel(BaitID)
	end
end

-- 使用按钮可用性判定：判断鱼饵限制等级
function FishNewWinItemView:CheckBaitLimitLevel(BaitID)
	local IsLimit = self.FishBaitPanelVM:IsLimitLevel(BaitID)
	if IsLimit then
		self.BtnUse:SetIsDisabledState(true, true)
	else
		self.BtnUse:SetIsRecommendState(true)
	end
end

-- 购买按钮可用性判定：判断该鱼饵是否可跳转至商店购买
function FishNewWinItemView:CheckBaitCanJump(BaitID)
	local Cfg = FishBaitCfg:FindCfgByKey(BaitID)
	local ItemID = Cfg.ItemID
	local GetWayList = ItemUtil.GetItemGetWayList(ItemID)
	local GetWayItem = table.find_by_predicate(GetWayList,function(Element)
        return Element.ItemAccessFunType == ProtoRes.ItemAccessFunType.Fun_Store
    end)
	if nil ~= GetWayItem then
		self.BtnUse:SetIsRecommendState(true)
		self.GetWayCache = GetWayItem
	else
		self.BtnUse:SetIsDisabledState(true, true)
	end
end

-- 玩家升级更新页面
function FishNewWinItemView:OnMajorLevelUpdate(Params)
	local ProfID = Params.ProfID
    local OldLevel = Params.OldLevel
	if ProfID and ProfID == ProfFisher and nil ~= OldLevel then
		if self.SelectBaitID ~= 0 then
			self:CheckBtnState(self.SelectBaitID)
		end
	end
end

return FishNewWinItemView