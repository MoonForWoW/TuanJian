local AddonName, ns = ...

local L = ns.L
local After = C_Timer.After
local pt = print
local player = UnitName("player")
local realmID = GetRealmID()

local GetAddOnMetadata = GetAddOnMetadata or C_AddOns.GetAddOnMetadata

if not GetItemInfo then
    GetItemInfo = C_Item.GetItemInfo
end
if not GetItemInfoInstant then
    GetItemInfoInstant = C_Item.GetItemInfoInstant
end
if not GetItemQualityColor then
    GetItemQualityColor = C_Item.GetItemQualityColor
end
if not GetItemCount then
    GetItemCount = C_Item.GetItemCount
end
if not GetItemSetInfo then
    GetItemSetInfo = C_Item.GetItemSetInfo
end

local LibBG = ns.Menu -- 调用库菜单UI
ns.LibBG = LibBG

C_ChatInfo.RegisterAddonMessagePrefix("TuanJian")

TuanJianTooltip = CreateFrame("GameTooltip", "TuanJianTooltip", UIParent, "GameTooltipTemplate") -- 用来获取鼠标提示文本
TuanJianTooltip:SetClampedToScreen(false)
TuanJianTooltip2 = CreateFrame("GameTooltip", "TuanJianTooltip2", UIParent, "GameTooltipTemplate")
TuanJianTooltip2:SetClampedToScreen(false)

-- 游戏按键设置
BINDING_HEADER_TUANJIAN = AddonName
BINDING_NAME_TUANJIAN = L["打开/关闭界面"]

TJ = {}

TJ.IsNewUI = true
local ver = select(4, GetBuildInfo())
do
    if ver < 20000 then
        TJ.IsVanilla = true
    end
    if ver < 40000 then
        TJ.verLess3 = true
    else
        TJ.verOver4 = true
    end

    if ver < 16000 then
        TJ.IsVanilla = true
        if (C_Engraving and C_Engraving.IsEngravingEnabled()) then
            TJ.IsVanilla_Sod = true
        else
            TJ.IsVanilla_60 = true
        end
    elseif ver < 20000 then
        TJ.IsForever = true
        TJ.IsNewUI = true -- 正式服/无限服UI
    end
    if ver >= 20000 and ver < 30000 then
        TJ.IsTBC = true
    end
    if ver >= 30000 and ver < 40000 then
        TJ.IsWLK = true
        if ver >= 38000 then
            TJ.IsTitan = true
        else
            TJ.IsWLK_80 = true
        end
    end
    if ver >= 40000 and ver < 50000 then
        TJ.IsCTM = true
    end
    if ver >= 50000 then
        TJ.IsMOP = true
    end
    if ver >= 110000 then
        TJ.IsRetail = true
        TJ.IsNewUI = true -- 正式服/无限服UI
    end
end

-- 全局变量
do
    TJ.options = {}
    TJ.iconTexCoord = { .07, .93, .07, .93 }
    TJ.borderAlpha = .5
    TJ.sendCD = .25
    TJ.sendCD2 = .3
    TJ.onEnterAlpha = 0.1
    TJ.scrollStep = 80
    TJ.FBtbl = {}
    TJ.FBinfo = {}
    TJ.tabFrame = {}
    TJ.frame = {}
    TJ.Load = {}
    TJ.healerClass = { "PALADIN", "SHAMAN", "DRUID", "PRIEST", "MONK" }
    TJ.tankClass = { "DEATHKNIGHT", "WARRIOR", "DRUID", "PALADIN", "MONK" }
    TJ.dps1Class = { "DEATHKNIGHT", "PALADIN", "WARRIOR", "SHAMAN", "DRUID", "ROGUE", "MONK" }
    TJ.dps2Class = { "HUNTER", "SHAMAN", "DRUID", "MAGE", "WARLOCK", "PRIEST" }
    TJ.TJClass = { "DEATHKNIGHT", "PALADIN", "WARRIOR", "SHAMAN", "MONK", "DRUID", "ROGUE", "PRIEST", }
    TJ.ver = "v" .. GetAddOnMetadata(AddonName, "Version")
    TJ.dispelInfo = {}
    TJ.dispelFB = {}
    TJ.teamList = {}
    TJ.DBMCallback = {}
    TJ.SSpowerSpell = TJ.IsTitan and 48090
    TJ.editTemplate = "TuanJian_InputBoxTemplate" or "InputBoxTemplate"
    TJ.scrollTemplate = "TuanJian_ModernScrollFrameTemplate" or "UIPanelScrollFrameTemplate"
    for i = 1, 8 do
        tinsert(TJ.teamList, i .. L["队"])
    end
    ns.BiaoGeName = 'BiaoGeX'
end

-- 事件
do
    function TJ.Init(func)
        local f = CreateFrame("Frame")
        f:RegisterEvent("PLAYER_LOGIN")
        f:SetScript("OnEvent", function(self, event)
            self:UnregisterEvent("PLAYER_LOGIN")
            securecall(func)
        end)
    end

    function TJ.Init2(func)
        local f = CreateFrame("Frame")
        f:RegisterEvent("PLAYER_ENTERING_WORLD")
        f:SetScript("OnEvent", function(self, event, isLogin, isReload)
            self:UnregisterEvent("PLAYER_ENTERING_WORLD")
            securecall(func)
        end)
    end

    local events = {}
    local f = CreateFrame("Frame")
    f:SetScript("OnEvent", function(_, event, ...)
        for _, func in ipairs(events[event]) do
            if event == "COMBAT_LOG_EVENT_UNFILTERED" then
                securecall(func, f, event, CombatLogGetCurrentEventInfo())
            else
                securecall(func, f, event, ...)
            end
        end
    end)
    function TJ.RegisterEvent(event, func)
        if not events[event] then
            events[event] = {}
            f:RegisterEvent(event)
        end
        tinsert(events[event], func)
    end
end

-- 名字
do
    function TJ.GN(unit)
        unit = unit or "player"
        if unit == "t" then
            unit = "target"
        end
        return GetUnitName(unit, true)
    end

    TJ.Init(function()
        TJ.myName = TJ.GN()
    end)
    TJ.realmName = GetRealmName()
    local realmName_chat = GetRealmName():gsub(" %- ", "")

    function TJ.GFN(name)
        if not name then return end
        local name, realm = strsplit("-", name)
        realm = realm or realmName_chat
        return name .. "-" .. realm
    end

    function TJ.GSN(name)
        if not name then return end
        local name, realm = strsplit("-", name)
        if not realm or realm == "" or realm == realmName_chat then
            return name
        else
            return name .. "-" .. realm
        end
    end

    function TJ.SPN(name)
        if not name then return end
        return strsplit("-", name)
    end
end

-- 初始化
TJ.Init(function()
    local spFB = {}

    do
        local function AddDB(FB, instanceID, phase, dispelPoint)
            local tbl = {
                FB = FB,
                ID = instanceID,
                localName = GetRealZoneText(instanceID),
                phase = phase,
            }
            tinsert(TJ.FBtbl, tbl)
            TJ.FBinfo[FB] = tbl
            if dispelPoint then
                TJ.dispelFB[FB] = dispelPoint
            end
        end
        if TJ.IsTBC then
            TJ.nowPhase = "P2"
            AddDB("SSCtitan", 548, "P2")
            AddDB("TKtitan", 550, "P2")
            spFB["SSCtitan"] = "SSC"
            spFB["TKtitan"] = "SSC"
        elseif TJ.IsWLK then
            if TJ.IsTitan then
                TJ.nowPhase = "P6"
                AddDB("ULDtitan", 603, "P6")

                AddDB("SWtitan", 580, "P5")
                AddDB("ZAMtitan", 568, "P5")
                spFB["ZAMtitan"] = "SWtitan"

                AddDB("TOC", 649, "P4")
                AddDB("ZUGtitan", 309, "P4", "LEFT")
                spFB["TOC"] = "TOCtitan"
                spFB["ZUGtitan"] = "TOCtitan"

                AddDB("NAXXtitan", 533, "P3", "LEFT")
                AddDB("OStitan", 615, "P3")
                AddDB("EOEtitan", 616, "P3")
                spFB["OStitan"] = "NAXXtitan"
                spFB["EOEtitan"] = "NAXXtitan"

                AddDB("SSCtitan", 548, "P2")
                AddDB("TKtitan", 550, "P2")
                spFB["TKtitan"] = "SSCtitan"

                AddDB("MCtitan", 409, "P1", "RIGHT")
            end
            -- AddDB("ICC", 631)
            -- AddDB("RS", 724)
            -- spFB["RS"] = "ICC"
        elseif TJ.IsCTM then
            AddDB("FL", 720)
            AddDB("DS", 967)
        elseif TJ.IsMOP then
            TJ.nowPhase = "P5"
            AddDB("SOO", 1136, "P5")
            AddDB("TOT", 1098, "P3")
            AddDB("TES", 996, "P1")
            AddDB("HOF", 1009, "P1")
            AddDB("MSV", 1008, "P1")
            spFB["HOF"] = "MSV"
            spFB["TES"] = "MSV"

            if BGDEBUG then
                AddDB("ULDtitan", 603, "P6")
            end
        end

        function TJ.GetFB(FB)
            FB = FB or TuanJian.FB
            return spFB[FB] or FB
        end
    end

    do
        local function AddDB(FB, encounterIDs, name, width, height, notFinish, hide)
            tinsert(TJ.FBinfo[FB], {
                FB = FB,
                encounterID = encounterIDs,
                name = name,
                width = width,
                height = height,
                notFinish = notFinish,
                hide = hide,
            })
        end
        local width = 560
        local height = 500
        if TJ.IsTBC then
            TJ.defaultFB = "SSCtitan"
            TJ.defaultBossIndex = 6
            -- P2
            do
                AddDB("SSCtitan", { 623, }, L["海度斯"], width, 550)
                AddDB("SSCtitan", { 624, }, L["鱼斯拉"], width, 550)
                AddDB("SSCtitan", { 625, }, L["盲眼者"], width, 550)
                AddDB("SSCtitan", { 626, }, L["深水领主"], width, 550)
                AddDB("SSCtitan", { 627, }, L["踏潮者"], width, 550)
                AddDB("SSCtitan", { 628, }, L["瓦丝琪"], width, 550)
                AddDB("TKtitan", { 730, }, L["奥"], width, height)
                AddDB("TKtitan", { 731, }, L["空灵机甲"], width, height)
                AddDB("TKtitan", { 732, }, L["大星术师"], width, height)
                AddDB("TKtitan", { 733, }, L["凯尔萨斯"], width, height)
            end
        elseif TJ.IsWLK then
            if TJ.IsTitan then
                TJ.defaultFB = "ULDtitan"
                TJ.defaultBossIndex = 13
                -- p1
                do
                    AddDB("MCtitan", { 663, }, L["鲁西弗隆"], width, 550)
                    AddDB("MCtitan", { 664, }, L["玛格曼达"], width, height)
                    AddDB("MCtitan", { 665, }, L["基赫纳斯"], width, height)
                    AddDB("MCtitan", { 666, }, L["加尔"], width, height)
                    AddDB("MCtitan", { 667, }, L["沙斯拉尔"], width, height)
                    AddDB("MCtitan", { 668, }, L["迦顿男爵"], width, height)
                    AddDB("MCtitan", { 669, }, L["萨弗隆先驱者"], width, height)
                    AddDB("MCtitan", { 670, }, L["古雷曼格"], width, height)
                    AddDB("MCtitan", { 671, }, L["埃克索图斯"], width, height)
                    AddDB("MCtitan", { 672, }, L["拉格纳罗斯"], width, height)
                end
                -- P2
                do
                    AddDB("SSCtitan", { 623, }, L["海度斯"], width, 550)
                    AddDB("SSCtitan", { 624, }, L["鱼斯拉"], width, 550)
                    AddDB("SSCtitan", { 625, }, L["盲眼者"], width, 550)
                    AddDB("SSCtitan", { 626, }, L["深水领主"], width, 550)
                    AddDB("SSCtitan", { 627, }, L["踏潮者"], width, 550)
                    AddDB("SSCtitan", { 628, }, L["瓦丝琪"], width, 550)
                    AddDB("TKtitan", { 730, }, L["奥"], width, height)
                    AddDB("TKtitan", { 731, }, L["空灵机甲"], width, height)
                    AddDB("TKtitan", { 732, }, L["大星术师"], width, height)
                    AddDB("TKtitan", { 733, }, L["凯尔萨斯"], width, height)
                end
                -- P3
                do
                    local naxxWidth = width
                    AddDB("NAXXtitan", { 1107, }, L["阿努布雷坎"], naxxWidth, height)
                    AddDB("NAXXtitan", { 1110, }, L["黑女巫法琳娜"], naxxWidth, height)
                    AddDB("NAXXtitan", { 1116, }, L["迈克斯纳"], naxxWidth, height)
                    AddDB("NAXXtitan", { 1118, }, L["帕奇维克"], naxxWidth, height)
                    AddDB("NAXXtitan", { 1111, }, L["格罗布鲁斯"], naxxWidth, height)
                    AddDB("NAXXtitan", { 1108, }, L["格拉斯"], naxxWidth, height)
                    AddDB("NAXXtitan", { 1120, }, L["塔迪乌斯"], naxxWidth, height)
                    AddDB("NAXXtitan", { 1113, }, L["教官"], naxxWidth, height)
                    AddDB("NAXXtitan", { 1109, }, L["收割者戈提克"], naxxWidth, height)
                    AddDB("NAXXtitan", { 1121, }, L["天启四骑士"], naxxWidth, height)
                    AddDB("NAXXtitan", { 1117, }, L["瘟疫使者诺斯"], naxxWidth, height)
                    AddDB("NAXXtitan", { 1112, }, L["肮脏的希尔盖"], naxxWidth, height)
                    AddDB("NAXXtitan", { 1115, }, L["洛欧塞布"], naxxWidth, height)
                    AddDB("NAXXtitan", { 1119, }, L["萨菲隆"], naxxWidth, height)
                    AddDB("NAXXtitan", { 1114, }, L["克尔苏加德"], naxxWidth, height)
                    AddDB("OStitan", { 742, 1090, }, L["萨塔里奥"], width, height)
                    AddDB("EOEtitan", { 734, 1094, }, L["玛里苟斯"], width, height)
                end
                -- P4
                do
                    AddDB("TOC", { 629, 1088, }, L["诺森德猛兽"], width, height)
                    AddDB("TOC", { 633, 1087, }, L["加拉克苏斯"], width, height)
                    AddDB("TOC", { 637, 1086, }, L["阵营冠军"], width, height)
                    AddDB("TOC", { 641, 1089, }, L["瓦格里双子"], width, height)
                    AddDB("TOC", { 645, 1085, }, L["阿努巴拉克"], width, TJ.IsTitan and height or 730)

                    AddDB("ZUGtitan", { 785, }, L["高阶祭司耶克里克"], width, height)
                    AddDB("ZUGtitan", { 784, }, L["高阶祭司温诺希斯"], width, height)
                    AddDB("ZUGtitan", { 786, }, L["高阶祭司玛尔里"], width, height)
                    AddDB("ZUGtitan", { 787, }, L["血领主"], width, height)
                    AddDB("ZUGtitan", { 788, }, L["疯狂之缘"], width, height)
                    AddDB("ZUGtitan", { 790, }, L["加兹兰卡"], width, height)
                    AddDB("ZUGtitan", { 789, }, L["高阶祭司塞卡尔"], width, height)
                    AddDB("ZUGtitan", { 791, }, L["高阶祭司娅尔罗"], width, height)
                    AddDB("ZUGtitan", { 792, }, L["妖术师金度"], width, height)
                    AddDB("ZUGtitan", { 793, }, L["哈卡"], width, height)
                end
                -- P5
                do
                    AddDB("SWtitan", { 724, }, L["卡雷苟斯"], width, height)
                    AddDB("SWtitan", { 725, }, L["布鲁塔卢斯"], width, height)
                    AddDB("SWtitan", { 726, }, L["菲米丝"], width, height)
                    AddDB("SWtitan", { 727, }, L["艾瑞达双子"], width, height)
                    AddDB("SWtitan", { 728, }, L["穆鲁"], width, height)
                    AddDB("SWtitan", { 729, }, L["基尔加丹"], width, height)

                    AddDB("ZAMtitan", { 1189, }, L["埃基尔松"], width, height, true)
                    AddDB("ZAMtitan", { 1190, }, L["纳洛拉克"], width, height, true)
                    AddDB("ZAMtitan", { 1191, }, L["加亚莱"], width, height, true)
                    AddDB("ZAMtitan", { 1192, }, L["哈尔拉兹"], width, height, true)
                    AddDB("ZAMtitan", { 1193, }, L["妖术领主玛拉卡斯"], width, height)
                    AddDB("ZAMtitan", { 1194, }, L["祖尔金"], width, height, true)
                end
                -- P6
                do
                    AddDB("ULDtitan", { 744, 1132, }, L["烈焰巨兽"], width, height, true)
                    AddDB("ULDtitan", { 746, 1139, }, L["锋鳞"], width, height, true)
                    AddDB("ULDtitan", { 745, 1136, }, L["掌炉者"], width, height, true)
                    AddDB("ULDtitan", { 747, 1142, }, L["拆解者"], width, height, true)
                    AddDB("ULDtitan", { 748, 1140, }, L["钢铁议会"], width, height, true)
                    AddDB("ULDtitan", { 749, 1137, }, L["科隆加恩"], width, height, true)
                    AddDB("ULDtitan", { 750, 1131, }, L["欧尔利亚"], width, height, true)
                    AddDB("ULDtitan", { 751, 1135, }, L["霍迪尔"], width, height, true)
                    AddDB("ULDtitan", { 752, 1141, }, L["托里姆"], width, height)
                    AddDB("ULDtitan", { 753, 1133, }, L["弗蕾亚"], width, height, true)
                    AddDB("ULDtitan", { 754, 1138, }, L["米米尔隆"], width, height, true)
                    AddDB("ULDtitan", { 755, 1134, }, L["维扎克斯将军"], width, height, true)
                    AddDB("ULDtitan", { 756, 1143, }, L["尤格萨隆"], width, height)
                    AddDB("ULDtitan", { 757, 1130, }, L["奥尔加隆"], width, height)
                end
            else
                TJ.defaultFB = "ICC"
                TJ.defaultBossIndex = 12
            end

            do
                -- AddDB("ICC", { 845, 1101, }, L["玛洛加尔"], width, 560)
                -- AddDB("ICC", { 846, 1100, }, L["亡语者女士"], width, 560)
                -- AddDB("ICC", { nil, }, L["炮舰战"], width, height, nil, true)
                -- AddDB("ICC", { 848, 1096, }, L["萨鲁法尔"], width, 560)
                -- AddDB("ICC", { 849, 1097, }, L["烂肠"], width, height)
                -- AddDB("ICC", { 850, 1104, }, L["腐面"], width, height)
                -- AddDB("ICC", { 851, 1102, }, L["普崔塞德教授"], width, height)
                -- AddDB("ICC", { 852, 1095, }, L["鲜血议会"], width, height)
                -- AddDB("ICC", { 853, 1103, }, L["鲜血女王"], width, height)
                -- AddDB("ICC", { 854, 1098, }, L["踏梦者"], width, height)
                -- AddDB("ICC", { 855, 1105, }, L["辛达苟萨"], width, height)
                -- AddDB("ICC", { 856, 1106, }, L["巫妖王"], width, 700)
                -- AddDB("RS", { 887, 1150, }, L["海里昂"], width, height)
            end
        elseif TJ.IsCTM then
            TJ.defaultFB = "DS"
            TJ.defaultBossIndex = 1
            AddDB("FL", { 1197, }, L["贝丝缇拉克"], width, height)
            AddDB("FL", { 1204, }, L["雷奥利斯领主"], width, height)
            AddDB("FL", { 1206, }, L["奥利瑟拉佐尔"], width, height)
            AddDB("FL", { 1205, }, L["沙恩诺克斯"], width, height)
            AddDB("FL", { 1200, }, L["贝尔洛克"], width, height)
            AddDB("FL", { 1185, }, L["管理者鹿盔"], width, height)
            AddDB("FL", { 1203, }, L["拉格纳罗斯"], width, height)
            AddDB("DS", { 1292, }, L["莫卓克"], width, height)
            AddDB("DS", { 1294, }, L["督军佐诺兹"], width, height)
            AddDB("DS", { 1295, }, L["不眠的约萨希"], width, height)
            AddDB("DS", { 1296, }, L["缚风者哈格拉"], width, height)
            AddDB("DS", { 1297, }, L["奥卓克希昂"], width, height)
            AddDB("DS", { 1298, }, L["战争大师黑角"], width, height)
            AddDB("DS", { 1291, }, L["死亡之翼的背脊"], width, height)
            AddDB("DS", { 1299, }, L["疯狂的死亡之翼"], width, height)
        elseif TJ.IsMOP then
            TJ.defaultFB = "SOO"
            TJ.defaultBossIndex = 1
            -- P1
            do
                AddDB("MSV", { 1395, }, L["石头守卫"], width, height)
                AddDB("MSV", { 1390, }, L["受诅者魔封"], width, height)
                AddDB("MSV", { 1434, }, L["缚灵者戈拉亚"], width, height)
                AddDB("MSV", { 1436, }, L["先王之魂"], width, height)
                AddDB("MSV", { 1500, }, L["伊拉贡"], width, height)
                AddDB("MSV", { 1407, }, L["皇帝的意志"], width, height)
                AddDB("HOF", { 1507, }, L["皇家宰相"], width, 550)
                AddDB("HOF", { 1504, }, L["刀锋领主"], width, 550)
                AddDB("HOF", { 1463, }, L["加拉隆"], width, 550)
                AddDB("HOF", { 1498, }, L["风领主"], width, 550)
                AddDB("HOF", { 1499, }, L["琥珀塑形者"], width, 550)
                AddDB("HOF", { 1501, }, L["大女皇夏柯希尔"], width, 550)
                AddDB("TES", { 1409, }, L["无尽守护者"], width, height)
                AddDB("TES", { 1505, }, L["烛龙"], width, height)
                AddDB("TES", { 1506, }, L["雷施"], width, height)
                AddDB("TES", { 1431, }, L["惧之煞"], width, height)
            end
            -- 雷电
            do
                AddDB("TOT", { 1577 }, L["击碎者金罗克"], width, 550)
                AddDB("TOT", { 1575 }, L["赫利东"], width, 550)
                AddDB("TOT", { 1570 }, L["长者议会"], width, 550)
                AddDB("TOT", { 1565 }, L["托多斯"], width, 550)
                AddDB("TOT", { 1578 }, L["墨格瑞拉"], width, 550)
                AddDB("TOT", { 1573 }, L["季鹍"], width, 550)
                AddDB("TOT", { 1572 }, L["遗忘者杜鲁姆"], width, 550)
                AddDB("TOT", { 1574 }, L["普利莫修斯"], width, 550)
                AddDB("TOT", { 1576 }, L["黑暗意志"], width, 550)
                AddDB("TOT", { 1559 }, L["铁穹"], width, 550)
                AddDB("TOT", { 1560 }, L["神女双天"], width, 550)
                AddDB("TOT", { 1579 }, L["雷神"], width, 550)
                AddDB("TOT", { 1580, 1581 }, L["莱登"], width, 550)
            end
            -- 奥格
            do
                -- local height = 550
                AddDB("SOO", { 1602, }, L["伊墨苏斯"], width, height)
                AddDB("SOO", { 1598, }, L["堕落的守护者"], width, height)
                AddDB("SOO", { 1624, }, L["诺鲁什"], width, height)
                AddDB("SOO", { 1604, }, L["傲之煞"], width, height)
                AddDB("SOO", { 1622, }, L["迦拉卡斯"], width, height)
                AddDB("SOO", { 1600, }, L["钢铁战蝎"], width, height)
                AddDB("SOO", { 1606, }, L["库卡隆黑暗萨满"], width, height)
                AddDB("SOO", { 1603, }, L["纳兹戈林将军"], width, height)
                AddDB("SOO", { 1595, }, L["马尔考罗克"], width, height)
                AddDB("SOO", { 1594, }, L["潘达利亚战利品"], width, height)
                AddDB("SOO", { 1599, }, L["嗜血的索克"], width, height)
                AddDB("SOO", { 1601, }, L["攻城匠师黑索"], width, height)
                AddDB("SOO", { 1593, }, L["卡拉克西英杰"], width, height)
                AddDB("SOO", { 1623, }, L["地狱咆哮"], width, height)
            end

            if BGDEBUG then
                AddDB("ULDtitan", { 744, 1132, }, L["烈焰巨兽"], width, height, true)
                AddDB("ULDtitan", { 746, 1139, }, L["锋鳞"], width, height, true)
                AddDB("ULDtitan", { 745, 1136, }, L["掌炉者"], width, height, true)
                AddDB("ULDtitan", { 747, 1142, }, L["拆解者"], width, height, true)
                AddDB("ULDtitan", { 748, 1140, }, L["钢铁议会"], width, height, true)
                AddDB("ULDtitan", { 749, 1137, }, L["科隆加恩"], width, height, true)
                AddDB("ULDtitan", { 750, 1131, }, L["欧尔利亚"], width, height, true)
                AddDB("ULDtitan", { 751, 1135, }, L["霍迪尔"], width, height, true)
                AddDB("ULDtitan", { 752, 1141, }, L["托里姆"], width, height)
                AddDB("ULDtitan", { 753, 1133, }, L["弗蕾亚"], width, height, true)
                AddDB("ULDtitan", { 754, 1138, }, L["米米尔隆"], width, height, true)
                AddDB("ULDtitan", { 755, 1134, }, L["维扎克斯将军"], width, height, true)
                AddDB("ULDtitan", { 756, 1143, }, L["尤格萨隆"], width, height)
                AddDB("ULDtitan", { 757, 1130, }, L["奥尔加隆"], width, height)
            end
        end
    end

    -- 职业天赋图标
    TJ.talentIcon = {
        PALADIN = {
            "Interface\\Icons\\Spell_Holy_HolyBolt",     -- N
            "Interface\\Icons\\Spell_Holy_DevotionAura", -- T
            "Interface\\Icons\\Spell_Holy_AuraOfLight",  -- 光掌惩戒骑
            "Interface\\Icons\\Spell_Holy_AuraOfLight",  -- 大牺牲惩戒骑
        },
        WARRIOR = {
            "Interface\\Icons\\ability_warrior_savageblow",
            "Interface\\Icons\\ability_warrior_innerrage",
            "Interface\\Icons\\ability_warrior_defensivestance", -- T
        },
        SHAMAN = {
            "Interface\\Icons\\spell_nature_lightning",          -- 元素
            "Interface\\Icons\\spell_nature_lightningshield",    -- 增强
            "Interface\\Icons\\Spell_Nature_HealingWaveGreater", -- N
        },
        HUNTER = {
            "Interface\\Icons\\Ability_Hunter_BeastTaming",
            "Interface\\Icons\\Ability_Marksmanship",
            "Interface\\Icons\\Ability_Hunter_SwiftStrike",
        },
        ROGUE = {
            "Interface\\Icons\\ability_rogue_eviscerate",
            "Interface\\Icons\\ability_backstab",
            "Interface\\Icons\\ability_stealth",
        },
        MAGE = {
            "Interface\\Icons\\inv_misc_rune_03",
            "Interface\\Icons\\spell_fire_firebolt02",
            "Interface\\Icons\\spell_frost_frostbolt02",
        },
        WARLOCK = {
            "Interface\\Icons\\spell_shadow_deathcoil",
            "Interface\\Icons\\spell_shadow_metamorphosis",
            "Interface\\Icons\\spell_shadow_rainoffire",
        },
        PRIEST = {
            "Interface\\Icons\\spell_holy_wordfortitude",    -- N
            "Interface\\Icons\\spell_holy_guardianspirit",   -- N
            "Interface\\Icons\\spell_shadow_shadowwordpain", -- 暗牧
        },
    }
    if TJ.IsTBC or TJ.IsWLK then
        TJ.talentIcon.DEATHKNIGHT = {
            "Interface\\Icons\\Spell_Deathknight_BloodPresence", -- T
            "Interface\\Icons\\Spell_Deathknight_FrostPresence",
            "Interface\\Icons\\Spell_Deathknight_UnholyPresence",
            "Interface\\Icons\\inv_sword_07", -- DPS血DK
        }
        TJ.talentIcon.DRUID = {
            "Interface\\Icons\\spell_nature_starfall",
            "Interface\\Icons\\ability_racial_bearform",
            "Interface\\Icons\\Spell_Nature_HealingTouch", -- N
        }
    elseif TJ.IsMOP then
        TJ.talentIcon.DEATHKNIGHT = {
            "Interface\\Icons\\Spell_Deathknight_BloodPresence", -- T
            "Interface\\Icons\\Spell_Deathknight_FrostPresence",
            "Interface\\Icons\\Spell_Deathknight_UnholyPresence",
        }
        TJ.talentIcon.DRUID = {
            "Interface\\Icons\\spell_nature_starfall",     -- 鸟
            "Interface\\Icons\\ability_druid_catform",     -- 猫
            "Interface\\Icons\\ability_racial_bearform",   -- 熊
            "Interface\\Icons\\Spell_Nature_HealingTouch", -- 奶
        }
        TJ.talentIcon.MONK = {
            "Interface/Icons/spell_monk_brewmaster_spec", -- 酒仙
            "Interface/Icons/spell_monk_mistweaver_spec", -- 织雾
            "Interface/Icons/spell_monk_windwalker_spec", -- 踏风
        }
    end

    -- 天赋对应的职责
    TJ.talentToCombatRole = {
        WARRIOR = {
            { role = "DAMAGER", dps = 1, },
            { role = "DAMAGER", dps = 1, },
            { role = "TANK", dps = 0, },
        },
        SHAMAN = {
            { role = "DAMAGER", dps = 2, },
            { role = "DAMAGER", dps = 1, },
            { role = "HEALER", dps = 0, },
        },
        HUNTER = {
            { role = "DAMAGER", dps = 2, },
            { role = "DAMAGER", dps = 2, },
            { role = "DAMAGER", dps = 2, },
        },
        ROGUE = {
            { role = "DAMAGER", dps = 1, },
            { role = "DAMAGER", dps = 1, },
            { role = "DAMAGER", dps = 1, },
        },
        MAGE = {
            { role = "DAMAGER", dps = 2, },
            { role = "DAMAGER", dps = 2, },
            { role = "DAMAGER", dps = 2, },
        },
        WARLOCK = {
            { role = "DAMAGER", dps = 2, },
            { role = "DAMAGER", dps = 2, },
            { role = "DAMAGER", dps = 2, },
        },
        PRIEST = {
            { role = "HEALER", dps = 0, },
            { role = "HEALER", dps = 0, },
            { role = "DAMAGER", dps = 2, },
        },
    }
    if TJ.IsTBC or TJ.IsWLK then
        TJ.talentToCombatRole.DEATHKNIGHT = {
            { role = "TANK", dps = 0, },
            { role = "DAMAGER", dps = 1, },
            { role = "DAMAGER", dps = 1, },
            { role = "DAMAGER", dps = 1, }, -- 输出血DK
        }
        TJ.talentToCombatRole.PALADIN = {
            { role = "HEALER", dps = 0, },
            { role = "TANK", dps = 0, },
            { role = "DAMAGER", dps = 1, },
            { role = "DAMAGER", dps = 1, }, -- 有大牺牲的惩戒骑
        }
        TJ.talentToCombatRole.DRUID = {
            { role = "DAMAGER", dps = 2, },
            { role = nil, dps = 0, },
            { role = "HEALER", dps = 0, },
        }
    elseif TJ.IsMOP then
        TJ.talentToCombatRole.DEATHKNIGHT = {
            { role = "TANK", dps = 0, },
            { role = "DAMAGER", dps = 1, },
            { role = "DAMAGER", dps = 1, },
        }
        TJ.talentToCombatRole.PALADIN = {
            { role = "HEALER", dps = 0, },
            { role = "TANK", dps = 0, },
            { role = "DAMAGER", dps = 1, },
        }
        TJ.talentToCombatRole.DRUID = {
            { role = "DAMAGER", dps = 2, },
            { role = "DAMAGER", dps = 1, },
            { role = "TANK", dps = 0, },
            { role = "HEALER", dps = 0, },
        }
        TJ.talentToCombatRole.MONK = {
            { role = "TANK", dps = 0, },
            { role = "HEALER", dps = 0, },
            { role = "DAMAGER", dps = 1, },
        }
    end

    -- 声音
    do
        TJ.sound1 = SOUNDKIT.GS_TITLE_OPTION_OK -- 按键音效
        TJ.sound2 = 569593                      -- 升级音效
        TJ.sound3 = SOUNDKIT.IG_MAINMENU_CLOSE  -- 菜单打开音效

        local Interface = ns.Interface .. "Media\\sound\\AI\\"
        TJ.voice = {}
        -- TJ.voice["即将连线"] = Interface .. "即将连线.mp3"
        -- TJ.voice["即将寄生"] = Interface .. "即将寄生.mp3"
        -- TJ.voice["即将收割"] = Interface .. "即将收割.mp3"
        -- TJ.voice["即将群体寒冰箭"] = Interface .. "即将群体寒冰箭.mp3"
        -- TJ.voice["准备孢子减伤"] = Interface .. "准备孢子减伤.mp3"
        -- TJ.voice["即将刺鼻毒气"] = Interface .. "即将刺鼻毒气.mp3"
    end

    -- 给文本上颜色
    do
        TJ.b1 = "00BFFF"
        function TJ.STC_b1(text)
            if text then
                local t
                t = "|cff" .. "00BFFF" .. text .. "|r"
                return t
            end
        end

        TJ.r1 = "FF0000"
        function TJ.STC_r1(text)
            if text then
                local t
                t = "|cff" .. "FF0000" .. text .. "|r"
                return t
            end
        end

        TJ.r2 = "FF1493"
        function TJ.STC_r2(text)
            if text then
                local t
                t = "|cff" .. "FF1493" .. text .. "|r"
                return t
            end
        end

        TJ.r3 = "FF69B4"
        function TJ.STC_r3(text)
            if text then
                local t
                t = "|cff" .. "FF69B4" .. text .. "|r"
                return t
            end
        end

        TJ.g1 = "00FF00"
        function TJ.STC_g1(text)
            if text then
                local t
                t = "|cff" .. "00FF00" .. text .. "|r"
                return t
            end
        end

        TJ.g2 = "40c040"
        function TJ.STC_g2(text)
            if text then
                local t
                t = "|cff" .. "40c040" .. text .. "|r"
                return t
            end
        end

        TJ.y1 = "FFFF00"
        function TJ.STC_y1(text) -- yellow
            if text then
                local t
                t = "|cff" .. "FFFF00" .. text .. "|r"
                return t
            end
        end

        TJ.y2 = "FFD100"
        function TJ.STC_y2(text) -- gold
            if text then
                local t
                t = "|cff" .. "FFD100" .. text .. "|r"
                return t
            end
        end

        TJ.w1 = "FFFFFF"
        function TJ.STC_w1(text) -- 白色
            if text then
                local t
                t = "|cff" .. "FFFFFF" .. text .. "|r"
                return t
            end
        end

        TJ.dis = "808080"
        function TJ.STC_dis(text) -- 灰色
            if text then
                local t
                t = "|cff" .. "808080" .. text .. "|r"
                return t
            end
        end
    end

    -- 字体
    do
        if not BIAOGE_TEXT_FONT then
            local l = GetLocale()
            if (l == "koKR") then
                BIAOGE_TEXT_FONT = "Fonts\\2002.TTF"
            elseif (l == "zhCN") then
                BIAOGE_TEXT_FONT = "Fonts\\ARKai_T.ttf"
            elseif (l == "zhTW") then
                BIAOGE_TEXT_FONT = "Fonts\\blei00d.TTF"
            elseif (l == "ruRU") then
                BIAOGE_TEXT_FONT = "Fonts\\FRIZQT___CYR.TTF"
            else
                BIAOGE_TEXT_FONT = "Fonts\\FRIZQT__.TTF"
            end
        end
        local fontSize = 14
        if BiaoGe and BiaoGe.options and BiaoGe.options.editFontSize then
            fontSize = BiaoGe.options.editFontSize
        end
        function TuanJian_InputBoxTemplate_OnLoad(self)
            self:SetFont(BIAOGE_TEXT_FONT, fontSize, "OUTLINE")
        end

        local function CreateMyFont(color, size, H)
            local cff
            if color == "Blue" then
                cff = "00BFFF"
            elseif color == "Green" then
                cff = "00FF00"
            elseif color == "Green2" then
                cff = "40c040"
            elseif color == "Red" then
                cff = "FF0000"
            elseif color == "Fen" then
                cff = "FF69B4"
            elseif color == "Gold" then
                cff = "FFD100"
            elseif color == "Yellow" then
                cff = "FFFF00"
            elseif color == "White" then
                cff = "FFFFFF"
            elseif color == "Dis" then
                cff = "808080"
            end
            TJ["Font" .. color .. size] = CreateFont("TJ.Font" .. color .. size)
            TJ["Font" .. color .. size]:SetTextColor(ns.RGB(cff))
            TJ["Font" .. color .. size]:SetFont(BIAOGE_TEXT_FONT, size, "OUTLINE")
        end

        CreateMyFont("Blue", 13)
        CreateMyFont("Blue", 15)
        CreateMyFont("Blue", 16)
        CreateMyFont("Blue", 18)
        CreateMyFont("Blue", 20)
        CreateMyFont("Blue", 25)

        CreateMyFont("Green", 13)
        CreateMyFont("Green", 15)
        CreateMyFont("Green", 25)

        CreateMyFont("Green2", 15)

        CreateMyFont("Gold", 13)
        CreateMyFont("Gold", 15)

        CreateMyFont("Yellow", 13)
        CreateMyFont("Yellow", 15)

        CreateMyFont("Red", 13)
        CreateMyFont("Red", 15)

        CreateMyFont("Fen", 15)

        CreateMyFont("White", 13)
        CreateMyFont("White", 14)
        CreateMyFont("White", 15)
        CreateMyFont("White", 16)
        CreateMyFont("White", 18)
        CreateMyFont("White", 20)
        CreateMyFont("White", 25)
        CreateMyFont("White", 28)
        CreateMyFont("White", 30)

        CreateMyFont("Dis", 13)
        CreateMyFont("Dis", 15)
        CreateMyFont("Dis", 16)
        CreateMyFont("Dis", 18)
        CreateMyFont("Dis", 20)
        CreateMyFont("Dis", 25)
    end
end)

-- 配置
TJ.Init(function()
    TuanJian = TuanJian or {}
    TuanJian.options = TuanJian.options or {}
    TuanJian.options.SearchHistory = TuanJian.options.SearchHistory or {}
    TuanJian.FB = TuanJian.FB or TJ.defaultFB
    TuanJian.bossIndex = TuanJian.bossIndex or TJ.defaultBossIndex
    TuanJian.combatLog = TuanJian.combatLog or {}
    TuanJian.lastCombatLog = TuanJian.lastCombatLog or {}
    TuanJian.lastCombatLog.lastBossID = 0

    if not TJ.FBinfo[TuanJian.FB] then
        TuanJian.FB = TJ.defaultFB
        TuanJian.bossIndex = TJ.defaultBossIndex
    end
    if not TJ.FBinfo[TuanJian.FB][TuanJian.bossIndex] then
        TuanJian.bossIndex = 1
    end
    TuanJian.FKmoney = TuanJian.FKmoney or 500
    TuanJian.raidTarget = TuanJian.raidTarget or {}
    TuanJian.talentInfo = TuanJian.talentInfo or {}
    if TJ.IsWLK then
        TuanJian.talentTreeInfo = TuanJian.talentTreeInfo or {}
    end
    TuanJian.itemInfo = TuanJian.itemInfo or {}
    TuanJian.point = TuanJian.point or {}
    TuanJian.dispel = TuanJian.dispel or {}
    TuanJian.dispel.show = TuanJian.dispel.show or 0
    TuanJian.dispel.detached = TuanJian.dispel.detached or 0
    TuanJian.MOPdpstips = TuanJian.MOPdpstips or 1
    TuanJian.MOPTJ = TuanJian.MOPTJ or {}
    TuanJian.MOPTJ.type = TuanJian.MOPTJ.type or "physics"
    TuanJian.MOPTJ.num = TuanJian.MOPTJ.num or 3
    TuanJian.MOPTJ.history = TuanJian.MOPTJ.history or {}
    TuanJian.MOPTJ.showMRT = TuanJian.MOPTJ.showMRT or 1
    TuanJian.MOPTJ.showBoardMRT = TuanJian.MOPTJ.showBoardMRT or 0

    for i, v in ipairs(TJ.FBtbl) do
        local FB = v.FB
        TuanJian[FB] = TuanJian[FB] or {}
        TuanJian.dispel[FB] = TuanJian.dispel[FB] or {}
        TuanJian[FB].dispel = nil
        for bossIndex in ipairs(TJ.FBinfo[FB]) do
            TuanJian[FB][bossIndex] = TuanJian[FB][bossIndex] or {}
            if not TuanJian.options.SearchHistory["map20510"] then
                TuanJian[FB][bossIndex].map = nil
            end
            if not TuanJian.options.SearchHistory["board250907"] then
                TuanJian[FB][bossIndex].board = nil
            end
            TuanJian[FB][bossIndex].map = TuanJian[FB][bossIndex].map or {}
            TuanJian[FB][bossIndex].map2 = TuanJian[FB][bossIndex].map2 or {}
            TuanJian[FB][bossIndex].board = TuanJian[FB][bossIndex].board or {}
        end
    end
    TuanJian.options.SearchHistory["map20510"] = true    -- 重置map数据
    TuanJian.options.SearchHistory["board250907"] = true -- 重置战术板数据

    TuanJian.options.showMap = TuanJian.options.showMap or 1
    TuanJian.options.showRaidMemberFrame = TuanJian.options.showRaidMemberFrame or 0
    TuanJian.options.mapScale = TuanJian.options.mapScale or .75
    TuanJian.options.mapIconScale = TuanJian.options.mapIconScale or 1
    if type(TuanJian.options.mapScale) ~= "number" then
        TuanJian.options.mapScale = .75
    end
    if TuanJian.options.mapScale <= 0 then
        TuanJian.options.mapScale = .75
    end
    if type(TuanJian.options.mapIconScale) ~= "number" then
        TuanJian.options.mapIconScale = 1
    end
    if TuanJian.options.mapIconScale <= 0 then
        TuanJian.options.mapIconScale = 1
    end

    TuanJian.options.boardSound = TuanJian.options.boardSound or 1
    TuanJian.options.boardSendMsg = TuanJian.options.boardSendMsg or 1
    TuanJian.options.boardScale = TuanJian.options.boardScale or 1
    TuanJian.options.boardWidth = TuanJian.options.boardWidth or 250
    TuanJian.point.board = TuanJian.point.board or { "TOP", nil, "TOP", 0, -250 }
    TuanJian.options.boardTipsTime = TJ.IsTitan and 15 or 25
    TuanJian.options.onEnterShowEquip = TuanJian.options.onEnterShowEquip or 1

    -- 清空旧数据
    for _, FB in pairs({ "FL", "DS", "ICC", "RS" }) do
        TuanJian[FB] = nil
    end
end)
