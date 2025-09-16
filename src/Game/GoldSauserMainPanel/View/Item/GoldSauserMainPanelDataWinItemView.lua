---
--- Author: Administrator
--- DateTime: 2023-12-29 20:13
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local GoldSauserMainPanelMainVM = require("Game/GoldSauserMainPanel/VM/GoldSauserMainPanelMainVM")
local GoldSauserMainPanelMgr = require("Game/GoldSauserMainPanel/GoldSauserMainPanelMgr")
local GoldSauserMainPanelDefine = require("Game/GoldSauserMainPanel/GoldSauserMainPanelDefine")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local GoldSauserMainPanelDataWinItemVM

local UIBinderSetText = require("Binder/UIBinderSetText")
local LSTR = _G.LSTR
local AudioType = GoldSauserMainPanelDefine.AudioType

---@class GoldSauserMainPanelDataWinItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CloseBtn CommonCloseBtnView
---@field FTextBlock_140 UFTextBlock
---@field Icon1 UFImage
---@field Icon2 UFImage
---@field Icon3 UFImage
---@field IconRanking1 UFImage
---@field IconRanking2 UFImage
---@field IconRanking3 UFImage
---@field ImgTotalFocusL UFImage
---@field ImgTotalFocusM UFImage
---@field ImgTotalFocusR UFImage
---@field TableViewList UTableView
---@field TextListPlayerRatio UFTextBlock
---@field TextMedal UFTextBlock
---@field TextMyData UFTextBlock
---@field TextPlayerRatio UFTextBlock
---@field TextQuantity1 UFTextBlock
---@field TextQuantity2 UFTextBlock
---@field TextQuantity3 UFTextBlock
---@field Textpercentage UFTextBlock
---@field Textpercentage1 UFTextBlock
---@field Textpercentage2 UFTextBlock
---@field WinBG PlayStyleCommFrameLView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSauserMainPanelDataWinItemView = LuaClass(UIView, true)

function GoldSauserMainPanelDataWinItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CloseBtn = nil
	--self.FTextBlock_140 = nil
	--self.Icon1 = nil
	--self.Icon2 = nil
	--self.Icon3 = nil
	--self.IconRanking1 = nil
	--self.IconRanking2 = nil
	--self.IconRanking3 = nil
	--self.ImgTotalFocusL = nil
	--self.ImgTotalFocusM = nil
	--self.ImgTotalFocusR = nil
	--self.TableViewList = nil
	--self.TextListPlayerRatio = nil
	--self.TextMedal = nil
	--self.TextMyData = nil
	--self.TextPlayerRatio = nil
	--self.TextQuantity1 = nil
	--self.TextQuantity2 = nil
	--self.TextQuantity3 = nil
	--self.Textpercentage = nil
	--self.Textpercentage1 = nil
	--self.Textpercentage2 = nil
	--self.WinBG = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelDataWinItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.WinBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelDataWinItemView:InitConstStringInfo()
	self.TextMyData:SetText(LSTR(350067))
	self.TextListPlayerRatio:SetText(LSTR(350068))
	self.TextPlayerRatio:SetText(LSTR(350068))
	self.Textpercentage1:SetText(LSTR(350069))
	self.Textpercentage2:SetText(LSTR(350070))
	self.Textpercentage:SetText(LSTR(350071))
	self.FTextBlock_140:SetText(LSTR(350072))
	self.TextMedal:SetText(LSTR(350073))
end

function GoldSauserMainPanelDataWinItemView:OnInit()
	GoldSauserMainPanelDataWinItemVM = GoldSauserMainPanelMainVM:GetGoldSauserMainPanelDataWinItemVM()
	self.TableViewListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList)
	self:InitConstStringInfo()
end

function GoldSauserMainPanelDataWinItemView:OnDestroy()

end

function GoldSauserMainPanelDataWinItemView:OnShow()
	UIUtil.SetIsVisible(self.WinBG.PanelCurrency, false)
	self.WinBG:SetTitle(LSTR(350026))
	--GoldSauserMainPanelMgr:SendGetDataWinItemViewDataMsg()
end

function GoldSauserMainPanelDataWinItemView:OnHide()
	
end

function GoldSauserMainPanelDataWinItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.WinBG.ButtonClose, self.OnButtonCloseClick)
end

function GoldSauserMainPanelDataWinItemView:OnRegisterGameEvent()

end

function GoldSauserMainPanelDataWinItemView:OnRegisterBinder()
	self.Binders = {
		--{"HardPercentage", UIBinderSetText.New(self, self.Textpercentage1)},
		--{"MiddlePercentage", UIBinderSetText.New(self, self.Textpercentage2)},
		--{"SimplePercentage", UIBinderSetText.New(self, self.Textpercentage)},
		{"HardDataNum", UIBinderSetText.New(self, self.TextQuantity1)},
		{"MiddleDataNum", UIBinderSetText.New(self, self.TextQuantity2)},
		{"SimpleDataNum", UIBinderSetText.New(self, self.TextQuantity3)},
		{"DataItemList", UIBinderUpdateBindableList.New(self, self.TableViewListAdapter)},
	}
	self:RegisterBinders(GoldSauserMainPanelDataWinItemVM, self.Binders)
end

function GoldSauserMainPanelDataWinItemView:OnButtonCloseClick()
	self:Hide()
	GoldSauserMainPanelMgr:PlayAudio(AudioType.SubView)
end

return GoldSauserMainPanelDataWinItemView