local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local OpsCommTabChildItemVM = require("Game/Ops/VM/OpsCommTabChildItemVM")
local OpsActivityDefine = require("Game/Ops/OpsActivityDefine")
local ActivityPageCfg = require("TableCfg/ActivityPageCfg")
local OpsActivityMgr
---@class OpsCommTabParentItemVM : UIViewModel
local OpsCommTabParentItemVM = LuaClass(UIViewModel)

function OpsCommTabParentItemVM:Ctor()
    self.BindableActivityList = UIBindableList.New( OpsCommTabChildItemVM )
	self.IsExpanded = false
	self.CanExpanded = true

	self.UpArrowVisible = false
	self.DownArrowVisible = false

	self.SelectVisible = false
	self.NameColor = "#d5d5d5"

	self.NewcomersVisible = nil

	OpsActivityMgr = _G.OpsActivityMgr
end

function OpsCommTabParentItemVM:GetKey()
	return self.Classcify
end

function OpsCommTabParentItemVM:GetFirstActivityID()
	local ChildItemVM = self.BindableActivityList:Get(1)
	if ChildItemVM == nil then
		return
	end
	return ChildItemVM.ActivityID
end

function OpsCommTabParentItemVM:GetClasscifyID()
	return self.Classcify
end

function OpsCommTabParentItemVM:HasActivityID(ActivityID)
	for j = 1, self.BindableActivityList:Length() do
		local ActivityVM = self.BindableActivityList:Get(j)
		if ActivityVM~= nil then
			if ActivityVM:GetKey() == ActivityID then
				return true
			end
		end
	end

	return false
end

function OpsCommTabParentItemVM:UpdateVM(Value)
	self.Classcify = Value.Classcify
	self.CanExpanded = true
	local ActivityList = OpsActivityMgr:GetActivityListByClassify(Value.Classcify)
	self.BindableActivityList:UpdateByValues(ActivityList)

	local Cfg = ActivityPageCfg:FindCfgByKey(Value.Classcify)
	if Cfg ~= nil then
		self.Name = Cfg.PageName
		self.CanExpanded = Cfg.NoChildPage == 0
		self.NewcomersVisible = Cfg.PageTag == OpsActivityDefine.ActivityPageTag.ActivityNodeTypeNewcomers
		self.ImgPic = Cfg.PageIcon
		self.SelectImgPic = Cfg.SelectedPageIcon
	end

	self.IsExpanded = false
	self:UpdateArrowVisible()

end

function OpsCommTabParentItemVM:GetBPName()
	local ChildItemVM = self.BindableActivityList:Get(1)
	if ChildItemVM == nil then
		return ""
	end
	return ChildItemVM:GetBPName()
end

function OpsCommTabParentItemVM:GetBGPicPath()
	local ChildItemVM = self.BindableActivityList:Get(1)
	if ChildItemVM == nil then
		return ""
	end
	return ChildItemVM:GetBGPicPath()
end

function OpsCommTabParentItemVM:GetActivityTimeDisplay()
	local ChildItemVM = self.BindableActivityList:Get(1)
	if ChildItemVM == nil then
		return 0
	end
	return ChildItemVM:GetActivityTimeDisplay()
end

function OpsCommTabParentItemVM:GetActivityHelpInfo()
	local ChildItemVM = self.BindableActivityList:Get(1)
	if ChildItemVM == nil then
		return 0
	end
	return ChildItemVM:GetActivityHelpInfo()
end

--活动结束时间戳
function OpsCommTabParentItemVM:GetActivityTimeCountdown()
	local ChildItemVM = self.BindableActivityList:Get(1)
	if ChildItemVM == nil then
		return 0
	end
	return ChildItemVM:GetActivityTimeCountdown()
end

--活动完整时间显示
function OpsCommTabParentItemVM:GetActivityCompleteTime()
	local ChildItemVM = self.BindableActivityList:Get(1)
	if ChildItemVM == nil then
		return ""
	end
	return ChildItemVM:GetActivityCompleteTime()
end

--指定输入时间显示
function OpsCommTabParentItemVM:GetActivityAppointTime()
	local ChildItemVM = self.BindableActivityList:Get(1)
	if ChildItemVM == nil then
		return ""
	end

	return ChildItemVM:GetActivityAppointTime()
end



function OpsCommTabParentItemVM:AdapterOnGetCanBeSelected()
    return not (self.CanExpanded == true  and self.IsExpanded == false)
end

function OpsCommTabParentItemVM:AdapterOnGetWidgetIndex()
    return 0
end

function OpsCommTabParentItemVM:AdapterOnGetIsCanExpand()
	return self.CanExpanded
end

function OpsCommTabParentItemVM:AdapterOnGetChildren()
	if self.CanExpanded == true then
		return self.BindableActivityList:GetItems()
	end
end

function OpsCommTabParentItemVM:AdapterOnExpansionChanged(bExpanded)
	self.IsExpanded = bExpanded
	self:UpdateArrowVisible()
end

function OpsCommTabParentItemVM:UpdateArrowVisible()
	local IsExpanded = self.IsExpanded

	self.UpArrowVisible = self.CanExpanded and IsExpanded
	self.DownArrowVisible = self.CanExpanded and not IsExpanded
	
end

function OpsCommTabParentItemVM:SetSelectedVisible(Visible)
	self.SelectVisible = Visible
	self.NameColor = Visible and "#594123" or "#d5d5d5"
end


function OpsCommTabParentItemVM:IsEqualVM(Value)
    return Value ~= nil and self.Classcify ~= nil and self.Classcify == Value.Classcify
end

--要返回当前类
return OpsCommTabParentItemVM