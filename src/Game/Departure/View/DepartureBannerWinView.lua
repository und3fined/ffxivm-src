---
--- Author: Administrator
--- DateTime: 2025-03-13 14:21
--- Description:右侧玩法说明弹窗界面
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local AudioUtil = require("Utils/AudioUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsChecked  = require("Binder/UIBinderSetIsChecked")
local EquipmentDefine = require("Game/Equipment/EquipmentDefine")
local EquipmentMgr = require("Game/Equipment/EquipmentMgr")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderSetActiveWidgetIndexBool = require("Binder/UIBinderSetActiveWidgetIndexBool")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local DepartOfLightMgr = require("Game/Departure/DepartOfLightMgr")
local DepartOfLightDefine = require("Game/Departure/DepartOfLightDefine")
local DepartOfLightVMUtils = require("Game/Departure/DepartOfLightVMUtils")
local DepartOfLightVM = require("Game/Departure/VM/DepartOfLightVM")

---@class DepartureBannerWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnArrowL UFButton
---@field BtnArrowR UFButton
---@field BtnClose UFButton
---@field BtnGoto CommBtnLView
---@field ImgBanner UFImage
---@field PanlBtnText UFCanvasPanel
---@field RichTextDetailed URichTextBox
---@field TableViewDot UTableView
---@field TableViewList UTableView
---@field TextBtnHint UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local DepartureBannerWinView = LuaClass(UIView, true)

function DepartureBannerWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnArrowL = nil
	--self.BtnArrowR = nil
	--self.BtnClose = nil
	--self.BtnGoto = nil
	--self.ImgBanner = nil
	--self.PanlBtnText = nil
	--self.RichTextDetailed = nil
	--self.TableViewDot = nil
	--self.TableViewList = nil
	--self.TextBtnHint = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function DepartureBannerWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnGoto)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function DepartureBannerWinView:OnInit()
	self.PointsTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList, nil, true, false)
	self.IndexTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewDot, nil, true, false)
	self.MultiBinders = {
		{
			ViewModel = DepartOfLightVM,
			Binders = {
				{"GoToBtnDesc", UIBinderSetText.New(self, self.TextBtnHint)},
				{"GoToBtnDescVisible", UIBinderSetIsVisible.New(self, self.PanlBtnText)},
				{"GoToBtnName", UIBinderSetText.New(self, self.BtnGoto.TextContent)},
			}
		},
		{
			ViewModel = DepartOfLightVM.DepartActivityDetailVM,
			Binders = {
				{"CurDescPointVMList", UIBinderUpdateBindableList.New(self, self.PointsTableViewAdapter)},
				{"DescIndexVMList", UIBinderUpdateBindableList.New(self, self.IndexTableViewAdapter)},
				{"CurDescTitle", UIBinderSetText.New(self, self.TextTitle)},
				{"CurDescContent", UIBinderSetText.New(self, self.RichTextDetailed)},
				{"CurDescIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgBanner)},
			}
		},
	}
end

function DepartureBannerWinView:OnDestroy()

end

function DepartureBannerWinView:OnShow()
	self:SetLSTR()
	self.CurSelectedIndex = 1
	if self.Params and self.Params.Index then
		self.CurSelectedIndex = self.Params.Index
	end
	self.PointsTableViewAdapter:SetSelectedIndex(self.CurSelectedIndex)
	self.IndexTableViewAdapter:SetSelectedIndex(self.CurSelectedIndex)
	AudioUtil.LoadAndPlayUISound(DepartOfLightDefine.UISoundPath.ActivityDetail)
end

function DepartureBannerWinView:OnHide()

end

function DepartureBannerWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnArrowL, self.OnBtnArrowLClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnArrowR, self.OnBtnArrowRClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnGoto.Button, self.OnBtnGotoClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnClose, self.OnBtnCloseClicked)
end

function DepartureBannerWinView:OnRegisterGameEvent()
	
end

function DepartureBannerWinView:OnRegisterBinder()
	self:RegisterMultiBinders(self.MultiBinders)
end

function DepartureBannerWinView:SetLSTR()
	--self.BtnGoto.TextContent:SetText(_G.LSTR(10019)) -- 10019(”前往“)
end

-- ---@type 
-- function DepartureBannerWinView:OnActivitySelected(Index, ItemData, ItemView)

-- end

function DepartureBannerWinView:OnBtnGotoClicked()
	local CurActivityIndex = DepartOfLightVM:GetCurrActivityIndex()
	DepartOfLightMgr:OnGotoPlayStyle(CurActivityIndex)
end

function DepartureBannerWinView:OnBtnArrowLClicked()
	self.CurSelectedIndex = DepartOfLightMgr:OnUpDescIconClicked()
	self.IndexTableViewAdapter:SetSelectedIndex(self.CurSelectedIndex)
end

function DepartureBannerWinView:OnBtnArrowRClicked()
	self.CurSelectedIndex = DepartOfLightMgr:OnNextDescIconClicked()
	self.IndexTableViewAdapter:SetSelectedIndex(self.CurSelectedIndex)
end

function DepartureBannerWinView:OnBtnCloseClicked()
	self:Hide()
end

return DepartureBannerWinView