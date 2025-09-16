---
--- Author: haialexzhou
--- DateTime: 2023-6-13
--- Description:
---

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local CommonUtil = require("Utils/CommonUtil")

---@class StorySubLevelLoader : MgrBase
local StorySubLevelLoader = LuaClass(MgrBase)

function StorySubLevelLoader:OnInit()
	self.OnAllSublevelLoadedCallback = nil
	self.SublevelLoader = nil
	self.bLoadingSublevels = false
end

function StorySubLevelLoader:OnBegin()
end

function StorySubLevelLoader:OnEnd()
end

function StorySubLevelLoader:OnShutdown()
end

function StorySubLevelLoader:IsLoadingSubLevels()
	return self.bLoadingSublevels
end

function StorySubLevelLoader:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.AllSeqSubLevelPostLoad, self.OnAllSublevelLoaded)
end

function StorySubLevelLoader:OnAllSublevelLoaded(Params)
	if (self.bLoadingSublevels and self.OnAllSublevelLoadedCallback) then
		self.bLoadingSublevels = false
		self.OnAllSublevelLoadedCallback()
	end
end

function StorySubLevelLoader:LoadSublevels(SequenceObject, bLoadAllSubLevels, bSkipLoadLevelStreaming, CallbackFunc)
	local bLoadResult = false
	local _ <close> = CommonUtil.MakeProfileTag("LoadSublevels")

	self.SublevelLoader = _G.NewObject(_G.UE.USequenceSublevelLoader)
	if (self.SublevelLoader) then
		local bRet = self.SublevelLoader:LoadSublevels(SequenceObject, bLoadAllSubLevels, bSkipLoadLevelStreaming)
		if (bRet) then
			self.OnAllSublevelLoadedCallback = CallbackFunc
			self.bLoadingSublevels = true
			self.SublevelLoaderRef = UnLua.Ref(self.SublevelLoader)
			bLoadResult = true
		else
			self.bLoadingSublevels = false
			self.SublevelLoader = nil
			bLoadResult = false
		end
	end
	return bLoadResult
end

function StorySubLevelLoader:DestroySublevelLoader()
	if (self.SublevelLoader) then
		self.SublevelLoaderRef = nil
		self.SublevelLoader = nil
	end
	self.bLoadingSublevels = false
end

return StorySubLevelLoader