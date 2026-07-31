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
local bossIndex = 2
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

    -- 自动标记
    local name = "rt" .. FB .. bossIndex
    do
        mainFrame.autoRT = name
        local instanceID = TJ.FBinfo[FB].ID
        TJ.autoRaidTargetInfo[instanceID] = TJ.autoRaidTargetInfo[instanceID] or {}
        TJ.autoRaidTargetInfo[instanceID][69221] = { -- 统领
            [8] = true,
            np = true,
        }
        TJ.autoRaidTargetInfo[instanceID][69175] = { -- 法拉基瘠行者
            [7] = true,
            [6] = true,
            [5] = true,
            [4] = true,
            np = true,
        }
        TJ.autoRaidTargetInfo[instanceID][69164] = { -- 古拉巴色什剧毒祭司
            [7] = true,
            [6] = true,
            [5] = true,
            [4] = true,
            np = true,
        }
        TJ.autoRaidTargetInfo[instanceID][69178] = { -- 达卡莱冰封督军
            [7] = true,
            [6] = true,
            [5] = true,
            [4] = true,
            np = true,
        }
        TJ.autoRaidTargetInfo[instanceID][69176] = { -- 阿曼尼狂兽萨满
            [7] = true,
            [6] = true,
            [5] = true,
            [4] = true,
            np = true,
        }

        TJ.options[name .. "reset"] = 1
        TuanJian.options[name] = TuanJian.options[name] or TJ.options[name .. "reset"]
        local icon = TJ.SetRaidTargetingTex(8, 7, 6, 5)
        local ontext = {
        }
        local f = ns.O.CreateCheckButton(name, format(L["战斗中把重点小怪标记为%s（需要团长/助理）"], icon),
            mainFrame, 40, -150, ontext)
        f:ClearAllPoints()
        f:SetPoint("BOTTOMLEFT", TJ.spChild.title, "TOPRIGHT", 0, 15)
        f:SetHitRectInsets(0, 0, 0, 0)
    end

    -- 战术板
    do
        local bossSpellID = 136817
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
                local tbl = TJ.SortRaidRosterInfo({ "WARRIOR" }, nil, true)
                for i, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, s2)
                    TJ.SetBoardEditFormNum(v, i, nil, s3)
                end

                local tbl = TJ.SortRaidRosterInfo({ "SHAMAN" }, "healer", true)
                for i, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, s7)
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "ROGUE" }, nil, true)
                for i, v in ipairs(tbl) do
                    for i = 3, 1, -1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, s6)
                            done[i] = true
                            break
                        end
                    end
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "healer", true)
                for i, v in ipairs(tbl) do
                    for i = 3, 1, -1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, s1)
                            done[i] = true
                            break
                        end
                    end
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, "healer", true)
                for i, v in ipairs(tbl) do
                    if TuanJian.talentInfo[v.name] == 1 then
                        for i = 3, 1, -1 do
                            if not done[i] then
                                TJ.SetBoardEditFormNum(v, i, nil, s5)
                                done[i] = true
                                break
                            end
                        end
                    end
                end
            end

            local tbl = {
                {
                    name = L["兽性咆哮减伤链"],
                    bossSpellID = bossSpellID,
                    arrange = 6,
                    icon = "ability_hunter_masterscall",
                    id = 1,
                    spell = spellTbl,
                    event = "SPELL_CAST_SUCCESS",
                    canUpdate = nil,
                    autoNextSpell = true,
                    startIndex = 1,
                    maxIndex = #spellTbl,
                    bossTime = { 5, 10, 10, },
                },
                AutoFuc = AutoFuc,
            }

            mainFrame.Board_test = function()
                TJ.Board_ENCOUNTER_START(FB, bossIndex, true)
                TJ.Board_info[bossSpellID].canUpdate = true
            end

            TJ.CreateBoard(FB, bossIndex, tbl)

            mainFrame.INSTANCE_ENCOUNTER_ENGAGE_UNIT = function()
                if TJ.GetNPCID("boss2") == 69374 then
                    TJ.Board_info[bossSpellID].canUpdate = true
                    TJ.Board_info[bossSpellID].updateFrame.t = 0
                    tinsert(TJ.GetNewCombatLog().otherTime, {
                        time = TJ.GetDurTime(),
                        name = "战神",
                    })
                end
            end
        end
        tinsert(TJ.boardCallback, init)
        if TJ.boardInited and not isload then init() end
    end

    -- 坦克
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "tank", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["安排坦克。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "Spell_Deathknight_BloodPresence", L["坦克"],
            text, TJ.tankClass, nil, nil, nil,
            nil)
        TJ.CreateEdit(FB, bossIndex, L["主坦克"])
        TJ.CreateEdit(FB, bossIndex, L["副坦克"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 换嘲
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = { 136767 },
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
                destNPCID = { 68476 },
                notShowCount = true,
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_reincarnation", L["换嘲"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 冲锋
    do
        local info = {
            {
                castSuccess = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 136769 },
                            colorNum = 2,
                        },
                    },
                },
                title = L["点名"],
                notShowDead = true,
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_warrior_bullrush", L["冲锋"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 双重打击
    do
        local info = {
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 136740, 136739 },
                            colorNum = 1,
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L["受到%s伤害"]:format(L["双重打击"]) }
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_misc_monsterhorn_07", L["双重打击"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 恐怖凝视
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 140946, },
                            tooltip = "aura+castAll:destNPCID|70688",
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = L["点名"],
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_misc_eye_03", L["恐怖凝视"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 打断小怪
    do
        local info = {
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                136708, -- 岩石凝视
                                136797, -- 龙形治愈
                                136587, -- 毒箭之雨
                                136465, -- 火球术
                                136480, -- 闪电链
                            },
                        },
                    },
                    showIcon = true,
                },
                title = { name = L["漏打断"], color = { 1, 0, 0 } },
            },
            {
                interrupt = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                136708, -- 岩石凝视
                                136797, -- 龙形治愈
                                136587, -- 毒箭之雨
                                136465, -- 火球术
                                136480, -- 闪电链
                            },
                        },
                    },
                    showIcon = true,
                },
                title = { name = L["成功打断"] }
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_creature_poison_02", L["打断"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 兽性咆哮
    do
        local info = {
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = { 136817, },
                            colorNum = 2,
                        },
                    },
                },
            },
        }
        tinsert(info, TJ.combatInfoMore)

        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_hunter_masterscall", L["兽性咆哮"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转火小怪
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    69314, -- 剧毒渗透者
                    69164, -- 古拉巴什剧毒祭司
                    69167, -- 古拉巴什血领主
                    69185, -- 复生的达卡莱勇士
                    69184, -- 复生的达卡莱战士
                    69173, -- 法拉基散兵
                    69175, -- 法拉基瘠行者
                    69172, -- 苏利萨斯凝石者
                    69221, -- 赞达拉恐龙统领
                    69178, -- 达卡莱冰封督军
                    70448, -- 远古巨蟒
                    69169, -- 阿曼尼保卫者
                    69177, -- 阿曼尼战熊
                    69168, -- 阿曼尼烈焰法师
                    69176, -- 阿曼尼狂兽萨满
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "achievement_character_troll_male", L["转火小怪"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转火战神
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    69374,
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "racial_troll_berserk", L["转火战神"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    mainFrame.BOSS_SAY = function(msg)
        if msg:match("") then
            return
        end
    end
end

--[[

赫利东
ID: 68476


]]
