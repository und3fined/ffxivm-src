---
--- Author: guanjiewu
--- DateTime: 2023-12-11 20:47
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local ActorUtil = require("Utils/ActorUtil")
---@class ModelAdjustUIView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAdd1 UFButton
---@field BtnAdd2 UFButton
---@field BtnAdd3 UFButton
---@field BtnAdd4 UFButton
---@field BtnDebugConfirm UFButton
---@field BtnSub1 UFButton
---@field BtnSub2 UFButton
---@field BtnSub3 UFButton
---@field BtnSub4 UFButton
---@field DebugZone1 UFCanvasPanel
---@field DebugZone2 UFCanvasPanel
---@field DebugZone3 UFCanvasPanel
---@field DebugZone4 UFCanvasPanel
---@field DistanceText UFGMEditableText
---@field HeightText UFGMEditableText
---@field HorizontalText UFGMEditableText
---@field Root UFCanvasPanel
---@field RotateText UFGMEditableText
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ModelAdjustUIView = LuaClass(UIView, true)

function ModelAdjustUIView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.BtnAdd1 = nil
    --self.BtnAdd2 = nil
    --self.BtnAdd3 = nil
    --self.BtnAdd4 = nil
    --self.BtnDebugConfirm = nil
    --self.BtnSub1 = nil
    --self.BtnSub2 = nil
    --self.BtnSub3 = nil
    --self.BtnSub4 = nil
    --self.DebugZone1 = nil
    --self.DebugZone2 = nil
    --self.DebugZone3 = nil
    --self.DebugZone4 = nil
    --self.DistanceText = nil
    --self.HeightText = nil
    --self.HorizontalText = nil
    --self.Root = nil
    --self.RotateText = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ModelAdjustUIView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ModelAdjustUIView:OnInit()
    print("ModelAdjustUIView:OnInit")
end

function ModelAdjustUIView:OnDestroy()
end

function ModelAdjustUIView:OnShow()
end

function ModelAdjustUIView:OnHide()
end

function ModelAdjustUIView:OnRegisterUIEvent()
    -- 模型显示调试
    for i = 1, 4 do
        UIUtil.AddOnClickedEvent(
            self,
            self["BtnSub" .. i],
            function()
                self:OnBtnSubClicked(i)
            end
        )
        UIUtil.AddOnClickedEvent(
            self,
            self["BtnAdd" .. i],
            function()
                self:OnBtnAddClicked(i)
            end
        )
    end
    UIUtil.AddOnClickedEvent(self, self.BtnDebugConfirm, self.OnBtnDebugConfirmClicked)
end

function ModelAdjustUIView:OnRegisterGameEvent()
end

function ModelAdjustUIView:OnRegisterBinder()
    self:RegisterBinders(self.viewModel, self.Binders)
end

-- 传入外层的ViewModel和对应的模型绘制控件
function ModelAdjustUIView:Setup(viewModel, TargetView, bIsWeapon, bIsSub)
    print("ModelAdjustUIView:Setup", bIsSub)
    self.viewModel = viewModel
    self.TargetView = TargetView
    self.bIsWeapon = bIsWeapon or false
    self.bIsSub = bIsSub
    if not self.bIsSub then
        self.Binders = {
            {"ModelCameraDistance", UIBinderSetText.New(self, self.DistanceText)},
            {"ModelHeightOffset", UIBinderSetText.New(self, self.HeightText)},
            {"ModelHorizontalOffset", UIBinderSetText.New(self, self.HorizontalText)},
            {"ModelRotate", UIBinderSetText.New(self, self.RotateText)}
        }
    else
        self.Binders = {
            {"SubModelCameraDistance", UIBinderSetText.New(self, self.DistanceText)},
            {"SubModelHeightOffset", UIBinderSetText.New(self, self.HeightText)},
            {"SubModelHorizontalOffset", UIBinderSetText.New(self, self.HorizontalText)},
            {"SubModelRotate", UIBinderSetText.New(self, self.RotateText)}
        }
    end
end

function ModelAdjustUIView:SetMonsterEntityID(entityID)
    self.MonsterEntityID = entityID
end

function ModelAdjustUIView:CollectViewDebugData()
    if not self.bIsSub then
        self.viewModel.ModelCameraDistance = tonumber(self.DistanceText:GetText())
        self.viewModel.ModelHeightOffset = tonumber(self.HeightText:GetText())
        self.viewModel.ModelHorizontalOffset = tonumber(self.HorizontalText:GetText())
        self.viewModel.ModelRotate = tonumber(self.RotateText:GetText())
    else
        self.viewModel.SubModelCameraDistance = tonumber(self.DistanceText:GetText())
        self.viewModel.SubModelHeightOffset = tonumber(self.HeightText:GetText())
        self.viewModel.SubModelHorizontalOffset = tonumber(self.HorizontalText:GetText())
        self.viewModel.SubModelRotate = tonumber(self.RotateText:GetText())
    end
end

local StepValue = 5
function ModelAdjustUIView:OnBtnSubClicked(index)
    self:UpdateValue(index, -StepValue)
end
function ModelAdjustUIView:OnBtnAddClicked(index)
    self:UpdateValue(index, StepValue)
end
function ModelAdjustUIView:UpdateValue(index, value)
    self:CollectViewDebugData()
    if not self.bIsSub then
        if index == 1 then
            self.viewModel.ModelCameraDistance = self.viewModel.ModelCameraDistance + value
        elseif index == 2 then
            self.viewModel.ModelHeightOffset = self.viewModel.ModelHeightOffset + value
        elseif index == 3 then
            self.viewModel.ModelHorizontalOffset = self.viewModel.ModelHorizontalOffset + value
        elseif index == 4 then
            self.viewModel.ModelRotate = self.viewModel.ModelRotate + value
        end
    else
        if index == 1 then
            self.viewModel.SubModelCameraDistance = self.viewModel.SubModelCameraDistance + value
        elseif index == 2 then
            self.viewModel.SubModelHeightOffset = self.viewModel.SubModelHeightOffset + value
        elseif index == 3 then
            self.viewModel.SubModelHorizontalOffset = self.viewModel.SubModelHorizontalOffset + value
        elseif index == 4 then
            self.viewModel.SubModelRotate = self.viewModel.SubModelRotate + value
        end
    end
    self:RefreshModelParams(true)
end

-- 应用界面中填写的调试数据
function ModelAdjustUIView:OnBtnDebugConfirmClicked()
    self:RefreshModelParams(false)
end

function ModelAdjustUIView:RefreshModelParams(bSkipCollect)
    if self.viewModel == nil then
        _G.FLOG_ERROR("ModelAdjustUIView:RefreshModelParams return!!!")
        return
    end
    if not bSkipCollect then
        self:CollectViewDebugData()
    end

    self.TargetView:TryApplyModelOffsetAndRotate()
end

return ModelAdjustUIView
