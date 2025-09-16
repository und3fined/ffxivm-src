---
--- Author: qibaoyiyi
--- DateTime: 2023-03-08 09:53
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

local ArmyMainVM = require("Game/Army/VM/ArmyMainVM")
local ArmyMemberPanelVM = nil
local ArmyMemberPageVM = nil
local ArmyMemEditSortPageVM = nil

local ArmyMgr = require("Game/Army/ArmyMgr")
local UIDefine = require("Define/UIDefine")
local CommBtnColorType = UIDefine.CommBtnColorType
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID
local LSTR = _G.LSTR

--- todo 废弃待删蓝图
---@class ArmyMemberClassEditSortPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCancelEdit CommBtnLView
---@field BtnSaveBack CommBtnLView
---@field RichTextOnlineNum URichTextBox
---@field TableViewClass UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyMemberClassEditSortPageView = LuaClass(UIView, true)

function ArmyMemberClassEditSortPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCancelEdit = nil
	--self.BtnSaveBack = nil
	--self.RichTextOnlineNum = nil
	--self.TableViewClass = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyMemberClassEditSortPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnCancelEdit)
	self:AddSubView(self.BtnSaveBack)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyMemberClassEditSortPageView:OnInit()
	ArmyMemberPanelVM = ArmyMainVM:GetMemberPanelVM()
    ArmyMemberPageVM = ArmyMemberPanelVM:GetArmyMemberPageVM()
    ArmyMemEditSortPageVM = ArmyMemberPageVM:GetMemEditSortPageVM()
	self.TableViewCategoryAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewClass)
	self.TableViewCategoryAdapter:SetOnClickedCallback(self.OnClickedItem)
	self.Binders = {
		{"CategoryList", UIBinderUpdateBindableList.New(self, self.TableViewCategoryAdapter)},
	}
	UIUtil.SetIsVisible(self.BtnSaveBack, false, true, false)
end

function ArmyMemberClassEditSortPageView:OnClickedItem(Index, ItemData, ItemView)
	local PopInputParams = {
        -- LSTR string:新增分组
        Title = LSTR(910148),
        -- LSTR string:请输入新的分组名称
        HintText = LSTR(910229),
        MaxTextLength = 5,
		-- LSTR string:确定
		ConfirmText = LSTR(910182),
        SureCallback = function(Name)
            if Name == "" then
                return
            end
			local IsExist = ArmyMemEditSortPageVM:CheckedIsExistCategoryName(Name)
			if IsExist then
				-- LSTR string:该分组名称已存在
				_G.MsgTipsUtil.ShowTips(LSTR(910220))
			else
				ArmyMgr:SendArmyAddCategoryMsg(Name)
			end
        end
    }
    UIViewMgr:ShowView(UIViewID.ArmyEditClassNamePanel, PopInputParams)
end

function ArmyMemberClassEditSortPageView:OnDestroy()

end

function ArmyMemberClassEditSortPageView:OnShow()
	self.RichTextOnlineNum:SetText(ArmyMemberPageVM.MemberOnLinenNum)
	-- LSTR string:结束编辑并返回
	self.BtnCancelEdit:SetText(_G.LSTR(910203))
	self.BtnCancelEdit:UpdateImage(CommBtnColorType.Recommend)
end

function ArmyMemberClassEditSortPageView:OnHide()

end

function ArmyMemberClassEditSortPageView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSaveBack, self.OnClickedSaveBack)
	UIUtil.AddOnClickedEvent(self, self.BtnCancelEdit, self.OnClickedCancel)
end

function ArmyMemberClassEditSortPageView:OnRegisterGameEvent()

end

function ArmyMemberClassEditSortPageView:OnRegisterBinder()
	self:RegisterBinders(ArmyMemEditSortPageVM, self.Binders)
end

function ArmyMemberClassEditSortPageView:OnClickedSaveBack()
end

function ArmyMemberClassEditSortPageView:OnClickedCancel()
	ArmyMemberPageVM:CloseCategoryEdit()
end

return ArmyMemberClassEditSortPageView