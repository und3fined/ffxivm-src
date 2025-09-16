---
--- Author: xingcaicao
--- DateTime: 2023-05-31 14:30
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local TeamRecruitTypeCfg = require("TableCfg/TeamRecruitTypeCfg")
local TeamRecruitCfg = require("TableCfg/TeamRecruitCfg")
local TeamRecruitUtil = require("Game/TeamRecruit/TeamRecruitUtil")
local TeamRecruitProfVM = require("Game/TeamRecruit/VM/TeamRecruitProfVM")
local PWorldHelper = require("Game/PWorld/PWorldHelper")

local LSTR = _G.LSTR

---@class TeamRecruitDetailVM : UIViewModel
local TeamRecruitDetailVM = LuaClass(UIViewModel)

---Ctor
function TeamRecruitDetailVM:Ctor()
    self.ServerData = nil

	self.ContentID = nil
    self.SceneMode = nil
    self.RoleID = nil
    self.IsMajor = false
    self.HasPassword = false
    self.EquipLv = nil
    self.CompleteTask = false
    self.UnOpenTask = false

    self.ContentDesc = ""
    self.TypeIcon = "" 
    self.Message = ""
    self.RemainMemNumDesc = ""

    self.MemberProfVMList = UIBindableList.New(TeamRecruitProfVM)
end

function TeamRecruitDetailVM:Clear()
    self.ServerData = nil
	self.ContentID = nil
    self.SceneMode = nil
    self.RoleID = nil
    self.IsMajor = false
    self.HasPassword = false
    self.EquipLv = nil
    self.CompleteTask = false
    self.UnOpenTask = false

    self.ContentDesc = ""
    self.TypeIcon = "" 
    self.Message = ""
    self.RemainMemNumDesc = ""

    self.MemberProfVMList:Clear()
end

function TeamRecruitDetailVM:IsEqualVM(Value)
	return nil ~= Value and self.RoleID == Value.RoleID
end

---@param Data csteamrecruit.TeamRecruit @招募信息
function TeamRecruitDetailVM:UpdateVM(Data)
    self.ServerData = table.clone(Data)

    self.ContentID      = Data.ID
    self.SceneMode      = Data.TaskLimit
    self.RoleID         = Data.RoleID
    self.IsMajor        = TeamRecruitUtil.IsMajorRecruitByID(self.RoleID)
    self.HasPassword    = not string.isnilorempty(Data.Password)
    self.EquipLv        = Data.EquipLv or 0
    self.CompleteTask   = Data.ComplateTask == true
    self.Message        = TeamRecruitUtil.AdaptMessage(Data.Message, self.CompleteTask)
    self.WeeklyAward    = Data.WeeklyAward


    --更新成员信息
    self:UpdateMembers(Data.Prof)

    local Cfg = TeamRecruitCfg:FindCfgByKey(self.ContentID)
    self.TypeID = Cfg and Cfg.TypeID or nil
    if Cfg then
        local TypeInfo = TeamRecruitTypeCfg:GetRecruitTypeInfo(Cfg.TypeID) or {}
        self.TypeIcon = TypeInfo.Icon or ""

        if TeamRecruitUtil.IsRecruitUnlocked(self.ContentID) then
            self.ContentDesc = string.format("%s - %s", TypeInfo.Name or "", Cfg.TaskName or "")
        else
            self.UnOpenTask = true
            self.ContentDesc = LSTR(1310037) 
        end
    else
        self.UnOpenTask = true
        self.ContentDesc = LSTR(1310038) 
    end
end

function TeamRecruitDetailVM:UpdateMembers( RecruitProfList )
    local Profs = table.clone(RecruitProfList or {})
    self.MemberProfVMList:UpdateByValues(Profs, TeamRecruitUtil.SortEditProf) 

    --剩余可招募成员数量
    local Sum = 0 
    local CurNum = 0 
    local Items = self.MemberProfVMList:GetItems() or {}

    for _, v in ipairs(Items) do
        if v.HasRole then
            CurNum = CurNum + 1
            Sum = Sum + 1
        else
            if not table.empty(v.Profs) then
                Sum = Sum + 1
            end
        end
    end

    local RemainNum = math.max(Sum - CurNum, 0)
    self.RemainMemNumDesc = PWorldHelper.pformat("RECRUIT_REMAIN_NUM", RemainNum)
end

return TeamRecruitDetailVM