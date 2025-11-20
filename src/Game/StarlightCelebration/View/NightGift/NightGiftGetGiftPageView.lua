---
--- Author: Administrator
--- DateTime: 2025-07-28 15:14
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local NightGiftGetGiftPageVM = require("Game/StarlightCelebration/VM/NightGift/NightGiftGetGiftPageVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local ProtoCS = require("Protocol/ProtoCS")
local OpsStarlightDefine = require("Game/StarlightCelebration/OpsStarlightDefine")
local LSTR = _G.LSTR
---@class NightGiftGetGiftPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BGPanel NightGiftBGPanelView
---@field BtnAccept CommBtnLView
---@field CommonBkg02_UIBP CommonBkg02View
---@field CommonBkgMask_UIBP CommonBkgMaskView
---@field TableViewSlot UTableView
---@field Text2 UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NightGiftGetGiftPageView = LuaClass(UIView, true)

function NightGiftGetGiftPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BGPanel = nil
	--self.BtnAccept = nil
	--self.CommonBkg02_UIBP = nil
	--self.CommonBkgMask_UIBP = nil
	--self.TableViewSlot = nil
	--self.Text2 = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NightGiftGetGiftPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BGPanel)
	self:AddSubView(self.BtnAccept)
	self:AddSubView(self.CommonBkg02_UIBP)
	self:AddSubView(self.CommonBkgMask_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NightGiftGetGiftPageView:OnInit()
	self.ViewModel = NightGiftGetGiftPageVM:New()
	self.AdapterTableViewGift = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot)
	self.Binders = {	
		{"BlessingText", UIBinderSetText.New(self, self.Text2) },
		{"NightGiftItemVMList", UIBinderUpdateBindableList.New(self, self.AdapterTableViewGift) },
	}
end

function NightGiftGetGiftPageView:OnDestroy()

end

function NightGiftGetGiftPageView:OnShow()
	self.ViewModel:UpdateGetPageInfo()

end

function NightGiftGetGiftPageView:OnHide()

end

function NightGiftGetGiftPageView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnAccept.Button, self.OnClickAcceptButton)
end

function NightGiftGetGiftPageView:OnRegisterGameEvent()

end

function NightGiftGetGiftPageView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)

	self.TextTitle:SetText(LSTR(1700029))
	self.BtnAccept:SetBtnName(LSTR(1700030))
end

function NightGiftGetGiftPageView:OnClickAcceptButton()
	if self.ViewModel.GetGiftNode == nil then
		self:Hide()
		return
	end
	
	local StarGift = self.ViewModel.GetGiftNode.Extra.StarGift or {}
	local GetGiftNum = StarGift.Gifts and #StarGift.Gifts or 0
	if GetGiftNum > 0 then
		local Params = {}
		Params.ItemList = {}
		for _, Value in ipairs(StarGift.Gifts[GetGiftNum].Items) do
			table.insert(Params.ItemList, { ResID = Value.ResID, Num = Value.Num})
		end

		for _, Value in ipairs(StarGift.Gifts[GetGiftNum].SystemItems) do
			table.insert(Params.ItemList, { ResID = Value.ResID, Num = Value.Num})
		end
			   
		if #Params.ItemList > 0 then
			_G.UIViewMgr:ShowView(_G.UIViewID.CommonRewardPanel, Params)
		end

	end

	self:Hide()
end


return NightGiftGetGiftPageView