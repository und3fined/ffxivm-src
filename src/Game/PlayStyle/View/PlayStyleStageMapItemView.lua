---
--- Author: Administrator
--- DateTime: 2024-04-28 14:43
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local GoldSauserMgr = require("Game/Gate/GoldSauserMgr")
local GoldSauseGateCfg = require("TableCfg/GoldSauserGateCfg")
local TimeUtil = require("Utils/TimeUtil")
local MapDefine = require("Game/Map/MapDefine")
local LocalizationUtil = require("Utils/LocalizationUtil")

local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID
local BuoyMgr = _G.BuoyMgr


---@class PlayStyleStageMapItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnTrack UFButton
---@field ImgIcon UFImage
---@field ImgTrackIcon UFImage
---@field PanelTips UFCanvasPanel
---@field TextNPCWaiting UFTextBlock
---@field TextName UFTextBlock
---@field TextProgress UFTextBlock
---@field TextTime UFTextBlock
---@field TimeProgressPanel UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PlayStyleStageMapItemView = LuaClass(UIView, true)

function PlayStyleStageMapItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnTrack = nil
	--self.ImgIcon = nil
	--self.ImgTrackIcon = nil
	--self.PanelTips = nil
	--self.TextNPCWaiting = nil
	--self.TextName = nil
	--self.TextProgress = nil
	--self.TextTime = nil
	--self.TimeProgressPanel = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PlayStyleStageMapItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PlayStyleStageMapItemView:OnInit()

end

function PlayStyleStageMapItemView:OnDestroy()

end

function PlayStyleStageMapItemView:OnShow()
	local Params = self.Params
	if Params == nil then
		return
	end
	self:HideNoNeedView()

	local bShowRight = Params.ID == 1 -- 1表示NPC，2表示小雏鸟的雏鸟
	UIUtil.SetIsVisible(self.CanvasFollow, bShowRight, true)

	local ID = Params.EntertainID
	local Cfg = GoldSauseGateCfg:FindCfgByKey(ID)
	if Cfg == nil then
		_G.FLOG_ERROR("错误，无法获取机遇临门数据，ID是："..tostring(ID))
		return
	end

	self.TextName:SetText(Cfg.GameName)

	local function CountDown()
		local SignUpEndTime = GoldSauserMgr.SignUpEndTime
		if (SignUpEndTime == nil) then
			return
		end
		local ServerTime = TimeUtil.GetServerTimeMS()
		local RemainTime = SignUpEndTime - ServerTime
		local RemainSec = math.floor(RemainTime / 1000)
		-- local ReaminMin = math.floor(RemainSec / 60)
		-- local RemianSecForShow  = RemainSec % 60
		local EndShowTime = LocalizationUtil.GetCountdownTimeForShortTime(RemainSec, "mm:ss")

		-- if RemianSecForShow >= 10 then
		-- 	EndShowTime = string.format("0%s:%s", ReaminMin, RemianSecForShow)
		-- else
		-- 	EndShowTime = string.format("0%s:0%s", ReaminMin, RemianSecForShow)
		-- end
		
		if RemainTime <= 0 and self.CountDownTimer ~= nil then
			self:UnRegisterTimer(self.CountDownTimer)
			self.CountDownTimer = nil
			self:Hide()
		end

		self.TextTime:SetText(EndShowTime)
	end
	self.CountDownTimer = self:RegisterTimer(CountDown, 0, 0.2, 0)

	local IconPath
	if BuoyMgr:GetGoldGameNPCFollowInfo() then
		IconPath = MapDefine.MapFollowStateIconPath.Following
	else
		IconPath = MapDefine.MapFollowStateIconPath.UnFollow
	end
	UIUtil.ImageSetBrushFromAssetPath(self.ImgTrackIcon, IconPath)
end

function PlayStyleStageMapItemView:OnHide()
	if self.CountDownTimer ~= nil then
		self:UnRegisterTimer(self.CountDownTimer)
	end
end

function PlayStyleStageMapItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnTrack, self.OnClickedFollow)
end

function PlayStyleStageMapItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.MapOnRemoveMarker, self.OnGameEventRemoveMarker)
end

function PlayStyleStageMapItemView:OnRegisterBinder()

end

function PlayStyleStageMapItemView:OnGameEventRemoveMarker(Params)
	-- local Marker = Params.Marker
	-- if Marker.FateID == self.FateID then
	-- 	_G.FLOG_INFO("[fate] Hide map item view")
	-- 	UIViewMgr:HideView(UIViewID.WorldMapMarkerFateStageInfoPanel)
	-- end
end

function PlayStyleStageMapItemView:HideNoNeedView()
	UIUtil.SetIsVisible(self.ImgIcon, false)
	UIUtil.SetIsVisible(self.TextProgress, false)
	UIUtil.SetIsVisible(self.TextNPCWaiting, false)
end

function PlayStyleStageMapItemView:OnClickedFollow()
	if BuoyMgr:GetGoldGameNPCFollowInfo() then
		BuoyMgr:SetGoldGameNPCFollowState(false)
	else
		BuoyMgr:SetGoldGameNPCFollowState(true)
	end

	UIViewMgr:HideView(UIViewID.WorldMapMarkerPlayStyleStageInfo)
end

return PlayStyleStageMapItemView