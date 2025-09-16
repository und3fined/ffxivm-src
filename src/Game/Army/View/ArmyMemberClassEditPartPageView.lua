---
--- Author: daniel
--- DateTime: 2023-03-08 09:52
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIAdapterTreeView = require("UI/Adapter/UIAdapterTreeView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

local ArmyMainVM = require("Game/Army/VM/ArmyMainVM")
local ArmyMemEditPartPageVM = nil
local ArmyMemberPanelVM = nil
local ArmyMemberPageVM = nil

local ArmyDefine = require("Game/Army/ArmyDefine")
local ProtoCommon = require("Protocol/ProtoCommon")

local TipsUtil = require("Utils/TipsUtil")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local GroupGlobalCfg = require("TableCfg/GroupGlobalCfg")
local GroupMemberCategoryCfg = require("TableCfg/GroupMemberCategoryCfg")
local DefineCategorys = ArmyDefine.DefineCategorys
local GlobalCfgType = ArmyDefine.GlobalCfgType

---@deprecated 
---@class ArmyMemberClassEditPartPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCancelEdit CommBtnLView
---@field BtnSaveBack CommBtnLView
---@field RichTextOnlineNum URichTextBox
---@field TreeViewClass UFTreeView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyMemberClassEditPartPageView = LuaClass(UIView, true)

local LastExpandedIndex = -1 --- TreeView选中的Index
--local LastItemView = nil

function ArmyMemberClassEditPartPageView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCancelEdit = nil
	--self.BtnSaveBack = nil
	--self.RichTextOnlineNum = nil
	--self.TreeViewClass = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyMemberClassEditPartPageView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnCancelEdit)
	self:AddSubView(self.BtnSaveBack)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyMemberClassEditPartPageView:OnInit()
    ArmyMemberPanelVM = ArmyMainVM:GetMemberPanelVM()
    ArmyMemberPageVM = ArmyMemberPanelVM:GetArmyMemberPageVM()
    ArmyMemEditPartPageVM = ArmyMemberPageVM:GetMemEditPartPageVM()

    self.TreeViewAdapter = UIAdapterTreeView.CreateAdapter(self, self.TreeViewClass, nil, true)
    self.TreeViewAdapter:SetOnClickedCallback(self.OnClickedClassItem)
    -- self.TreeViewAdapter:SetOnExpansionChangedCallback(self.OnItemExpansionChanged)
    self.Binders = {
        {"CategoryTreeList", UIBinderUpdateBindableList.New(self, self.TreeViewAdapter)},
    }
    UIUtil.SetIsVisible(self.BtnCancelEdit, false, true, false)
end

function ArmyMemberClassEditPartPageView:OnClickedClassItem(Index, ItemData, ItemView)
    local ItemParams = ItemView.Params
    if nil == ItemParams then
        return
    end
    local ItemVM = ItemParams.Data
    if nil == ItemVM then
        return
    end
    --- 点击父节点
    if ItemVM.Type == ArmyDefine.Zero then
        --- 如果上一个是展开，则先收缩
        -- if LastExpandedIndex == Index then
        --     self.TreeViewClass:SetItemExpansionAtIndex(LastExpandedIndex - 1, false)
        --     ItemView.ToggleBtn:SetChecked(false, false)
        --     LastExpandedIndex = -1
        --     LastItemView = nil
        --     return
        -- end
        -- if LastExpandedIndex >= 0 then
        --     self.TreeViewClass:SetItemExpansionAtIndex(LastExpandedIndex - 1, false)
        -- end
        -- if not ItemData.IsExpanded then
        --     LastExpandedIndex = Index
        -- end
        -- if LastItemView ~= nil then
        --     LastItemView.ToggleBtn:SetChecked(false, false)
        -- end
        -- self.TreeViewClass:SetItemExpansionAtIndex(Index - 1, not ItemData.IsExpanded)
        -- ItemView.ToggleBtn:SetChecked(true, false)
        -- LastItemView = ItemView
        ItemView.ToggleBtn:SetChecked(false, false)
    else
        -- 点击子节点
        -- local Member = ItemVM.MemberData[Index]
        -- local Categories = {}
        -- for _, CategoryData in ipairs(ArmyMemberPageVM.MyArmyInfo.Categories) do
        --     --- 会长和见习不可设置
        --     if CategoryData.ID ~= ArmyDefine.LeaderCID and CategoryData.ID ~= ProtoCommon.group_category_type.GROUP_CATEGORY_TYPE_INTERN then
        --         table.insert(Categories, {
        --             CategoryData = CategoryData,
        --             bSelected = Member.CategoryID == CategoryData.ID
        --         })
        --     end
        -- end
        -- local DesignSize = ItemView:GetDesiredSize()
        -- local Widget_X = DesignSize.X / ArmyDefine.Half
        -- local Count = #Categories
        -- if Count > ArmyDefine.ShowMaxClassNum then
        --     Count = ArmyDefine.ShowMaxClassNum
        -- end
        -- local Heigth = Count * ArmyDefine.ClassItemHeight + ArmyDefine.ItemSpace
        -- local OffsetX
        -- if Index == ArmyDefine.One then
        --     OffsetX =  ArmyDefine.SortOffsetX
        -- else
        --     OffsetX = Widget_X + ArmyDefine.SortOffsetX
        -- end
        -- local Position = UIUtil.WidgetLocalToViewport(ItemView, OffsetX, ArmyDefine.Zero)
        -- local BottomPosY = Position.Y + Heigth
        -- local ScreenSize = UIUtil.GetScreenSize()
        -- local ScreenBottomY = ScreenSize.Y - ArmyDefine.ScreenOffsetY
        -- if BottomPosY > ScreenBottomY then
        --     Position.Y = Position.Y - (Heigth - ArmyDefine.ClassItemHeight)
        -- end
        -- _G.UIViewMgr:ShowView(_G.UIViewID.ArmyMemberCategoryChangePanel,
        --     {
        --         RoleID = Member.RoleID,
        --         Position = Position,
        --         Heigth = Heigth,
        --         Categories = Categories,
        --         SelectedID = Member.CategoryID,
        --     }
        -- )

        local Params = {}
        Params.Data = {}
        --Params.View = self
       -- Params.ClickItemCallback = self.ClickItemCallback
        local Member = ItemVM.MemberData[Index]
        for _, CategoryData in ipairs(ArmyMemberPageVM.MyArmyInfo.Categories) do
            --- 会长不可设置
            if CategoryData.ID ~= ArmyDefine.LeaderCID then
                CategoryData.RoleID = Member.RoleID
                table.insert(Params.Data, {
                    TextName = self:ParseNameByCategoryData(CategoryData),
                    Icon = GroupMemberCategoryCfg:GetCategoryIconByID(CategoryData.IconID),
                    Data = CategoryData,
                    IsSelected = Member.CategoryID == CategoryData.ID,
                    ClickItemCallback = self.OnClickedItem,
                    View = self,
                })
            end
        end

        local Btn
        if Index == ArmyDefine.One then
            Btn = ItemView.BtnSetting1
        else
            Btn = ItemView.BtnSetting2
        end

        if Btn ~= nil then
            local BtnSize = UIUtil.GetLocalSize(Btn)
            TipsUtil.ShowJumpToTips(Params, Btn, _G.UE.FVector2D(0, BtnSize.Y * 0.12),  _G.UE.FVector2D(0, 0), false)
        end
    end
end

function ArmyMemberClassEditPartPageView:ParseNameByCategoryData(CategoryData)
    local Name = CategoryData.Name
    if string.isnilorempty(Name) then
        local CfgCategoryName
        if CategoryData.ID == ArmyDefine.LeaderCID then
			CfgCategoryName = GroupGlobalCfg:GetStrValueByType(GlobalCfgType.DefaultMajorCategoryName)
            Name = CfgCategoryName or DefineCategorys.LeaderName
        else
			CfgCategoryName = GroupGlobalCfg:GetStrValueByType(GlobalCfgType.DefaultMinorCategoryName)
            Name = CfgCategoryName or DefineCategorys.MemName
        end
    end

    return string.format("%d %s", CategoryData.ShowIndex + 1, Name)
end

function ArmyMemberClassEditPartPageView:OnClickedItem(ItemData)
    local Params = ItemData
	if nil ~= Params then
		local CategoryID = ItemData.Data.ID
		if not Params.IsSelected then
			_G.ArmyMgr:SendArmySetMemberCategoryMsg(ItemData.Data.RoleID, CategoryID)
		end
	end
	
    if UIViewMgr:IsViewVisible(UIViewID.CommJumpWayTipsView) then
        UIViewMgr:HideView(UIViewID.CommJumpWayTipsView)
    end
end

function ArmyMemberClassEditPartPageView:OnItemExpansionChanged(ItemData, IsExpanded)
    if LastExpandedIndex ~= ItemData.ShowIndex then
        if IsExpanded then
            self.TreeViewClass:SetItemExpansionAtIndex(ItemData.ShowIndex - 1, false)
        end
    end
end

function ArmyMemberClassEditPartPageView:OnDestroy()
end

function ArmyMemberClassEditPartPageView:OnShow()
    LastExpandedIndex = -1
    --LastItemView = nil
    -- self:SetTreeExpanedState(false)
    self.RichTextOnlineNum:SetText(ArmyMemberPageVM.MemberOnLinenNum)
    -- LSTR string:结束编辑并返回
    self.BtnSaveBack:SetText(_G.LSTR(910203))
end

-- function ArmyMemberClassEditPartPageView:SetTreeExpanedState(IsExpanded)
--     local Length = self.TreeViewClass:GetNumItems()
--     for i = 1, Length do
--         self.TreeViewClass:SetItemExpansionAtIndex(i - 1, IsExpanded)
--     end
-- end

function ArmyMemberClassEditPartPageView:OnHide()
end

function ArmyMemberClassEditPartPageView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnSaveBack, self.OnClickedSaveBack)
    UIUtil.AddOnClickedEvent(self, self.BtnCancelEdit, self.OnClickedBack)
end

function ArmyMemberClassEditPartPageView:OnRegisterGameEvent()
end

function ArmyMemberClassEditPartPageView:OnRegisterBinder()
    self:RegisterBinders(ArmyMemEditPartPageVM, self.Binders)
end

function ArmyMemberClassEditPartPageView:OnClickedSaveBack()
    ArmyMemberPageVM:CloseCategoryEdit()
end

function ArmyMemberClassEditPartPageView:OnClickedBack()
    ArmyMemberPageVM:CloseCategoryEdit()
end

return ArmyMemberClassEditPartPageView
