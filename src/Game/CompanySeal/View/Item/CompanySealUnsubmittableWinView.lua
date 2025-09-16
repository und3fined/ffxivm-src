---
--- Author: Administrator
--- DateTime: 2024-06-24 16:29
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local LootMappingCfg = require("TableCfg/LootMappingCfg")
local ItemUtil = require("Utils/ItemUtil")
local ItemVM = require("Game/Item/ItemVM")
local UIBindableList = require("UI/UIBindableList")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local ItemDefine = require("Game/Item/ItemDefine")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local LSTR = _G.LSTR

---@class CompanySealUnsubmittableWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn CommBtnLView
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field FCanvasPanel_147 UFCanvasPanel
---@field RichTextHint URichTextBox
---@field TableViewSlot UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CompanySealUnsubmittableWinView = LuaClass(UIView, true)

function CompanySealUnsubmittableWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.Comm2FrameM_UIBP = nil
	--self.FCanvasPanel_147 = nil
	--self.RichTextHint = nil
	--self.TableViewSlot = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CompanySealUnsubmittableWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Btn)
	self:AddSubView(self.Comm2FrameM_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CompanySealUnsubmittableWinView:OnInit()
    self.ItemList =
        UIBindableList.New(
        ItemVM,
        {
            Source = ItemDefine.ItemSource.MatchReward,
            IsCanBeSelected = true,
            IsShowNum = true,
            IsDaily = false,
            IsShowSelectStatus = false
        }
    )
    self.TableViewAdapter =
        UIAdapterTableView.CreateAdapter(self, self.TableViewSlot, self.OnSelectChanged, true, false)
end

function CompanySealUnsubmittableWinView:OnDestroy()

end

function CompanySealUnsubmittableWinView:OnShow()
    if not self.Params then
        return
    end

	self.Comm2FrameM_UIBP.FText_Title:SetText(LSTR(1160002))
	self.Btn.TextContent:SetText(LSTR(1160044))
	--该物品已镶嵌<span color="#d1ba8e">魔晶石</>，若仍需提交，需先将魔晶石卸下

	local Content = string.format("%s<span color=\"#d1ba8e\">%s</>,%s", LSTR(1160051), LSTR(1160057), LSTR(1160001))
	self.RichTextHint:SetText(Content)

	if self.Params.ItemList then
        self:UpdateListView(self.Params.ItemList)
    end

end

function CompanySealUnsubmittableWinView:OnHide()

end

function CompanySealUnsubmittableWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnClickedBtn)
end

function CompanySealUnsubmittableWinView:OnRegisterGameEvent()

end

function CompanySealUnsubmittableWinView:OnRegisterBinder()

end

---更新item列表
---@param ItemList table
function CompanySealUnsubmittableWinView:UpdateListView(ItemList)
    self.ItemList:Clear()
    for _, V in ipairs(ItemList) do
        self.ItemList:AddByValue({GID = V.GID, ResID = V.ResID, Num = 1}, nil, true)
    end
    self.TableViewAdapter:UpdateAll(self.ItemList)
end

function CompanySealUnsubmittableWinView:OnSelectChanged(Index, ItemData, ItemView)
    ItemTipsUtil.ShowTipsByGID(ItemData.GID, ItemView)
end

function CompanySealUnsubmittableWinView:OnClickedBtn()
	self:Hide()
end

return CompanySealUnsubmittableWinView