---
--- Author: Administrator
--- DateTime: 2024-12-16 14:27
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBindableList = require("UI/UIBindableList")
local StoreGoodVM = require("Game/Store/VM/ItemVM/StoreGoodVM")
local ProtoRes = require("Protocol/ProtoRes")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")

---@class OpsShoppingExchangeWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm2FrameL_UIBP Comm2FrameLView
---@field RichText URichTextBox
---@field TableView UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsShoppingExchangeWinView = LuaClass(UIView, true)

function OpsShoppingExchangeWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm2FrameL_UIBP = nil
	--self.RichText = nil
	--self.TableView = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsShoppingExchangeWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm2FrameL_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsShoppingExchangeWinView:OnInit()
	self.GoodsTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableView)
	self.GoodList = UIBindableList.New(StoreGoodVM, {IsCalculateDisCount = false})
end

function OpsShoppingExchangeWinView:OnDestroy()

end

function OpsShoppingExchangeWinView:OnShow()
	if self.Params == nil then
		return
	end
	if self.Params.Node == nil then
		return
	end
	local Node = self.Params.Node
	local NodeID  = Node.Head.NodeID
	local ActivityNode = ActivityNodeCfg:FindCfgByKey(NodeID)
	if ActivityNode then
		self.Comm2FrameL_UIBP:SetTitleText(ActivityNode.NodeTitle)
		self.RichText:SetText(ActivityNode.NodeDesc)
		if ActivityNode.ParamNum > 1 then
			self:UpdateGoodsList(_G.StoreMgr:OnGetStoreGoodsByPriceLimit(ProtoRes.Store_Label_Type.STORE_LABEL_MAIN_FASHION, ActivityNode.Params[1], ActivityNode.Params[2]))
		end
	end

end

function OpsShoppingExchangeWinView:OnHide()

end

function OpsShoppingExchangeWinView:OnRegisterUIEvent()

end

function OpsShoppingExchangeWinView:OnRegisterGameEvent()

end

function OpsShoppingExchangeWinView:OnRegisterBinder()

end

function OpsShoppingExchangeWinView:UpdateGoodsList(Goods)
	self.GoodList:UpdateByValues(Goods)
	self.GoodsTableViewAdapter:UpdateAll(self.GoodList)
end

return OpsShoppingExchangeWinView