--[[
Author: zhangyuhao_ds zhangyuhao@dasheng.tv
Date: 2025-01-13 19:37:45
LastEditors: zhangyuhao_ds zhangyuhao@dasheng.tv
LastEditTime: 2025-06-27 18:34:27
FilePath: \Script\Game\Ops\View\OpsActivity\Item\OpsWhaleMonutRebatesWinView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
---
--- Author: Administrator
--- DateTime: 2024-12-06 10:41
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBindableList = require("UI/UIBindableList")
local OpsActivityWhaleMonutItemVM = require("Game/Ops/VM/OpsActivityWhaleMonutItemVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIViewMgr = require("UI/UIViewMgr")
local ProtoRes = require("Protocol/ProtoRes")
local SCORE_TYPE = ProtoRes.SCORE_TYPE

---@class OpsWhaleMonutRebatesWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnRecommend OpsCommBtnLView
---@field CommSidebarFrameS_UIBP CommSidebarFrameSView
---@field PopUpBG CommonPopUpBGView
---@field TableViewList UTableView
---@field TextHint UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsWhaleMonutRebatesWinView = LuaClass(UIView, true)

function OpsWhaleMonutRebatesWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnRecommend = nil
	--self.CommSidebarFrameS_UIBP = nil
	--self.PopUpBG = nil
	--self.TableViewList = nil
	--self.TextHint = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsWhaleMonutRebatesWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnRecommend)
	self:AddSubView(self.CommSidebarFrameS_UIBP)
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsWhaleMonutRebatesWinView:OnInit()
	self.TaskList = UIBindableList.New(OpsActivityWhaleMonutItemVM)
	self.AdapterTableViewDetail = UIAdapterTableView.CreateAdapter(self, self.TableViewList)
end

function OpsWhaleMonutRebatesWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnRecommend.CommBtnL, self.OnClickBuy)
end

function OpsWhaleMonutRebatesWinView:OnDestroy()

end

function OpsWhaleMonutRebatesWinView:OnShow()
	self.BtnRecommend:SetBtnName(_G.LSTR(100040))
	self.CommSidebarFrameS_UIBP:SetTitleText(_G.LSTR(100041))
	self.TextHint:SetText(_G.LSTR(100042))
	if self.Params and self.Params.ViewModel then
		local ViewModel = self.Params.ViewModel
		local GoodsID = ViewModel:GetGoodsID()
		self.GoodsID = GoodsID
		self.BtnRecommend:SetBtnPriceByGoodsID(GoodsID)
		self:UpdateTaskList(ViewModel)
	end
end

function OpsWhaleMonutRebatesWinView:OnClickBuy()
	local GoodsID = self.GoodsID

	if GoodsID and GoodsID ~= 0 then
		_G.StoreMgr:OpenExternalPurchaseInterfaceByNewUIBP(GoodsID)
	end
end

function OpsWhaleMonutRebatesWinView:UpdateTaskList(ViewModel)
	self.TaskList:UpdateByValues(ViewModel.Tasks)
	self.AdapterTableViewDetail:UpdateAll(self.TaskList)
end

return OpsWhaleMonutRebatesWinView