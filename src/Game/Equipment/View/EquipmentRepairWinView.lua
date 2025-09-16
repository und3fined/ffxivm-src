---
--- Author: zimuyi
--- DateTime: 2023-05-25 16:29
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderSetScoreIcon = require("Binder/UIBinderSetScoreIcon")

local MsgTipsUtil = require("Utils/MsgTipsUtil")
local EquipmentRepairWinVM = require("Game/Equipment/VM/EquipmentRepairWinVM")
local ScoreMgr = require("Game/Score/ScoreMgr")
local EquipmentMgr = require("Game/Equipment/EquipmentMgr")

local CommBtnColorType = {
	Normal = 0, -- 普通 灰色
	Recommend = 1, -- 推荐 绿色
	Disable = 2, -- 禁用状态
}

local COLOR_ENABLE = "fffcf1ff"
local COLOR_DISABLE = "828282ff"

---@class EquipmentRepairWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Bg Comm2FrameLView
---@field BorderIntro UBorder
---@field BtnDiscount UFButton
---@field BtnDiscountTipsBG UFButton
---@field BtnRepairAll CommBtnLView
---@field ImgMoney UFImage
---@field ImgMoney1 UFImage
---@field TableViewRepair UTableView
---@field TextD UFTextBlock
---@field TextDContent UFTextBlock
---@field TextOwn UFTextBlock
---@field TextPrice UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EquipmentRepairWinView = LuaClass(UIView, true)

function EquipmentRepairWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Bg = nil
	--self.BorderIntro = nil
	--self.BtnDiscount = nil
	--self.BtnDiscountTipsBG = nil
	--self.BtnRepairAll = nil
	--self.ImgMoney = nil
	--self.ImgMoney1 = nil
	--self.TableViewRepair = nil
	--self.TextD = nil
	--self.TextDContent = nil
	--self.TextOwn = nil
	--self.TextPrice = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EquipmentRepairWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Bg)
	self:AddSubView(self.BtnRepairAll)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EquipmentRepairWinView:OnInit()
	self.EquipmentsTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewRepair, self.OnEquipmentSelectChange, false)
	self.EquipmentsTableView:SetScrollbarIsVisible(false)
	self.ViewModel = EquipmentRepairWinVM.New()
	self.Binders =
	{
		{ "RepairItemVMList", UIBinderUpdateBindableList.New(self, self.EquipmentsTableView) },
		{ "Balance", UIBinderSetText.New(self, self.TextOwn) },
		{ "bCanRepair", UIBinderValueChangedCallback.New(self, nil, self.OnCanRepairChanged) },
		{ "FormattedTotalPrice", UIBinderSetText.New(self, self.TextPrice) },
		{ "TotalPriceColor", UIBinderSetColorAndOpacityHex.New(self, self.TextPrice) },
		{ "ScoreType", UIBinderSetScoreIcon.New(self, self.ImgMoney) },
		{ "ScoreType", UIBinderSetScoreIcon.New(self, self.ImgMoney1) },
	}
end

function EquipmentRepairWinView:OnDestroy()

end

function EquipmentRepairWinView:OnShow()
	self:UpdateBalance()
	if nil ~= self.Params then
		self.ViewModel.SelectedGID = self.Params.GID
	end
	self.ViewModel:UpdateData()
	self.Bg.FText_Title:SetText(LSTR(1050158))
	self.BtnRepairAll.TextContent:SetText(LSTR(1050163))
	self.TextD:SetText(LSTR(1050164))
	self.TextDContent:SetText(LSTR(1050165))
	self.TextEquipment:SetText(LSTR(1050122))
	self.TextCondition:SetText(LSTR(1050109))
	self.TextDiscount:SetText(LSTR(1050184))
	self.TextPrice1:SetText(LSTR(1050185))
end

function EquipmentRepairWinView:OnHide()

end

function EquipmentRepairWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnDiscount, self.OnDiscountTipsClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnDiscountTipsBG, self.OnTipsBGClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnRepairAll, self.OnRepairAllClicked)
end

function EquipmentRepairWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.EquipRepairSucc, self.OnEquipRepairSucc)
end

function EquipmentRepairWinView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function EquipmentRepairWinView:UpdateBalance()
	self.TextOwn:SetText(ScoreMgr.FormatScore(ScoreMgr:GetScoreValueByID(self.ViewModel.ScoreType)))
end

---------- 游戏事件 ----------

function EquipmentRepairWinView:OnEquipRepairSucc(Params)
	_G.MsgTipsUtil.ShowTips(string.format(LSTR(1050020), #Params))
	self.ViewModel.bCanRepair = true
	-- self:RegisterTimer(function ()
		-- self.ViewModel.bCanRepair = true
	-- end, 1.5, 0, 0)

	-- 播动效
	local MaxAnimPlayTime = 0
	for _, GID in pairs(Params) do
		local RepairItemVM = self.ViewModel:FindRepairItemVMByGID(GID)
		if RepairItemVM ~= nil and RepairItemVM.EndureDegProgress < 1.0 then
			local PlayTime = RepairItemVM:PlayFixAnim()
			MaxAnimPlayTime = math.max(MaxAnimPlayTime, PlayTime)
		end
	end
	-- 更新界面
	local DelayEpsilon = 0.1
	self:RegisterTimer(function() self.ViewModel:UpdateData() end, MaxAnimPlayTime + DelayEpsilon)
	self:UpdateBalance()

end

---------- 按钮事件 ----------
function EquipmentRepairWinView:OnDiscountTipsClicked()
	UIUtil.SetIsVisible(self.BtnDiscountTipsBG, true, true)
end

function EquipmentRepairWinView:OnTipsBGClicked()
	UIUtil.SetIsVisible(self.BtnDiscountTipsBG, false, false)
end

function EquipmentRepairWinView:OnRepairAllClicked()
	local CurScore = ScoreMgr:GetGoldScoreValue()
	if CurScore < self.ViewModel.TotalPrice then
		MsgTipsUtil.ShowTips(LSTR(1050133))
		return
	end

	if EquipmentMgr:HasEquipmentNeedRepair() == false then
		MsgTipsUtil.ShowTips(LSTR(1050068))
		return
	end

	self.ViewModel.bCanRepair = false -- 修理期间禁用按钮避免重复修理
	EquipmentMgr:SendEquipRepair(self.ViewModel:GetAllNeedRepairGIDs(), true)
end

---------- VM事件 ----------

function EquipmentRepairWinView:OnCanRepairChanged(bCanRepair)
	-- self.BtnRepairAll:SetIsEnabled(bCanRepair)
	local ColorType = bCanRepair and CommBtnColorType.Recommend or CommBtnColorType.Disable
	local ColorHex = bCanRepair and COLOR_ENABLE or COLOR_DISABLE
	self.BtnRepairAll:UpdateImage(ColorType)
	UIUtil.SetColorAndOpacityHex(self.BtnRepairAll.TextContent, ColorHex)
end

return EquipmentRepairWinView