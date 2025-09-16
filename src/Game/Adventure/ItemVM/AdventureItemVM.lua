---
--- Author: sammrli
--- DateTime: 2023-05-12 15:46
--- Description:冒险系统公共Item ViewModel
---不处理业务逻辑

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local AdventureItemItemVM = require("Game/Adventure/ItemVM/AdventureItemItemVM")
local UIBindableList = require("UI/UIBindableList")

---@see AdventureCompletionItem02View

---@class AdventureItemVM : UIViewModel
---@field ID number
---@field ContentText string
---@field DescriptionText string
---@field IsDescriptionVisible bool
---@field MainIconPath string
---@field JobIconPath string
---@field IsJobVisible boolean
---@field IsBtnGoVisible boolean
---@field IsBtnGetVisible boolean
---@field BtnGoText string
---@field BtnGetText string
---@field IsUnFinishVisible boolean
---@field UnFinishText string
---@field OnClickGet function
---@field OnClickGo function
local AdventureItemVM = LuaClass(UIViewModel)

function AdventureItemVM:Ctor()
    self.Type = nil
    self.ID = nil
    self.ContentText = nil
    self.DescriptionText = nil
    self.IsDescriptionVisible = nil
    self.MainIconPath = nil
    self.JobIconPath = nil
    self.IsJobVisible = nil
    self.IsBtnGoVisible = nil
    self.IsBtnGetVisible = nil
    self.BtnGoText = nil
    self.BtnGetText = nil
    self.IsUnFinishVisible = nil
    self.UnFinishText = nil
    self.IsNewRedVisible = nil

    self.OnClickGet = nil
    self.OnClickGo = nil
    self.RewardList = UIBindableList.New(AdventureItemItemVM)
end

function AdventureItemVM:UpdateVM(Params)
    self.Type = Params.Type
    self.ID = Params.ID
    self.IsBtnGoVisible = Params.IsBtnGoVisible
    self.IsUnFinishVisible = Params.IsUnFinishVisible
    self.BtnGoText = Params.BtnGoText or ""
    self.UnFinishText = Params.UnFinishText or ""
    self.JobIconPath = Params.JobIconPath or ""
    self.IsJobVisible = Params.IsJobVisible
    self.ContentText = Params.ContentText or ""
    self.DescriptionText = Params.DescriptionText or ""
    self.IsBtnGetVisible = Params.IsBtnGetVisible
    self.BtnGetText = Params.BtnGetText or ""
    self.IsDescriptionVisible = Params.IsDescriptionVisible
    self.MainIconPath = Params.MainIconPath or ""
    self.IsNewRedVisible = Params.IsNew
    self.OnClickGet = Params.OnClickGet
    self.OnClickGo = Params.OnClickGo

    if Params.RewardList then
        self:SetRewardData(Params.RewardList)
    end
end

function AdventureItemVM:SetRewardData(RewardList)
    self.RewardList:UpdateByValues(RewardList)
end

function AdventureItemVM:IsEqualVM(Value)
	return self.Type == Value.Type
end

return AdventureItemVM


