---
--- Author: anypkvcai
--- DateTime: 2023-04-04 17:30
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local FLOG_INFO = _G.FLOG_INFO

---@class SampleCommBP3PageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommMenu CommMenuView
---@field CommMenu2 CommMenuView
---@field CommVerIconTabs CommVerIconTabsView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SampleCommBP3PageView = LuaClass(UIView, true)

function SampleCommBP3PageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommMenu = nil
	--self.CommMenu2 = nil
	--self.CommVerIconTabs = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SampleCommBP3PageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommMenu)
	self:AddSubView(self.CommMenu2)
	self:AddSubView(self.CommVerIconTabs)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SampleCommBP3PageView:OnInit()

end

function SampleCommBP3PageView:OnDestroy()

end

function SampleCommBP3PageView:OnShow()
	do
		local IconPath = "Texture2D'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Main_WZ.UI_Icon_Job_Main_WZ"
		local ListData = { { IconPath = IconPath }, { IconPath = IconPath }, { IconPath = IconPath }, { IconPath = IconPath }, { IconPath = IconPath } }
		self.CommVerIconTabs:UpdateItems(ListData, 2)
	end

	do
		--没有二级菜单 通过回调函数的Index判断选中哪个
		local ListData = { { Name = 'Item1' }, { Name = 'Item2' }, { Name = 'Item3' }, { Name = 'Item4' }, { Name = 'Item5' } }
		self.CommMenu:UpdateItems(ListData)

		--选中第2个页签
		self.CommMenu:SetSelectedIndex(2)
	end

	do
		--有二级菜单 需要传递Key 通过回调函数的ItemData:GetKey()判断选中哪个
		-- Key可以自己定义 只要在选中回调函数里能区分就行 但是不能重复
		local ListData = {}

		for i = 1, 5 do
			local Parent = { Name = string.format("Parent%d", i), Key = i }
			Parent.Children = {}
			table.insert(ListData, Parent)
			for j = 1, 3 do
				local Child = { Name = string.format("Child%d", j), Key = i * 10 + j }
				table.insert(Parent.Children, Child)
			end
		end
		-- self.CommMenu2:SetParams({HasTwoTab = true})
		self.CommMenu2:UpdateItems(ListData, false)

		--选中第2个父页签第1个子页签, 并展开
		-- self.CommMenu2:SetSelectedKey(21)

		-- 折叠所有 也可以通过 UpdateItems 参数控制
		--self.CommMenu2:CollapseAll()

		-- 展开所有 也可以通过 UpdateItems 参数控制
		--self.CommMenu2:ExpandAll()
	end
end

function SampleCommBP3PageView:OnHide()

end

function SampleCommBP3PageView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.CommVerIconTabs, self.OnSelectionChangedCommVerIconTabs)
	UIUtil.AddOnSelectionChangedEvent(self, self.CommMenu, self.OnSelectionChangedCommMenu)
	UIUtil.AddOnSelectionChangedEvent(self, self.CommMenu2, self.OnSelectionChangedCommMenu2)
end

function SampleCommBP3PageView:OnRegisterGameEvent()

end

function SampleCommBP3PageView:OnRegisterBinder()

end

function SampleCommBP3PageView:OnSelectionChangedCommVerIconTabs(Index)
	FLOG_INFO("OnSelectionChangedCommVerIconTabs Index=%d ", Index)
end

function SampleCommBP3PageView:OnSelectionChangedCommMenu(Index)
	FLOG_INFO("OnSelectionChangedCommMenu Index=%d ", Index)
end

function SampleCommBP3PageView:OnSelectionChangedCommMenu2(_, ItemData)
	FLOG_INFO("OnSelectionChangedCommMenu2  %d ", ItemData:GetKey())
end

return SampleCommBP3PageView