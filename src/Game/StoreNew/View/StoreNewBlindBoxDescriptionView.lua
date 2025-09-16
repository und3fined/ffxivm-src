---
--- Author: ds_tianjiateng
--- DateTime: 2024-12-18 16:47
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

---@class StoreNewBlindBoxDescriptionView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field RichTextDescribe URichTextBox
---@field TableViewSlot UTableView
---@field TextAward UFTextBlock
---@field TextAwardDescribe UFTextBlock
---@field TextIntroduce UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StoreNewBlindBoxDescriptionView = LuaClass(UIView, true)

function StoreNewBlindBoxDescriptionView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm2FrameM_UIBP = nil
	--self.RichTextDescribe = nil
	--self.TableViewSlot = nil
	--self.TextAward = nil
	--self.TextAwardDescribe = nil
	--self.TextIntroduce = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StoreNewBlindBoxDescriptionView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm2FrameM_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StoreNewBlindBoxDescriptionView:OnInit()
	
	self.GoodsTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot, self.OnEquipPartSelectChanged, true, false)

	self.Binders = {
		{ "MysteryBosItemVMList", 			UIBinderUpdateBindableList.New(self, self.GoodsTableViewAdapter) },
	}

end

function StoreNewBlindBoxDescriptionView:OnDestroy()

end

function StoreNewBlindBoxDescriptionView:OnShow()
	self.TextIntroduce:SetText(LSTR(950081))	--- 盲盒介绍
	self.TextAward:SetText(LSTR(950082))		--- 奖励一览
	self.TextAwardDescribe:SetText(LSTR(950083))--- 下次购买盲盒的奖励获取概率
	
	local TempCfgData = _G.StoreMainVM.SkipTempData
	self.Comm2FrameM_UIBP:SetTitleText(TempCfgData.Name)
	self.RichTextDescribe:SetText(TempCfgData.Note)
end

function StoreNewBlindBoxDescriptionView:OnHide()

end

function StoreNewBlindBoxDescriptionView:OnRegisterUIEvent()

end

function StoreNewBlindBoxDescriptionView:OnRegisterGameEvent()

end

function StoreNewBlindBoxDescriptionView:OnRegisterBinder()
	self:RegisterBinders(_G.StoreMainVM, self.Binders)
end

return StoreNewBlindBoxDescriptionView