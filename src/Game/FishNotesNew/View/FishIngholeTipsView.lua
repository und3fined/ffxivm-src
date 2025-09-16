---
--- Author: v_vvxinchen
--- DateTime: 2025-01-06 10:07
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

---@class FishIngholeTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBg2 UFImage
---@field TableView UTableView
---@field TextName UFTextBlock
---@field TextState UFTextBlock
---@field TextTitle2 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishIngholeTipsView = LuaClass(UIView, true)

function FishIngholeTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBg2 = nil
	--self.TableView = nil
	--self.TextName = nil
	--self.TextState = nil
	--self.TextTitle2 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishIngholeTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishIngholeTipsView:OnInit()
	self.TextName:SetText(_G.LSTR(180080))--"捕鱼人之识"
	self.TextState:SetText(_G.LSTR(180081))--"能察觉到稀有鱼类活动的增益效果，只有拥有捕鱼人之识增益 ，才有概率钓起该鱼类"
	self.TextTitle2:SetText(_G.LSTR(180050))--"捕鱼人之识前置鱼"
	self.Adapter = UIAdapterTableView.CreateAdapter(self, self.TableView)
	self.Binders = {
		{"FishDetailStatusFishIoreList", UIBinderUpdateBindableList.New(self, self.Adapter)},
	}
end

function FishIngholeTipsView:OnDestroy()

end

function FishIngholeTipsView:OnShow()

end

function FishIngholeTipsView:OnHide()

end

function FishIngholeTipsView:OnRegisterUIEvent()

end

function FishIngholeTipsView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonUp, self.OnPreprocessedMouseButtonUp)
end

function FishIngholeTipsView:OnRegisterBinder()
	self:RegisterBinders(_G.FishIngholeVM, self.Binders)
end

function FishIngholeTipsView:OnPreprocessedMouseButtonUp(MouseEvent)
	local MousePosition =  _G.UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
	if UIUtil.IsUnderLocation(self.ImgBg2, MousePosition) == false then
		_G.UIViewMgr:HideView(_G.UIViewID.FishIngHoleTips)
	end
end

function FishIngholeTipsView:OnRegisterTimer()
	self:RegisterTimer(self.OnTimer, 0, 1, 0)
end
function FishIngholeTipsView:OnTimer()
	_G.FishIngholeVM:RefreshFishIoreListSecond()
end

return FishIngholeTipsView