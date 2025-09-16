---
--- Author: loiafeng
--- DateTime: 2024-05-09 10:33
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local LoadingMgr = require("Game/Loading/LoadingMgr")
local LoadingVM = require("Game/Loading/LoadingVM")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetImageBrushSync = require("Binder/UIBinderSetImageBrushSync")

---@class LoadingMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBG UFImage
---@field ProBar LoadingProBarItemView
---@field TextBody UFTextBlock
---@field TextSubTitle UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoadingMainPanelView = LuaClass(UIView, true)

function LoadingMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBG = nil
	--self.ProBar = nil
	--self.TextBody = nil
	--self.TextSubTitle = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoadingMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ProBar)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoadingMainPanelView:OnInit()
	self.Binders = {
		{ "DisplayName", UIBinderSetText.New(self, self.TextTitle) },
		{ "RegionName", UIBinderSetText.New(self, self.TextSubTitle) },
		{ "TextBody", UIBinderSetText.New(self, self.TextBody) },
		{ "MainImage", UIBinderSetImageBrushSync.New(self, self.ImgBG) },
	}
end

function LoadingMainPanelView:OnDestroy()

end

function LoadingMainPanelView:OnShow()

end

function LoadingMainPanelView:OnHide()
	if LoadingMgr:IsLoadingView() then
		-- LoadingUI有可能被UIViewMgr通过其他途径关闭，故这里需要主动通知LoadingMgr
		LoadingMgr:HideLoadingView()
	end
end

function LoadingMainPanelView:OnRegisterUIEvent()

end

function LoadingMainPanelView:OnRegisterGameEvent()

end

function LoadingMainPanelView:OnRegisterBinder()
	self:RegisterBinders(LoadingVM, self.Binders)
end

return LoadingMainPanelView