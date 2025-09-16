---
--- Author: v_hggzhang
--- DateTime: 2023-08-15 14:27
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")
local CommonBoxDefine = require("Game/CommMsg/CommonBoxDefine")
local UIViewMgr = _G.UIViewMgr

---@class CommCostBoxView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CheckBoxLacking CommCheckBoxView
---@field CheckBoxSpent CommCheckBoxView
---@field ImgSpent UFImage
---@field ItemSlot CommBackpackSlotView
---@field ItemSlotConsume CommBackpackSlotView
---@field LeftBtnOp CommBtnLView
---@field Panel2Btns UFHorizontalBox
---@field PopUpBG CommonPopUpBGView
---@field RichTextBoxDesc URichTextBox
---@field RichTextBoxTitle URichTextBox
---@field RichTextBoxTotal URichTextBox
---@field RichTextBoxTotalMaterial URichTextBox
---@field RightBtnOp CommBtnLView
---@field TextMaterialName UFTextBlock
---@field TextSpent UFTextBlock
---@field TextSpentTotal UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommCostBoxView = LuaClass(UIView, true)

function CommCostBoxView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CheckBoxLacking = nil
	--self.CheckBoxSpent = nil
	--self.ImgSpent = nil
	--self.ItemSlot = nil
	--self.ItemSlotConsume = nil
	--self.LeftBtnOp = nil
	--self.Panel2Btns = nil
	--self.PopUpBG = nil
	--self.RichTextBoxDesc = nil
	--self.RichTextBoxTitle = nil
	--self.RichTextBoxTotal = nil
	--self.RichTextBoxTotalMaterial = nil
	--self.RightBtnOp = nil
	--self.TextMaterialName = nil
	--self.TextSpent = nil
	--self.TextSpentTotal = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommCostBoxView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CheckBoxLacking)
	self:AddSubView(self.CheckBoxSpent)
	self:AddSubView(self.ItemSlot)
	self:AddSubView(self.ItemSlotConsume)
	self:AddSubView(self.LeftBtnOp)
	self:AddSubView(self.BG)
	self:AddSubView(self.RightBtnOp)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommCostBoxView:OnInit()

end

function CommCostBoxView:OnDestroy()

end

function CommCostBoxView:OnShow()
	self:UpdateView(self.Params)
end

function CommCostBoxView:OnHide()

end

function CommCostBoxView:OnRegisterUIEvent()

end

function CommCostBoxView:OnRegisterGameEvent()
	UIUtil.AddOnStateChangedEvent(self, self.CheckBoxSpent, 				self.OnCheckBoxSpent)
	UIUtil.AddOnStateChangedEvent(self, self.CheckBoxLacking, 				self.OnCheckBoxInstead)

	UIUtil.AddOnClickedEvent(self, self.LeftBtnOp, 							self.OnBtnClickL)
	UIUtil.AddOnClickedEvent(self, self.RightBtnOp, 						self.OnBtnClickR)
end

function CommCostBoxView:OnRegisterBinder()

end

local function GetItemIcon(ItemID)
	local IconID = ItemUtil.GetItemIcon(ItemID)
	if IconID then
		return UIUtil.GetIconPath(IconID)
	end

	_G.FLOG_ERROR("zhg CommCostBoxView GetItemIcon IconID = nil ItemID =  " .. tostring(ItemID))
	return ""
end

local function GetItemNum(ItemID)
	return _G.BagMgr:GetItemNum(ItemID)

end

local function GetItemName(ItemID)
	return ItemUtil.GetItemName(ItemID)
end

local NumColor = {
	Succ = "D5D5D5FF",
	Fail = "DC5868FF",
}

function CommCostBoxView:UpdateView(Info)
	if nil == Info then
		return
	end

	self.IsCheckedInstead = false

	self.RichTextBoxDesc:SetText(Info.Message or "")
	self.RichTextBoxTitle:SetText(Info.Title or "")

	if nil == Info.CostStyle then
		return
	end

	self.BtnMap = {}
	self.BtnMap[CommonBoxDefine.BtnType.Right] = self.RightBtnOp
	self.BtnMap[CommonBoxDefine.BtnType.Left] = self.LeftBtnOp


	for BtnType, Btn in pairs(self.BtnMap) do
		local BtnName = CommonBoxDefine.BtnInitialName[BtnType]
		if nil ~= Info.BtnInfo and nil ~= Info.BtnInfo.Name then
			BtnName = Info.BtnInfo.Name[BtnType] or BtnName
		end
		Btn:SetText(BtnName)
		Btn:SetColorType(Info.BtnInfo.Style[BtnType])
	end

	-- Upd Style

	UIUtil.SetIsVisible(self.LeftBtnOp, false)
	UIUtil.SetIsVisible(self.PanelCost, false)
	UIUtil.SetIsVisible(self.CheckBoxLacking, false)
	UIUtil.SetIsVisible(self.PanelSpent, false)
	UIUtil.SetIsVisible(self.VerticalBoxConsume, false)

	if Info.CostStyle == CommonBoxDefine.CostStyle.Cost then
		UIUtil.SetIsVisible(self.PanelCost, true)
		UIUtil.SetIsVisible(self.PanelSpent, true)
		self:UpdConsume()

		local Icon = GetItemIcon(self.Params.CostItemID)
		local Num = GetItemNum(self.Params.CostItemID)
		local ReqNum = self.Params.CostNum
		local IsSucc = 	Num >= ReqNum
		local Color = IsSucc and NumColor.Succ or NumColor.Fail
		self.TextSpentTotal:SetText(Num)
		UIUtil.ImageSetBrushFromAssetPath(self.ImgSpent, Icon)
		UIUtil.SetColorAndOpacityHex(self.TextSpentTotal, Color)

	elseif Info.CostStyle == CommonBoxDefine.CostStyle.Instead then
		UIUtil.SetIsVisible(self.PanelCost, true)
		UIUtil.SetIsVisible(self.CheckBoxLacking, true)
		self:UpdConsume()

	elseif Info.CostStyle == CommonBoxDefine.CostStyle.Simple then
		UIUtil.SetIsVisible(self.LeftBtnOp, true, true)
		UIUtil.SetIsVisible(self.VerticalBoxConsume, true)

		local Icon = GetItemIcon(self.Params.ConsumeItemID)
		local Num = GetItemNum(self.Params.ConsumeItemID)
		local ReqNum = self.Params.ConsumeNum
		local IsSucc = 	Num >= ReqNum
		local Color = IsSucc and NumColor.Succ or NumColor.Fail

		local StrFmt = string.format("<span color=\"#%s\">%s</>/%s", Color, ReqNum, Num)
		self.RichTextBoxTotal:SetText(StrFmt)
		UIUtil.ImageSetBrushFromAssetPath(self.ItemSlotConsume.FImg_Icon, Icon)
	else
		-- body
	end
	
	UIUtil.SetIsVisible(self.SpacerMid, (UIUtil.IsVisible(self.LeftBtnOp) == UIUtil.IsVisible(self.RightBtnOp)))

	self.CheckBoxLacking:SetChecked(false)
	self.CheckBoxSpent:SetChecked(false)
	self.IsCheckedInstead = false
	self.IsCheckedSpent = false
end

function CommCostBoxView:UpdConsume()
	if not self.Params then
		return
	end

	local Icon = GetItemIcon(self.Params.ConsumeItemID)
	local Num = GetItemNum(self.Params.ConsumeItemID)
	local Name = GetItemName(self.Params.ConsumeItemID)

	local ReqNum = self.Params.ConsumeNum
	local IsSucc = 	Num >= ReqNum
	local Color = IsSucc and NumColor.Succ or NumColor.Fail

	local StrFmt = string.format("<span color=\"#%s\">%s</>/%s", Color, ReqNum, Num)
	self.RichTextBoxTotalMaterial:SetText(StrFmt)
	self.TextMaterialName:SetText(Name)
	UIUtil.ImageSetBrushFromAssetPath(self.ItemSlot.FImg_Icon, Icon)
end

function CommCostBoxView:OnBtnClickL()
	self:OnBtnClick(CommonBoxDefine.BtnType.Left)
end

function CommCostBoxView:OnBtnClickR()
	self:OnBtnClick(CommonBoxDefine.BtnType.Right)
end

function CommCostBoxView:OnBtnClick(BtnType)
	if self.Params and self.Params.BtnInfo and self.Params.BtnInfo.Callback then
		local Callback = self.Params.BtnInfo.Callback[BtnType]
		if nil ~= Callback then
			Callback(self.Params.UIView, {
				IsCheckedInstead = self.IsCheckedInstead,
				IsCheckedSpent = self.IsCheckedSpent,
			})
		end
	end

	if self.Params then
		UIViewMgr:HideView(self.ViewID)
	end
end

function CommCostBoxView:OnCheckBoxInstead(_, Stat)
	local IsChecked = UIUtil.IsToggleButtonChecked(Stat)
	self.IsCheckedInstead = IsChecked
end

function CommCostBoxView:OnCheckBoxSpent(_, Stat)
	local IsChecked = UIUtil.IsToggleButtonChecked(Stat)
	self.IsCheckedSpent = IsChecked
end

return CommCostBoxView