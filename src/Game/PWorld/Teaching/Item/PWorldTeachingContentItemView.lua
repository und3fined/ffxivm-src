---
--- Author: ashyuan
--- DateTime: 2024-05-01 15:14
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local TeachingContentVM = require("Game/Pworld/Teaching/TeachingContentVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local EventID = require("Define/EventID")
--local MainPanelVM = require("Game/Main/MainPanelVM")

---@class PWorldTeachingContentItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TableViewProject UTableView
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldTeachingContentItemView = LuaClass(UIView, true)

function PWorldTeachingContentItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TableViewProject = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldTeachingContentItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldTeachingContentItemView:OnInit()
	self.TableViewProjectAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewProject, nil, false)
end

function PWorldTeachingContentItemView:OnDestroy()

end

function PWorldTeachingContentItemView:OnShow()
	local Params = self.Params
	if Params and Params.InteractiveID then
		TeachingContentVM:UpdateContent(Params.InteractiveID)
	end

	-- self.TopLeftUIVisible = MainPanelVM:GetTopLeftMainTeamPanelVisible()
    -- if self.TopLeftUIVisible then
	-- 	self.TopLeftUIVisible = false
    --     MainPanelVM:SetTopLeftMainTeamPanelVisible(false)
    -- end

	self:PlayAnimation(self.AnimIn)
end

function PWorldTeachingContentItemView:OnHide()
    -- if not self.TopLeftUIVisible then
    --     MainPanelVM:SetTopLeftMainTeamPanelVisible(true)
    -- end
end

function PWorldTeachingContentItemView:OnRegisterUIEvent()

end

function PWorldTeachingContentItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.PWorldUIChange, self.OnPWorldUIChange)
	self:RegisterGameEvent(EventID.PWorldItemChange, self.OnPWorldItemChange)
end

-- 挑战项目状态变化，更新State后刷新Content
function PWorldTeachingContentItemView:OnPWorldUIChange(UIType, ResultType)
	TeachingContentVM:UpdateItemState(UIType, ResultType)
	TeachingContentVM:RefreshContent()
end

-- 切换挑战项目，重置Content
function PWorldTeachingContentItemView:OnPWorldItemChange(InteractiveID)
	TeachingContentVM:UpdateContent(InteractiveID)
end

function PWorldTeachingContentItemView:OnRegisterBinder()
	local Binders = {
		{ "Content", UIBinderSetText.New(self, self.TextTitle) },
		{ "TableViewProjectVMList", UIBinderUpdateBindableList.New(self, self.TableViewProjectAdapter)},
	}

	self:RegisterBinders(TeachingContentVM, Binders)
end

return PWorldTeachingContentItemView