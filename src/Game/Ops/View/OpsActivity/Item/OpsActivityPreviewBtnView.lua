---
--- Author: yutingzhan
--- DateTime: 2024-11-22 17:13
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class OpsActivityPreviewBtnView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnView UFButton
---@field Text01 UFTextBlock
---@field Text02 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsActivityPreviewBtnView = LuaClass(UIView, true)

function OpsActivityPreviewBtnView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnView = nil
	--self.Text01 = nil
	--self.Text02 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsActivityPreviewBtnView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsActivityPreviewBtnView:OnInit()
	
end

function OpsActivityPreviewBtnView:SetTitleText(TitleText)
	if TitleText == nil then
		UIUtil.SetIsVisible(self.Text01, false)
		return 
	end
	self.Text01:SetText(TitleText)
end

function OpsActivityPreviewBtnView:SetSubTitleText(SubTitleText)
	if SubTitleText == nil then
		UIUtil.SetIsVisible(self.Text02, false)
		return 
	end
	self.Text02:SetText(SubTitleText)
end

function OpsActivityPreviewBtnView:OnDestroy()

end

function OpsActivityPreviewBtnView:OnShow()

end

function OpsActivityPreviewBtnView:OnHide()

end

function OpsActivityPreviewBtnView:OnRegisterUIEvent()

end

function OpsActivityPreviewBtnView:OnRegisterGameEvent()

end

function OpsActivityPreviewBtnView:OnRegisterBinder()

end

return OpsActivityPreviewBtnView