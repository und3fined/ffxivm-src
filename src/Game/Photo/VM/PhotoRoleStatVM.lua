local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local UIBindableList = require("UI/UIBindableList")
local PhotoRoleStatCfg = require("TableCfg/PhotoRoleStatCfg")
local PhotoRoleStatItemVM = require("Game/Photo/ItemVM/PhotoRoleStatItemVM")
local PhotoTemplateUtil = require("Game/Photo/Util/PhotoTemplateUtil")

local PhotoRoleStatVM = LuaClass(UIViewModel)
local PhotoMgr
local PhotoEmojiVM

function PhotoRoleStatVM:Ctor()
    self.StatList = UIBindableList.New(PhotoRoleStatItemVM)
    self.StatIdx = nil
    self.UniMove = nil
    self.CurID = nil
end

function PhotoRoleStatVM:OnInit()
    PhotoMgr = _G.PhotoMgr
    PhotoEmojiVM = _G.PhotoEmojiVM
end

function PhotoRoleStatVM:OnBegin()
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
            table.insert(self.ListData, {ID = Cfg.ID, NotMove = (Cfg.Move == 1)})
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
    local bNotMove = self.ListData[Idx] and self.ListData[Idx].NotMove == true or false
    self.StatIdx = Idx
    self.UniMove = ID and bNotMove
    self.CurID = ID
    if ID then
	    PhotoMgr:SeltRoleEff(ID)
    else
        PhotoMgr:CheckAndClearRoleEff(true)
    end
    PhotoMgr:DirectPauseSeltAnim(bNotMove)
    self:UpdateCurIdx()
end

function PhotoRoleStatVM:GetIsBanAnim()
    return self.CurID and (self.UniMove == true)
end

function PhotoRoleStatVM:UpdateCurIdx()
    for i = 1, self.StatList:Length() do
        local ItemVM = self.StatList:Get(i)
        if ItemVM then
            ItemVM:SetIsSelected(ItemVM.ID == self.CurID)
        end
	end
end

-------------------------------------------------------------------------------------------------------
---@region template setting

function PhotoRoleStatVM:TemplateSave(InTemplate)
    PhotoTemplateUtil.SetRoleStat(InTemplate, self.CurID)
end

function PhotoRoleStatVM:TemplateApply(InTemplate)
    local Info = PhotoTemplateUtil.GetRoleStat(InTemplate)
    local Idx
    if Info then
        local CurID = Info.StatID
        for K, Item in pairs(self.ListData or {}) do
            if Item.ID == CurID then
                Idx = K
                break
            end
        end

        if Idx then
            PhotoRoleStatVM:SetStatIdx(Idx, CurID)
        else
            PhotoRoleStatVM:SetStatIdx(nil, nil)
        end
    end
end

return PhotoRoleStatVM