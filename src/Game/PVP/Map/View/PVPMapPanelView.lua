---
--- Author: peterxie
--- DateTime:
--- Description: PVP地图，PVP玩法共用 不同之处，战场指挥时小地图可以放大进行操作
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MapUtil = require("Game/Map/MapUtil")
local MapDefine = require("Game/Map/MapDefine")
local MapContentType = MapDefine.MapContentType
local LSTR = _G.LSTR


---@class PVPMapPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnExit UFButton
---@field BtnMap UFButton
---@field MaskBoxMap UMaskBox
---@field NaviMapContent NaviMapContentView
---@field PanelMap UFCanvasPanel
---@field TableViewJob UTableView
---@field ToggleBtnAttack UToggleButton
---@field ToggleBtnLimit UToggleButton
---@field ToggleBtnMuster UToggleButton
---@field ToggleBtnRetreat UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPMapPanelView = LuaClass(UIView, true)

function PVPMapPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnExit = nil
	--self.BtnMap = nil
	--self.MaskBoxMap = nil
	--self.NaviMapContent = nil
	--self.PanelMap = nil
	--self.TableViewJob = nil
	--self.ToggleBtnAttack = nil
	--self.ToggleBtnLimit = nil
	--self.ToggleBtnMuster = nil
	--self.ToggleBtnRetreat = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPMapPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.NaviMapContent)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPMapPanelView:OnInit()
	self.NaviMapContent:SetContentType(MapContentType.PVPMap)
end

function PVPMapPanelView:OnDestroy()

end

function PVPMapPanelView:OnShow()
	local MajorUIMapID = _G.MapMgr:GetUIMapID()
	local HalfWidth = MapUtil.GetPVPUIMapHalfWidth(MajorUIMapID)
	self.NaviMapContent:SetContentSize(_G.UE.FVector2D(HalfWidth * 2, HalfWidth * 2))

	if nil ~= self.MaskBoxMap then
		self.MaskBoxMap:RequestRender()
	end

	-- PVP地图，在地图层和背景层之间加了一层遮罩
	UIUtil.SetIsVisible(self.NaviMapContent.ImgMiniMapBg, true)
	UIUtil.SetIsVisible(self.NaviMapContent.ImgBG, false)
end

function PVPMapPanelView:OnHide()

end

function PVPMapPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnExit, self.OnClickedBtnExit)
	UIUtil.AddOnClickedEvent(self, self.BtnMap, self.OnClickedBtnMap)
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnAttack, self.OnToggleBtnAttackClicked)
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnRetreat, self.OnToggleBtnRetreatClicked)
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnMuster, self.OnToggleBtnMusterClicked)
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnLimit, self.OnToggleBtnLimitClicked)
end

function PVPMapPanelView:OnRegisterGameEvent()

end

function PVPMapPanelView:OnRegisterBinder()

end

function PVPMapPanelView:OnClickedBtnExit()

	local function ConfirmCallBack()
		local ProtoCS = require ("Protocol/ProtoCS")
		local ColosseumSequence = ProtoCS.ColosseumSequence
		local PVPColosseumMgr = _G.PVPColosseumMgr
		if (PVPColosseumMgr:GetSequence() ~= ColosseumSequence.COLOSSEUM_PHASE_RESULT) then
			-- 非结算阶段，判断场上人数是否满员
			if PVPColosseumMgr:IsMatchFull() then
				MsgTipsUtil.ShowTipsByID(338009)
			end
		end

		_G.PWorldMgr:SendLeavePWorld()
	end

	MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(10004), LSTR(810029), nil, ConfirmCallBack, LSTR(10002), LSTR(10003))
end

function PVPMapPanelView:OnClickedBtnMap()
	-- nothing
end


---PVP二期内容，暂未开放
function PVPMapPanelView:OnToggleBtnAttackClicked()
	MsgTipsUtil.ShowTips(LSTR(10062))
	self.ToggleBtnAttack:SetChecked(false)
end

function PVPMapPanelView:OnToggleBtnRetreatClicked()
	MsgTipsUtil.ShowTips(LSTR(10062))
	self.ToggleBtnRetreat:SetChecked(false)
end

function PVPMapPanelView:OnToggleBtnMusterClicked()
	MsgTipsUtil.ShowTips(LSTR(10062))
	self.ToggleBtnMuster:SetChecked(false)
end

function PVPMapPanelView:OnToggleBtnLimitClicked()
	MsgTipsUtil.ShowTips(LSTR(10062))
	self.ToggleBtnLimit:SetChecked(false)
end

return PVPMapPanelView