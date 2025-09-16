--- Author: MichaelYang_LightPaw
---
--- DateTime: 2023-10-23 11:25
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local CardsPrepareEmoActPanelVM = require("Game/Cards/VM/CardsPrepareEmoActPanelVM")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local MajorUtil = require("Utils/MajorUtil")
local LightMgr = require("Game/Light/LightMgr")
local Json = require("Core/Json")
local ProtoCommon = require("Protocol/ProtoCommon")
local EmotionCfg = require("TableCfg/EmotionCfg")
local LocalDef = require("Game/MagicCard/MagicCardLocalDef")
local MagicCardMgr = require("Game/MagicCard/MagicCardMgr")
local MagicCardVMUtils = require("Game/MagicCard/MagicCardVMUtils")
local EmotionAnimUtils = require("Game/Emotion/Common/EmotionAnimUtils")
local EmotionDefines = require("Game/Emotion/Common/EmotionDefines")
local CameraFocusCfgMap = require("Game/Equipment/VM/CameraFocusCfgMap")
local CameraControlDataLoader = require("Game/Common/Render2d/CameraControlDataLoader")
local CameraControlDefine = require("Game/Common/Render2D/CameraControlDefine")
local PersonPortraitDefine = require("Game/PersonPortrait/PersonPortraitDefine")
local PersonPortraitUtil = require("Game/PersonPortrait/PersonPortraitUtil")
local MinDistance = PersonPortraitDefine.MinDistance
local MaxDistance = PersonPortraitDefine.MaxDistance
local MinFOV = PersonPortraitDefine.MinFOV
local MaxFOV = PersonPortraitDefine.MaxFOV
local LSTR = _G.LSTR
local EquipmentMgr = _G.EquipmentMgr

local RaceType = ProtoCommon.race_type

---@class CardsPrepareEmoActPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ClickTestBtn UButton
---@field Common_Render2DToImage_UIBP CommonRender2DToImageView
---@field DrawItem CardsEmoActSettingItemView
---@field FailItem CardsEmoActSettingItemView
---@field SaluteItem CardsEmoActSettingItemView
---@field TableViewEmoAct UTableView
---@field VictoryItem CardsEmoActSettingItemView
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsPrepareEmoActPanelView = LuaClass(UIView, true)

function CardsPrepareEmoActPanelView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.DrawItem = nil
    -- self.FailItem = nil
    -- self.SaluteItem = nil
    -- self.TableViewEmoAct = nil
    -- self.VictoryItem = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
    self.ViewModel = CardsPrepareEmoActPanelVM.New()
    self.SelectUsedSlotIndex = 0
    self.CurrentSelectSlotItem = nil
    self.CameraCtrlDataLoader = CameraControlDataLoader.New()
	self.FocusType = CameraControlDefine.FocusType.WholeBody
end

function CardsPrepareEmoActPanelView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.DrawItem)
    self:AddSubView(self.FailItem)
    self:AddSubView(self.SaluteItem)
    self:AddSubView(self.VictoryItem)
    self:AddSubView(self.Common_Render2DToImage_UIBP)
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsPrepareEmoActPanelView:OnInit()
    self.CameraFocusCfgMap = CameraFocusCfgMap.New()
    self.EmoSlotItemTable = {}
    self.EmoSlotItemTable[LocalDef.EmotionClassifyType.EmotionSolute] = self.SaluteItem
    self.EmoSlotItemTable[LocalDef.EmotionClassifyType.EmotionDraw] = self.DrawItem
    self.EmoSlotItemTable[LocalDef.EmotionClassifyType.EmotionWin] = self.VictoryItem
    self.EmoSlotItemTable[LocalDef.EmotionClassifyType.EmotionLose] = self.FailItem

    self.TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewEmoAct, self.OnEmoActSelectChange, true)

    local _binders = {{"EmoItemVMList", UIBinderUpdateBindableList.New(self, self.TableViewAdapter)}}
    self.Binders = _binders

    self.EmoSlotItemTable[LocalDef.EmotionClassifyType.EmotionSolute]:SetName(LSTR(LocalDef.UKeyConfig.Salute))
    self.EmoSlotItemTable[LocalDef.EmotionClassifyType.EmotionWin]:SetName(LSTR(LocalDef.UKeyConfig.Victory))
    self.EmoSlotItemTable[LocalDef.EmotionClassifyType.EmotionDraw]:SetName(LSTR(LocalDef.UKeyConfig.Draw))
    self.EmoSlotItemTable[LocalDef.EmotionClassifyType.EmotionLose]:SetName(LSTR(LocalDef.UKeyConfig.Fail))

    for k,v in ipairs(self.EmoSlotItemTable) do
        v:SetEmoID(0)
        v:SetIndex(k) -- 这里其实是 EmoType
        v:SetIsSelect(false)
        v:SetClickCallback(self, self.OnTargetSlotClicked)
    end

    local DefaultSoluteEmoID = 5 -- 默认的敬礼动作都是鞠躬
    self.EmoSlotItemTable[1]:SetEmoID(DefaultSoluteEmoID)
    self.ViewModel:InitData()
end

function CardsPrepareEmoActPanelView:TryFlushSelection()
    if (self.CurrentSelectSlotItem ~= nil) then
        self.CurrentSelectSlotItem:SetIsSelected(false)
        self.CurrentSelectSlotItem = nil
        self.TableViewAdapter:ClearSelectedItem()
    end

    if (self.SelectUsedSlotIndex > 0) then
        self.EmoSlotItemTable[self.SelectUsedSlotIndex]:SetIsSelect(false)
        self.SelectUsedSlotIndex = 0
    end

    self.ViewModel:UpdateInfoByEmoType(0)
end

function CardsPrepareEmoActPanelView:OnTargetSlotClicked(EmoType)
    if (self.SelectUsedSlotIndex > 0) then
        self.EmoSlotItemTable[self.SelectUsedSlotIndex]:SetIsSelect(false)
    end

    if (self.CurrentSelectSlotItem ~= nil) then
        self.CurrentSelectSlotItem:SetIsSelected(false)
        self.CurrentSelectSlotItem = nil
        self.TableViewAdapter:ClearSelectedItem()
    end

    if (self.SelectUsedSlotIndex ~= EmoType) then
        self.ViewModel:ResetAllUsedIcon()
        self.SelectUsedSlotIndex = EmoType
        self.EmoSlotItemTable[self.SelectUsedSlotIndex]:SetIsSelect(true)
        self.ViewModel:UpdateInfoByEmoType(self.SelectUsedSlotIndex)
        self:TryInitUsedSlotWithIDMap()
    else
        self.EmoSlotItemTable[self.SelectUsedSlotIndex]:SetIsSelect(false)
        self.SelectUsedSlotIndex = 0
        self.ViewModel:UpdateInfoByEmoType(self.SelectUsedSlotIndex)
        self.ViewModel:ResetAllUsedIcon()
    end
end

function CardsPrepareEmoActPanelView:TrySetEmo()
    if (self.SelectUsedSlotIndex<=0) then
        return false
    end

    local _index = self.SelectUsedSlotIndex
    if (_index <= 0 or self.CurrentSelectSlotItem == nil) then
        return false
    end

    if not self.CurrentSelectSlotItem:GetIsGetted() then
        return false
    end

    local _originUsedID = self.EmoSlotItemTable[_index]:GetEmoID()
    local _slotCardID = self.CurrentSelectSlotItem:GetEmoID()

    self.EmoSlotItemTable[_index]:SetEmoID(_slotCardID)

    -- 这里去找一下，前面一个的VM，取消已使用
    local _noUse = true
    for i = 1, 4 do
        if (self.EmoSlotItemTable[i]:GetEmoID() == _originUsedID) then
            _noUse = false
            break
        end
    end

    if (_noUse) then
        local _findItem = table.find_item(self.ViewModel.EmotionList, _originUsedID, "TableID")
        if (_findItem ~= nil) then
            _findItem:SetIsUsed(false)
        end
    else
        self.CurrentSelectSlotItem:SetIsUsed(true)
    end

    -- 这里发送协议
    self:TrySaveEmoList()

    return true
end

function CardsPrepareEmoActPanelView:TryCancelEmo()
    local _index = self.SelectUsedSlotIndex
    -- 第一个不能取消
    if (_index <= 1) then
        return false
    end

    self.EmoSlotItemTable[_index]:SetEmoID(0)
    -- 这里发送协议
    self:TrySaveEmoList()
    return true
end

function CardsPrepareEmoActPanelView:TrySaveEmoList()
    local _idList = {}
    for i = 1, 4 do
        _idList[i] = self.EmoSlotItemTable[i]:GetEmoID()
    end
    local _clientSetupMgr = require("Game/ClientSetup/ClientSetupMgr")
    local _strContent = Json.encode(_idList)
    _clientSetupMgr:SetCardEmoIDList(_strContent)
end

---@param ItemData 是 CardsEmoActSlotItemVM
function CardsPrepareEmoActPanelView:OnEmoActSelectChange(Index, ItemData, ItemView)
    if (self.CurrentSelectSlotItem ~= nil) then
        self.CurrentSelectSlotItem:SetIsSelected(false)
        if (self.CurrentSelectSlotItem == ItemData) then
            if self.CurrentSelectSlotItem:GetIsGetted() then
                self:TryCancelEmo()
            end
            self.CurrentSelectSlotItem = nil
            return
        end
    end
    if (self.CurrentSelectSlotItem ~= nil) then
        self.CurrentSelectSlotItem:SetIsSelected(false)
    end
    self.CurrentSelectSlotItem = ItemData
    self.CurrentSelectSlotItem:SetIsSelected(true)
    self:TryPlayAnim(ItemData:GetEmoID())
    self:TrySetEmo()
end

function CardsPrepareEmoActPanelView:TryPlayAnim(EmoID)
    if (EmoID <= 0) then
        return
    end

    local EmotionCfg = EmotionCfg:FindCfgByKey(EmoID)

    if EmotionCfg then
        local Actor = self.Common_Render2DToImage_UIBP:GetRender2DBP().UIComplexCharacter
        local AnimPath = EmotionAnimUtils.GetActorEmotionAnimPath(
            EmotionCfg.AnimPath,
            Actor,
            EmotionDefines.AnimType.EMOT
        )

        local AnimComp = Actor:GetAnimationComponent()
        AnimComp:PlayAnimation(AnimPath, 1.0, 0.25, 0.25, true)
    end
end

function CardsPrepareEmoActPanelView:OnDestroy()
end

function CardsPrepareEmoActPanelView:OnShow()
    local AvatarComp = MajorUtil.GetMajorAvatarComponent()
    if nil ~= AvatarComp then
        self.ViewModel.AttachType = AvatarComp:GetAttachType()
    end
    local function CreateCallback()
        local Render2DBP = self.Common_Render2DToImage_UIBP:GetRender2DBP()
        self.CameraFocusCfgMap:SetAssetUserData(Render2DBP:GetEquipmentConfigAssetUserData())
        Render2DBP:EnableRotator(true)
        Render2DBP:SetCameraFocusScreenLocation(nil, nil, nil, nil)
        local SpringArmRotation = Render2DBP:GetSpringArmRotation()
        Render2DBP:SetSpringArmRotation(0, SpringArmRotation.Yaw, SpringArmRotation.Roll, true)
        Render2DBP:SetModelRotation(0, 0, 0, true)
        LightMgr:EnableUIWeather(22)
        local LightPreset = self:GetLightPresetPathByRace()
        if not string.isnilorempty(LightPreset) then
            Render2DBP:ResetLightPreset(LightPreset)
        end
        local CameraParams = MagicCardVMUtils.GetCameraControlParams(self.ViewModel.AttachType)
        if CameraParams then
            local SpringArmLoc = CameraParams.Offset --Render2DBP:GetSpringArmLocation()
            Render2DBP:SetSpringArmLocation(SpringArmLoc.X, SpringArmLoc.Y, SpringArmLoc.Z,false)
            Render2DBP:SetCameraFOV(CameraParams.FOV)
            Render2DBP:SetSpringArmDistance(CameraParams.Distance, false)
        end
        Render2DBP:SetPostProcessVignetteIntensity(self.VignetteIntensityDefaultValue)
    end

    self.Common_Render2DToImage_UIBP:EnableZoom(false)

    self.Common_Render2DToImage_UIBP:CreateRenderActor(true, CreateCallback)

    -- 显示一下表情相关
    self:TryInitUsedSlotWithIDMap()
    self:OnTargetSlotClicked(LocalDef.EmotionClassifyType.EmotionSolute)
end

function CardsPrepareEmoActPanelView:GetLightPresetPathByRace()
    local Race = MajorUtil.GetMajorRaceID()
    if Race == RaceType.RACE_TYPE_Lalafell then
        return "LightPreset'/Game/UI/Render2D/LightPresets/Login/TODUI_TripleTriad/TripleTriad_c1101.TripleTriad_c1101'"
    elseif Race == RaceType.RACE_TYPE_Roegadyn then
        return "LightPreset'/Game/UI/Render2D/LightPresets/Login/TODUI_TripleTriad/TripleTriad_c0901.TripleTriad_c0901'"
    else
        return "LightPreset'/Game/UI/Render2D/LightPresets/Login/TODUI_TripleTriad/TripleTriad_c0101.TripleTriad_c0101'"
    end
end

function CardsPrepareEmoActPanelView:TryInitUsedSlotWithIDMap()
    self.ViewModel:ResetAllUsedIcon()

    local _usedIDList = MagicCardMgr.EmoIDTable

    for k,v in pairs(LocalDef.EmotionClassifyType) do
        self.EmoSlotItemTable[v]:SetEmoID(_usedIDList[v])
    end

    if (self.SelectUsedSlotIndex > 0 and _usedIDList[self.SelectUsedSlotIndex] > 0) then
        local VMItemList = self.ViewModel.EmoItemVMList.Items
        local _findItem = table.find_item(VMItemList, _usedIDList[self.SelectUsedSlotIndex], "EmotionTableID")
        if (_findItem ~= nil) then
            _findItem:SetIsUsed(true)
        end
    end
end

function CardsPrepareEmoActPanelView:OnHide()
    self:TryFlushSelection()
    LightMgr:DisableUIWeather()
end

function CardsPrepareEmoActPanelView:OnRegisterUIEvent()
end

function CardsPrepareEmoActPanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.ClientSetupPost, self.OnEventClientSetupPost)
end

function CardsPrepareEmoActPanelView:OnEventClientSetupPost(EventParams)
    self:TryInitUsedSlotWithIDMap()
end

function CardsPrepareEmoActPanelView:OnRegisterBinder()
    self:RegisterBinders(self.ViewModel, self.Binders)
end

return CardsPrepareEmoActPanelView
