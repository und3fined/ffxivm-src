---
--- Author: Administrator
--- DateTime: 2023-10-07 20:52
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local GoldSauserDefine = require("Game/Gate/GoldSauserDefine")
local LSTR = _G.LSTR
local TimerMgr = _G.TimerMgr
local FVector2D = _G.UE.FVector2D
local PWorldMgr = _G.PWorldMgr

local MapLoadStatus = {
    Loading = 1,
    Finish = 2,
}

---@class PlayStyleLoadingPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBG UFImage
---@field ImgCactus UFImage
---@field ImgProfilePic UFImage
---@field PanelContent01 UFCanvasPanel
---@field PanelContent02 UFCanvasPanel
---@field PanelPlayStyleIntroduce UFCanvasPanel
---@field PanelPlayStyleLoading UFCanvasPanel
---@field PanelProbar UFCanvasPanel
---@field PopUpBG CommonPopUpBGView
---@field ProBarLoading UProgressBar
---@field TextDescribe UFTextBlock
---@field TextPlayStyle UFTextBlock
---@field TextProfileDescribe UFTextBlock
---@field TextProfileTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PlayStyleLoadingPanelView = LuaClass(UIView, true)

function PlayStyleLoadingPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBG = nil
	--self.ImgCactus = nil
	--self.ImgProfilePic = nil
	--self.PanelContent01 = nil
	--self.PanelContent02 = nil
	--self.PanelPlayStyleIntroduce = nil
	--self.PanelPlayStyleLoading = nil
	--self.PanelProbar = nil
	--self.PopUpBG = nil
	--self.ProBarLoading = nil
	--self.TextDescribe = nil
	--self.TextPlayStyle = nil
	--self.TextProfileDescribe = nil
	--self.TextProfileTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PlayStyleLoadingPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PlayStyleLoadingPanelView:OnInit()

end

function PlayStyleLoadingPanelView:OnDestroy()

end

function PlayStyleLoadingPanelView:OnShow()
	-- self.bCanFinish = false
	self.PopUpBG:SetHideOnClick(false)

	local Params = self.Params
	self:SetLoadingStyleVisible(Params.bAirForceBgVisible)

	local GateRuleDesc = GoldSauserDefine.GateRuleDesc
	self.TextPlayStyle:SetText(LSTR("机遇临门"))
	self.TextDescribe:SetText(GateRuleDesc.Desc1)

	self.TextProfileTitle:SetText(LSTR("机遇临门"))
	self.TextProfileDescribe:SetText(GateRuleDesc.Desc2)
	self.ProBarLoading:SetPercent(0)

	local Size = UIUtil.CanvasSlotGetSize(self.PanelProbar)
	local OffsetX = 70
	local TotleLength = Size.X - OffsetX
	local OffsetY = -35
	self.CurPositionX = -TotleLength / 2
	UIUtil.CanvasSlotSetPosition(self.ImgCactus, FVector2D(self.CurPositionX, OffsetY))
	self.CurProgress = 0
	self.UpdateTimer = TimerMgr:AddTimer(self, self.UpdateProBar, 0.1, 0.1, 100, TotleLength) --10秒
end

function PlayStyleLoadingPanelView:OnHide()

end

function PlayStyleLoadingPanelView:OnRegisterUIEvent()

end

function PlayStyleLoadingPanelView:OnRegisterGameEvent()
	--self:RegisterGameEvent(EventID.GoldSauserCommFinishProBar, self.FinishUpdate)
end

function PlayStyleLoadingPanelView:OnRegisterBinder()

end

function PlayStyleLoadingPanelView:SetLoadingStyleVisible(bVisible)
	UIUtil.SetIsVisible(self.PanelPlayStyleLoading, bVisible)
	UIUtil.SetIsVisible(self.PanelPlayStyleIntroduce, not bVisible)
end

--- @type 更新进度条与Img位置
function PlayStyleLoadingPanelView:UpdateProBar(TotleLength)
	-- if PWorldMgr:IsLoadingWorld() then
	self.CurProgress = self.CurProgress + 0.01
	self.ProBarLoading:SetPercent(self.CurProgress)

	local OffsetY = -35
	self.CurPositionX = -TotleLength / 2 + TotleLength * self.CurProgress
	UIUtil.CanvasSlotSetPosition(self.ImgCactus, FVector2D(self.CurPositionX, OffsetY))
	self.bCanFinish = true
	-- end

	local MapTravelInfo = PWorldMgr.MapTravelInfo
	local TravelStatus = MapTravelInfo.TravelStatus
	if TravelStatus == MapLoadStatus.Finish then
		self:FinishUpdate()
	end
end

function PlayStyleLoadingPanelView:FinishUpdate()
	if self.UpdateTimer then
		TimerMgr:CancelTimer(self.UpdateTimer)
	end
	self.ProBarLoading:SetPercent(1)

	local OffsetY = -35
	local Size = UIUtil.CanvasSlotGetSize(self.PanelProbar)
	local OffsetX = 70
	local TotleLength = Size.X - OffsetX
	local NeedPosX = TotleLength / 2
	UIUtil.CanvasSlotSetPosition(self.ImgCactus, FVector2D(NeedPosX, OffsetY))
	TimerMgr:AddTimer(self, self.ShowGateOppoPanel, 0.1, 0, 1, TotleLength)
end

function PlayStyleLoadingPanelView:ShowGateOppoPanel()
	self:Hide()

end

return PlayStyleLoadingPanelView