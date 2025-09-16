local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local PhotoRoleStatVM = LuaClass(UIViewModel)
local PhotoActorUtil = require("Game/Photo/Util/PhotoActorUtil")

local PhotoDefine = require("Game/Photo/PhotoDefine")

local UIBindableList = require("UI/UIBindableList")
local PhotoRoleStatCfg = require("TableCfg/PhotoRoleStatCfg")
local PhotoRoleStatItemVM = require("Game/Photo/ItemVM/PhotoRoleStatItemVM")

-- local ItemVM = require("Game/Item/ItemVM")

local LSTR = _G.LSTR


function PhotoRoleStatVM:Ctor()
    self.StatList = UIBindableList.New(PhotoRoleStatItemVM)
    self.StatIdx = nil
    self.UniMove = nil
    self.CurID = nil
end

function PhotoRoleStatVM:OnInit()
end

function PhotoRoleStatVM:OnBegin()
    -- PWorldQuestMgr = _G.PWorldQuestMgr
    -- PWorldMgr = _G.PWorldMgr
    -- PWorldTeamMgr = _G.PWorldTeamMgr
end

function PhotoRoleStatVM:OnEnd()
end

function PhotoRoleStatVM:OnShutdown()
end

function PhotoRoleStatVM:UpdateVM()
    self:UpdFilterList()
    self:SetStatIdx(nil, nil)
end

function PhotoRoleStatVM:UpdFilterList()
    self.ListData = {}
    local AllCfg = PhotoRoleStatCfg:FindAllCfg()
    for _, Cfg in pairs(AllCfg or {}) do
        -- if not Cfg.Hide then
            -- @todo config move field can't read on branch  
            table.insert(self.ListData, {ID = Cfg.ID, Move = Cfg.ID == 1 or Cfg.ID == 2 or Cfg.ID == 4})
        -- end
    end

    self.StatList:UpdateByValues(self.ListData)
end

function PhotoRoleStatVM:TryRptStat()
    if self.UniMove then
        self:SetStatIdx(nil, nil)
    end
end

function PhotoRoleStatVM:SetStatIdx(Idx, ID)
    self.StatIdx = Idx
    local bMove = (self.ListData[Idx] or {}).Move
    -- if bMove then
    --     _G.PhotoActionVM:ResetRoleActAni()
    --     _G.PhotoEmojiVM:ResetRoleActAni()
    -- end

    self.UniMove = bMove

    if ID then
        self.CurID = ID
	    _G.PhotoMgr:SeltRoleEff(ID)
    else
        self.CurID = nil
        _G.PhotoMgr:CheckAndClearRoleEff(true)
    end
end

return PhotoRoleStatVM