--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2024-04-16 20:43:53
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2024-12-03 15:34:06
FilePath: \Client\Source\Script\Game\FishNotes\View\Item\FishIngholeWindowsItemView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
---
--- Author: Administrator
--- DateTime: 2023-03-29 12:11
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

local FishIngholeVM = require("Game/FishNotes/FishIngholeVM")

---@class FishIngholeWindowsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TableViewTime UTableView
---@field TextTitle UFTextBlock
---@field AnimUpdate UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishIngholeWindowsItemView = LuaClass(UIView, true)

function FishIngholeWindowsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TableViewTime = nil
	--self.TextTitle = nil
	--self.AnimUpdate = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishIngholeWindowsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishIngholeWindowsItemView:OnInit()
	self.FishDetailWindowsList = UIAdapterTableView.CreateAdapter(self, self.TableViewTime, nil, false, false)

	self.Binders = {
		{ "FishDetailWindowsList", UIBinderUpdateBindableList.New(self, self.FishDetailWindowsList) },
	}
end

function FishIngholeWindowsItemView:OnDestroy()

end

function FishIngholeWindowsItemView:OnShow()
	self.TextTitle:SetText(_G.LSTR(180053))--窗口期
end

function FishIngholeWindowsItemView:OnHide()

end

function FishIngholeWindowsItemView:OnRegisterUIEvent()

end

function FishIngholeWindowsItemView:OnRegisterGameEvent()

end

function FishIngholeWindowsItemView:OnRegisterBinder()
	self:RegisterBinders(FishIngholeVM, self.Binders)
end

return FishIngholeWindowsItemView