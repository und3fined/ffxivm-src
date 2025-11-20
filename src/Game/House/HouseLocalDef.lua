---
--- Author: muyanli
--- DateTime: 2025-06-06 09:23
--- Description:
---
local LSTR = _G.LSTR
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoCS = require("Protocol/ProtoCS")

---@class HouseLocalDef
local HouseLocalDef = {
    HouseTabIndex = {
        MyHouse = 1, -- 我的房屋
        LandBuy = 2 -- 土地购买
    },
    -- 房屋类型
    HouseEntranceType = {
        Personal = 0, -- 个人房屋
        Army = 1, -- 部队的屋
        Shared = 2 ---	共享房屋
    },
    LandQuerySceneType = {
        LandList = 1, -- 土地列表
        LandInfo = 2, -- 土地信息
        HouseList = 3, -- 房屋列表
        MapLand = 4 -- 地图土地
    },
    ServerTimeZone = 8, -- 服务器时区
    HouseTabData = {
        [1] = {Name = LSTR("我的房屋"), RedDot = 30004},
        [2] = {Name = LSTR("土地购买"), RedDot = 30001},
    },
    BuyHouseStateType = {
        [1] = LSTR("%s购房条件"), -- "参与抽选
        [2] = LSTR("参与抽选"), -- "参与抽选
        [3] = LSTR("抽选结果"), -- "抽选结果"
        [4] = LSTR("建造房屋") -- "建造房屋"
    },

    BuyHouseBelongTypeStr = {
        [1] = LSTR("个人"), -- "未达成
        [2] = LSTR("部队") -- "剩%s
    },

    BuyHouseBelongType = {
        Personal = 1, -- 个人
        Army = 2 -- 部队
    },

    BuildHouseItemCostNum = 1, -- 建造房屋所需的物品数量

    SelectInfoType = {
        MySelect = 1, -- "我的抽选
        ArmySelect = 2, -- "部队抽选"
        RecycleAssets = 3 -- 资产回收
    },
    
    RedDotDefine = {
        MySelectionRedDot = 30002,
        ArmySelectionRedDot = 30003,
        PersonRecycle = 30006,
        ArmyRecycle = 30007,
        SelfRoomRecycle = 30008,
        HouseFirstUnLock = 30009,
        ShareHouseInvite = 30012,
        ShareEntranceRedDot = 30010
    },

    SelectInfoTypeData = {
        [1] = {Name = LSTR("我的抽选"), RedDot = 30002},-- "参与抽选
        [2] = {Name = LSTR("部队抽选"), RedDot = 30003},-- "抽选结果"
        [3] = {Name = LSTR("资产回收"), RedDot = 30005}
    },


    BuyHouseState = {
        [1] = LSTR("(未达成)"), -- "未达成
        [2] = LSTR("剩%s"), -- "剩%s
        [3] = LSTR("未参选"), -- "未参选"
        [4] = LSTR("不可参选"), -- "不可参选"
        [5] = LSTR("已参选"), -- "已参选"
        [6] = LSTR("未公示"), -- "未公示"
        [7] = LSTR("%s后公示"), -- "%s后公示"
        [8] = LSTR("已公示"), -- "已公示"
        [9] = LSTR("未中选"), -- "未中选"
        [10] = LSTR("已中选"), -- "已中选"
        [11] = LSTR("不可建造"), -- "不可建造"
        [12] = LSTR("可建造"), -- "不可建造"
        [13] = LSTR("已建造"), -- "已建造"
        [14] = LSTR("已逾期") -- "已逾期"
    },
    ApplyStatus = {
        [1] = LSTR("不可参选"), -- "未达成
        [2] = LSTR("未参选"), -- "剩%s
        [3] = LSTR("已参选"), -- "未参选"
        [4] = LSTR("已中奖"), -- "不可参选"
        [5] = LSTR("未退钱"), -- "已参选"
        [6] = LSTR("已退钱"), -- "未公示"
    },

    BuyHouseStateTxtColor = {"d5d5d5ff", "89bd88ff", "ee0000ff"},
    BuyHouseProcessIconPrePath = "PaperSprite'/Game/UI/Atlas/House/Frames/%s.%s'",
    BuyHouseProcessIconType = {
        [1] = "UI_House_Icon_Process_Lock_png", -- 锁定
        [2] = "UI_House_Icon_Process_Wait_png", -- 等待
        [3] = "UI_House_Icon_Process_Interrupt_png", -- 未达成
        [4] = "UI_House_Icon_Process_Hook_png" -- 达成
    },

    LandSizeTypeStr = {
        [1] = "S",
        [2] = "M",
        [3] = "L"

    },

    HouseInfoSizeStr = {
        [0] = LSTR("小"), -- "小"
        [1] = LSTR("中"), -- "中"
        [2] = LSTR("大") -- "大"
    },

    LandSizeTabTypeStr = {{
        Name = LSTR("全部")
    }, -- "全部
    {
        Name = LSTR("S") .. LSTR("尺寸")
    }, {
        Name = LSTR("M") .. LSTR("尺寸")
    }, {
        Name = LSTR("L") .. LSTR("尺寸")
    }},

    LandBuyTabTypeStr = {{
        Name = LSTR("全部")
    }, -- "全部
    {
        Name = LSTR("个人可购买")
    }, -- "个人可购买
    {
        Name = LSTR("部队可购买")
    }, -- "部队可购买
    {
        Name = LSTR("所有人可购买")
    } -- "所有人可购买
    },
    LandListTabType = {
        All = 1, -- "全部
        Sale = 2, -- "申请中
        Ready = 3, -- "准备中
        Public = 4, -- "公示中
        Collect = 5 -- "收藏
    },

    LocalTxtStr = {
        LandListTitle = LSTR("土地列表"), -- 土地列表
        HouseInfoTitle = LSTR("房屋资料"), -- 房屋资料
        BuildHouseTitle = LSTR("选择房屋样式"), -- 选择房屋样式
        HousePurchaseConditionTitle = LSTR("购房条件"), -- 购房条件
        HouseInfoSettingsTitle= LSTR("住房设置"), -- 购房条件
        LandSize = LSTR("尺寸"), -- 尺寸
        AllType = LSTR("全部"), -- 全部
        LandListInfoTxt = LSTR("第%d区 %s %s号[%s]"), -- 第%d区 %s %s号[%s]
        UnLockByTask = LSTR("任务解锁"), -- 任务解锁
        SelectSuc = LSTR("成功参选"), -- 成功参选
        SelectSucTips = LSTR("参与抽选成功!你的号码如下:"), -- 参与抽选成功!你的号码如下:
        SelectResultTimeStr = LSTR("%s公示抽选结果"), -- %s公示抽选结果
        SelectOwnerTitle = LSTR("参选身份选择"), -- 参选身份选择
        SelectOwnerTips = LSTR(
            "请选择参与抽选的身份：\n每个申请期内，只能参与一处土地的抽选，参选后无法主动取消抽选。"), -- 参选身份选择
        LandBelongType1 = LSTR("玩家角色"), -- 玩家角色
        LandBelongTips = LSTR("完成土地购买时，土地所有权归属于%s"), -- 参选身份选择
        SelectLandBelongTypeTips = LSTR("请先选择参选身份"), -- 请先选择参选身份
        LandBuyReminderStr = LSTR("同意注意事项，参与土地抽选"),
        NoReminderTips = LSTR("请先同意注意事项"),
        BtnSure = LSTR(1160045), -- 确定
        BtnCancel = LSTR(1160017), -- 取消
        NoTips = LSTR("无"), -- 无
        BuildHouse = LSTR("建造"), -- 建造
        BuildHouseItemNotEnough = LSTR("道具数量不足"), -- 道具数量不足
        NoBuildHousePrivilege = LSTR("无建房权限"), -- 无建房权限
        TextNoTag = LSTR("暂未设置标签"), -- 暂未设置标签
        TextGreetingContentEmpty = LSTR("暂未设置问候语"), -- 暂未设置问候语
        HouseOwnerTittle = LSTR("房主"), -- 房主
        HouseNoPhoto = LSTR("未设置展示图片"), -- 未设置展示图片
        HouseCannotBrowser = LSTR("房屋信息未公开~"), -- 房屋信息未公开~
        HouseReturnmoney = LSTR("%s×%d"), -- %s×%d
        HouseSelectResultTitle = LSTR("土地抽选结果"), -- 土地抽选结果
        HouseSelectResultTips = LSTR("你参与的[第%d期]土地抽选结果已逾期，请领取返还货币~"), -- 你参与的[第%d期]土地抽选结果已逾期，请领取返还货币~
        HouseSelectFailTips = LSTR("您参选的土地中选号码为%s，您落选了。请领取返还货币。"),
        NoBuildHousePermission = LSTR("无建房权限"),
    },

    HouseOpTipsData = {
        [1] = {
            Title = LSTR("拆除房屋"),
            CannotTips = LSTR("条件未达成，无法拆除"),
            AgreeCheck = LSTR("同意拆除房屋"),
            AgreeCheckTips = LSTR("请先同意拆除房屋"),
            AgreeTips = LSTR("确定要拆除房屋吗？"),
            SureTipsPersonal = LSTR("拆除房屋时，将不会返还设置的装潢配件、不会返还建造房屋的费用。"),
            SureTipsGroup = LSTR("拆除房屋时，所有个人房间也会一并拆除，需在部队房屋——房间资产界面，回收资产。"),
            DesHasPlayerInRange = LSTR("无法进行该操作，房屋外观变更范围内有玩家存在")
        },
        [2] = {
            Title = LSTR("放弃土地"),
            CannotTips = LSTR("条件未达成，无法放弃土地"),
            AgreeCheck = LSTR("同意放弃土地"),
            AgreeCheckTips = LSTR("同意放弃土地"),
            AgreeTips = LSTR("确定要放弃土地吗？"),
            SureTipsPersonal = LSTR("放弃土地时，不会返还购买土地的费用。"),
        }
    },

    LandInfoStr = {
        [1] = LSTR("价格"), -- "价格
        [2] = LSTR("地址"), -- "地址
        [3] = LSTR("尺寸"), -- "尺寸
        [4] = LSTR("土地状况"), -- "土地状况
        [5] = LSTR("参与抽选人数"), -- "参与抽选人数
        [6] = LSTR("你的参选号码"), -- "你的参选号码
        [7] = LSTR("中选号码"), -- "中选号码
        JoinPlayerName = LSTR("参选玩家"), -- "参选玩家
        ArmSelectNumber = LSTR("部队参选号码"), -- "部队参选号码
        LandInfo = LSTR("土地资料"), -- "土地资料
        Transmit = LSTR("传送"), -- "传送
        SelectFail = LSTR("参选失败%d"), -- 你的部队
        ReceiveMoney = LSTR("领取返还货币"), -- 领取返还货币
        JoinSelect = LSTR("参与抽选"), -- "参与抽选
        CannotSelect = LSTR("不可抽选"), -- "不可抽选
        HasJoinSelect = LSTR("已参与抽选"), -- "已参与抽选
        ReadyTimeTips = LSTR("%s后可抽选"), -- "%s后可抽选
        PublicTimeTips = LSTR("%s后公示结果"), -- "%s后公示结果
        NoSelecCondition = LSTR("不满足抽选条件"), -- "不满足抽选条件
        CannotVisitorSelect = LSTR("不可跨服抽选土地"), -- "不可跨服抽选土地
        Address = LSTR("%s 第%d区%d号"), -- "%s 第%d区%d号
        BuildTips = LSTR("请于本次公示期内前往建造房屋，逾期视为放弃土地"), -- 请于本次公示期内前往建造房屋，逾期视为放弃土地
        CurPeriod = LSTR("本期"), -- "本期
        UnSelected = LSTR("%d %s未中选~"), -- %s未中选~
        Selected = LSTR("%d 恭喜%s中选!"), -- 恭喜%s中选!
        YourTeam = LSTR("你的部队"), -- 你的部队
        Your = LSTR("你"), -- 你
        [8] = LSTR("仅限个人购买"), -- 仅限个人购买
        [9] = LSTR("仅限部队购买"), -- 仅限部队购买
        [10] = LSTR("所有人可购买") -- 所有人可购买
    },
    LandInfoItemColor = {
        Defalut = "070707FF",
        Select = "b56728ff",
        Selected = "ffeebbff",
        BuildTips = "af4c58ff"
    },

    BuyStateTips = {
        [1] = LSTR("(该期土地抽选已结束)"), -- 该期土地抽选已结束
        [2] = LSTR("未参与抽选"), -- 未参与抽选%s
        [3] = LSTR("当前不可建造") -- 当前不可建造"
    },

    BuyConditionTabs = {{
        Index = 1,
        Name = LSTR("个人房屋")
    }, {
        Index = 2,
        Name = LSTR("部队房屋")
    }},

    SubAreaTypeStr = {{
        Name = LSTR("初始区")
    }, {
        Name = LSTR("扩建区")
    }},

    LandStateTabList = {{
        Index = 1,
        LandStatu = 0,
        Name = LSTR("全部"),
        IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Region_026.UI_Icon_Tab_Region_026'"

    }, -- "全部
    {
        Index = 2,
        LandStatu = 2,
        Name = LSTR("售卖中"),
        IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_House_001.UI_Icon_Tab_House_001'"
    }, -- "售卖中
    {
        Index = 3,
        LandStatu = 1,
        Name = LSTR("准备中"),
        IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_House_002.UI_Icon_Tab_House_002'"
    }, -- "准备中
    {
        Index = 4,
        LandStatu = 3,
        Name = LSTR("公示中"),
        IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_House_003.UI_Icon_Tab_House_003'"
    }, -- "公示中
    {
        Index = 5,
        LandStatu = 0,
        Name = LSTR("收藏"),
        IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Region_025.UI_Icon_Tab_Region_025'",
        TabCanShow = function()
            local OriginWorldID = _G.LoginMgr:GetWorldID()  -- 原始WorldID
            local CurWorldID = _G.PWorldMgr:GetCurrWorldID()
            return OriginWorldID == CurWorldID
        end
    } -- "收藏
    },

    LandStatuIconPath = "PaperSprite'/Game/UI/Texture/House/Icon/UI_House_Icon_Sell_%02d.UI_House_Icon_Sell_%02d'",

    LandInfoItemBg = {
        [1] = "ImgListBG",
        [2] = "ImgListUnSelected",
        [3] = "ImgListSelected",
        [4] = "ImgListBGRed"
    },

    LandListPhaseTypeStr = {LSTR("准备中"), LSTR("正在售卖"), LSTR("公示中")},

    LandListPhaseTimeStr = {LSTR("%s开始售卖"), LSTR("%s后结束")},
    HouseOpType = {
        None = 0, -- 无
        Destory = 1, -- 拆除
        GiveUpLand = 2 -- 放弃土地
    },

    HouseOpCondition = {
        RecycleAll = 1, -- 回收全部家具
        EmptyDepot = 2, -- 清空仓库
        EmptyLand = 1,  -- 空地无房屋
    },

    DestoryHouseConditions = {
        [1] = {
            Desc = LSTR("已回收全部庭具、家具"),
            HouseOpType = 1
        },
        [2] = {
            Desc = LSTR("已清空房屋仓库"),
            HouseOpType = 1
        },
        [3] = {
            Desc = LSTR("-不会返还设置的装潢配件、不会返还建造房屋的费用"),
            BtnName = LSTR("拆除房屋"),
            HouseOpType = 1
        }
    },

    GiveUpLandConditions = {
        [1] = {
            Desc = LSTR("需要拆除房屋"),
            HouseOpType = 2
        },
        [2] = {
            Desc = LSTR("-不会返还购买土地的费用"),
            BtnName = LSTR("放弃土地"),
            HouseOpType = 2
        }
    },

    LocationInfoStr = {
        TextSerialNumber = LSTR("号"), -- 号
        TextName = LSTR("业主"), -- 业主
        TextHousingLocation = LSTR("问候语/售价"), -- "问候语/售价
        TextTag = LSTR("标签"), -- "标签
        TextLike = LSTR("点赞数"), -- "点赞数
        Tab = LSTR("%d-%d区"), -- %d-%d区
        SubTab = LSTR("第%d区"), -- "第%d区
        LandNumName = LSTR("%02d【%s】"), -- "第%d区
        HouseInfoHide = LSTR("房屋信息已隐藏"), -- 房屋信息已隐藏
        TextGeeting = LSTR("问候语"), -- 问候语
        HouseAddr = LSTR("%s 第%d区%d号 [%s]"), -- %s 第%d区%d号 [%s]
        RoomAddr = LSTR("%s 第%d区 %d号 %d号房间")
    },

    LocationHouseTagIconPath = "PaperSprite'/Game/UI/Texture/House/Icon/UI_House_Icon_Tag_%02d.UI_House_Icon_Tag_%02d'",
    LocationHouseIconPath = "PaperSprite'/Game/UI/Texture/House/Icon/UI_House_Icon_Type_%s_%02d.UI_House_Icon_Type_%s_%02d'",
    LocationLandIconPath = "PaperSprite'/Game/UI/Texture/House/Icon/UI_House_Icon_Sell_%02d.UI_House_Icon_Sell_%02d'",
    LocationAreaSubTabNum = 5,
    HouseType = {
        ReadyLand = 1,
        SaleLand = 2,
        PublicLand = 3,
        ShareHouse = 4,
        MyPersonalHouse = 5,
        MyArmyHouse = 6,
        CanVisitPersonalHouse = 7,
        CanVisitArmyHouse = 8,
        CanNotVisitPersonalHouse = 9,
        CanNotVisitArmyHouse = 10
    },

    HouseTypeInfo = {
        [1] = {
            Tips = LSTR("准备中的土地"),
            IconIndex = 1
        },
        [2] = {
            Tips = LSTR("正在售卖的土地"),
            IconIndex = 2
        },
        [3] = {
            Tips = LSTR("公示中的土地"),
            IconIndex = 3
        },

        [4] = {
            Tips = LSTR("共享房屋"),
            IconIndex = 1
        },
        [5] = {
            Tips = LSTR("我的个人房屋"),
            IconIndex = 2
        },
        [6] = {
            Tips = LSTR("我的部队房屋"),
            IconIndex = 3
        },
        [7] = {
            Tips = LSTR("可访问的个人房屋"),
            IconIndex = 4
        },
        [8] = {
            Tips = LSTR("可访问的部队房屋"),
            IconIndex = 5
        },
        [9] = {
            Tips = LSTR("不可访问的个人房屋"),
            IconIndex = 6
        },
        [10] = {
            Tips = LSTR("不可访问的部队房屋"),
            IconIndex = 7
        }
    },
    LandTransmitType = {
        Residence = 1,
        Land = 2,
        House = 3,
        Room = 4
    },
    LandTransmitClientTag = {
        NoTips = 1,
        Normal = 2
    },
    MajorHouseInfoTitle = LSTR("我的房屋"),
    HouseEntranceTips = {
        MajorNoHouse = LSTR("未持有个人房屋"),
        ArmyUnlock = LSTR("部队系统未解锁"),
        MajorNoArmy = LSTR("请先加入部队"),
        ArmyUnderLevel = LSTR("部队等级不足"),
        ArmyNoHouse = LSTR("未持有部队房屋"),
    },
    RoommatesSettingInfoStr = {
        RoommateTittle = LSTR("室友"),
        PrivilegeTittle = LSTR("权限设置"),
        InviteFriend = LSTR("邀请好友"),
        HintText = LSTR("邀请好友成为室友后，才能设置权限~"),
        Privilege = {
            [1] = {Name = LSTR("编辑住房名称、问候语"), IsShow = false},
            [2] = {Name = LSTR("设置访客权限及房屋宣传标签"), IsShow = false},
            [3] = {Name = LSTR("设置展示图片"), IsShow = false},
            [4] = {Name = LSTR("购买土地和搭建房屋"),IsShow = false},
            [5] = {Name = LSTR("房屋内外装潢/家具/庭具的追加、回收、布置"),IsShow = true},
            [6] = {Name = LSTR("管弦乐琴管理"), IsShow = false},
        },
        UnShareTipsOwner = LSTR("已与%s解除了共享"),
        UnShareTipsRM = LSTR("%s已与你解除了共享"),
        WinTittle = LSTR("房屋解除共享"),
        WinNotice = LSTR("确定要与%s解除房屋共享吗？解除后将无法继续使用该房屋功能")
    },
    HouseSaveStr = LSTR("保存"),
    HouseSaveSuc = LSTR("保存成功"),
    HouseSettingTag = "已选标签:%d/%d",
    HouseTagNumLimit = 3,
    HouseTagMaxNum = 23, -- 可勾选Tag的数量
    HouseNoArmy = LSTR("尚未加入部队"),
    HouseNoHouse = LSTR("尚未拥有个人房屋"),
    HouseGetHouse = LSTR("前往获取个人房屋"),
    HouseNoPic = LSTR("未设置展示照片"),
    HouseGetPic = LSTR("前往拍照"),
    HousePicLoading = LSTR("图片正在加载"),
    RoommatesInviteWinViewStr = {
        MenuList = {{
            NormalIcon = "Texture2D'/Game/UI/Texture/Icon/SideFrame/UI_Icon_SideTab_friend_Normal.UI_Icon_SideTab_friend_Normal'",
            SelectedIcon = "Texture2D'/Game/UI/Texture/Icon/SideFrame/UI_Icon_SideTab_friend_selected.UI_Icon_SideTab_friend_selected'",
            ModuleID = ProtoCommon.ModuleID.ModuleIDHOUSE,
            Type = 1
        }},
        PanelTittle = LSTR("邀请好友"),
        InviteTips = LSTR("已邀请%s"),
        InviteDelayTips = LSTR("请等玩家处理"),
        InviteFailTips = {
            [1] = LSTR("室友数量达到上线"),
            [2] = LSTR("无法邀请，该玩家已与其他玩家共享房屋"),
            [3] = LSTR("无法邀请，该玩家角色等级不足10级")
        },
        InviteRspTips = {
            [1] = LSTR("已成为%s的室友"),
            [2] = LSTR("已拒绝%s的室友邀请"),
            [3] = LSTR("%s已成为你的室友"),
            [4] = LSTR("%s拒绝了你的室友邀请")
        }
    },
    BeInvitedEmptyStr = LSTR("暂未收到其他人邀请你成为室友~"),
    RoommateInviteSideBarTittle = LSTR("室友邀请"),
    RoommateInviteSideBarContent = LSTR("玩家%s邀请你成为房屋[%s]的室友"),
    HouseLandAwardTitle = LSTR("%s房屋土地中选"),
    HouseLandAwardContent = LSTR("是否前往查看"),
    HouseLandAwardConfirm = LSTR("查看"),
    HouseLandAwardCancel = LSTR("取消"),
    HouseInfoText = LSTR("成功中选土地"),
    HouseInfoStr = {
        PictureText = LSTR("前往拍照"),
        TipsText = LSTR("未设置展示图片"),
        TeleportText = LSTR("传送"),
        TraceText = LSTR("追踪"),
        WayFinding = LSTR("寻路"),
        HouseSettingText = LSTR("住房设置"),
        OwnerText = LSTR("房主"),
        ArmyOwnerText = LSTR("部队长"),
        ArmyText = LSTR("部队"),
        DisSolveShare = LSTR("解除共享"),
        DoLikeText = LSTR("不可以给自己的房屋点赞"),
        HouseDefaultText = LSTR("%s%s-%s"),
        ArmyRoomDefaultText = LSTR("个人房间%s")
    },
    HouseInfoSettingWinStr = {
        HouseNameHint = LSTR("请输入房屋名称"),
        GreetingHint = LSTR("请输入问候语"),
        HouseNameTittle = LSTR("房屋名称"),
        GreetingTittle = LSTR("问候语"),
        PermissionTittle = LSTR("房屋出入和资料查看权限"),
        PermissionHint = LSTR("此处好友指房主的好友，不包含室友的好友"),
        AllPermission = LSTR("所有人"),
        FriendPermission = LSTR("仅好友、自己"),
        SelfPermission = LSTR("仅自己"),
        ArmyMemberPermission = LSTR("仅部队成员"),
        DestoryHouse = LSTR("拆除房屋"),
        GiveUpLand = LSTR("放弃土地"),
    },
    HouseRemoveRoommate = {
        [1] = LSTR("已与%s解除房屋共享"),
        [2] = LSTR("%s已与你解除房屋共享")
    },
    HouseDissolveBoxStr = {
        Tittle = LSTR("房屋解除共享"),
        Content = LSTR("确定要与%s解除房屋共享吗？解除后将无法继续使用该房屋功能")
    },
    HouseSharePrivilegeTittle = LSTR("定制管理"),
    HouseShareNoPrivilege = LSTR("暂无共享管理权限"),
    HouseArmyRoom = {
        RoomHide = LSTR("房屋信息已隐藏"),
        RoomEmpty = LSTR("空房"),
        IconPath = "Texture2D'/Game/UI/Texture/House/Icon/UI_House_Icon_Access_%02d.UI_House_Icon_Access_%02d'",
        BackToHome = LSTR("回房间"),
        ArmyNoHouse = LSTR("部队暂无房间"),
        MajorNoHouse = LSTR("个人暂无房间"),
        ArmyCreateHouse = LSTR("创建部队个人房间"),
        ArmyCreateHouseButton = LSTR("创建个人房间"),
        ArmyUnlock = LSTR("部队10级解锁"),
        IsEmptyRoom = LSTR("空房无法查看"),
        CannotVisit = LSTR("该房间不可查看"),
        ExitArmy = LSTR("你已被移出部队"),
        CreateRoomSuc = LSTR("创建成功"),
        VisArmyRoomTitle = LSTR("%s的部队房间"),
        GroupRoom = LSTR("部队房屋"),
    },
    SharingPermissionTittle = LSTR("定制管理"),

    FurnitureInteractionFood = {
        Title = LSTR("就餐"),
        Desc = LSTR("还可提供就餐%s次，确定要吃%s吗？"),
        Tips1 = LSTR("%s的味道真不错！"),
        Tips2 = LSTR("%s的最后一口味道仍然很不错！"),
        Tips3 = LSTR("%s已经没剩下什么了..."),
    },

    MyHousePanelPageDefine = {
        PersonalHouse = 0,
        ArmyHouse = 2,
        ShareHouse = 5
    },

    RecycleAssetsTitle = LSTR("资产回收"),

    RecycleAssetsTab = {
        [1] = {
            Key = ProtoCS.RecycleHouseAssetType.RecycleHouseAssetType_Personal,
            Name = LSTR("个人房屋资产"),
            RedDotID = 30006
        },
        [2] = {
            Key = ProtoCS.RecycleHouseAssetType.RecycleHouseAssetType_Group,
            Name = LSTR("部队房屋资产"),
            RedDotID = 30007
        },
        [3] = {
            Key = ProtoCS.RecycleHouseAssetType.RecycleHouseAssetType_GroupMemberRoom,
            Name = LSTR("个人房间资产"),
            RedDotID = 30008
        },
    },

    OtherStr = {
        CrossWorld = "该房屋不在当前服务器, \n是否跨界传送至【%s】。"
    },

    RecycleAssetsPanelText = {
        RecycleAssets = LSTR("可回收资产"),
        UnRecycleAssets = LSTR("不可回收资产"),
        PersonalTips = LSTR("你的个人房屋于%s(UTC+8)已被系统自动撤除"),
        ArmyTips = LSTR("你的部队房屋于%s(UTC+8)已被系统自动撤除"),
        ArmyRoomTips = LSTR("你的个人房间于%s(UTC+8)已被系统自动撤除"),
        RecycleBtnText = LSTR("回收资产"),
        RecycledBuyGoldContent = LSTR("由于原土地被系统自动撤除，以【个人】身份重新购买金币支付的土地时，将获得原土地价格%s金币的减免，该减免在中选土地后将自动使用生效(仅生效一次)。若新的土地价格低于减免的土地价格，不会返还相差费用。" ),
        RecycledBuyStampContent = LSTR("由于原土地被系统自动撤除，以【个人】身份重新购买金币支付的土地时，将获得原土地价格%s水晶点的减免，该减免在中选土地后将自动使用生效(仅生效一次)。若新的土地价格低于减免的土地价格，不会返还相差费用。" )
    },

    HouseBuyCondSpecialID = 8,
    HouseBuyCondSpecialStr = "部队中已有玩家以部队身份参与[%s%s区%s号土地]的抽选，可参与该土地的抽选",
    EmptyLandList = "暂无土地",
    GroupAplNoPermission = "没有抽选部队土地权限",
    HouseHadDestroied = "房屋已被拆除",
    CantTransInPworld = "副本内不能传送",
    HasExitedArmyTips = "无法创建，你已被踢出部队",
}
return HouseLocalDef
