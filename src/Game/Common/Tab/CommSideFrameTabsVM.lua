---
--- Author: ds_herui
--- DateTime: 2023-12-26 16:11
--- Description:
---


local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local CommTabsDefine = require("Game/Common/Tab/CommTabsDefine")
local CommSideFrameTabItemVM = require("Game/Common/Tab/CommSideFrameTabItemVM")
---@class CommSideFrameTabsVM : UIViewModel
local CommSideFrameTabsVM = LuaClass(UIViewModel)

---Ctor
function CommSideFrameTabsVM:Ctor()
	self.CommSideFrameTabItemVMTab1 = CommSideFrameTabItemVM.New()
	self.CommSideFrameTabItemVMTab1.ParentVM = self
	self.CommSideFrameTabItemVMTab2 = CommSideFrameTabItemVM.New()
	self.CommSideFrameTabItemVMTab2.ParentVM = self
	self.CommSideFrameTabItemVMTab3 = CommSideFrameTabItemVM.New()
	self.CommSideFrameTabItemVMTab3.ParentVM = self
	self.CommSideFrameTabItemVMTab4 = CommSideFrameTabItemVM.New()
	self.CommSideFrameTabItemVMTab4.ParentVM = self
	self.CurrentSelect = CommTabsDefine.TabType.Tab1
	self.bSelect = false
end
function CommSideFrameTabsVM:SetCurrentSelect(InIndex)
	self.CurrentSelect = InIndex
end

function CommSideFrameTabsVM:OnUpdateToSelect(NewValue,OldValue)
	local tempList = {}
	tempList[#tempList + 1] = self.CommSideFrameTabItemVMTab1
	tempList[#tempList + 1] = self.CommSideFrameTabItemVMTab2
	tempList[#tempList + 1] = self.CommSideFrameTabItemVMTab3
	tempList[#tempList + 1] = self.CommSideFrameTabItemVMTab4
	for key,value in ipairs(tempList) do
		if value.bEnable then
			if value.CurrentType == self.CurrentSelect then
				value.bSelect = true
			else
				value.bSelect = false
			end
		end
    end
	if self.UpdateVMfunc ~= nil then
		self.UpdateVMfunc(NewValue)
	end
end
function CommSideFrameTabsVM:UpdateRedDots(InFunction,InData)
	local tempList = {}
	tempList[#tempList + 1] = self.CommSideFrameTabItemVMTab1
	tempList[#tempList + 1] = self.CommSideFrameTabItemVMTab2
	tempList[#tempList + 1] = self.CommSideFrameTabItemVMTab3
	tempList[#tempList + 1] = self.CommSideFrameTabItemVMTab4
	if InFunction ~= nil then
		InFunction(tempList,InData)
	end

end
--要返回当前类
return CommSideFrameTabsVM