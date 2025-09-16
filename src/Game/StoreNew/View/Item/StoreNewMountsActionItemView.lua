---
--- Author: ds_tianjiateng
--- DateTime: 2024-12-18 16:12
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath =  require("Binder/UIBinderSetBrushFromAssetPath")
local SkillTipsMgr = require("Game/Skill/SkillTipsMgr")

---@class StoreNewMountsActionItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSkillTis UFButton
---@field IconActionl UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StoreNewMountsActionItemView = LuaClass(UIView, true)

function StoreNewMountsActionItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSkillTis = nil
	--self.IconActionl = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StoreNewMountsActionItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StoreNewMountsActionItemView:OnInit()

	self.Binders = {
		{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.IconActionl) },
	}
end

function StoreNewMountsActionItemView:OnDestroy()

end

function StoreNewMountsActionItemView:OnShow()

end

function StoreNewMountsActionItemView:OnHide()

end

function StoreNewMountsActionItemView:OnClockBtnTips()
	local Params = {}
	Params.SkillName = self.ViewModel.SkillName
	Params.SkillTag = {}
	Params.SkillTag[1] = self.ViewModel.SkillTag
	Params.SkillInfoList = {}
	Params.SkillInfoList[1] = LSTR(1090042)..self.ViewModel.Distance..LSTR(1090044)
	Params.SkillInfoList[2] = LSTR(1090043)..self.ViewModel.Range..LSTR(1090044)
	Params.SkillInfoList[3] = "   "
	Params.SkillInfoList[4] = string.format("<span color=\"#%s\">%s</>", "C9BB9CFF", LSTR(1090045)..self.ViewModel.SingTimeDescribe)
	Params.SkillInfoList[5] = string.format("<span color=\"#%s\">%s</>", "C9BB9CFF", LSTR(1090046)..self.ViewModel.SingTime2..LSTR(1090047))
	Params.SkillInfoList[6] = "   "
	Params.SkillInfoList[7] = self.ViewModel.SkillDescribe
	Params.SkillInfoList[8] = LSTR(1090048)
	Params.SkillInfoList[9] = LSTR(1090049)
	Params.InTargetWidget = self.BtnSkillTis
	Params.IsAutoFlip = true
	Params.InfoTipGap = -40
	Params.NameColor = "FFFFFFFF"
	SkillTipsMgr:ShowMountSkillTips(Params, true)
	
	local Adapter = self.Params.Adapter
	if nil == Adapter then
		return
	end
	Adapter:OnItemClicked(self, self.Params.Index)
end

function StoreNewMountsActionItemView:OnRegisterUIEvent()

end

function StoreNewMountsActionItemView:OnRegisterGameEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSkillTis, self.OnClockBtnTips)
end

function StoreNewMountsActionItemView:OnRegisterBinder()
	if nil == self.Params or  nil == self.Params.Data then
		return
	end
	local ViewModel = self.Params.Data
	self.ViewModel = ViewModel
	self:RegisterBinders(ViewModel, self.Binders)
end

return StoreNewMountsActionItemView