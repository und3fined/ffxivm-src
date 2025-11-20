---
--- Author: Administrator
--- DateTime: 2025-07-28 11:14
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoRes = require("Protocol/ProtoRes")
local UIViewID = require("Define/UIViewID")
local PVPInfoDefine = require("Game/PVP/PVPInfoDefine")
local WidgetPoolMgr = require("UI/WidgetPoolMgr")

local CrystallineRankCfg = require("TableCfg/CrystallineRankCfg")
local CrystallineParamCfg = require("TableCfg/CrystallineParamCfg")

local LSTR = _G.LSTR
local UIViewMgr = _G.UIViewMgr
local PVPInfoMgr = _G.PVPInfoMgr

local UE = _G.UE
local Anchor = UE.FAnchors()
Anchor.Minimum = UE.FVector2D(0.5, 0.5)
Anchor.Maximum = UE.FVector2D(0.5, 0.5)
local Alignment = UE.FVector2D(0.5, 0.5)
local Margin = UE.FMargin()
Margin.Left = 0
Margin.Top = 0
Margin.Right = 700
Margin.Bottom = 540

---@class PVPColosseumDanView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonBkg02 CommonBkg02View
---@field CommonBkgMask CommonBkgMaskView
---@field CommonPopUpBG CommonPopUpBGView
---@field PVPColosseumStar1 PVPColosseumStarItemView
---@field PVPColosseumStar2 PVPColosseumStarItemView
---@field PVPColosseumStar3 PVPColosseumStarItemView
---@field PanelDan UFCanvasPanel
---@field TextContinue UFTextBlock
---@field TextCrystal UFTextBlock
---@field TextDan UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPColosseumDanView = LuaClass(UIView, true)

function PVPColosseumDanView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonBkg02 = nil
	--self.CommonBkgMask = nil
	--self.CommonPopUpBG = nil
	--self.PVPColosseumStar1 = nil
	--self.PVPColosseumStar2 = nil
	--self.PVPColosseumStar3 = nil
	--self.PanelDan = nil
	--self.TextContinue = nil
	--self.TextCrystal = nil
	--self.TextDan = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPColosseumDanView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonBkg02)
	self:AddSubView(self.CommonBkgMask)
	self:AddSubView(self.CommonPopUpBG)
	self:AddSubView(self.PVPColosseumStar1)
	self:AddSubView(self.PVPColosseumStar2)
	self:AddSubView(self.PVPColosseumStar3)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPColosseumDanView:OnInit()
	self.CommonPopUpBG:SetCallback(self, self.CloseUI)
	local Cfg = CrystallineParamCfg:FindCfgByKey(ProtoRes.Game.game_pvpcolosseum_params_id.PVPCOLOSSEUM_RANK_SHOWTIME)
	self.CountDownTime = (Cfg and Cfg.Value[1] or 3) + 1	-- 加一秒是因为OnTimer触发了才设置文本，OnTimer触发马上会减一秒，所以把第一秒补回来显示
	self.RemainTime = self.CountDownTime
end

function PVPColosseumDanView:OnDestroy()

end

function PVPColosseumDanView:OnShow()
	local Params = self.Params
	if Params == nil then return end

	local OldRank = Params.OldRank
	local OldPoint = Params.OldCrystalPoint or 0
	local NewRank = Params.NewRank
	local NewPoint = Params.NewCrystalPoint or 0

	local OldRankCfg = CrystallineRankCfg:FindCfgByKey(OldRank)
	local NewRankCfg = CrystallineRankCfg:FindCfgByKey(NewRank)
	if OldRankCfg == nil or NewRankCfg == nil then return end

	self:SetFixText()
	self:SetTitle(OldRankCfg.ResultMode)
	self:CreateRankBP(OldRankCfg.Type, NewRankCfg.Type)
	self:SetRankName(OldRankCfg.RankName)
	self:SetWinStarScore(OldRankCfg, OldPoint)
	--self:PlayAnimRankChange(OldRank, OldPoint, NewRank, NewPoint)
end

function PVPColosseumDanView:OnHide()
	self:RemoveCloseTimer()
	self.RemainTime = self.CountDownTime

	if self.OldRankWidget then
		self.PanelDan:ClearChildren()
		WidgetPoolMgr:RecycleWidget(self.OldRankWidget)
		self.OldRankWidget = nil
	end
	if self.NewRankWidget then
		self.PanelDan:ClearChildren()
		WidgetPoolMgr:RecycleWidget(self.NewRankWidget)
		self.NewRankWidget = nil
	end
end

function PVPColosseumDanView:OnRegisterUIEvent()

end

function PVPColosseumDanView:OnRegisterGameEvent()

end

function PVPColosseumDanView:OnRegisterTimer()
	self:AddCloseTimer()
end

function PVPColosseumDanView:OnRegisterBinder()

end

function PVPColosseumDanView:SetFixText()
	self.TextCrystal:SetText(LSTR(810050))
end

function PVPColosseumDanView:SetTitle(ResultMode)
	local Text = ResultMode == ProtoRes.Game.pvp_rank_result_mode.RRM_WINSTAR and LSTR(810047) or LSTR(810049)
	self.TextTitle:SetText(Text)
end

function PVPColosseumDanView:CreateRankBP(OldRankType, NewRankType)
	local function CreateBP(BPPath)
		if not string.isnilorempty(BPPath) then
			local function OnComplete(Widget)
				if Widget then
					if UE.UCommonUtil.IsObjectValid(self.PanelDan) then
						self.PanelDan:AddChildToCanvas(Widget)
						UIUtil.CanvasSlotSetAnchors(Widget, Anchor)
						UIUtil.CanvasSlotSetAlignment(Widget, Alignment)
						UIUtil.CanvasSlotSetOffsets(Widget, Margin)
						self:AddSubView(Widget)
						return Widget
					else
						WidgetPoolMgr:RecycleWidget(Widget)
					end
				end
			end
	
			WidgetPoolMgr:CreateWidgetAsyncByName(BPPath, nil, OnComplete, true, true)
		end
	end

	local OldRankBP = PVPInfoDefine.RankBPMap[OldRankType]
	local NewRankBP = PVPInfoDefine.RankBPMap[NewRankType]
	self.OldRankWidget = CreateBP(OldRankBP)
	self.NewRankWidget = CreateBP(NewRankBP)
end

function PVPColosseumDanView:SetRankName(RankName)
	self.TextDan:SetText(RankName)
end

function PVPColosseumDanView:SetWinStarScore(Rank, Point)
	local IsWinStar = Rank.ResultMode == ProtoRes.Game.pvp_rank_result_mode.RRM_WINSTAR

	for Index = 1, PVPInfoMgr:GetCrystallineRankWinStarMax() do
		local VariableName = "PVPColosseumStar" .. Index
		UIUtil.SetIsVisible(self[VariableName], IsWinStar)

		if IsWinStar then
			local StarGlow = Rank.WinStar >= Index
			self[VariableName]:SetStarGlow(StarGlow)
		end
	end
end

function PVPColosseumDanView:PlayAnimRankChange(OldRank, NewRank)

end

function PVPColosseumDanView:SequenceEvent_()
	
end

function PVPColosseumDanView:OnTimer()
	self.RemainTime = self.RemainTime - 1

	self.TextContinue:SetTExt(string.format(LSTR(810048), self.RemainTime))

	if self.RemainTime <= 0 then
		self:CloseUI()
	end
end

function PVPColosseumDanView:AddCloseTimer()
	self:RemoveCloseTimer()
	self.CloseTimerID = self:RegisterTimer(self.OnTimer, 0, 1, 0)
end

function PVPColosseumDanView:RemoveCloseTimer()
	if self.CloseTimerID then
		self:UnRegisterTimer(self.CloseTimerID)
		self.CloseTimerID = nil
	end
end

function PVPColosseumDanView:CloseUI()
	self:Hide()

	local IsShowGameResult = self.Params and self.Params.IsShowGameResult
	if IsShowGameResult then
		UIViewMgr:ShowView(UIViewID.PVPColosseumRecord)
	end
end

return PVPColosseumDanView