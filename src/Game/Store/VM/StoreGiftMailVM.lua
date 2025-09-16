local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local StoreMgr = require("Game/Store/StoreMgr")
local ItemCfg = require("TableCfg/ItemCfg")
local StoreCfg = require("TableCfg/StoreCfg")

---@class StoreGiftMailVM : UIViewModel
local StoreGiftMailVM = LuaClass(UIViewModel)

---Ctor
function StoreGiftMailVM:Ctor()
	self.ToName = ""
	self.FromName = ""
	self.AmountText = 0
	self.ContainsItemList = nil
	self.MultiBuyIcon = ""
	self.OriginalPanelVisible = false
	self.DiscountPanelVisible = false
	self.DiscountPanelVisible = false
	self.DeadlinePanelVisible = false
	self.GoodsPanelVisible = false
	self.PropsPanelVisible = false
	self.PanelAmountVisible = false
	self.GiftMessage = ""
	self.ItemNameText = ""
	self.IsProp = false
	self.GiftTime = 0
	self.DecorativeStyle = 1
	self.AlreadyReceived = false
	self.GoodsID = 0
end

function StoreGiftMailVM:UpdateVM(Value)
	if Value == nil then
		return
	end
	self.AlreadyReceived = Value.AlreadyReceived

	local FriendID = Value.FriendID
	local GoodID = Value.GoodID
	self.GoodsID = GoodID
	local TempData = {Cfg = StoreCfg:FindCfgByKey(GoodID)}
	if TempData.Cfg == nil then
		FLOG_ERROR("StoreGiftMailVM:UpdateVM   TempData == nil")
		return
	end
	_G.StoreMainVM:InitContainsItemList(TempData.Cfg.Items)
	self.ContainsItemList = _G.StoreMainVM.ContainsItemList

	self.ItemNameText = TempData.Cfg.Name
	local IsProp = StoreMgr:GetIsPropsByID(GoodID)
	self.IsProp = IsProp
	self.PropsPanelVisible = IsProp
	self.GoodsPanelVisible = not IsProp
	local IconPath = TempData.Cfg.Icon
	if self.IsProp then
		local ItemCfgData = ItemCfg:FindCfgByKey(TempData.Cfg.Items[1].ID)
		if nil ~= ItemCfgData then
			IconPath = ItemCfgData.IconID
		end
	end
	self.MultiBuyIcon = StoreMgr.GetGoodIconPath(IconPath)
    self.MultiBuyBg = TempData.Cfg.PropQualityIconPath
	self.BuyGoodIcon = StoreMgr.GetGoodIconPath(IconPath)
	self.GiftMessage = Value.GiftMessage 
	self.AmountText = string.format(LSTR(950041), tonumber(Value.GiftNum))	-- "数量:%d"
	self.DecorativeStyle = Value.Style
	self.GiftTime = Value.GiftTime
	_G.RoleInfoMgr:QueryRoleSimple(FriendID, self.UpdateFriendDetail, self, true)

end

function StoreGiftMailVM:OnInit()
end

function StoreGiftMailVM:OnBegin()

end

function StoreGiftMailVM:OnEnd()
end

function StoreGiftMailVM:OnShutdown()
end

function StoreGiftMailVM:UpdateFriendDetail(ViewModel)
	local MajorUtil = require("Utils/MajorUtil")
	self.ToName = MajorUtil.GetMajorName()
	self.FromName = ViewModel.Name
	UIViewMgr:ShowView(_G.UIViewID.StoreGiftMailWin, {GoodsID = self.GoodsID, bIsExternal = true})
end

return StoreGiftMailVM