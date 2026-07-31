local AddonName, ns = ...

local LibBG = ns.LibBG
local L = ns.L

local AddTexture = ns.AddTexture

local pt = print
local After = C_Timer.After
local BG = TJ

local realmID = GetRealmID()
local player = UnitName("player")


local T = {}
local FB = "TOT"
local bossIndex = 6
--[[
"DEATHKNIGHT"
"PALADIN"
"WARRIOR"
"SHAMAN"
"HUNTER"
"DRUID"
"ROGUE"
"MAGE"
"WARLOCK"
"PRIEST"
 ]]

TJ.Load[FB .. bossIndex] = function()
    local mainFrame = TJ.frame[FB][bossIndex]

    -- 技能提醒
    local tipsFrame = CreateFrame("Frame")
    if TJ.canUseTips then
        local name = "tips1" .. FB .. bossIndex

        local msgs = {}
        local _msgs = {
            L["1队下"],
            L["2队下(有守卫)，有飞羽满天"],
            L["3队下"],
            L["4队下，1队上"],
            L["5队下，2队上(有守卫)，有飞羽满天"], -- 5

            L["4队上"],
            L["1队下，3队上，有飞羽满天"],
            L["2队下，5队上(有守卫)"],
            L["3队下，有飞羽满天"],
            L["4队下，1队上"], -- 10

            L["5队下，2队上(有守卫)，有飞羽满天"],
            L["1队下，4队上"],
            L["2队下，3队上，有飞羽满天"],
            L["3队下，5队上(有守卫)，1队上"],
            L["4队下，2队上，有飞羽满天"], -- 15
        }
        for i, text in ipairs(_msgs) do
            tinsert(msgs, L["第%s轮："]:format(i) .. text)
        end

        local function SendMsg()
            local msg = msgs[tipsFrame.index]
            SendChatMessage(L[">15秒后< "] .. msg, "RAID_WARNING")
            TJ.AddTimer(5, function()
                SendChatMessage(L[">10秒后< "] .. msg, "RAID_WARNING")
            end)
            TJ.AddTimer(10, function()
                SendChatMessage(L[">5秒后< "] .. msg, "RAID_WARNING")
            end)
            TJ.AddTimer(15, function()
                SendChatMessage(L[">现在< "] .. msg, "RAID_WARNING")
            end)
        end

        local oneTime = 30
        function tipsFrame:Start()
            if TuanJian.options[name] == 1 and TJ.Is25H() and TJ.IsLeader() then
                SendChatMessage(L[">现在< "] .. msgs[1], "RAID_WARNING")
                tipsFrame.index = 2
                tipsFrame.t = oneTime
                tipsFrame.canUpdate = true
                tipsFrame:SetScript("OnUpdate", function(self, t)
                    tipsFrame.t = tipsFrame.t - t
                    if tipsFrame.canUpdate and tipsFrame.t <= 15 then
                        SendMsg()
                        tipsFrame.index = tipsFrame.index + 1
                        tipsFrame.canUpdate = nil
                    end
                end)
            end
        end

        function tipsFrame:End()
            tipsFrame:SetScript("OnUpdate", nil)
        end

        TJ.options[name .. "reset"] = 0
        TuanJian.options[name] = TuanJian.options[name] or TJ.options[name .. "reset"]
        local ontext = {
            L["鸟巢时间轴团队提醒"],
            L["在团队通知频道自动发送25人模式鸟巢时间轴，该功能仅在25人H模式生效。"],
            " ",
            L["需要你是团长或助理，该功能才生效。"],
            " ",
            L["通报内容如下："],
        }
        for i, text in ipairs(msgs) do
            tinsert(ontext, text)
        end

        local f = ns.O.CreateCheckButton(name, AddTexture(648726) .. L["鸟巢时间轴团队提醒（需要团长/助理）"],
            TJ.frame[FB][bossIndex], 40, -150, ontext)
        f:ClearAllPoints()
        f:SetPoint("BOTTOMLEFT", TJ.spChild.title, "TOPRIGHT", 0, 15)
        f:SetHitRectInsets(0, 0, 0, 0)

        --[[
/run TJ.frame["TOT"][6].ENCOUNTER_START()
/run TJ.frame["TOT"][6].BOSS_SAY("某个鸟巢中的蛋开始孵化了")
]]

        local count = 0
        mainFrame.ENCOUNTER_START = function(...)
            count = 0
            tipsFrame:Start()
        end
        mainFrame.ENCOUNTER_END = function(...)
            tipsFrame:End()
        end
        mainFrame.BOSS_SAY = function(msg)
            if msg:match(L["某个鸟巢中的蛋开始孵化了"]) and not TJ.SetCD(mainFrame, 2, "say") then
                tipsFrame.canUpdate = true
                tipsFrame.t = oneTime

                local start = TJ.GetDurTime()
                count = count + 1
                tinsert(TJ.GetNewCombatLog().otherTime, {
                    startTime = start,
                    endTime = start + (TJ.Is10Man() and 39 or 29),
                    name = "nc" .. count,
                })
                return
            end
        end
    end

    -- 战术板
    local bossSpellID = 134380
    do
        local isload
        local init = function()
            isload = true
            local s1, s2, s3, s4, s5, s6, s7 = ns.s1, ns.s2, ns.s3, ns.s4, ns.s5, ns.s6, ns.s7
            local spellTbl = {
                {
                    title = L["1/4"],
                    class = nil,
                    spell = TJ.Board_TJ1
                },
                {
                    title = L["2/5"],
                    class = nil,
                    spell = TJ.Board_TJ1
                },
                {
                    title = L["3/6"],
                    class = nil,
                    spell = TJ.Board_TJ1
                },
            }
            local function AutoFuc()
                local maxIndex = #spellTbl
                local tbl = TJ.SortRaidRosterInfo({ "WARRIOR" }, nil, true)
                for i, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, s2)
                    TJ.SetBoardEditFormNum(v, i, nil, s3)
                end
                local tbl = TJ.SortRaidRosterInfo({ "SHAMAN" }, "healer", true)
                for i, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, ns.s9)
                    TJ.SetBoardEditFormNum(v, i, nil, ns.s8)
                end
                local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, "healer", true)
                for i, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, TuanJian.talentInfo[v.name] == 1 and s5 or ns.s13)
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "SHAMAN" }, "dps", true)
                for i, v in ipairs(tbl) do
                    for i = maxIndex, 1, -1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, ns.s9)
                            TJ.SetBoardEditFormNum(v, i, nil, ns.s10)
                            done[i] = true
                            break
                        end
                    end
                end
                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "healer", true)
                for i, v in ipairs(tbl) do
                    for i = maxIndex, 1, -1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, s1)
                            done[i] = true
                            break
                        end
                    end
                end
                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "DRUID" }, "healer", true)
                for i, v in ipairs(tbl) do
                    for i = maxIndex, 1, -1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, ns.s12)
                            done[i] = true
                            break
                        end
                    end
                end
                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "MONK" }, "healer", true)
                for i, v in ipairs(tbl) do
                    for i = maxIndex, 1, -1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, ns.s11)
                            done[i] = true
                            break
                        end
                    end
                end
                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, "dps", true)
                for i, v in ipairs(tbl) do
                    for i = maxIndex, 1, -1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, ns.s14)
                            done[i] = true
                            break
                        end
                    end
                end
            end

            local tbl = {
                {
                    name = L["飞羽满天减伤链"],
                    bossSpellID = bossSpellID,
                    arrange = 6,
                    icon = "ability_hunter_pet_dragonhawk",
                    id = 1,
                    spell = spellTbl,
                    event = "SPELL_CAST_SUCCESS",
                    canUpdate = true,
                    autoNextSpell = true,
                    startIndex = 1,
                    maxIndex = nil,
                    bossTime = function()
                        return TJ.Is10Man()
                            and { 63, 81, }
                            or { 42, 68, 63, 63, 66, 64, 63 }
                    end,
                    autoHide = nil,
                },
                AutoFuc = AutoFuc,
            }

            mainFrame.Board_test = function()
                TJ.Board_ENCOUNTER_START(FB, bossIndex, true)
                local t = TJ.Board_info[bossSpellID].updateFrame.t
                local nextTime = TJ.Board_info[bossSpellID].bossTime[1]
                if t and nextTime and nextTime - t > 10 then
                    TJ.Board_info[bossSpellID].updateFrame.t = nextTime - 10
                end
            end

            TJ.CreateBoard(FB, bossIndex, tbl)
        end
        tinsert(TJ.boardCallback, init)
        if TJ.boardInited and not isload then init() end
    end

    -- 站位图
    do
        local tbl = {
            { point = "TOPLEFT", xy = { 461, -118 } },
            { point = "TOPLEFT", xy = { 397, -80 } },
            { point = "TOPLEFT", xy = { 507, -177 } },
            { point = "TOPLEFT", xy = { 371, -153 } },
            { point = "TOPLEFT", xy = { 426, -207 } },
            { point = "TOPLEFT", xy = { 477, -424 } },
            { point = "TOPLEFT", xy = { 423, -466 } },
            { point = "TOPLEFT", xy = { 509, -358 } },
            { point = "TOPLEFT", xy = { 390, -392 } },
            { point = "TOPLEFT", xy = { 438, -328 } },
            { point = "TOPLEFT", xy = { 278, -503 } },
            { point = "TOPLEFT", xy = { 193, -484 } },
            { point = "TOPLEFT", xy = { 356, -498 } },
            { point = "TOPLEFT", xy = { 225, -412 } },
            { point = "TOPLEFT", xy = { 311, -430 } },
            { point = "TOPLEFT", xy = { 76, -313 } },
            { point = "TOPLEFT", xy = { 76, -235 } },
            { point = "TOPLEFT", xy = { 111, -392 } },
            { point = "TOPLEFT", xy = { 153, -272 } },
            { point = "TOPLEFT", xy = { 173, -350 } },
            { point = "TOPLEFT", xy = { 155, -103 } },
            { point = "TOPLEFT", xy = { 115, -158 } },
            { point = "TOPLEFT", xy = { 214, -67 } },
            { point = "TOPLEFT", xy = { 187, -187 } },
            { point = "TOPLEFT", xy = { 244, -137 } },

            [97] = {
                xy = { 344, -306 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["奶骑\n奶僧"],
                isNPC_icon = "Interface\\Icons\\Spell_Holy_AuraOfLight",
            },
            [98] = {
                xy = { 267, -306 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["近战"],
                isNPC_icon = "Interface\\Icons\\ability_steelmelee",
            },
            [99] = {
                xy = { 305, -236 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["坦克"],
                isNPC_icon = "Interface\\Icons\\Spell_Deathknight_BloodPresence",
            },
            [100] = { xy = { 305, -280 }, isNPC = "b" .. bossIndex },
        }

        --[[

]]
        local xy = {
            { 509, -98 },  -- 星星
            { 503, -475 }, -- 大饼
            { 291, -514 }, -- 紫菱
            { 60, -308 },  -- 三角
            { 135, -73 },
            { 626, -133 },
            { 628, -81 },
            { 625, -25 },
        }
        for index = 1, 8 do
            local left = mod((index - 1) / 4, 1);
            local right = left + 0.25;
            local top = floor((index - 1) / 4) * 0.25;
            local bottom = top + 0.25;
            tbl[index + 80] = {
                xy = xy[index],
                isNPC = true,
                isNPC_help = true,
                isNPC_icon = [[Interface\TargetingFrame\UI-RaidTargetingIcons]],
                coord = { left, right, top, bottom },
                notMask = true,
            }
        end

        local function AutoFuc()
            local mapIndex = ""
            local team = TJ.GetRaidPointByTeam(1)
            if team then
                for i, v in ipairs(team) do
                    TJ.SetMapIconPlayer(v, { min = 1, max = 5 }, mapIndex)
                end
            end
            local team = TJ.GetRaidPointByTeam(2)
            if team then
                for i, v in ipairs(team) do
                    TJ.SetMapIconPlayer(v, { min = 6, max = 10 }, mapIndex)
                end
            end
            local team = TJ.GetRaidPointByTeam(3)
            if team then
                for i, v in ipairs(team) do
                    TJ.SetMapIconPlayer(v, { min = 11, max = 15 }, mapIndex)
                end
            end
            local team = TJ.GetRaidPointByTeam(4)
            if team then
                for i, v in ipairs(team) do
                    TJ.SetMapIconPlayer(v, { min = 16, max = 20 }, mapIndex)
                end
            end
            local team = TJ.GetRaidPointByTeam(5)
            if team then
                for i, v in ipairs(team) do
                    TJ.SetMapIconPlayer(v, { min = 21, max = 25 }, mapIndex)
                end
            end
        end
        local text = {
            L["1-5：1队。"],
            L["6-10：2队。"],
            L["11-15：3队。"],
            L["16-20：4队。"],
            L["21-25：5队。"],
        }
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_wispsplode", L["站位"],
            text)
        local width = 600
        local map = TJ.CreateMap(FB, bossIndex, tbl, width, width / 815 * 764)
        local t = map:CreateFontString()
        t:SetFont(BIAOGE_TEXT_FONT, 20, "OUTLINE")
        t:SetPoint("TOP", 0, -5)
        t:SetText(L["Boss当前朝向为12点"])
    end

    -- 狂奔怒吼
    do
        local function AutoFuc(title)
            local count = 0
            for _, role in ipairs({ "tank", "dps1", "dps2", "healer" }) do
                local tbl = TJ.SortRaidRosterInfo({ "DRUID", }, role, true)
                for i, v in ipairs(tbl) do
                    count = count + 1
                    TJ.SetEditText(v, title)
                end
            end
            if count > 0 then
                local tbl = TJ.SortRaidRosterInfo({ "WARRIOR" }, "dps", true)
                for i, v in ipairs(tbl) do
                    if i > count then break end
                    TJ.SetEditText(v, title)
                end
            end
        end
        local info = {
            castSuccess = {
                type = "s",
                spell = {
                    {
                        spellID = ns.sp["狂奔"],
                    },
                },
            },
            notShowDead = true,
            title = { name = L["施放狂奔怒吼"] }
        }
        local text = L["安排小德。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_druid_stampedingroar_cat", L["狂奔怒吼"],
            text, { "DRUID", "WARRIOR" }, nil, info, nil,
            nil)
        TJ.CreateEdit(FB, bossIndex, L["1狂奔"])
        TJ.CreateEdit(FB, bossIndex, L["2狂奔"])
        TJ.CreateEdit(FB, bossIndex, L["3狂奔"])
        TJ.CreateEdit(FB, bossIndex, L["4狂奔"])
        TJ.CreateEdit(FB, bossIndex, L["5狂奔"])
        TJ.CreateEdit(FB, bossIndex, L["6狂奔"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 换嘲
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 134366, },
                            colorNum = 2,
                        },
                    },
                    destNpcType = { "Player" },
                },
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = ns.sp["单嘲+群嘲"],
                            colorNum = 1,
                            frameLevel = 2,
                            combatRole = { "Istank" },
                        },
                    },
                    destNPCID = { 69712 },
                    notShowCount = true,
                },
                title = { name = L["爪掠层数"], icon = 134366 }
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 140092 },
                            colorNum = 2,
                        },
                    },
                    destNpcType = { "Player" },
                },
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = ns.sp["单嘲+群嘲"],
                            colorNum = 1,
                            frameLevel = 2,
                            combatRole = { "Istank" },
                        },
                    },
                    destNPCID = { 69712 },
                    notShowCount = true,
                },
                title = { name = L["感染之爪层数"], icon = 140092 }
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_reincarnation", L["换嘲"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 鸣叫
    do
        local info = {
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                134375,
                            },
                            colorNum = 1
                        },
                    },
                    destNpcType = { "Player" }
                },
                canSend = "count",
                title = { name = L["受到%s伤害"]:format(L["鸣叫"]) }
            },
        }

        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_hunter_animalhandler", L["鸣叫"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 原始营养
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 112879, },
                        },
                    },
                    destNpcType = { "Player" },
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_misc_food_vendor_greenfishbonescurry", L["原始营养"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 飞羽满天
    do
        local info = {
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = { bossSpellID, },
                            colorNum = 2,
                        },
                    },
                },
            },
        }
        tinsert(info, TJ.combatInfoMore)

        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_hunter_pet_dragonhawk", L["飞羽满天"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转火小怪
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    70134, -- 守卫
                    68194, -- 凤凰蛋
                    69628, -- 成熟的凤凰蛋
                    69836, -- 幼年凤凰
                    68192, -- 雏鸟
                    68193, -- 幼鸟
                },
                showDropDown = {
                    key = "nc" .. "(%d+)",
                    name = L["第%s轮小怪"],
                },
            },
            notShowRaidMember = true,
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 648726, L["转火小怪"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
end

--[[
TJ.GetCombatLog().otherTime={}
tinsert(TJ.GetCombatLog().otherTime, {
    startTime = 0,
    endTime = 0 + 28,
    name = "nc" .. 1,
})

tinsert(TJ.GetCombatLog().otherTime, {
    startTime = 30,
    endTime = 30 + 28,
    name = "nc" .. 2,
})
]]
