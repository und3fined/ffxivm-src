---
--- Author: Administrator
--- DateTime: 2025-03-17 20:59
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoRes = require("Protocol/ProtoRes")
local WorldExploraMgr = require("Game/WorldExplora/WorldExploraMgr")
local WorldExploraDefine = require("Game/WorldExplora/WorldExploraDefine")


local Wilder_Explore_GameType = ProtoRes.Wilder_Explore_GameType
local TabType = WorldExploraDefine.TabType
---@class WorldExploraExploraPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClick01 UFButton
---@field BtnClick02 UFButton
---@field BtnClick03 UFButton
---@field BtnClick04 UFButton
---@field BtnClick05 UFButton
---@field BtnClick06 UFButton
---@field BtnClick07 UFButton
---@field BtnClick08 UFButton
---@field BtnClick09 UFButton
---@field ImgLock01 UFImage
---@field ImgLock02 UFImage
---@field ImgLock03 UFImage
---@field ImgLock04 UFImage
---@field ImgLock05 UFImage
---@field ImgLock06 UFImage
---@field ImgLock07 UFImage
---@field ImgLock08 UFImage
---@field ImgLock09 UFImage
---@field TextName01 UFTextBlock
---@field TextName02 UFTextBlock
---@field TextName03 UFTextBlock
---@field TextName04 UFTextBlock
---@field TextName05 UFTextBlock
---@field TextName06 UFTextBlock
---@field TextName07 UFTextBlock
---@field TextName08 UFTextBlock
---@field TextName09 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldExploraExploraPanelView = LuaClass(UIView, true)

function WorldExploraExploraPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClick01 = nil
	--self.BtnClick02 = nil
	--self.BtnClick03 = nil
	--self.BtnClick04 = nil
	--self.BtnClick05 = nil
	--self.BtnClick06 = nil
	--self.BtnClick07 = nil
	--self.BtnClick08 = nil
	--self.BtnClick09 = nil
	--self.ImgLock01 = nil
	--self.ImgLock02 = nil
	--self.ImgLock03 = nil
	--self.ImgLock04 = nil
	--self.ImgLock05 = nil
	--self.ImgLock06 = nil
	--self.ImgLock07 = nil
	--self.ImgLock08 = nil
	--self.ImgLock09 = nil
	--self.TextName01 = nil
	--self.TextName02 = nil
	--self.TextName03 = nil
	--self.TextName04 = nil
	--self.TextName05 = nil
	--self.TextName06 = nil
	--self.TextName07 = nil
	--self.TextName08 = nil
	--self.TextName09 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldExploraExploraPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldExploraExploraPanelView:OnInit()
	self.Cfgs = nil
end

function WorldExploraExploraPanelView:OnDestroy()

end

function WorldExploraExploraPanelView:OnShow()
	self:InitByCfg()
end

function WorldExploraExploraPanelView:OnHide()
	self.Cfgs = nil
end

function WorldExploraExploraPanelView:OnRegisterUIEvent()
	for i = 1, 9 do
		local NameIndex = string.format("BtnClick0%d", i)
		UIUtil.AddOnClickedEvent(self, self[NameIndex], self.OnGameBtnClick, i)
	end
end

function WorldExploraExploraPanelView:OnRegisterGameEvent()

end

function WorldExploraExploraPanelView:OnRegisterBinder()

end

function WorldExploraExploraPanelView:InitByCfg()
	for i = Wilder_Explore_GameType.WILDER_EXPLORE_GAMEPLAY_AETHER, Wilder_Explore_GameType.WILDER_EXPLORE_GAMEPLAY_GATHER do
		local Cfg = self:FindCfgByGameType(i)
		if Cfg ~= nil then
			local NameIndex = "TextName0"..(i - 3)
			self[NameIndex]:SetText(Cfg.FuncName)
			local bLock = false
			if i == Wilder_Explore_GameType.WILDER_EXPLORE_GAMEPLAY_AETHER then				-- 风脉可能有锁
				bLock = not WorldExploraMgr:CheckAetherIsUnlock()
			elseif i == Wilder_Explore_GameType.WILDER_EXPLORE_GAMEPLAY_SIGHTSEE then		-- 探索笔记可能有锁
				bLock = not WorldExploraMgr:CheckSightseeingLogIsUnlock()
			end
			local LockName = "ImgLock0"..(i - 3)
			UIUtil.SetIsVisible(self[LockName], bLock)
		end
	end
end

function WorldExploraExploraPanelView:OnGameBtnClick(Index)
	local Offset = 3
	local GameTypeEnum = Index + Offset
	local bBan = false
	if GameTypeEnum == Wilder_Explore_GameType.WILDER_EXPLORE_GAMEPLAY_AETHER and not WorldExploraMgr:CheckAetherIsUnlock() then
		bBan = true
	end

	if GameTypeEnum == Wilder_Explore_GameType.WILDER_EXPLORE_GAMEPLAY_SIGHTSEE and not WorldExploraMgr:CheckSightseeingLogIsUnlock() then
		bBan = true
	end

	if bBan then
		local NameIndex = string.format("BtnClick0%d", Index)

		WorldExploraMgr:ShowLockTips(GameTypeEnum, self[NameIndex], TabType.EExplora)
		return
	end

	WorldExploraMgr:ShowExploraWin(GameTypeEnum)
end

--- 找配置
function WorldExploraExploraPanelView:FindCfgByGameType(GameType)
	return WorldExploraMgr:FindCfgByGameType(GameType, TabType.EExplora)
end



return WorldExploraExploraPanelView