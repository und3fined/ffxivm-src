---
--- Author: peterxie
--- DateTime: 2024-06-14 09:49
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")


---@class PWorldBranchWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field TextDesc UFTextBlock
---@field TextIllustrate UFTextBlock
---@field TextState UFTextBlock
---@field TextState01 UFTextBlock
---@field TextState02 UFTextBlock
---@field TextState03 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldBranchWinView = LuaClass(UIView, true)

function PWorldBranchWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm2FrameM_UIBP = nil
	--self.TextDesc = nil
	--self.TextIllustrate = nil
	--self.TextState = nil
	--self.TextState01 = nil
	--self.TextState02 = nil
	--self.TextState03 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldBranchWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm2FrameM_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldBranchWinView:OnInit()

end

function PWorldBranchWinView:OnDestroy()

end

function PWorldBranchWinView:OnShow()
	self:InitText()
end

function PWorldBranchWinView:InitText()
	local LSTR = _G.LSTR

	self.Comm2FrameM_UIBP:SetTitleText(LSTR(800002)) -- 分线说明

	self.TextDesc:SetText(LSTR(800002)) -- 分线说明
	self.TextIllustrate:SetText(LSTR(800003))

	self.TextState:SetText(LSTR(800004)) -- 分线状态
	self.TextState01:SetText(LSTR(800005)) -- 爆满
	self.TextState02:SetText(LSTR(800006)) -- 繁忙
	self.TextState03:SetText(LSTR(800007)) -- 流畅
end

function PWorldBranchWinView:OnHide()

end

function PWorldBranchWinView:OnRegisterUIEvent()

end

function PWorldBranchWinView:OnRegisterGameEvent()

end

function PWorldBranchWinView:OnRegisterBinder()

end

return PWorldBranchWinView