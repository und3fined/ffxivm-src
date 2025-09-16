---
--- Author: Administrator
--- DateTime: 2023-09-07 17:06
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TimeUtil = require("Utils/TimeUtil")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local GuideCfg = require("TableCfg/GuideCfg")
local GuideTypeCfg = require("TableCfg/GuideTypeCfg")

---@class TutorialEntrancePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnEntrance UFButton
---@field ImgIcon UFImage
---@field RadialImage_37 URadialImage
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TutorialEntrancePanelView = LuaClass(UIView, true)

function TutorialEntrancePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnEntrance = nil
	--self.ImgIcon = nil
	--self.RadialImage_37 = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TutorialEntrancePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TutorialEntrancePanelView:OnInit()
end

function TutorialEntrancePanelView:OnDestroy()
end

function TutorialEntrancePanelView:OnShow()
	local Params = self.Params

	if Params == nil then
		return
	end

	local ID = Params.ID
	self.CountDown = Params.CountDown
	self.ID = ID

	local Cfg = GuideCfg:FindCfgByKey(ID)
	if Cfg ~= nil then
		self.TextName:SetText(Cfg.Title)
		local TypeCfg = GuideTypeCfg:FindCfgByID(Cfg.GuideTypeID)
		if TypeCfg ~= nil then
			UIUtil.ImageSetBrushFromAssetPath(TypeCfg.Icon)
		end
	end
	self.RadialImage_37:SetPercent(100)

	-- self:UpdCountDown()
end

function TutorialEntrancePanelView:OnHide()
	if self.TimerHdl then
		self:UnRegisterTimer(self.TimerHdl)
		self.TimerHdl = nil
	end
end

function TutorialEntrancePanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnEntrance, self.OnClickBtnEntrance)
end

function TutorialEntrancePanelView:OnRegisterGameEvent()
end

function TutorialEntrancePanelView:OnRegisterBinder()
end

function TutorialEntrancePanelView:PlayAnimIn()
	self.Super:PlayAnimIn()
	self:UpdCountDown()
end

function TutorialEntrancePanelView:OnClickBtnEntrance()

	if self.ID == nil then
		return
	end

	local Params = {}
	Params.ID = self.ID
	UIViewMgr:ShowView(UIViewID.TutorialGuideShowPanel, Params)
	if #(_G.TutorialGuideMgr:GetGuideQueue()) == 1 then
		_G.TutorialGuideMgr:ClearGuideQueue()
	end
	self:Hide()
end

function TutorialEntrancePanelView:UpdCountDown()
	if self.TimerHdl then
		self:UnRegisterTimer(self.TimerHdl)
		self.TimerHdl = nil
	end

	local Inv = 0.05

	if self.CountDown then
		UIUtil.SetIsVisible(self.RadialImage_37, true)
		local Start = TimeUtil.GetLocalTimeMS()
		self.TimerHdl = self:RegisterTimer(function()
			local Cur = TimeUtil.GetLocalTimeMS()
			local Delta = (Cur - Start) / 1000
			if Delta > self.CountDown then
				_G.EventMgr:SendEvent(_G.EventID.TutorialGuideCountDownEnd)
				return
			end
			local Prog = math.abs((Delta / self.CountDown) - 1)
			Prog = math.clamp(Prog, 0, 1)
			self.RadialImage_37:SetPercent(Prog)
		end, 0, Inv, 0)
	else
		UIUtil.SetIsVisible(self.RadialImage_37, false)
	end
end

return TutorialEntrancePanelView