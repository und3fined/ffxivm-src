---
--- Author: v_vvxinchen
--- DateTime: 2024-05-17 10:13
--- Description: 
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local ItemUtil = require("Utils/ItemUtil")
local ItemGetaccesstypeCfg = require("TableCfg/ItemGetaccesstypeCfg")

---@class GatheringLogTextItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBg UFImage
---@field TextTips URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GatheringLogTextItemView = LuaClass(UIView, true)

function GatheringLogTextItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBg = nil
	--self.TextTips = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GatheringLogTextItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GatheringLogTextItemView:OnInit()
	self.Binders = {
        {"TextTips", UIBinderSetText.New(self, self.TextTips)},
    }
end

function GatheringLogTextItemView:OnDestroy()

end

function GatheringLogTextItemView:OnShow()
end

function GatheringLogTextItemView:OnHide()

end

function GatheringLogTextItemView:OnRegisterUIEvent()
	UIUtil.AddOnHyperlinkClickedEvent(self, self.TextTips, self.OnHyperlinkClicked)
end

function GatheringLogTextItemView:OnHyperlinkClicked(Value)
	local Params = Value.Params
	if nil == Params or Params.Data == nil then
		return
	end

	local ItemID = Params.Data.CategoryItemID
	if nil == ItemID then
		return
	end

	local AccessList = ItemUtil.GetItemAccess(ItemID)
	if AccessList == nil then
		return
	end

	local MajorLevel = MajorUtil.GetMajorLevel()
	local Cfg = ItemGetaccesstypeCfg:FindCfgByKey(AccessList[1])
	if Cfg ~= nil and (Cfg.UnLockLevel == nil or MajorLevel == nil or Cfg.UnLockLevel <= MajorLevel) and ItemUtil.QueryIsUnLock(Cfg.FunType, Cfg.FunValue, ItemID) then
		_G.ShopMgr:JumpToShopGoods(Cfg.FunValue, ItemID)
	else
		_G.MsgTipsUtil.ShowTipsByID(157034)
	end
end

function GatheringLogTextItemView:OnRegisterGameEvent()

end

function GatheringLogTextItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

return GatheringLogTextItemView