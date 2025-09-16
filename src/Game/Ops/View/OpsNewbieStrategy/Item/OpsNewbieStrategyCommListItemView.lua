---
--- Author: Administrator
--- DateTime: 2024-11-18 14:23
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")

---@class OpsNewbieStrategyCommListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommBtn CommBtnSView
---@field Icon UFImage
---@field Text UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsNewbieStrategyCommListItemView = LuaClass(UIView, true)

function OpsNewbieStrategyCommListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommBtn = nil
	--self.Icon = nil
	--self.Text = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsNewbieStrategyCommListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsNewbieStrategyCommListItemView:OnInit()
	self.Binders = 
	{
		{ "ContentText", UIBinderSetText.New(self, self.Text)},
		{ "Icon", UIBinderSetImageBrush.New(self, self.Icon)},
	}
end

function OpsNewbieStrategyCommListItemView:OnDestroy()

end

function OpsNewbieStrategyCommListItemView:OnShow()
	-- LSTR string:前往
	self.CommBtn:SetText(LSTR(920002))
end

function OpsNewbieStrategyCommListItemView:OnHide()

end

function OpsNewbieStrategyCommListItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.CommBtn, self.OnClickedCommBtn)

end

function OpsNewbieStrategyCommListItemView:OnClickedCommBtn()
	local Params = self.Params
	if Params == nil then
		return
	end
	local VM = Params.Data
	if VM == nil then
		return
	end
	VM:Jump()
end

function OpsNewbieStrategyCommListItemView:OnRegisterGameEvent()

end

function OpsNewbieStrategyCommListItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end
	local VM = Params.Data
	if VM == nil then
		return
	end
	self:RegisterBinders(VM, self.Binders)
end

return OpsNewbieStrategyCommListItemView