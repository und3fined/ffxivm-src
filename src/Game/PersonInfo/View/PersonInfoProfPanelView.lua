---
--- Author: Administrator
--- DateTime: 2024-07-23 10:55
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local PersonInfoVM = require("Game/PersonInfo/VM/PersonInfoVM")
local TipsUtil = require("Utils/TipsUtil")

---@class PersonInfoProfPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TableViewAttack UTableView
---@field TableViewCarpenter UTableView
---@field TableViewEarthMessenger UTableView
---@field TableViewHealth UTableView
---@field TableViewTank UTableView
---@field TextAttack UFTextBlock
---@field TextCrafter UFTextBlock
---@field TextEarthMessenger UFTextBlock
---@field TextHealth UFTextBlock
---@field TextTank UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PersonInfoProfPanelView = LuaClass(UIView, true)

function PersonInfoProfPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TableViewAttack = nil
	--self.TableViewCarpenter = nil
	--self.TableViewEarthMessenger = nil
	--self.TableViewHealth = nil
	--self.TableViewTank = nil
	--self.TextAttack = nil
	--self.TextCrafter = nil
	--self.TextEarthMessenger = nil
	--self.TextHealth = nil
	--self.TextTank = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PersonInfoProfPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PersonInfoProfPanelView:OnInit()
	self.AdapterTableViewTank 			= UIAdapterTableView.CreateAdapter(self, self.TableViewTank)
	self.AdapterTableViewHealth 		= UIAdapterTableView.CreateAdapter(self, self.TableViewHealth)
	self.AdapterTableViewAttack 		= UIAdapterTableView.CreateAdapter(self, self.TableViewAttack)
	self.AdapterTableViewEarthMessenger = UIAdapterTableView.CreateAdapter(self, self.TableViewEarthMessenger)
	self.AdapterTableViewCarpenter 		= UIAdapterTableView.CreateAdapter(self, self.TableViewCarpenter)

	self.AdapterTableViewTank:SetOnClickedCallback(self.OnItemClickedProfItem)
	self.AdapterTableViewHealth:SetOnClickedCallback(self.OnItemClickedProfItem)
	self.AdapterTableViewAttack:SetOnClickedCallback(self.OnItemClickedProfItem)
	self.AdapterTableViewEarthMessenger:SetOnClickedCallback(self.OnItemClickedProfItem)
	self.AdapterTableViewCarpenter:SetOnClickedCallback(self.OnItemClickedProfItem)

	self.Binders = {
		{ "TankProfVMList", 			UIBinderUpdateBindableList.New(self, self.AdapterTableViewTank) },
		{ "HealthProfVMList", 			UIBinderUpdateBindableList.New(self, self.AdapterTableViewHealth) },
		{ "AttackProfVMList", 			UIBinderUpdateBindableList.New(self, self.AdapterTableViewAttack) },
		{ "EarthMessengerProfVMList", 	UIBinderUpdateBindableList.New(self, self.AdapterTableViewEarthMessenger) },
		{ "CarpenterProfVMList", 		UIBinderUpdateBindableList.New(self, self.AdapterTableViewCarpenter) },
	}

	self:InitLSTR()
end

function PersonInfoProfPanelView:InitLSTR()
	self.TextTank:SetText(LSTR(620054))
	self.TextHealth:SetText(LSTR(620055))
	self.TextAttack:SetText(LSTR(620056))
	self.TextCrafter:SetText(LSTR(620057))
	self.TextEarthMessenger:SetText(LSTR(620058))
end

function PersonInfoProfPanelView:OnDestroy()

end

function PersonInfoProfPanelView:OnShow()

end

function PersonInfoProfPanelView:OnHide()

end

function PersonInfoProfPanelView:OnRegisterUIEvent()

end

function PersonInfoProfPanelView:OnRegisterGameEvent()

end

function PersonInfoProfPanelView:OnRegisterBinder()
	self:RegisterBinders(PersonInfoVM, self.Binders)
	PersonInfoVM:UpdateAllClassProfVMList()
end

--- 界面说明按钮
function PersonInfoProfPanelView:OnItemClickedProfItem(Index, ItemData, ItemView)
	local Aff = ItemData.Level == 0 and _G.LSTR(620139) or (tostring(ItemData.Level) .. _G.LSTR(620138))
	local Content = string.format("%s%s",tostring(ItemData.Name),Aff)
	TipsUtil.ShowInfoTips(Content, ItemView, _G.UE.FVector2D(-10, 0), _G.UE.FVector2D(0, 0))
end

return PersonInfoProfPanelView