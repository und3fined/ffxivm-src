local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")
local ProtoCS = require("Protocol/ProtoCS")
local UIViewID = require("Define/UIViewID")
local LegendaryWeaponTopicCfg = require("TableCfg/LegendaryWeaponTopicCfg")         --传奇武器主题表
local LegendaryWeaponChapterCfg = require("TableCfg/LegendaryWeaponChapterCfg")     --传奇武器章节表
local LegendaryWeaponCfg = require("TableCfg/LegendaryWeaponCfg")                   --传奇武器表
local LegendaryWeaponSpecialCfg = require("TableCfg/LegendaryWeaponSpecialCfg")     --传奇武器配置表
local MajorUtil = require("Utils/MajorUtil")
local GlobalCfg = require("TableCfg/GlobalCfg")
local ProtoRes = require("Protocol/ProtoRes")
local LegendaryWeaponDefine = require("Game/LegendaryWeapon/LegendaryWeaponDefine")
local RedDotMgr = require("Game/CommonRedDot/RedDotMgr")
local EquipmentMgr = require("Game/Equipment/EquipmentMgr")
local ProtoCommon = require("Protocol/ProtoCommon")
local AudioUtil = require("Utils/AudioUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local RightMenuItemsCfg = require("TableCfg/RightMenuItemsCfg")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local Main2ndPanelDefine = require("Game/Main2nd/Main2ndPanelDefine")
local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.CsLegendaryWeaponCmd
local UCommonUtil = nil
local LegendaryWeaponMainPanelVM = nil
local LSTR = nil
local UIViewMgr = nil

---@class NaviDecalMgr : MgrBase
local LegendaryWeaponMgr = LuaClass(MgrBase)

function LegendaryWeaponMgr:OnInit()
    self.LastDragX = 0           --0
    self.bEnableRotator = true   --可旋转
end

function LegendaryWeaponMgr:OnBegin()
	if not _G.LoginMgr:CheckModuleSwitchOn(ProtoRes.module_type.MODULE_LEGEND_WEAPON, true) then
		return
	end
    LegendaryWeaponMainPanelVM = _G.LegendaryWeaponMainPanelVM
    UCommonUtil = _G.UE.UCommonUtil
    UIViewMgr = _G.UIViewMgr
    LSTR = _G.LSTR
    self.QueryList = {}          --已拥有的传奇武器
    self.TopicVersion = {}       --主题版本
    self.ChapterVersion = {}     --章节版本
    self.RedDotListID = {}       --某个ID是否显示红点
    self.ShowRedDotList = {}     --仅存可显示的红点ID
    self:GetGlobalVersions()
    self:GetVersions()
    -- self.ToggleGroupIndex = 1    --打开界面时,切换武器介绍界面1/材料球制作界面2
end

function LegendaryWeaponMgr:OnHide()
    UCommonUtil = nil
    self.QueryList = {}
    self.TopicVersion = {}
    self.ChapterVersion = {}
    self.bEnableRotator = false
    self.LastDragX = 0
    if self.DragTimer ~= nil then  --清除定时器
		self:UnRegisterTimer(self.DragTimer)
		self.DragTimer = nil
	end
    if self.BagTimerHandle ~= nil then
		self:UnRegisterTimer(self.BagTimerHandle)
		self.BagTimerHandle = nil
	end
end

function LegendaryWeaponMgr:OnEnd()
    self:OnHide()
end

function LegendaryWeaponMgr:OnRegisterNetMsg()
	if not _G.LoginMgr:CheckModuleSwitchOn(ProtoRes.module_type.MODULE_LEGEND_WEAPON, true) then
		return
	end

    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LEGENDARY_WEAPON, SUB_MSG_ID.CS_LEGENDARY_WEAPON_CMD_PRODUCE, self.OnNetMsgProduce)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LEGENDARY_WEAPON, SUB_MSG_ID.CS_LEGENDARY_WEAPON_CMD_QUERY, self.OnNetMsgQuery)
end

function LegendaryWeaponMgr:OnRegisterGameEvent()
	if not _G.LoginMgr:CheckModuleSwitchOn(ProtoRes.module_type.MODULE_LEGEND_WEAPON, true) then
		return
	end

	self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventRoleLoginRes)		-- 角色登录成功
    self:RegisterGameEvent(EventID.MajorCreate, self.OnGameEventMajorCreate)
    self:RegisterGameEvent(EventID.LegendaryUpdateRedDot, self.OnGameEventUpdateRedDot)
    self:RegisterGameEvent(EventID.BagUpdate, self.OnGameEventBagUpdate)
    self:RegisterGameEvent(EventID.PreCrystalTransferReq, self.OnGameEventPreCrystalTransferReq)
    self:RegisterGameEvent(EventID.ModuleOpenNotify, self.OnModuleOpenNotify) --系统解锁
end

function LegendaryWeaponMgr:OnGameEventRoleLoginRes(Params)
    self.UpdateRoleTr = function()
        self:SendQueryMsg()     --查询已制作的武器
        self:GetRoleTransform() --获取角色模型变换
        self:InitRedDot()       --初始化武器的红点
    end
end

function LegendaryWeaponMgr:OnGameEventMajorCreate(Params)
    if self.UpdateRoleTr then
        self.UpdateRoleTr()
        self.UpdateRoleTr = nil
    end
end

--- 接收制作回包
function LegendaryWeaponMgr:OnNetMsgProduce(MsgBody)
    local Prof = MsgBody.Produce.Prof
    local WeaponID = MsgBody.Produce.WeaponID
    local HasGem = MsgBody.Produce.HasGem   --材料中的武器是否镶嵌了魔晶石
    self:StartPlay(Prof, WeaponID, HasGem)
end

--- 发送制作请求
function LegendaryWeaponMgr:SendProdsuceMsg(Prof, WeaponID)
    local MsgID = CS_CMD.CS_CMD_LEGENDARY_WEAPON
    local SubMsgID = SUB_MSG_ID.CS_LEGENDARY_WEAPON_CMD_PRODUCE
    local MsgBody = {
        Cmd = SubMsgID,
        Produce = {
            Prof = Prof,
            WeaponID = WeaponID
        }
    }
    --FLOG_INFO("[LegendaryWeapon] SendProduceMsg Prof = %d, ID = %d",Prof,WeaponID)
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 发送查询请求
function LegendaryWeaponMgr:SendQueryMsg()
    local MsgID = CS_CMD.CS_CMD_LEGENDARY_WEAPON
    local SubMsgID = SUB_MSG_ID.CS_LEGENDARY_WEAPON_CMD_QUERY
    local MsgBody = {
        Cmd = SubMsgID,
        Produce = {
            
        }
    }
    --print("LegendaryWeaponMgr:SendQueryMsg")
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 接收查询回包
function LegendaryWeaponMgr:OnNetMsgQuery(MsgBody)
    self.QueryList = {}
    if MsgBody.Query and MsgBody.Query.Weapons then
        local WeaponsList = MsgBody.Query.Weapons
        for i, Value in pairs(WeaponsList) do
            local IDList = Value.Weapons
            if IDList ~= nil then
                for j = 1, #IDList do
                    local ID = IDList[j]
                    if ID ~= nil and not self.QueryList[ID] then
                        self.QueryList[ID] = true
                    end
                end
            end 
        end
    end
    if self.QueryList ~= {} then
        _G.EventMgr:SendEvent(EventID.LegendaryCompletionStatus, {self.QueryList})
    end
end

--- 入场动画，若自动播放则这里不调用
function LegendaryWeaponMgr:PlaySequence1()
    local BP_SceneActor = LegendaryWeaponMainPanelVM.BP_SceneActor
    if UCommonUtil.IsObjectValid(BP_SceneActor) and BP_SceneActor.ActorSequence then
        BP_SceneActor.ActorSequence.SequencePlayer:Play()
    end
end

--- 循环动画，强化结束后需调用  --（策划说需求变更：不再让武器自动旋转）
function LegendaryWeaponMgr:PlayLoopSequence(bIsPlay)
    -- local BP_SceneActor = LegendaryWeaponMainPanelVM.BP_SceneActor
    -- if UCommonUtil.IsObjectValid(BP_SceneActor) then
    --     local LoopSeq = BP_SceneActor:GetLoopSequence()
    --     if LoopSeq then
    --         if bIsPlay then
    --             LoopSeq:PlayLooping(-1)
    --         else
    --             LoopSeq:Stop()
    --         end
    --     end
    -- end
end

--- 播放旋转动画（武器切换时）
function LegendaryWeaponMgr:PlaySequence4(bIsPlay)
    local ViewModel = LegendaryWeaponMainPanelVM
    if not ViewModel then return end
    local BP_SceneActor = ViewModel.BP_SceneActor
    if UCommonUtil and UCommonUtil.IsObjectValid(BP_SceneActor) then
        if bIsPlay then
            BP_SceneActor:PlayCotuverSequence()
        else
            local CotuverSeq = BP_SceneActor:GetCotuverSequence()
            if CotuverSeq then
                CotuverSeq:Stop()
            end
        end
    
        --播放切换音效
        local Location = BP_SceneActor:K2_GetActorLocation()
        Location.Z = Location.Z + 150
        local Rotation = _G.UE.FRotator(0)
        AudioUtil.LoadAndPlaySoundAtLocation(LegendaryWeaponDefine.SwitchSoundPath, Location, Rotation, _G.UE.EObjectGC.NoCache)
    end
end

---【开启入口】 制作强化武器的效果表现
function LegendaryWeaponMgr:StartPlay(Prof, WeaponID, HasGem)
    
    --1、播放 UI 强化动效(白屏前)
    _G.EventMgr:SendEvent(EventID.LegendaryPlayCompletionAnim)

    --2、播放法阵动画、过场动画
    self:PlayCompositeSequence(Prof, WeaponID, HasGem)
end

--- 强化动画（白屏前）
function LegendaryWeaponMgr:PlayCompositeSequence(Prof, WeaponID, HasGem)
    local BP_SceneActor = LegendaryWeaponMainPanelVM.BP_SceneActor
    if not UCommonUtil.IsObjectValid(BP_SceneActor) then return end
    self:PlayLoopSequence(false)  --先停止自转
    
    --3、播放强化音效
    local Location = BP_SceneActor:K2_GetActorLocation()
    Location.Z = Location.Z + 150
    local Rotation = _G.UE.FRotator(0)
    AudioUtil.LoadAndPlaySoundAtLocation(LegendaryWeaponDefine.AppearSoundPath, Location, Rotation, _G.UE.EObjectGC.NoCache)
    
    --4、显示头顶飘字（应在过场动画开始后播）
    self:ShowCraftPopUp(WeaponID, 1)

    --5、播放法阵动画（结束时白屏转场衔接6）
    local CompositeSeq, EndTime = BP_SceneActor:GetCompositeSequence()
    if CompositeSeq then
        CompositeSeq:Play()
        EndTime = EndTime or 6
        _G.TimerMgr:AddTimer(self, self.PlayCharacterSequence, EndTime, 0, 1, {Prof = Prof, WeaponID = WeaponID, HasGem = HasGem})
    end
end

--- 过场动画（白屏后）
function LegendaryWeaponMgr:PlayCharacterSequence(Params)
    local Prof, WeaponID = Params.Prof, Params.WeaponID
--   local SequencePath = LegendaryWeaponDefine.InterludeSeq[Prof]
--   local StopCallBack = function()

        --7、播放结束时，显示获取武器的弹窗
        self:ShowRewardPanel(LegendaryWeaponMainPanelVM.ProfInfo.WeaponCfg.ID)

        --8、结束后刷新已完成武器, 设置主界面可视, 隐藏材料槽
        self:SendQueryMsg()
        _G.EventMgr:SendEvent(EventID.LegendaryCompletionEnd, Params)
--    end

    --6、角色过场动画（过场动画暂时不做）
--    _G.StoryMgr:PlaySequenceByPath(SequencePath, StopCallBack)
end

--- 制作完成时文字提示   "%s冒出了璀璨的光芒！"
function LegendaryWeaponMgr:ShowCraftPopUp(WeaponID, TopicID)
    local Params = {}
    local WeaponCfg = LegendaryWeaponCfg:FindCfgByKey(WeaponID)
    if WeaponCfg then
        Params.WeaponID = WeaponCfg.EquipmentID
    end
    Params.TopicID = TopicID
    _G.UIViewMgr:ShowView(UIViewID.LegendaryWeaponCraftPopUp, Params)
end

--- 制作完成，最终奖励弹窗
function LegendaryWeaponMgr:ShowRewardPanel(WeaponID)
    local WeaponCfg = LegendaryWeaponCfg:FindCfgByKey(WeaponID)
    if WeaponCfg == nil then return end
    local Params = {}
    local Temp = {}
    table.insert(Temp,
    {
        ResID = WeaponCfg.EquipmentID,
        Num = 1,
    })
    if WeaponCfg.SubEquipmentID ~= 0 then
        table.insert(Temp,
        {
            ResID = WeaponCfg.SubEquipmentID,
            Num = 1,
        })        
    end
    Params.ItemList = Temp
    Params.Title = LSTR(220013) --"获得物品"
    Params.CloseCallback = function()
        self:ShowAllRewardPanel()
    end 
    _G.UIViewMgr:ShowView(UIViewID.CommonRewardPanel, Params)
end

--- 任务提示“上古武器圆满落幕”
function LegendaryWeaponMgr:ShowTaskCompletionTips(WeaponID)
    -- local MainPanelVM = LegendaryWeaponMainPanelVM
    -- if not MainPanelVM then return end
    -- if MainPanelVM.ChapterID ~= 3 then return end
    local WeCfg = LegendaryWeaponCfg:FindCfgByKey(WeaponID)
    if WeCfg.ChapterID ~= 3 then return end
    local TopicID = WeCfg.TopicID
    local Cfg = LegendaryWeaponTopicCfg:FindCfgByKey(TopicID)
    if not Cfg then return end
    local Params = {}

    if Cfg.Name then
        Params.SysNotice = Cfg.Name .. LSTR(220057)   --"传奇"
    end

    if TopicID == 1 then
        Params.Icon = "Texture2D'/Game/UI/Texture/InfoTips/ContentUnlock/UI_InfoTips_Img_AncientWeapons.UI_InfoTips_Img_AncientWeapons'"
    elseif TopicID == 2 then
        Params.Icon = "Texture2D'/Game/UI/Texture/InfoTips/ContentUnlock/UI_InfoTips_Img_ZodiacWeapon.UI_InfoTips_Img_ZodiacWeapon'"
    end

    Params.SubSysNotice = LSTR(220056)  --"圆满落幕"
    MsgTipsUtil.ShowMentorTips(Params)

    local Scd = "AkAudioEvent'/Game/WwiseAudio/Events/sound/zingle/Zingle_ZodiacOpen/Play_Zingle_ZodiacOpen.Play_Zingle_ZodiacOpen'"    --音频
    AudioUtil.LoadAndPlayUISound(Scd)
end

--- 文字提示：魔晶石继承
function LegendaryWeaponMgr:ShowTipsMJS(Params)
    local WeaponCfg = LegendaryWeaponCfg:FindCfgByKey(Params.WeaponID)
    if WeaponCfg == nil then return end
    if WeaponCfg and WeaponCfg.ConsumeItems[1] and WeaponCfg.ConsumeItems[1].ResID then
        local ResID = WeaponCfg.ConsumeItems[1].ResID
        if not Params.HasGem then
            return   --判断材料中的武器是否镶嵌了魔晶石，若无则return
        end
        local TipsMJS = function()
            local WeaponName = ItemCfg:GetItemName(ResID)
            local Tips = WeaponName .. LSTR(220058)
            MsgTipsUtil.ShowTips(Tips)
        end
        _G.TimerMgr:AddTimer(self, TipsMJS, 4)
    end
end

---@param Task	table
function LegendaryWeaponMgr:InsertTask(Task)
    self.TaskViewMap = self.TaskViewMap or {}
    table.insert(self.TaskViewMap, Task)
end

function LegendaryWeaponMgr:RemoveTask()
    table.remove(self.TaskViewMap, 1)
end

--- 11、当制作完该主题下所有传奇武器时，触发成就解锁外观弹窗
function LegendaryWeaponMgr:ShowAllRewardPanel()
    if nil == self.TaskViewMap or self.TaskViewMap == {} then
        return
    end
    local Task = self.TaskViewMap[1]
    if Task == nil or #Task <= 0 then
        return
    end

    local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")
    local Params = {}
	Params.Title = LSTR(1080001)
    local Temp = {}
    for _, AppearanceID in ipairs(Task) do
        table.insert(Temp,
        {
            ResID = WardrobeUtil.GetIsSpecial(AppearanceID) and WardrobeUtil.GetUnlockCostItemID(AppearanceID) or WardrobeUtil.GetEquipIDByAppearanceID(AppearanceID),
            Num = 1,
            ItemNameVisible = true,
        })
    end
    Params.ItemList = Temp
    Params.CloseCallback = function()
        self:RemoveTask()
    end 

    UIViewMgr:HideView(UIViewID.CommonRewardPanel)
    _G.TimerMgr:AddTimer(self, function()
        UIViewMgr:ShowView(UIViewID.CommonRewardPanel, Params)
    end, 0.1)
end

--- 适配角色位置比例
function LegendaryWeaponMgr:GetRoleTransform()
    local AvatarComp = MajorUtil.GetMajorAvatarComponent()
    if AvatarComp then
		self.AttachType = AvatarComp:GetAttachType()
        local RoleTransformID = LegendaryWeaponDefine.RoleTransform[self.AttachType]
        local RoleData = LegendaryWeaponSpecialCfg:FindCfgByKey(RoleTransformID)
        if nil ~= RoleData then
            self.CharacterLocationX = RoleData.CharacterLocationX
            self.CharacterLocationY = RoleData.CharacterLocationY
            self.CharacterLocationZ = RoleData.CharacterLocationZ
            self.CharacterScale = RoleData.CharacterScale
        end
    end
end

--- 获取游戏版本
function LegendaryWeaponMgr:GetGlobalVersions()
    self.GlobalVersions = {2,0,0}    --游戏版本(译为全球资料片版本，可能会根据不同地区调整)

    local VersiongGlobalCfg = GlobalCfg:FindCfgByKey(ProtoRes.global_cfg_id.GLOBAL_CFG_GAME_VERSION)
    if not VersiongGlobalCfg then return end
    if not VersiongGlobalCfg.Value then return end
    self.GlobalVersions = VersiongGlobalCfg.Value
end

--- 适配版本号
function LegendaryWeaponMgr:GetVersions()
    local ChapterCfg = LegendaryWeaponChapterCfg:FindAllCfg()
    local TopicCfg = LegendaryWeaponTopicCfg:FindAllCfg()
    
    -- 章节版本
    self.ChapterVersion = {}
    for _, v in pairs(ChapterCfg) do
        local ID = v.ID
        self.ChapterVersion[ID] = false
        if self.GlobalVersions[1] == nil then
            return
        end
        if self.GlobalVersions[1] > v.MajorVersion then      --若主版本直接满足则为true
            self.ChapterVersion[ID] = true
        elseif self.GlobalVersions[1] == v.MajorVersion then --若主版本可能满足，再判断次版本
            if self.GlobalVersions[2] > v.MinorVersion then
                self.ChapterVersion[ID] = true
            elseif self.GlobalVersions[2] == v.MinorVersion then
                if self.GlobalVersions[3] >= v.PatchVersion then
                    self.ChapterVersion[ID] = true
                end
            end
        end
    end

    -- 主题版本
    self.TopicVersion = {}
    for _, v in pairs(TopicCfg) do
        local VersionString = v.Version
        local VersionString = string.split(VersionString, '.')
        local Topics = {}
        for i, Ver in ipairs(VersionString) do
            Topics[i] = tonumber(Ver)
        end
        if nil == Topics[1] then return end
        local ID = v.TopicID
        self.TopicVersion[ID] = false
        if self.GlobalVersions[1] > Topics[1] then      --若主版本直接满足则为true
            self.TopicVersion[ID] = true
        elseif self.GlobalVersions[1] == Topics[1] then --若主版本可能满足，再判断次版本
            if self.GlobalVersions[2] > Topics[2] then
                self.TopicVersion[ID] = true
            elseif self.GlobalVersions[2] == Topics[2] then
                if self.GlobalVersions[3] >= Topics[3] then
                    self.TopicVersion[ID] = true
                end
            end
        end
    end
end

------------- ↓ 红点相关 ↓ ------------------
--- 初始化红点
function LegendaryWeaponMgr:InitRedDot()

	self:RegisterTimer(self.OnGameEventUpdateRedDot, 5.0)

end

function LegendaryWeaponMgr:OnGameEventBagUpdate(Params)
    if self.BagTimerHandle ~= nil then  --清除定时器
		self:UnRegisterTimer(self.BagTimerHandle)
		self.BagTimerHandle = nil
	end
	self.BagTimerHandle = self:RegisterTimer(self.OnGameEventUpdateRedDot, 1.0)
end

--- 更新红点
function LegendaryWeaponMgr:OnGameEventUpdateRedDot()
    self:UpdateRedDotList()

    if _G.UIViewMgr:IsViewVisible(UIViewID.LegendaryWeaponPanel) then
        self:UpdateMainPanelRedDot() --在主界面中
    else
        self:UpdateMenuRedDot()      --在外部
    end
end

--- 统计所有可显示红点的武器
function LegendaryWeaponMgr:UpdateRedDotList()
    local LegendaryWeaponCfg = LegendaryWeaponCfg:FindAllCfg() or {}
    self.ShowRedDotList = {}
    self.RedDotListID = {}
    for _, WeaponCfg in pairs(LegendaryWeaponCfg) do
        if nil ~= WeaponCfg and
            self.TopicVersion[WeaponCfg.TopicID] and self.ChapterVersion[WeaponCfg.ChapterID] and   --游戏(资料片)版本已解锁
            (not LegendaryWeaponMgr.QueryList[WeaponCfg.ID]) then --未获取、未制作、未强化过

            local bIsEnough = self:FindMaterialEnough(WeaponCfg)    --判断制作材料是否满足
            self.RedDotListID[WeaponCfg.ID] = bIsEnough

            if bIsEnough == true then  --仅存可显示红点的ID
                self.ShowRedDotList[WeaponCfg.ID] = 
                {
                    WeaponID = WeaponCfg.ID,
                    TopicID = WeaponCfg.TopicID,
                    ChapterID = WeaponCfg.ChapterID,
                    EquipmentID = WeaponCfg.EquipmentID,
                }
            end

            if not bIsEnough then   --将不满足制作条件的删除
               if self.ShowRedDotList[WeaponCfg.ID] ~= nil then
                    self.ShowRedDotList[WeaponCfg.ID] = nil
               end
            end
        end
    end
end

--- 更新红点：内部（主界面）
function LegendaryWeaponMgr:UpdateMainPanelRedDot()
    local VM = LegendaryWeaponMainPanelVM
    self:UpdateChapterRedDot(VM)
    self:UpdateTopicRedDot(VM)
    self:UpdateMakeRedDot(VM)
    self:UpdateProfRedDot(VM)
end

--- 更新红点：可制作章节
function LegendaryWeaponMgr:UpdateChapterRedDot(ViewModel)
    if not ViewModel then return end
    local WeaponTopicID = ViewModel.WeaponCfg and ViewModel.WeaponCfg.TopicID or 1
    local CurProf = nil
    if ViewModel.ProfList and ViewModel.SelectWeaponIndex ~= nil then
        if nil ~= ViewModel.ProfList[ViewModel.SelectWeaponIndex] then
            CurProf = ViewModel.ProfList[ViewModel.SelectWeaponIndex].Prof
        end
    end
    local CurShowChapter = {}
    local CurTopicList = LegendaryWeaponCfg:FindAllCfg(string.format("TopicID=%d", WeaponTopicID))
    for _, CurTopicCfg in pairs(CurTopicList) do
        local Cfg = ItemCfg:FindCfgByKey(CurTopicCfg.EquipmentID)
        if Cfg and Cfg.ProfLimit[1] ~= nil then
            local CfgProf = Cfg.ProfLimit[1]
            if CurProf == CfgProf then
                CurShowChapter[CurTopicCfg.ID] = {TopicID = CurTopicCfg.TopicID, ChapterID = CurTopicCfg.ChapterID}
            end
        end
    end
    for k, v in pairs(CurShowChapter) do
        if v and v.TopicID and v.ChapterID then
            local RedDotID = LegendaryWeaponDefine.GetTopicOrChapterRedDotID(v.TopicID, v.ChapterID)
            if RedDotID then
                if self.RedDotListID[k] == true then
                    self:SetRedDot(RedDotID, true)
                end
                if not self.RedDotListID[k] then
                    self:SetRedDot(RedDotID, false)
                end
            end
        end
    end

    --[[ 下面这段功能是区分与上面的不同红点显示规则：
            1、基于章节的显示规则，当前章节的任意职业可制作即显示红点；
            2、其他职业能做武器，但是当前展示的职业不能做，也会显示；
            3、例如第一章的战士武器能制作，则切换到任意职业，第一章都会显示红点。
    local ChapterCfg = LegendaryWeaponChapterCfg:FindAllCfg()
    if ChapterCfg == nil then return end
    local ChapterRedDotList = LegendaryWeaponDefine.ChapterRedDotID
	if ChapterRedDotList == nil then return end
    for _, Value in pairs(ChapterCfg) do
        if Value.ChapterID and Value.TopicID then
            local function FindID(Data)
                return Data.TopicID == Value.TopicID and Data.ChapterID == Value.ChapterID
            end
            local v, k = table.find_by_predicate(self.ShowRedDotList, FindID)
            if v ~= nil then
                --显示红点
                local RedDotID = ChapterRedDotList[v.ChapterID]
                if RedDotID then
                    self:SetRedDot(RedDotID, true)
                end
            end
            if not v then
                --隐藏红点
                local RedDotID = ChapterRedDotList[Value.ID]
                if RedDotID then
                    self:SetRedDot(RedDotID, false)
                end
            end
        end
    end ]]
end

function LegendaryWeaponMgr:UpdateTopicRedDot(ViewModel)
    if not LegendaryWeaponDefine.TopicRedDotID then
        return
    end
    if not self.ShowRedDotList then
        for _, v in pairs(LegendaryWeaponDefine.TopicRedDotID) do
            self:SetRedDot(v, false)
        end
        return
    end
    for k, v in pairs(LegendaryWeaponDefine.TopicRedDotID) do
        local RedDotID = v
        local IsExist = false
        if RedDotID then
            for _, WeaponCfg in pairs(self.ShowRedDotList) do
                if WeaponCfg and WeaponCfg.TopicID == k then
                    self:SetRedDot(RedDotID, true)
                    IsExist = true
                    break
                end
            end
        end
        if IsExist == false then
            self:SetRedDot(RedDotID, false)
        end
    end
end

--- 更新红点：切换到材料制作页按钮
function LegendaryWeaponMgr:UpdateMakeRedDot(ViewModel)
    if not ViewModel then return end
    local WeaponCfg = ViewModel.WeaponCfg   --当前选中的武器
    if WeaponCfg and WeaponCfg.ID then
        if self.RedDotListID[WeaponCfg.ID] == true then
            self:SetRedDot(LegendaryWeaponDefine.RedDotID.Make, true)
        end
        if not self.RedDotListID[WeaponCfg.ID] then
            self:SetRedDot(LegendaryWeaponDefine.RedDotID.Make, false)
        end
    end
end

--- 更新红点：职业切换下拉菜单
function LegendaryWeaponMgr:UpdateProfRedDot(ViewModel)
    local ProfRedDotList = LegendaryWeaponDefine.ProfRedDotID
	if ProfRedDotList == nil or ViewModel == nil then return end
    local ProfList = ViewModel.ProfList
    if (ProfList == nil or type(ProfList) ~= "table") then return end
    local IsExist = false
    local ShowProfList = {}
    for k, v in pairs(self.ShowRedDotList) do
        local Cfg = ItemCfg:FindCfgByKey(v.EquipmentID)
        if Cfg and Cfg.ProfLimit[1] ~= nil then
            ShowProfList[Cfg.ProfLimit[1]] = true
        end
    end
    for _, Value in pairs(ProfList) do
        local Prof = Value.Prof
        if ShowProfList[Prof] == true then
            self:SetRedDot(ProfRedDotList[Prof], true)
            IsExist = true
        end
        if not ShowProfList[Prof] then
            self:SetRedDot(ProfRedDotList[Prof], false)
        end
        self:SetRedDot(ProfRedDotList[Value.Prof], ShowProfList[Value.Prof] == true)
    end
    if not IsExist then
        self:SetRedDot(LegendaryWeaponDefine.RedDotID.ProfChange, false)
    end

    --显示红点的规则有调整，把下面这段注销掉了，再在上面写新规则。
    --[[ 下面这段的作用是基于章节的红点显示规则：
            1、在当前主题章节所对应的武器中显示红点；
            2、每个章节都对应不同职业武器；
            3、例如主题1第二章只配置10个职业武器，则会检查这10个是否显示红点。
    for _, Value in pairs(ProfList) do
        if Value.Prof and Value.WeaponCfg.ID then
            if true == self.RedDotListID[Value.WeaponCfg.ID] then
                self:SetRedDot(ProfRedDotList[Value.Prof], true)
                IsExist = true
            end
            if not self.RedDotListID[Value.WeaponCfg.ID] then
                self:SetRedDot(ProfRedDotList[Value.Prof], false)
            end
        end
    end
    if not IsExist then
        self:SetRedDot(LegendaryWeaponDefine.RedDotID.ProfChange, false)
    end     ]]
end

--- 更新红点：外部
function LegendaryWeaponMgr:UpdateMenuRedDot()
    local MyType = Main2ndPanelDefine.MenuType.LegendaryWeapon
    local MenuItemsCfg = RightMenuItemsCfg:FindAllCfg(string.format("BtnEntranceID=%d", MyType))
    if not MenuItemsCfg or not MenuItemsCfg[1] or MenuItemsCfg[1].IsOpen ~= 1 then
        return  --菜单中没有则不显示
    end

    local MOpen = _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDLegendaryWeapon)
    if not MOpen then
        return  --菜单中未解锁则不显示
    end

    for _, Value in pairs(self.ShowRedDotList) do
        if nil ~= Value then
            self:SetRedDot(LegendaryWeaponDefine.RedDotID.Make, true)
            --如果不在主界面，则只需要显示外部红点，执行一次即可跳出
            return
        end
    end

    if ( nil == self.ShowRedDotList or #self.ShowRedDotList == 0 ) and self.bFirstOpenModule ~= true then
        self:SetRedDot(LegendaryWeaponDefine.RedDotID.LegendaryWeapon, false)
    elseif self.bFirstOpenModule == true then
        self.bFirstOpenModule = nil
    end
end

--- 设置红点
function LegendaryWeaponMgr:SetRedDot(RedDotID, bShow)
    if not RedDotID then return end
	local IsDelRedDot = RedDotMgr:GetIsSaveDelRedDotByID(RedDotID)
    
    if bShow then
        --if not IsDelRedDot then
            RedDotMgr:AddRedDotByID(RedDotID, nil, true)    --显示红点
        --end
    end

    if not bShow then
        if not IsDelRedDot then
            RedDotMgr:DelRedDotByID(RedDotID)   --隐藏红点
        end
    end
end

function LegendaryWeaponMgr:OnModuleOpenNotify(ModuleID)
    if ModuleID == ProtoCommon.ModuleID.ModuleIDLegendaryWeapon then
        self.bFirstOpenModule = true
        self:OnGameEventBagUpdate()
    end
end
------------- ↑ 红点相关 ↑ end ------------------

--- 判断该武器材料是否满足制作条件
function LegendaryWeaponMgr:FindMaterialEnough(WeaponCfg)
    local bHaveSpecial = (WeaponCfg.SpecialItems[1] and WeaponCfg.SpecialItems[1].ResID ~= 0)
    local bIsEnough = true
    for _, ConsumeItem in pairs(WeaponCfg.ConsumeItems) do
        local CurNumber = _G.BagMgr:GetItemNum(ConsumeItem.ResID)  --获取背包中的通用材料数量
        if EquipmentMgr:GetEquipedItemByPart((ProtoCommon.equip_part.EQUIP_PART_MASTER_HAND)) or 
            EquipmentMgr:GetEquipedItemByPart((ProtoCommon.equip_part.EQUIP_PART_SLAVE_HAND)) then
            CurNumber = CurNumber + EquipmentMgr:GetEquipedItemNum(ConsumeItem.ResID)   --获取已装备的数量（武器原型）
        end
        if CurNumber < ConsumeItem.Num then
            bIsEnough = false
            break
        end
    end
    if bIsEnough and bHaveSpecial then
        for _, ConsumeItem in pairs(WeaponCfg.SpecialItems) do
            local CurNumber = _G.BagMgr:GetItemNum(ConsumeItem.ResID)  --获取背包中的特殊魂晶数量
            if CurNumber < ConsumeItem.Num then
                bIsEnough = false
                break
            end
        end
    end
    return bIsEnough
end

--- 打开传奇武器主界面，并解锁全部版本。（仅限内部GM调试使用）
function LegendaryWeaponMgr:ShowLegendaryWeaponPanel()
	if _G.UIViewMgr:IsViewVisible(UIViewID.LegendaryWeaponPanel) then
		_G.UIViewMgr:HideView(UIViewID.LegendaryWeaponPanel)
	else
        --- 解锁全部版本
        self.GlobalVersions = {9,9,9}
        self:GetVersions()

		_G.UIViewMgr:ShowView(UIViewID.LegendaryWeaponPanel, {OpenSource = 9})
	end
end

--- 传奇武器调试工具（仅限内部GM调试使用）
function LegendaryWeaponMgr:ShowDebugUI()
    if not _G.UIViewMgr:IsViewVisible(UIViewID.LegendaryWeaponDeBugUI) then
        _G.UIViewMgr:ShowView(UIViewID.LegendaryWeaponDeBugUI)
        MsgTipsUtil.ShowTips(LSTR(220012))  --"请打开传奇武器主界面后，查看此工具"
    end
end

--- 绑定触控输入
function LegendaryWeaponMgr:BindCommGesture(UIView, InSingleClick)
    self.CommGesture = UIView
    self.SingleClick = InSingleClick
    UIView:SetOnClickedCallback(function(ScreenPosition)
        self:OnClickedHandle(ScreenPosition)
    end)
    UIView:SetOnPositionChangedCallback(function(X, Y)
        self:OnDragHandle(X, Y)
    end)
end

function LegendaryWeaponMgr:OnClickedHandle(ScreenPosition)
    if self.SingleClick then
        self.SingleClick(ScreenPosition)
    end
end

--- 手指触控拖动武器旋转
function LegendaryWeaponMgr:OnDragHandle(X, Y)
    local OffsetX = self.LastDragX - X
    if math.abs(OffsetX) <= 5 then
        return
    end

    if OffsetX > 15.0 then
        OffsetX = 15.0
    elseif OffsetX < -15.0 then
        OffsetX = -15.0
    end

    if self.bEnableRotator then
        local MainPanelVM = LegendaryWeaponMainPanelVM
        local BP_SceneActor = MainPanelVM.BP_SceneActor
        self:DragWeaponLoop()

        do
            local WeaponActor = BP_SceneActor and BP_SceneActor.WeaponBaseChar or nil
            if WeaponActor ~= nil and _G.UE.UCommonUtil.IsObjectValid(WeaponActor) then
                local NewRotation = _G.UE.FRotator(0, OffsetX, 0)

                -- 若为双武器，则围绕中心点旋转
                if (MainPanelVM.IsShowWeaponModel == true) and MainPanelVM.SelectSubWeaponID ~= 0 then
                    local WeaLoc = WeaponActor:K2_GetActorLocation()
                    local CenterPoint = _G.UE.FVector(0, 0, 100000)
                    local OffsetToActor = WeaLoc - CenterPoint
                    local RotatedOffset = NewRotation:RotateVector(OffsetToActor)
                    local NewLocation = CenterPoint + RotatedOffset
                    WeaponActor:K2_SetActorLocation(NewLocation, false, nil, false)
                end

                BP_SceneActor:AddWeaponMeshRotation(NewRotation)
            end
        end

        do
            local SubWeaponActor = BP_SceneActor and BP_SceneActor.SubWeaponBaseChar or nil
            if SubWeaponActor ~= nil and _G.UE.UCommonUtil.IsObjectValid(SubWeaponActor) then
                local NewRotation = _G.UE.FRotator(0, OffsetX, 0)

                if (MainPanelVM.IsShowWeaponModel == true) and MainPanelVM.SelectSubWeaponID ~= 0 then
                    local SubWeaLoc = SubWeaponActor:K2_GetActorLocation()
                    local CenterPoint = _G.UE.FVector(0, 0, 100000)   --中心点旋转轴
                    local OffsetToActor = SubWeaLoc - CenterPoint
                    local RotatedOffset = NewRotation:RotateVector(OffsetToActor)
                    local NewLocation = CenterPoint + RotatedOffset
                    SubWeaponActor:K2_SetActorLocation(NewLocation, false, nil, false)
                end

                BP_SceneActor:AddSubWeaponMeshRotation(NewRotation)
            end
        end
    end
    self.LastDragX = X
end

--- 拖动时，由手指控制武器转动，此时关闭武器loop自转，当停止拖动1s后会再次开启loop
function LegendaryWeaponMgr:DragWeaponLoop()
    local MainPanelVM = LegendaryWeaponMainPanelVM
    if not MainPanelVM then return end
    local BP_SceneActor = MainPanelVM.BP_SceneActor or nil
    if not UCommonUtil.IsObjectValid(BP_SceneActor) then return end

    if MainPanelVM.IsComposeMode then
        local CotuverSeq = BP_SceneActor:GetCotuverSequence()
        --此处调用Stop是为避免速切后又进行速拖动的情况
        if CotuverSeq then
            CotuverSeq:Stop()
        end
    end
    BP_SceneActor.bIsComposeMode = true

    local function WeaponLoopR()
        if UCommonUtil.IsObjectValid(BP_SceneActor) then
            if MainPanelVM.IsComposeMode then
                return   --如果在材料制作界面，则不自转
            end
            BP_SceneActor.bIsComposeMode = false
        end
    end
    if self.DragTimer ~= nil then
        self:UnRegisterTimer(self.DragTimer)
        self.DragTimer = nil
    end
    self.DragTimer = self:RegisterTimer(WeaponLoopR, 1.0)
end

--- 传送时关闭传奇武器界面
function LegendaryWeaponMgr:OnGameEventPreCrystalTransferReq()
    if _G.UIViewMgr:IsViewVisible(UIViewID.LegendaryWeaponPanel) then
		_G.UIViewMgr:HideView(UIViewID.LegendaryWeaponPanel)
    end
end

return LegendaryWeaponMgr