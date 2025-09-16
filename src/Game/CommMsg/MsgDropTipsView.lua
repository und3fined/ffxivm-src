---
--- Author: anypkvcai
--- DateTime: 2021-08-17 11:01
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
--local ObjectPool = require("Game/ObjectPool/ObjectPool")
local UIViewMgr = require("UI/UIViewMgr")
local UIUtil = require("Utils/UIUtil")

---@class MsgDropTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Msg_DropTipsItem_UIBP MsgDropTipsItemView
---@field Root UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MsgDropTipsView = LuaClass(UIView, true)

---@field ObjectPool ObjectPool
function MsgDropTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Msg_DropTipsItem_UIBP = nil
	--self.Root = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	--self.ObjectPool = nil
	self.LootList = {}
	self.ItemCount = 0
end

function MsgDropTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Msg_DropTipsItem_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MsgDropTipsView:OnInit()
	UIUtil.SetIsVisible(self.Msg_DropTipsItem_UIBP, false)

	--local function PoolConstructor()
	--	return self:PoolConstructor()
	--end
	--
	--local function PoolDestructor(Object)
	--	return self:PoolDestructor(Object)
	--end
	--
	--self.ObjectPool = ObjectPool.New(PoolConstructor, PoolDestructor)

	self.ItemLayout = UIUtil.CanvasSlotGetLayout(self.Msg_DropTipsItem_UIBP)
end

function MsgDropTipsView:OnDestroy()
	--self.ObjectPool:ReleaseAll()
end

function MsgDropTipsView:OnShow()
	--print("self.Msg_DropTipsItem_UIBP",self.Msg_DropTipsItem_UIBP,self.Msg_DropTipsItem_UIBP.InitView)
end

function MsgDropTipsView:OnHide()

end

function MsgDropTipsView:OnRegisterUIEvent()

end

function MsgDropTipsView:OnRegisterGameEvent()

end

function MsgDropTipsView:OnRegisterTimer()
	self:RegisterTimer(self.OnTimer, 1, 0.6, 0)
end

function MsgDropTipsView:OnRegisterBinder()

end

function MsgDropTipsView:OnTimer()
	local selfLootList = self.LootList
	local Num = #selfLootList

	if Num <= 0 then
		--if self.ObjectPool:GetUsedCount() <= 0 then
		if self.ItemCount <= 0 then
			self:Hide()
			return
		end
	else
		local LootItem = table.remove(selfLootList, 1)
		self:ShowLootItem(LootItem)
		self.ItemCount = self.ItemCount + 1
	end
end

function MsgDropTipsView:AddLootList(LootList)
	if nil == LootList then
		return
	end

	for _, v in ipairs(LootList) do
		table.insert(self.LootList, v)
	end
end

function MsgDropTipsView:AddLootItem(LootItem)
	if nil == LootItem then
		return
	end

	table.insert(self.LootList, LootItem)
end

function MsgDropTipsView:ShowLootItem(LootItem)
	--print("MsgDropTipsView:ShowLootItem")
	--local Object = self.ObjectPool:AllocObject()
	local View = UIViewMgr:CloneView(self.Msg_DropTipsItem_UIBP, self, true)
	self.Root:AddChild(View)
	UIUtil.CanvasSlotSetLayout(View, self.ItemLayout)

	local Params = { LootItem = LootItem, View = self, OnItemAnimationFinished = self.OnItemAnimationFinished }
	View:ShowView(Params)
end

--function MsgDropTipsView:PoolConstructor()
--	local Item = UIViewMgr:CloneView(self.Msg_DropTipsItem_UIBP, nil, true, false)
--	self.Root:AddChildToCanvas(Item)
--	UIUtil.CanvasSlotSetLayout(Item, self.ItemLayout)
--	Item:HideView()
--	return Item
--end
--
--function MsgDropTipsView:PoolDestructor(Object)
--	Object:HideView()
--end

function MsgDropTipsView:OnItemAnimationFinished(View)
	self.ItemCount = self.ItemCount - 1
	self.Root:RemoveChild(View)
	UIViewMgr:RecycleView(View)

	--self.ObjectPool:FreeObject(Object)
	--print("OnItemAnimationFinished", self.ObjectPool:GetUsedCount())
end

return MsgDropTipsView