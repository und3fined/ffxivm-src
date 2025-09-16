--
-- Author: MichaelYang_LightPaw
-- Date: 2023-10-23 14:50
-- Description:
--
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local CardsGroupCardVM = require("Game/Cards/VM/CardsGroupCardVM")
local MagicCardMgr = require("Game/MagicCard/MagicCardMgr")
local LocalDef = require("Game/MagicCard/MagicCardLocalDef")
local ProfType = ProtoCommon.prof_type
local RoleGender = ProtoCommon.role_gender
local LSTR = _G.LSTR

---@class CardsDecksPageVM : UIViewModel
local CardsDecksPageVM = LuaClass(UIViewModel)

---Ctor
function CardsDecksPageVM:Ctor(TargetParentVM)
    -- self.LocalString = nil
    -- self.TextColor = nil
    -- self.ProfID = nil
    -- self.GenderID = nil
    -- self.IsVisible = nil
    self.ParentVM = TargetParentVM
    self.CurrentSelectItemVM = nil
    self.CardGroupSelectIndex = nil
    self.CardGroupList = nil
    self.GroupName = nil
    -- 构建可编辑卡组VM
    local CardGroupList = {}
    for i = 1, LocalDef.CardGroupCount do
        local GroupItemVM = CardsGroupCardVM.New(self, i)
        CardGroupList[i] = GroupItemVM
    end
    self.CardGroupList = CardGroupList
    -- END
end

--- func desc
---@param CardsSingleCardVM CardsSingleCardVM
function CardsDecksPageVM:OnDragEnter(CardsSingleCardVM)
end

--- func desc
---@param CardsSingleCardVM CardsSingleCardVM
function CardsDecksPageVM:OnDragLeave(CardsSingleCardVM)
end

--- func desc
---@param TargetCardVM CardsSingleCardVM
function CardsDecksPageVM:CanDrag(TargetCardVM)
    if (self.ParentVM ~= nil) then
        return self.ParentVM:CanCardClick(TargetCardVM)
    end

    return true
end

--- func desc
---@param TargetCardVM CardsSingleCardVM
function CardsDecksPageVM:CanCardClick(TargetCardVM)
    if (self.ParentVM ~= nil) then
        return self.ParentVM:CanCardClick(TargetCardVM)
    end

    return true
end

--- func desc
---@param CardsSingleCardVM CardsSingleCardVM
function CardsDecksPageVM:OnDrop(CardsSingleCardVM)
end

function CardsDecksPageVM:RefreshGroupName()
    self.GroupName = self.CurrentSelectItemVM.GroupName
end

function CardsDecksPageVM:OnRefresh()
    -- 卡组
    local GameInfo = MagicCardMgr.NpcGameInfo
    if (GameInfo == nil) then
        _G.FLOG_ERROR("GameInfo : MagicCardMgr.NpcGameInfo 为空，请检查一下是什么情况")
        return
    end

    for i = 1, LocalDef.CardGroupCount do
        local ServerGroupInfo = GameInfo.CardGroups[i]
        if (ServerGroupInfo) then
            if ServerGroupInfo.Name and ServerGroupInfo.Name ~= "" then
                self.CardGroupList[i].GroupName = ServerGroupInfo.Name
            end

            if ServerGroupInfo.Cards then
                self.CardGroupList[i]:SetGroupCardList(ServerGroupInfo.Cards)
            end

            if i == GameInfo.DefaultIndex + 1 then
                self:SetItemAsDefaultGroup(self.CardGroupList[i])
            end
        end
    end

    if (GameInfo.DefaultIndex <= 0) then
        self:SetItemAsDefaultGroup(self.CardGroupList[1])
    end
end

function CardsDecksPageVM:SetCurrentSelectItemDefault()
    self:SetItemAsDefaultGroup(self.CurrentSelectItemVM, true)
end

function CardsDecksPageVM:SetParentVM(TargetParentVM)
    self.ParentVM = TargetParentVM
end

function CardsDecksPageVM:HandleCardClicked(TargetVM)
    if (self.ParentVM ~= nil) then
        self.ParentVM:HandleCardClicked(TargetVM)
    end
end

---@param ItemVM CardsGroupCardVM
function CardsDecksPageVM:SetItemAsDefaultGroup(ItemVM, IsByPlayer)
    if not ItemVM then
        return
    end
    _G.FLOG_INFO("CardsDecksPageVM:SetItemAsDefaultGroup item index[%d]", ItemVM:GetIndex())

    if (IsByPlayer == nil or not IsByPlayer) then
        self:SetItemSelected(ItemVM)
    end

    -- 因为协议共用了，self:OnNetMsgSelectGroupRsp(Msg.SelectRsp) 里面没有返回index
    -- 因此只能在客户端先自行设置，也管不了是否发送成功
    local _targetIndex = ItemVM:GetIndex()
    for i = 1, LocalDef.CardGroupCount do
        self.CardGroupList[i].IsDefaultGroup = (i == _targetIndex)
    end

    if IsByPlayer then
        MagicCardMgr:SendSelectGroupAsDefaultReq(ItemVM:GetServerIndex())
    end
end

---@param ItemVM CardsGroupCardVM
function CardsDecksPageVM:SetItemSelected(ItemVM)
    if not ItemVM then
        return
    end

    if self.CurrentSelectItemVM and self.CurrentSelectItemVM == ItemVM then
        -- 如果是同一个，就不设置什么了
        return
    end

    if self.CurrentSelectItemVM then
        self.CurrentSelectItemVM.IsCurrentSelect = false
    end

    ItemVM.IsCurrentSelect = true
    self.CurrentSelectItemVM = ItemVM
    if (self.ParentVM ~= nil) then
        self.ParentVM:SetItemSelected(ItemVM)
    end
    self.GroupName = self.CurrentSelectItemVM.GroupName
end

function CardsDecksPageVM:OnEditGroup()
    if not self.CurrentSelectItemVM then
        return
    end
end

-- 要返回当前类
return CardsDecksPageVM
