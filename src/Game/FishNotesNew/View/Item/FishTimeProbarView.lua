--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2025-02-17 14:36:05
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2025-02-17 18:06:27
FilePath: \Client\Source\Script\Game\FishNotesNew\View\Item\FishTimeProbarView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
---
--- Author: v_vvxinchen
--- DateTime: 2025-02-17 14:36
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class FishTimeProbarView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelProBar UFCanvasPanel
---@field ProBarCD UProgressBar
---@field AnimProBar UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishTimeProbarView = LuaClass(UIView, true)

function FishTimeProbarView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelProBar = nil
	--self.ProBarCD = nil
	--self.AnimProBar = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishTimeProbarView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishTimeProbarView:OnInit()

end

function FishTimeProbarView:OnDestroy()

end

function FishTimeProbarView:OnShow()

end

function FishTimeProbarView:OnHide()

end

function FishTimeProbarView:OnRegisterUIEvent()

end

function FishTimeProbarView:OnRegisterGameEvent()

end

function FishTimeProbarView:OnRegisterBinder()

end

function FishTimeProbarView:SetAnimProBar(Progress, OldProgress)
	if Progress == nil then
		self:PlayAnimationTimeRange(self.AnimProBar, 1, 1.01, 1, nil, 1.0, false)
		return
	end
	if (Progress + 0.01) >= 1 then
		self:PlayAnimationTimeRange(self.AnimProBar, 0, 0.001, 1, nil, 1.0, false)
		return
	end
	OldProgress = OldProgress or Progress + 0.01
	self:PlayAnimationTimeRange(self.AnimProBar, 1-OldProgress, 1-Progress, 1, nil, 1.0, false)
end

return FishTimeProbarView