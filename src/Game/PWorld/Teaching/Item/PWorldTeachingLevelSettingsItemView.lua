---
--- Author: ashyuan
--- DateTime: 2024-05-23 11:08
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local UIInteractiveUtil = require("Game/PWorld/UIInteractive/UIInteractiveUtil")

local TeachingMgr = _G.TeachingMgr

---@class PWorldTeachingLevelSettingsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSettings UFButton
---@field IconSettings1 UFImage
---@field IconSettings2 UFImage
---@field Panel UFCanvasPanel
---@field PanelCountDown UFCanvasPanel
---@field TextTime UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldTeachingLevelSettingsItemView = LuaClass(UIView, true)

function PWorldTeachingLevelSettingsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSettings = nil
	--self.IconSettings1 = nil
	--self.IconSettings2 = nil
	--self.Panel = nil
	--self.PanelCountDown = nil
	--self.TextTime = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldTeachingLevelSettingsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldTeachingLevelSettingsItemView:OnInit()
end

function PWorldTeachingLevelSettingsItemView:OnDestroy()
end

function PWorldTeachingLevelSettingsItemView:OnShow()
	UIUtil.SetIsVisible(self.PanelCountDown, false)
	self:OnPWorldTeachingStateChange()
end

function PWorldTeachingLevelSettingsItemView:OnHide()

end

function PWorldTeachingLevelSettingsItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSettings, self.OnClickedSettings)
end

function PWorldTeachingLevelSettingsItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.PWorldTeachingStateChange, self.OnPWorldTeachingStateChange)
end

function PWorldTeachingLevelSettingsItemView:OnRegisterBinder()
end

function PWorldTeachingLevelSettingsItemView:OnClickedSettings()
	local bIsInChallenge = TeachingMgr:IsInTeaching()
	if bIsInChallenge then
		local function Callback()
			-- 这里需要给服务器发消息停掉当前挑战
			UIInteractiveUtil.SendInteractiveReq(300073)
			TeachingMgr:FinishCurrentChallenge()
		end
		MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(890026), LSTR(890027), Callback, nil, LSTR(890020),  LSTR(890021))
	else
		-- 没有挑战的时候弹出选择界面
		TeachingMgr:OnShowMainWindow()
	end
end

function PWorldTeachingLevelSettingsItemView:OnPWorldTeachingStateChange()
	local bIsInChallenge = TeachingMgr:IsInTeaching()
	UIUtil.SetIsVisible(self.IconSettings1, bIsInChallenge)
	UIUtil.SetIsVisible(self.IconSettings2, not bIsInChallenge)
end

return PWorldTeachingLevelSettingsItemView