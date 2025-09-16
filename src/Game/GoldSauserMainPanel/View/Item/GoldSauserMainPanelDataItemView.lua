---
--- Author: Administrator
--- DateTime: 2023-12-29 20:13
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = _G.UIViewID

---@class GoldSauserMainPanelDataItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSauserMainPanelDataItemView = LuaClass(UIView, true)

function GoldSauserMainPanelDataItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelDataItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelDataItemView:OnInit()

end

function GoldSauserMainPanelDataItemView:OnDestroy()

end

function GoldSauserMainPanelDataItemView:OnShow()

end

function GoldSauserMainPanelDataItemView:OnHide()

end

function GoldSauserMainPanelDataItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnBtnClicked)
end

function GoldSauserMainPanelDataItemView:OnRegisterGameEvent()

end

function GoldSauserMainPanelDataItemView:OnRegisterBinder()

end

function GoldSauserMainPanelDataItemView:OnBtnClicked()
	UIViewMgr:ShowView(UIViewID.GoldSauserMainPanelDataWinItem)	
end

return GoldSauserMainPanelDataItemView