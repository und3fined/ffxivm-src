--[[
Author: xingcaicao
Date: 2023-05-29 21:20
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-09-09 20:42:44
FilePath: \Script\Game\TeamRecruit\VM\TeamRecruitItemVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AED
--]]
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local TeamRecruitCfg = require("TableCfg/TeamRecruitCfg")
local TeamRecruitUtil = require("Game/TeamRecruit/TeamRecruitUtil")
local TeamRecruitDefine = require("Game/TeamRecruit/TeamRecruitDefine")
-- local TeamRecruitSimpleProfVM = require("Game/TeamRecruit/VM/TeamRecruitSimpleProfVM")
local UTF8Util = require("Utils/UTF8Util")
local TeamRecruitProfVM = require("Game/TeamRecruit/VM/TeamRecruitProfVM")

local LSTR = _G.LSTR

---@class TeamRecruitItemVM : UIViewModel
local TeamRecruitItemVM = LuaClass(UIViewModel)

function TeamRecruitItemVM:Ctor()
    self.ServerData = nil

	self.ContentID = nil
    self.SceneMode = nil
    self.RoleID = nil
    self.IsMajor = false
    self.HasPassword = false
    self.EuipLv = nil
    self.CompleteTask = false
    self.StartTime = 0 

    self.ContentName = ""
    self.Message = ""
    self.ItemOpacity = 1.0 

    -- self.MemberSimpleProfVMList = UIBindableList.New(TeamRecruitSimpleProfVM)
    self.MemberSimpleProfVMList = UIBindableList.New(TeamRecruitProfVM)
end

function TeamRecruitItemVM:UpdateVM(Data)
    self.ServerData = table.clone(Data)

    self.ContentID      = Data.ID
    self.SceneMode      = Data.TaskLimit
    self.RoleID         = Data.RoleID
    self.IsMajor        = TeamRecruitUtil.IsMajorRecruitByID(self.RoleID)
    self.HasPassword    = not string.isnilorempty(Data.Password)
    self.EquipLv        = Data.EquipLv or 0
    self.CompleteTask   = Data.ComplateTask == true
    self.StartTime      = Data.StartTime or 0
    self.ItemOpacity    = 1.0 
    self.OffsetRelationQuery = Data.OffsetRelationQuery
    self.OffsetQuery = Data.OffsetQuery

    self.MemberSimpleProfVMList:UpdateByValues(Data.Prof or {}, TeamRecruitUtil.SortEditProf)

    local Cfg = TeamRecruitCfg:FindCfgByKey(self.ContentID)
    if Cfg then
        if TeamRecruitUtil.IsRecruitUnlocked(self.ContentID) then
            local Text = Data.Message or ""
            if string.len(Text) > 75 then -- ToDo，临时处理
                Text = UTF8Util.Sub(Text, 1, 45) .. "..."
            end

            self.Message = TeamRecruitUtil.AdaptMessage(Text, self.CompleteTask)
            self.ContentName = Cfg.TaskName

        else
            self.Message = "--"
            self.ItemOpacity = 0.5
            self.ContentName = LSTR(1310037) 
        end
    else
        self.Message = "--"
        self.ItemOpacity = 0.5
        self.ContentName = LSTR(1310038) 
    end
end

function TeamRecruitItemVM:IsEqualVM(Value)
	return nil ~= Value and self.RoleID == Value.RoleID
end

return TeamRecruitItemVM