---
--- Author: xingcaicao
--- DateTime: 2024-07-10 10:16
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local FriendVM = require("Game/Social/Friend/FriendVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")

---@class FriendScreenProfListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---@field TableViewProf UTableView
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FriendScreenProfListItemView = LuaClass(UIView, true)

function FriendScreenProfListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--self.TableViewProf = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FriendScreenProfListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FriendScreenProfListItemView:OnInit()
	self.TableAdapterProf = UIAdapterTableView.CreateAdapter(self, self.TableViewProf, self.OnSelectChangedProf, true)
end

function FriendScreenProfListItemView:OnDestroy()

end

function FriendScreenProfListItemView:OnShow()

end

function FriendScreenProfListItemView:OnHide()

end

function FriendScreenProfListItemView:OnRegisterUIEvent()

end

function FriendScreenProfListItemView:OnRegisterGameEvent()

end

function FriendScreenProfListItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params or nil == Params.Data then
		return
	end

	local Data = Params.Data

	-- 名字
	self.TextName:SetText(Data.Name or "")

	-- 图标
	local IconPath = Data.Icon
	if not string.isnilorempty(IconPath) then
		UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, IconPath)
	end

	-- 职业列表
	self.TableAdapterProf:UpdateAll(Data.ProfInfoList or {})
end

function FriendScreenProfListItemView:OnSelectChangedProf(Index, ItemData, ItemView)
	if nil == ItemData then
		return
	end

	local ProfID = ItemData.ProfID
	if ProfID then
		FriendVM:UpdateProfScreen(ProfID)
	end
end

return FriendScreenProfListItemView