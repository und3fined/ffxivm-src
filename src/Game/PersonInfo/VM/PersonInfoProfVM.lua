---
--- Author: xingcaicao
--- DateTime: 2023-04-13 19:40
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProfUtil = require("Game/Profession/ProfUtil")
local LevelExpCfg = require("TableCfg/LevelExpCfg")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local ClientGlobalCfg = require("TableCfg/ClientGlobalCfg")
local ProtoRes = require("Protocol/ProtoRes")
local MajorUtil = require("Utils/MajorUtil")

---@class PersonInfoProfVM : UIViewModel
local PersonInfoProfVM = LuaClass(UIViewModel)

---Ctor
function PersonInfoProfVM:Ctor( )
    self.ProfID = nil
    self.ProfIcon = ""
    self.Level = 0 
    self.LevelDesc = ""
    self.IsUnLock = false
    self.IsJudgeShowSelectedIcon = false
    self.IsNone = false
    self.Name = nil
    self.IsEmpty = false
    self.IsMax = nil
end

function PersonInfoProfVM:IsEqualVM( Value )
    return Value ~= nil and self.ProfID ~= nil and self.ProfID == Value.ProfID
end

function PersonInfoProfVM:UpdateVM( Value )

    if Value.Empty then
        self.IsEmpty = true
        self.ProfID = nil
        return
    end

    self.IsEmpty = false

	self.ProfID     = Value.ProfID
	self.Level      = Value.Level or 0
    self.LevelDesc  = tostring(self.Level) or ""
    self.IsUnLock   = self.Level > 0
    self.IsNone     = nil == self.ProfID or self.ProfID <= 0
    self.Icon       = Value.Icon
    self.Name       = Value.Name
    self.RoleVM     = Value.RoleVM
    self.LevelColor = ProfUtil.GetLevelUniformColor(Value.Level or 0)
    self.IsFinishedLastPWorld = false
    if self.RoleVM then
        local MajorRoleID = MajorUtil.GetMajorRoleID()
        local PassSceneIDList = {}
        local CountCfg = ClientGlobalCfg:FindCfgByKey(ProtoRes.client_global_cfg_id.GLOBAL_FINAL_DUNGEON_COUNT_ID) or {}
        local SceneID = CountCfg.Value[1] or 1205013
        ---服务器确认不修改主角的通关数据下发，客户端区分处理
        if self.RoleVM.RoleID == MajorRoleID then
            local SceneFinishLogs = _G.PersonInfoMgr:GetMajorSceneFinishLogs()
            for _, Value in ipairs(SceneFinishLogs) do
                if Value.ProfID == self.ProfID then
                    table.insert(PassSceneIDList, Value.SceneID)
                end
            end
        else
            local ProfSimpleDataList = self.RoleVM.ProfSimpleDataList
            if ProfSimpleDataList then
                local ProfSimpleData = table.find_by_predicate(ProfSimpleDataList, function(A)
                    return A.ProfID == self.ProfID
                end)
                if ProfSimpleData then
                    PassSceneIDList = ProfSimpleData.ScenesID
                end
            end
        end
        self.IsFinishedLastPWorld = table.find_by_predicate(PassSceneIDList,function(A)
            return A == SceneID
        end)
    end
    if self.IsFinishedLastPWorld then
        self.ProfIcon = RoleInitCfg:FindRoleInitProfIconSimple6nd(self.ProfID)
    else
        self.ProfIcon = RoleInitCfg:FindRoleInitProfIconSimple2nd(self.ProfID)
    end
    self.IsMax = self:IsMaxLevel()
    self.IsJudgeShowSelectedIcon = Value.IsJudgeShowSelectedIcon == true
end

function PersonInfoProfVM:IsMaxLevel()
	if nil == self.Level then
		return false
	end
	return self.Level >= LevelExpCfg:GetMaxLevel()
end

return PersonInfoProfVM