---
--- Author: enqingchen
--- DateTime: 2021-12-27 15:03
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local EquipmentMgr = _G.EquipmentMgr
local MajorUtil = require("Utils/MajorUtil")
local EquipmentStrongestSuitTipsVM = require("Game/Equipment/VM/EquipmentStrongestSuitTipsVM")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetRenderOpacity = require("Binder/UIBinderSetRenderOpacity")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")

local MsgBoxUtil = _G.MsgBoxUtil
local CountPerPage = 8

---@class EquipmentStrongestSuitTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnApply CommBtnLView
---@field BtnCancel CommBtnLView
---@field BtnSwitch UFButton
---@field CommonBkg01_UIBP CommonBkg01View
---@field Common_CloseBtn_UIBP CommonCloseBtnView
---@field CurrentClone EquipmentStrongestCurrentView
---@field CurrentClone1 EquipmentStrongestCurrentView
---@field CurrentClone2 EquipmentStrongestCurrentView
---@field CurrentClone3 EquipmentStrongestCurrentView
---@field CurrentClone4 EquipmentStrongestCurrentView
---@field CurrentClone5 EquipmentStrongestCurrentView
---@field CurrentClone6 EquipmentStrongestCurrentView
---@field CurrentClone7 EquipmentStrongestCurrentView
---@field CurrentClone8 EquipmentStrongestCurrentView
---@field CurrentVerticalBox UFVerticalBox
---@field FBtn_Cancel Comm2BtnLView
---@field FBtn_Change UFButton
---@field FBtn_Use Comm2BtnLView
---@field PanelCurrentL UFCanvasPanel
---@field PanelCurrentR UFCanvasPanel
---@field PanelPage1 UFCanvasPanel
---@field PanelPage2 UFCanvasPanel
---@field StrongestClone EquipmentStrongestAfterView
---@field StrongestClone1 EquipmentStrongestAfterView
---@field StrongestClone2 EquipmentStrongestAfterView
---@field StrongestClone3 EquipmentStrongestAfterView
---@field StrongestClone4 EquipmentStrongestAfterView
---@field StrongestClone5 EquipmentStrongestAfterView
---@field StrongestClone6 EquipmentStrongestAfterView
---@field StrongestClone7 EquipmentStrongestAfterView
---@field StrongestClone8 EquipmentStrongestAfterView
---@field StrongestVerticalBox UFVerticalBox
---@field TableViewCurrentL UTableView
---@field TableViewCurrentR UTableView
---@field Text_AddClass UFTextBlock
---@field Text_AfterClass UFTextBlock
---@field Text_Current UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimSuitIn UWidgetAnimation
---@field AnimSuitOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EquipmentStrongestSuitTipsView = LuaClass(UIView, true)

function EquipmentStrongestSuitTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnApply = nil
	--self.BtnCancel = nil
	--self.BtnSwitch = nil
	--self.CommonBkg01_UIBP = nil
	--self.Common_CloseBtn_UIBP = nil
	--self.CurrentClone = nil
	--self.CurrentClone1 = nil
	--self.CurrentClone2 = nil
	--self.CurrentClone3 = nil
	--self.CurrentClone4 = nil
	--self.CurrentClone5 = nil
	--self.CurrentClone6 = nil
	--self.CurrentClone7 = nil
	--self.CurrentClone8 = nil
	--self.CurrentVerticalBox = nil
	--self.FBtn_Cancel = nil
	--self.FBtn_Change = nil
	--self.FBtn_Use = nil
	--self.PanelCurrentL = nil
	--self.PanelCurrentR = nil
	--self.PanelPage1 = nil
	--self.PanelPage2 = nil
	--self.StrongestClone = nil
	--self.StrongestClone1 = nil
	--self.StrongestClone2 = nil
	--self.StrongestClone3 = nil
	--self.StrongestClone4 = nil
	--self.StrongestClone5 = nil
	--self.StrongestClone6 = nil
	--self.StrongestClone7 = nil
	--self.StrongestClone8 = nil
	--self.StrongestVerticalBox = nil
	--self.TableViewCurrentL = nil
	--self.TableViewCurrentR = nil
	--self.Text_AddClass = nil
	--self.Text_AfterClass = nil
	--self.Text_Current = nil
	--self.AnimIn = nil
	--self.AnimSuitIn = nil
	--self.AnimSuitOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EquipmentStrongestSuitTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnApply)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.CommonBkg01_UIBP)
	self:AddSubView(self.Common_CloseBtn_UIBP)
	-- self:AddSubView(self.CurrentClone)
	-- self:AddSubView(self.CurrentClone1)
	-- self:AddSubView(self.CurrentClone2)
	-- self:AddSubView(self.CurrentClone3)
	-- self:AddSubView(self.CurrentClone4)
	-- self:AddSubView(self.CurrentClone5)
	-- self:AddSubView(self.CurrentClone6)
	-- self:AddSubView(self.CurrentClone7)
	-- self:AddSubView(self.CurrentClone8)
	self:AddSubView(self.FBtn_Cancel)
	self:AddSubView(self.FBtn_Use)
	-- self:AddSubView(self.StrongestClone)
	-- self:AddSubView(self.StrongestClone1)
	-- self:AddSubView(self.StrongestClone2)
	-- self:AddSubView(self.StrongestClone3)
	-- self:AddSubView(self.StrongestClone4)
	-- self:AddSubView(self.StrongestClone5)
	-- self:AddSubView(self.StrongestClone6)
	-- self:AddSubView(self.StrongestClone7)
	-- self:AddSubView(self.StrongestClone8)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EquipmentStrongestSuitTipsView:OnInit()
	self.Render2DView = nil
	self.ViewModel = EquipmentStrongestSuitTipsVM.New()
	self.AddScore = 0
	self.LeftTable = {}
	self.RightTable = {}
	self.TableViewMenuAdapterL = UIAdapterTableView.CreateAdapter(self, self.TableViewCurrentL)
	self.TableViewMenuAdapterR = UIAdapterTableView.CreateAdapter(self, self.TableViewCurrentR)
end

function EquipmentStrongestSuitTipsView:OnDestroy()

end

function EquipmentStrongestSuitTipsView:OnShow()
	self.Render2DView = self.Params.Render2DView
	self.FOV = self.Params.FOV
	self:Update3DScene(true)
	self.ViewModel:ChangePage(1)
	self.Strongest = EquipmentMgr:GetStrongest()
	self.ViewModel.CurrentScore = EquipmentMgr:CalculateEquipScore()
	self.StrongestScore = EquipmentMgr:CalculateStrongestScore()
	self.AddScore = self.StrongestScore - self.ViewModel.CurrentScore
	self.ViewModel.StrongestScore = 0
	self.ViewModel.AddScore = 0
	self:UpdateList()
	self.TextTitle:SetText(LSTR(1050157))
	self.Text_CurrentEquip:SetText(LSTR(1050161))
	self.Text_AfterEquip:SetText(LSTR(1050157))
	self.BtnCancel.TextContent:SetText(LSTR(1050162))
	self.BtnApply.TextContent:SetText(LSTR(1050160))
end

function EquipmentStrongestSuitTipsView:Update3DScene(bEnter)
	_G.EventMgr:SendEvent(_G.EventID.EquipStrongestViewHide, bEnter)
end

function EquipmentStrongestSuitTipsView:UpdateList()
	---Strongest元素：{Current = Item, Strongest = Item1, CurrentScore = ItemScore, StrongestScore = Item1Score}

	local Count = #self.Strongest
	self.ViewModel.bHasChange = Count > CountPerPage


	for ListIndex = 1, Count do
		local Strongest = self.Strongest[ListIndex]

			local CurrentItem = Strongest.Current
			local StrongestItem = Strongest.Strongest
			local EquipPart = Strongest.Part

			local ParamCurrent = {Part = EquipPart, ResID = CurrentItem and CurrentItem.ResID, DelayTime = 0.1* ListIndex}
			local ParamStrongest = {Part = EquipPart, ResID = StrongestItem.ResID, DelayTime = 0.1* ListIndex}
			table.insert(self.RightTable, ParamStrongest)
			table.insert(self.LeftTable, ParamCurrent)

	end
	self.TableViewMenuAdapterL:UpdateAll(self.LeftTable)
	self.TableViewMenuAdapterR:UpdateAll(self.RightTable)
end


function EquipmentStrongestSuitTipsView:OnHide()
	self.LeftTable = {}
	self.RightTable = {}
	self:Update3DScene(false)
	_G.EquipmentMgr:SetStrongestAnimPlayNum(false, 0)
	_G.EquipmentMgr:SetStrongestAnimPlayNum(true, 0)
end

function EquipmentStrongestSuitTipsView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.OnCancelClick)
	UIUtil.AddOnClickedEvent(self, self.BtnApply, self.OnApplyClick)
	UIUtil.AddOnScrolledEvent(self, self.TableViewCurrentL, self.OnLeftScrollChange)
	UIUtil.AddOnScrolledEvent(self, self.TableViewCurrentR, self.OnRightScrollChange)
end

function EquipmentStrongestSuitTipsView:OnLeftScrollChange()
	local OffsetL = self.TableViewMenuAdapterL:GetScrollOffset()
	local OffsetR = self.TableViewMenuAdapterR:GetScrollOffset()
	if OffsetR ~= OffsetL then
		self.TableViewMenuAdapterR:SetScrollOffset(OffsetL)
	end
end

function EquipmentStrongestSuitTipsView:OnRightScrollChange()
	local OffsetL = self.TableViewMenuAdapterL:GetScrollOffset()
	local OffsetR = self.TableViewMenuAdapterR:GetScrollOffset()
	if OffsetR ~= OffsetL then
		self.TableViewMenuAdapterL:SetScrollOffset(OffsetR)
	end
end

function EquipmentStrongestSuitTipsView:OnRegisterGameEvent()

end

--会重写蓝图中的Tick函数
function EquipmentStrongestSuitTipsView:Tick(_, InDeltaTime)
	if self.ViewModel.AddScore and self.AddScore and self.ViewModel.AddScore < self.AddScore then
		local Score = self.ViewModel.AddScore + math.ceil(InDeltaTime*100)
		self.ViewModel.AddScore = Score > self.AddScore and self.AddScore or Score
	end
	if self.ViewModel.StrongestScore and self.StrongestScore and self.ViewModel.StrongestScore < self.StrongestScore then
		local Score = self.ViewModel.StrongestScore + math.ceil(InDeltaTime*100)
		self.ViewModel.StrongestScore = Score > self.StrongestScore and self.StrongestScore or Score
	end
end

function EquipmentStrongestSuitTipsView:OnRegisterBinder()
	local Binders = {
		{ "CurrentScore", UIBinderSetTextFormat.New(self, self.Text_Current, "%04d") },
		{ "StrongestScore", UIBinderSetTextFormat.New(self, self.Text_AfterClass, "%04d") },
		{ "AddScore", UIBinderSetTextFormat.New(self, self.Text_AddClass, "+ %04d") },
		{ "OpacityPage1", UIBinderSetRenderOpacity.New(self, self.PanelPage1) },
		{ "OpacityPage2", UIBinderSetRenderOpacity.New(self, self.PanelPage2) },
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

function EquipmentStrongestSuitTipsView:AddItem(ParamCurrent, ParamStrongest, Index, bShow)
	-- local UIViewMgr = _G.UIViewMgr
	-- local CurrentClone = UIViewMgr:CloneView(self.CurrentClone, self, ParamCurrent)
	-- local StrongestClone = UIViewMgr:CloneView(self.StrongestClone, self, ParamStrongest)
	-- self.CurrentVerticalBox:AddChildToVerticalBox(CurrentClone)
	-- self.StrongestVerticalBox:AddChildToVerticalBox(StrongestClone)
	local Current = self["CurrentClone"..Index]
	local Strongest = self["StrongestClone"..Index]
	if Current == nil or Strongest == nil then
		return
	end
	Current:UpdateUI(ParamCurrent)
	Strongest:UpdateUI(ParamStrongest)
	UIUtil.SetIsVisible(Current, bShow)
	UIUtil.SetIsVisible(Strongest, bShow)
end

function EquipmentStrongestSuitTipsView:OnCancelClick()
	_G.UIViewMgr:HideView(UIViewID.EquipmentStrongest)
end

function EquipmentStrongestSuitTipsView:OnApplyClick()
	if nil == self.Strongest or not next (self.Strongest) then
		return
	end

	if not _G.EquipmentMgr:CheckCanOperate(LSTR(1050178), true) then
		return
	end
	local func = function ()
		local lstEquipInfo = {}
		for _,v in pairs(self.Strongest) do
			local StrongestItem = v.Strongest
			lstEquipInfo[#lstEquipInfo + 1] = {Part = v.Part, GID = StrongestItem.GID}
		end
		
		EquipmentMgr:SendEquipOn(lstEquipInfo)
		_G.UIViewMgr:HideView(UIViewID.EquipmentStrongest)
	end
	func()
end

return EquipmentStrongestSuitTipsView