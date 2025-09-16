local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local QUEST_STATUS =  ProtoCS.CS_QUEST_STATUS
local MallTypeInfo = ProtoRes.MallTypeInfo

local UnlockImg = "Texture2D'/Game/UI/Texture/Shop/UI_Shop_Img_UnLock.UI_Shop_Img_UnLock'"

---@class ShopInletListItemVM : UIViewModel
local ShopInletListItemVM = LuaClass(UIViewModel)

---Ctor
function ShopInletListItemVM:Ctor()
	self.Name = nil
	self.Icon = nil
	self.ScoreID = nil
	self.ShopID = nil
	self.State = nil
	self.ShopType = nil
	self.UnLockNotifyTipsID = 0
end

function ShopInletListItemVM:OnInit()

end

---UpdateVM
---@param List table
function ShopInletListItemVM:UpdateVM(List)
	--FLOG_ERROR("Test Item VM = %s",table_to_string(List))
	self.Name = List.Name
	self.ShopID = List.ID
	self.ShopType = List.ShopType
	self.UnLockNotifyTipsID = List.UnLockNotifyTipsID
	self:SetImgState(List.Icon, List.Task, List.ShopType)
    --- 表里ScoreID有可能不填，这里拦截一下，否则ScoreMgr:GetIconName会报错
	local Cfg_ScoreID = tonumber(List.ScoreID)
	if Cfg_ScoreID == nil then
		FLOG_WARNING("Cfg_ScoreID is nil. ShopID = %d", List.ID)
		return
	end
	self.ScoreID = Cfg_ScoreID
end

function ShopInletListItemVM:SetImgState(Icon)
	local IsUnLock = _G.ShopMgr:ShopIsUnLock(self.ShopID)
	if IsUnLock then
		self.Icon = Icon
		self.State = true
	else
		self.Icon = UnlockImg
		self.State = false
	end
end



function ShopInletListItemVM:IsEqualVM(Value)
    --return nil ~= Value and Value.ID == self.ShopItemData.ID
end


return ShopInletListItemVM