---
--- Author: lydianwang
--- DateTime: 2021-08-23 19:11
--- Description:
---

--新版ui 等级和角色信息放一起了 代码业合并到 MainMajorInfoPanelView

--[[
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local MajorUtil = require("Utils/MajorUtil")
local UIUtil = require("Utils/UIUtil")
local ScoreMgr = require("Game/Score/ScoreMgr")

local LevelExpCfg = require("TableCfg/LevelExpCfg")

local LevelExpCfgList = LevelExpCfg:FindAllCfg("true")
local CachedLevel = 0

---@class MainPlayerLevelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ExpBar UProgressBar
---@field PlayerLevel UCanvasPanel
---@field Text_Exp UTextBlock
---@field Text_Level UTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainPlayerLevelView = LuaClass(UIView, true)

function MainPlayerLevelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	self.ExpBar = nil
	self.PlayerLevel = nil
	self.Text_Exp = nil
	self.Text_Level = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MainPlayerLevelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainPlayerLevelView:OnInit()

end

function MainPlayerLevelView:OnDestroy()

end

function MainPlayerLevelView:OnShow()
	self:OnMajorLevelUpdate()
	UIUtil.SetIsVisible(self.PlayerLevel, true)
end

function MainPlayerLevelView:OnHide()

end

function MainPlayerLevelView:OnRegisterUIEvent()

end

function MainPlayerLevelView:OnRegisterGameEvent()
	--self:RegisterGameEvent(_G.EventID.MajorCreate, self.OnShow)
	self:RegisterGameEvent(_G.EventID.MajorLevelUpdate, self.OnMajorLevelUpdate)
	self:RegisterGameEvent(_G.EventID.MajorExpUpdate, self.OnMajorExpUpdate)
end

function MainPlayerLevelView:OnRegisterTimer()

end

function MainPlayerLevelView:OnRegisterBinder()

end

---升级或切换职业
function MainPlayerLevelView:OnMajorLevelUpdate(Params)
	-- if Params and Params.ULongParam1 ~= _G.MajorUtil.GetMajorEntityID() then
	-- 	_G.FLOG_WARNING("MainPlayerLevelView: Wrong major entity ID")
	-- 	return
	-- end

	local Level = MajorUtil.GetMajorLevel()
	if Params then Level = Params.RoleDetail.Simple.Level end
	CachedLevel = Level

	self.Text_Level:SetText(string.format(_G.LSTR("%d级"), Level))

	self:OnMajorExpUpdate()
end

---经验值更新
function MainPlayerLevelView:OnMajorExpUpdate(Params)
	-- if Params and Params.ULongParam1 ~= _G.MajorUtil.GetMajorEntityID() then
	-- 	_G.FLOG_WARNING("MainPlayerLevelView: Wrong major entity ID")
	-- 	return
	-- end

	local CurExp = ScoreMgr:GetExpScoreValue()
	if Params then CurExp = Params.ULongParam3 end

	local LevelCfg = LevelExpCfgList[CachedLevel]
	if LevelCfg == nil then
		self.ExpBar:SetPercent(1)
		self.Text_Exp:SetText("Max")
	else
		local MaxExp = LevelCfg.NextExp
		self.ExpBar:SetPercent(CurExp < MaxExp and CurExp/MaxExp or 1)
		self.Text_Exp:SetText(string.format("%d/%d", CurExp, MaxExp))
	end
end

return MainPlayerLevelView

--]]