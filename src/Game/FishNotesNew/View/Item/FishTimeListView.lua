--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2025-02-08 15:35:55
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2025-02-12 17:22:35
FilePath: \Client\Source\Script\Game\FishNotesNew\View\Item\FishTimeListView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
---
--- Author: v_vvxinchen
--- DateTime: 2025-01-06 10:09
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTreeView = require("UI/Adapter/UIAdapterTreeView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

---@class FishTimeListView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FTreeViewList UFTreeView
---@field ImgServerBg UFImage
---@field Server UFCanvasPanel
---@field TextServer UFTextBlock
---@field TextTime UFTextBlock
---@field TextTime2 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishTimeListView = LuaClass(UIView, true)

function FishTimeListView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FTreeViewList = nil
	--self.ImgServerBg = nil
	--self.Server = nil
	--self.TextServer = nil
	--self.TextTime = nil
	--self.TextTime2 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishTimeListView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishTimeListView:OnInit()
	self.TextTime:SetText(_G.LSTR(180090))--"钓鱼时钟"
	self.TextServer:SetText(_G.LSTR(70043))--"艾"
	self.TimeAdapter = UIAdapterTreeView.CreateAdapter(self, self.FTreeViewList, self.OnSelectChanged)
	self.TimeAdapter:SetAutoExpandAll(true)
	self.Binders = {
		{ "TimeList", UIBinderUpdateBindableList.New(self, self.TimeAdapter)},
		{ "FishDetailConditionTime", UIBinderSetText.New(self, self.TextTime2) },
		{ "bFishDetailConditionTimeState", UIBinderSetIsVisible.New(self, self.Server) },
	}
end

function FishTimeListView:OnDestroy()

end

function FishTimeListView:OnShow()

end

function FishTimeListView:OnHide()

end

function FishTimeListView:OnRegisterUIEvent()

end

function FishTimeListView:OnRegisterGameEvent()

end

function FishTimeListView:OnRegisterBinder()
	self:RegisterBinders(_G.FishIngholeVM, self.Binders)
end

return FishTimeListView