---
--- Author: Administrator
--- DateTime: 2024-10-24 10:26
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local RichTextUtil = require("Utils/RichTextUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetSelectedIndex = require("Binder/UIBinderSetSelectedIndex")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local PersonInfoMgr = require("Game/PersonInfo/PersonInfoMgr")

local MajorUtil = require("Utils/MajorUtil")
local GroupGlobalCfg = require("TableCfg/GroupGlobalCfg")
local ArmyDefine = require("Game/Army/ArmyDefine")
local ArmyTextColor = ArmyDefine.ArmyTextColor
local ProtoRes = require("Protocol/ProtoRes")
local GroupPermissionType = ProtoRes.GroupPermissionType
local GlobalCfgType = ArmyDefine.GlobalCfgType
local CategoryUIType = ArmyDefine.CategoryUIType
local ArmyMainVM = require("Game/Army/VM/ArmyMainVM")
local ArmyMgr = require("Game/Army/ArmyMgr")
local ProtoCommon = require("Protocol/ProtoCommon")
local ArmyMemberPanelVM = nil
local ArmyMemberPageVM = nil

---@class ArmyMemberClassPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClassEdit CommBtnLView
---@field ImgIcon UFImage
---@field TableViewAuthority UTableView
---@field TableViewClassList UTableView
---@field TextName UFTextBlock
---@field TextTitleClass1 UFTextBlock
---@field TextTitleMember1 UFTextBlock
---@field AnimShowPanel UWidgetAnimation
---@field AnimUpdateDisplay UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyMemberClassPageView = LuaClass(UIView, true)

function ArmyMemberClassPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClassEdit = nil
	--self.ImgIcon = nil
	--self.TableViewAuthority = nil
	--self.TableViewClassList = nil
	--self.TextName = nil
	--self.TextTitleClass1 = nil
	--self.TextTitleMember1 = nil
	--self.AnimShowPanel = nil
	--self.AnimUpdateDisplay = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyMemberClassPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClassEdit)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyMemberClassPageView:OnInit()
	ArmyMemberPanelVM = ArmyMainVM:GetMemberPanelVM()
    ArmyMemberPageVM = ArmyMemberPanelVM:GetArmyMemberPageVM()
    self.TableViewCategoryAdapter =
        UIAdapterTableView.CreateAdapter(self, self.TableViewClassList, self.OnSelectChangedCategory, true)
    self.TableViewAuthorityAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewAuthority)
    self.Binders = {
        {"CategoryPmssTitle", UIBinderSetText.New(self, self.TextName)},
        {"CategoryList", UIBinderUpdateBindableList.New(self, self.TableViewCategoryAdapter)},
        {"SelectedClassItemIndex", UIBinderSetSelectedIndex.New(self, self.TableViewCategoryAdapter)},
        {"CategoryEdit", UIBinderSetIsVisible.New(self, self.BtnClassEdit)},
        { "PermissionsList", UIBinderUpdateBindableList.New(self, self.TableViewAuthorityAdapter)},
		{ "CategoryPmssTitleIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon)},
    }
end

function ArmyMemberClassPageView:OnDestroy()

end

function ArmyMemberClassPageView:OnShow()
    -- LSTR string:分组序列
    self.TextTitleClass1:SetText(LSTR(910313))
    -- LSTR string:成员数量
    self.TextTitleMember1:SetText(LSTR(910314))
    -- LSTR string:分组编辑
    self.BtnClassEdit:SetButtonText(LSTR(910065))
end

function ArmyMemberClassPageView:OnHide()

end

function ArmyMemberClassPageView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnClassEdit, self.OnClickedCategoryEdit)
end

function ArmyMemberClassPageView:OnRegisterGameEvent()

end

function ArmyMemberClassPageView:OnRegisterBinder()
    self:RegisterBinders(ArmyMemberPageVM, self.Binders)
end

function ArmyMemberClassPageView:OnSelectChangedCategory(Index, ItemData, ItemView)
    self:PlayAnimation(self.AnimUpdateDisplay)
    ArmyMemberPageVM:SelectedCategoryPermissionsInfo(Index, ItemData)
end

--- 分组编辑
function ArmyMemberClassPageView:OnClickedCategoryEdit()
    ArmyMemberPageVM:OpenCategoryEditPanel()
end

return ArmyMemberClassPageView