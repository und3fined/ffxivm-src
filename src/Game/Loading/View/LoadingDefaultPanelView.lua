---
--- Author: loiafeng
--- DateTime: 2024-05-11 13:24
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local LoadingMgr = require("Game/Loading/LoadingMgr")

---@class LoadingDefaultPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoadingDefaultPanelView = LuaClass(UIView, true)

function LoadingDefaultPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoadingDefaultPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoadingDefaultPanelView:OnInit()

end

function LoadingDefaultPanelView:OnDestroy()

end

function LoadingDefaultPanelView:OnShow()

end

function LoadingDefaultPanelView:OnHide()
	if LoadingMgr:IsLoadingView() then
		-- LoadingUI有可能被UIViewMgr通过其他途径关闭，故这里需要主动通知LoadingMgr
		LoadingMgr:HideLoadingView()
	end
end

function LoadingDefaultPanelView:OnRegisterUIEvent()

end

function LoadingDefaultPanelView:OnRegisterGameEvent()

end

function LoadingDefaultPanelView:OnRegisterBinder()

end

return LoadingDefaultPanelView