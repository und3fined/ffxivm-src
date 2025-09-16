---
--- Author: sammrli
--- DateTime: 2023-05-11 20:56
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local SkillUtil = require("Utils/SkillUtil")
local TimeUtil = require("Utils/TimeUtil")
local EventID = require("Define/EventID")

local TimerMgr = _G.TimerMgr
local LSTR = _G.LSTR
local SingBarMgr = _G.SingBarMgr
local FLOG_INFO = _G.FLOG_INFO

---@class AttuningSingBarView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---@field ProgressSingBar UProgressBar
---@field SingBarName UFTextBlock
---@field TextBreak UFTextBlock
---@field TextCD UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local AttuningSingBarView = LuaClass(UIView, true)

function AttuningSingBarView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--self.ProgressSingBar = nil
	--self.SingBarName = nil
	--self.TextBreak = nil
	--self.TextCD = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	-- self.DefaultColor = "FFFFFFFF"
	-- self.GrayColor = "999999FF"
end

function AttuningSingBarView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function AttuningSingBarView:OnInit()
	self.ViewListToSetInvisible = {}
	local Config = self:GetConfig()
	if nil ~= Config and nil ~= Config.ListToSetInvisible then
		for _, ViewID in ipairs(Config.ListToSetInvisible) do
			table.insert(self.ViewListToSetInvisible, ViewID)
		end
	end
end

function AttuningSingBarView:OnDestroy()

end

function AttuningSingBarView:OnShow()
	_G.InteractiveMgr:SetMajorIsinging(true)
	--reset default effect
	self:CloseSingTimer()
	-- self:ResetView()

	UIUtil.SetIsVisible(self.ImgIcon, false)

	if _G.SingBarMgr.HideBreakText then
		UIUtil.SetIsVisible(self.TextBreak, false)
	else
		UIUtil.SetIsVisible(self.TextBreak, true)
	end

	local Params = self.Params
	if nil == Params or Params.SkillID == nil then
		return
	end
	
	--OnShow的时候stop没效果
	-- self:StopAnimation(self.AnimStop)

	if Params.IconPath and string.len(Params.IconPath) > 0 then
		UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, Params.IconPath)
		UIUtil.SetIsVisible(self.ImgIcon, true)
	else
		if Params.SkillID > 0 then
			SkillUtil.ChangeSkillIcon(Params.SkillID, self.ImgIcon)
		end
	end

	if nil ~= Params.HideOtherUIType then
		if Params.HideOtherUIType == "1" then
			local IsExist = false
			for _, ViewID in ipairs(self.ViewListToSetInvisible) do
				if ViewID == _G.UIViewID.MainPanel then
					IsExist = true
					break
				end
			end
			if not IsExist then
				table.insert(self.ViewListToSetInvisible, _G.UIViewID.MainPanel)
			end
		else
			self:RemoveMainPanelFromList()
		end
	end
end

function AttuningSingBarView:RemoveMainPanelFromList()
	for Index, ViewID in ipairs(self.ViewListToSetInvisible) do
		if ViewID == _G.UIViewID.MainPanel then
			table.remove(self.ViewListToSetInvisible, Index)
			break
		end
	end
end

function AttuningSingBarView:GetViewListToSetInvisible()
	return self.ViewListToSetInvisible
end

function AttuningSingBarView:OnHide()
	self:CloseSingTimer()
	_G.InteractiveMgr:SetMajorIsinging(false)
	self:RemoveMainPanelFromList()
end

function AttuningSingBarView:OnRegisterUIEvent()

end

function AttuningSingBarView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.MajorSingBarBreak, self.OnMajorSingBarBreak)
end

function AttuningSingBarView:OnRegisterBinder()
end

function AttuningSingBarView:CloseSingTimer()
	if self.SingTimerID then
		TimerMgr:CancelTimer(self.SingTimerID)
		self.SingTimerID = nil
	end
	
	if self.OverTimerID then
		TimerMgr:CancelTimer(self.OverTimerID)
		self.OverTimerID = nil
	end
end

function AttuningSingBarView:UpdateProcessBar()
	local PassTime = TimeUtil.GetLocalTimeMS() - self.BeginTime
	if PassTime >= self.SingTime then
		self.TextCD:SetText(string.format("0%.2f", 0))
		self.ProgressSingBar:SetPercent(1)

		self:CloseSingTimer()
		self:Hide()

		FLOG_INFO("AttuningSingBarView:UpdateProcessBar, OnMajorSingOver: " .. tostring(PassTime / self.SingTime) .. " time: " .. TimeUtil.GetLocalTimeMS())

		SingBarMgr:OnMajorSingOver(MajorUtil.GetMajorEntityID(), false)
		return
	end

	local Percent = PassTime / self.SingTime
	if Percent > 0.99 then
		Percent = 1
	end

	local CountDown = (self.SingTime - PassTime) / 1000
	if CountDown < 10 then
		self.TextCD:SetText(string.format("0%.2f", CountDown))
	else
		self.TextCD:SetText(string.format("%.2f", CountDown))
	end

	-- FLOG_INFO("SingBar percent: " .. tostring(Percent) .. " time: " .. TimeUtil.GetLocalTimeMS() .. " passTime: " .. PassTime .. "Sing: " .. self.SingTime)
	self.ProgressSingBar:SetPercent(Percent)
	_G.InteractiveMgr:SetMajorIsinging(true)

end

-- function AttuningSingBarView:UpdateBreakEffect()
-- 	local SinTime = math.sin(math.rad(TimeUtil.GetLocalTimeMS())) * 0.5 + 0.5
-- 	self.TextBreak:SetRenderOpacity(SinTime)
-- end

--参数是ms
--时间加长一点点
function AttuningSingBarView:BeginSingBar(SingTime, SingName, ShowSingTimeCountDown)
	self.SingTime = SingTime + SingBarMgr.SingLifeAddTime

	if SingName then
		self.SingBarName:SetText(SingName)
	end
	
	self:StopAnimation(self.AnimStop)

	UIUtil.SetIsVisible(self.TextCD, ShowSingTimeCountDown)

	-- self:ResetView()
	self:CloseSingTimer()
	if not self.SingTimerID then
		self.SingTimerID = TimerMgr:AddTimer(self, self.UpdateProcessBar, 0, 0.02, 0)
	end

	self.ProgressSingBar:SetPercent(0)

	FLOG_INFO("SingBar BeginSingBar time: " .. TimeUtil.GetLocalTimeMS() .. " singTime: " .. SingTime)
	self.BeginTime = TimeUtil.GetLocalTimeMS()
end

--对于打断，则调用专有接口
function AttuningSingBarView:BreakSingBar()
	if not self:GetIsShowView() then
		return
	end
	self:CloseSingTimer()
	self.TextBreak:SetText(LSTR(90029))

	self:PlayAnimation(self.AnimStop)
	self.OverTimerID =  TimerMgr:AddTimer(self, self.BreakOver, 2.33, 1, 1)
end

function AttuningSingBarView:BreakOver()
	self:Hide()
end

function AttuningSingBarView:OnMajorSingBarBreak()
	self:BreakSingBar()
end


return AttuningSingBarView