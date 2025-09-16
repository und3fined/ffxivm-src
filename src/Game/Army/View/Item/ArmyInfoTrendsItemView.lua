---
--- Author: qibaoyiyi
--- DateTime: 2023-03-20 09:33
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class ArmyInfoTrendsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgTrendsBG UFImage
---@field ImgTrendsIcon UFImage
---@field RichTextNews URichTextBox
---@field RichTextTime URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyInfoTrendsItemView = LuaClass(UIView, true)

--local LastShowIndex = 0

function ArmyInfoTrendsItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgTrendsBG = nil
	--self.ImgTrendsIcon = nil
	--self.RichTextNews = nil
	--self.RichTextTime = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyInfoTrendsItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyInfoTrendsItemView:OnInit()
    self.Binders = {
        {"LogContent", UIBinderSetText.New(self, self.RichTextNews)},
        {"LogTime", UIBinderSetText.New(self, self.RichTextTime)},
		{"LogIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgTrendsIcon)},
		{"IsCloseBG", UIBinderSetIsVisible.New(self, self.ImgTrendsBG, true)},
    }
end

function ArmyInfoTrendsItemView:OnDestroy()
end

function ArmyInfoTrendsItemView:OnShow()
    local Params = self.Params
    if nil == Params then
        return
    end
    if _G.ArmyMgr:GetLogsCount() - Params.Index == 0 then
        _G.ArmyMgr:SendGetArmyLogsMsg()
    end
end

function ArmyInfoTrendsItemView:OnHide()
end

function ArmyInfoTrendsItemView:OnRegisterUIEvent()
end

function ArmyInfoTrendsItemView:OnRegisterGameEvent()
end

function ArmyInfoTrendsItemView:OnRegisterBinder()
    local Params = self.Params
	if nil == Params then
		return
	end
	local VM = Params.Data
	if nil == VM then
		return
	end
	self.ViewModel = VM
    self:RegisterBinders(self.ViewModel, self.Binders)
end

return ArmyInfoTrendsItemView
