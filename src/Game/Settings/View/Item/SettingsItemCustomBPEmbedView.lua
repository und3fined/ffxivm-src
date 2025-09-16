---
--- Author: chriswang
--- DateTime: 2025-03-10 20:31
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class SettingsItemCustomBPEmbedView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BPContainer UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SettingsItemCustomBPEmbedView = LuaClass(UIView, true)

function SettingsItemCustomBPEmbedView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BPContainer = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SettingsItemCustomBPEmbedView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SettingsItemCustomBPEmbedView:OnInit()

end

function SettingsItemCustomBPEmbedView:OnDestroy()

end

function SettingsItemCustomBPEmbedView:OnShow()
	if nil == self.Params or nil == self.Params.Data then
		return
	end

	self.ItemVM = self.Params.Data
	local BPPath = self.ItemVM.NoTranslateStr
	if not string.isnilorempty(BPPath) then
		self.ChildBPView = _G.UIViewMgr:CreateViewByName(BPPath, nil, nil, true, true)
		self.BPContainer:AddChildToCanvas(self.ChildBPView)

		local Anchor = _G.UE.FAnchors()
		Anchor.Minimum = _G.UE.FVector2D(0.5, 0)
		Anchor.Maximum = _G.UE.FVector2D(0.5, 0)
		UIUtil.CanvasSlotSetAnchors(self.ChildBPView, Anchor)
		UIUtil.CanvasSlotSetAlignment(self.ChildBPView, _G.UE.FVector2D(0.5, 0))

		UIUtil.CanvasSlotSetAutoSize(self.ChildBPView, true)
	end
end

function SettingsItemCustomBPEmbedView:OnHide()
	if self.ChildBPView then
		self.BPContainer:RemoveChild(self.ChildBPView)
		_G.UIViewMgr:RecycleView(self.ChildBPView)
		self.ChildBPView = nil
	end
end

function SettingsItemCustomBPEmbedView:OnRegisterUIEvent()

end

function SettingsItemCustomBPEmbedView:OnRegisterGameEvent()

end

function SettingsItemCustomBPEmbedView:OnRegisterBinder()

end

return SettingsItemCustomBPEmbedView