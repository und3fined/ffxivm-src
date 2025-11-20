---
--- Author: Administrator
--- DateTime: 2025-07-16 14:16
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local RoleInitCfg = require("TableCfg/RoleInitCfg")

local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class PVPCrystallineLeaderBoardJobItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ContentNode UFCanvasPanel
---@field IconProf UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPCrystallineLeaderBoardJobItemView = LuaClass(UIView, true)

function PVPCrystallineLeaderBoardJobItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ContentNode = nil
	--self.IconProf = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPCrystallineLeaderBoardJobItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPCrystallineLeaderBoardJobItemView:OnInit()

end

function PVPCrystallineLeaderBoardJobItemView:OnDestroy()

end

function PVPCrystallineLeaderBoardJobItemView:OnShow()

end

function PVPCrystallineLeaderBoardJobItemView:OnHide()

end

function PVPCrystallineLeaderBoardJobItemView:OnRegisterUIEvent()

end

function PVPCrystallineLeaderBoardJobItemView:OnRegisterGameEvent()

end

function PVPCrystallineLeaderBoardJobItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end

	local ViewModel = Params.Data
	if nil == ViewModel then return end

	local Binders = {
		{ "ProfID", UIBinderValueChangedCallback.New(self, nil, self.OnProfIDChanged) },
	}

	self:RegisterBinders(ViewModel, Binders)
end

function PVPCrystallineLeaderBoardJobItemView:OnProfIDChanged(NewValue, OldValue)
	if NewValue == nil or NewValue == 0 then return end

	local Cfg = RoleInitCfg:FindCfgByKey(NewValue)
	if Cfg == nil then return end

	UIUtil.ImageSetBrushFromAssetPath(self.IconProf, Cfg.SimpleIcon2)
end

return PVPCrystallineLeaderBoardJobItemView