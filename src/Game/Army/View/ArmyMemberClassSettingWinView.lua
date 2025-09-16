---
--- Author: qibaoyiyi
--- DateTime: 2023-03-22 14:27
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoCommon = require("Protocol/ProtoCommon")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")

---@class ArmyMemberClassSettingWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameLView
---@field BtnCancel CommBtnLView
---@field BtnSave CommBtnLView
---@field ImgClassIcon UFImage
---@field ImgPlayer UFImage
---@field TableViewClass UTableView
---@field TextClassName UFTextBlock
---@field TextClassNum UFTextBlock
---@field TextPlayerName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyMemberClassSettingWinView = LuaClass(UIView, true)

function ArmyMemberClassSettingWinView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.BtnCancel = nil
	--self.BtnSave = nil
	--self.ImgClassIcon = nil
	--self.ImgPlayer = nil
	--self.TableViewClass = nil
	--self.TextClassName = nil
	--self.TextClassNum = nil
	--self.TextPlayerName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
    self.SelectedIndex = nil
end

function ArmyMemberClassSettingWinView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnSave)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyMemberClassSettingWinView:OnInit()
    self.AdapterCategoryTable =
        UIAdapterTableView.CreateAdapter(self, self.TableViewClass, self.OnCategoryItemSelected, true)
end

function ArmyMemberClassSettingWinView:OnCategoryItemSelected(Index, ItemData, ItemView)
	local Params = self.Params
    if nil == Params then
        return
    end
    if Index ~= self.SelectedIndex then
		local bChanged = Params.CategoryID ~= Params.Categories[Index].ID
		self.BtnSave:SetIsEnabled(bChanged)
		self.SelectedIndex = Index
    end
end

function ArmyMemberClassSettingWinView:OnDestroy()
end

function ArmyMemberClassSettingWinView:OnShow()
    local Params = self.Params
    if nil == Params then
        return
    end
	---见习分组已删除
    self.AdapterCategoryTable:UpdateAll(Params.Categories)
	for i, CategoryData in ipairs(Params.Categories) do
		if CategoryData.ID == Params.CategoryID then
			self.SelectedIndex = i
			CategoryData.IsGray = false
		end
	end
	self.AdapterCategoryTable:SetSelectedIndex(self.SelectedIndex)
    self.TextPlayerName:SetText(Params.RoleName)
	local ShowNum = tostring(Params.ShowIndex + 1)
    self.TextClassNum:SetText(ShowNum)
    self.TextClassName:SetText(Params.CategoryName)

    UIUtil.ImageSetBrushFromAssetPathSync(self.ImgClassIcon, Params.CategoryIcon)
	self.BtnSave:SetIsEnabled(false)
end

function ArmyMemberClassSettingWinView:OnHide()
end

function ArmyMemberClassSettingWinView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnSave, self.OnClickedSumbit)
    UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.Hide)
end

function ArmyMemberClassSettingWinView:OnRegisterGameEvent()
end

function ArmyMemberClassSettingWinView:OnRegisterBinder()
end

function ArmyMemberClassSettingWinView:OnClickedSumbit()
	local Params = self.Params
    if nil == Params then
        return
    end
	if Params.Callback then
		Params.Callback(self.Params.Categories[self.SelectedIndex].ID)
	end
	self:Hide()
end

return ArmyMemberClassSettingWinView
