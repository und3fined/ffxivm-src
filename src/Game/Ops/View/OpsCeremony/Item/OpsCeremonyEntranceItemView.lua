---
--- Author: usakizhang
--- DateTime: 2025-02-28 15:16
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local OpsCeremonyEntranceItemVM = require("Game/Ops/VM/OpsCeremony/OpsCeremonyEntranceItemVM")
---@class OpsCeremonyEntranceItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnProm UFButton
---@field Icon UFImage
---@field IconLock UFImage
---@field IconPassedProm UFImage
---@field IconProm USizeBox
---@field IconTaskProm UFImage
---@field RedDot CommonRedDotView
---@field TextTime UFTextBlock
---@field TextTitleProm UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsCeremonyEntranceItemView = LuaClass(UIView, true)

function OpsCeremonyEntranceItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnProm = nil
	--self.Icon = nil
	--self.IconLock = nil
	--self.IconPassedProm = nil
	--self.IconProm = nil
	--self.IconTaskProm = nil
	--self.RedDot = nil
	--self.TextTime = nil
	--self.TextTitleProm = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsCeremonyEntranceItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsCeremonyEntranceItemView:OnInit()
	--self.ItemVM = RedDotItemVM.New()
	if not self.ItemVM then
		self.ItemVM = _G.ObjectPoolMgr:AllocObject(OpsCeremonyEntranceItemVM)
	end
	self.ItemVM:Reset()
	if self.Binders == nil then
		self.Binders = {
			{ "IsLock", UIBinderSetIsVisible.New(self, self.IconLock)},
			{ "IconPromVisible", UIBinderSetIsVisible.New(self, self.IconTaskProm) },
			{ "TextTitleProm", UIBinderSetText.New(self, self.TextTitleProm) },
			{ "StartTime", UIBinderSetText.New(self,self.TextTime) },
			{ "StartTimeVisible", UIBinderSetIsVisible.New(self, self.TextTime) },
			{ "IconPassedPromVisible", UIBinderSetIsVisible.New(self, self.IconPassedProm) },
			{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.Icon)},
			{ "RedDotName", UIBinderValueChangedCallback.New(self, nil, self.OnRedDotNameChanged) },
			{ "RedDotStyle", UIBinderValueChangedCallback.New(self, nil, self.OnRedDotStyleChanged) },
		}
	end
end

function OpsCeremonyEntranceItemView:OnDestroy()
	_G.ObjectPoolMgr:FreeObject(OpsCeremonyEntranceItemVM, self.ItemVM)
	self.ItemVM = nil
end

function OpsCeremonyEntranceItemView:OnShow()

end

function OpsCeremonyEntranceItemView:OnHide()

end

function OpsCeremonyEntranceItemView:OnRegisterUIEvent()

end

function OpsCeremonyEntranceItemView:OnRegisterGameEvent()

end

function OpsCeremonyEntranceItemView:OnRegisterBinder()
	if self.ItemVM then
		self:RegisterBinders(self.ItemVM, self.Binders)
	end
end

function OpsCeremonyEntranceItemView:Update(Params)
	if self.ItemVM then
		self.ItemVM:Update(Params)
	end
end
function OpsCeremonyEntranceItemView:OnRedDotNameChanged(RedDotName)
	self.RedDot:SetRedDotNameByString(RedDotName)
end

function OpsCeremonyEntranceItemView:OnRedDotStyleChanged(RedDotStyle)
	if RedDotStyle then
		self.RedDot:SetStyle(RedDotStyle)
	end
end
return OpsCeremonyEntranceItemView