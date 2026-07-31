local AddonName, ns = ...

local LibBG = ns.LibBG
local L = ns.L

local AddTexture = ns.AddTexture
local Round = ns.Round
local pt = print
local After = C_Timer.After
local BG = TJ

local realmID = GetRealmID()
local player = UnitName("player")


local T = {}
local FB = "RS"
local bossIndex = 1
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
    -- 战术板
    local s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s31
    local i1
    local spellTbl1 = {
        -- {
        --     title = L["1/4"],
        --     class = nil,
        --     spell = TJ.Board_TJ3
        -- },
        -- {
        --     title = L["2/5"],
        --     class = nil,
        --     spell = TJ.Board_TJ3
        -- },
        -- {
        --     title = L["3/6"],
        --     class = nil,
        --     spell = TJ.Board_TJ3
        -- },
        {
            title = L["第1"],
            class = nil,
            spell = TJ.Board_TJ3
        },
        {
            title = L["第2"],
            class = nil,
            spell = TJ.Board_TJ3
        },
        {
            title = L["第3"],
            class = nil,
            spell = TJ.Board_TJ3
        },
        {
            title = L["第4"],
            class = nil,
            spell = TJ.Board_TJ3
        },
        {
            title = L["第5"],
            class = nil,
            spell = TJ.Board_TJ3
        },
        {
            title = L["第6"],
            class = nil,
            spell = TJ.Board_TJ3
        },
        {
            title = L["第7"],
            class = nil,
            spell = TJ.Board_TJ3
        },
        {
            title = L["第8"],
            class = nil,
            spell = TJ.Board_TJ3
        },
    }
    local spellTbl2 = {
        {
            title = L["1/5"],
            class = nil,
            spell = TJ.Board_TJ3
        },
        {
            title = L["2/6"],
            class = nil,
            spell = TJ.Board_TJ3
        },
        {
            title = L["3/7"],
            class = nil,
            spell = TJ.Board_TJ3
        },
        {
            title = L["4/8"],
            class = nil,
            spell = TJ.Board_TJ3
        },
        -- {
        --     title = L["第1"],
        --     class = nil,
        --     spell = TJ.Board_TJ3
        -- },
        -- {
        --     title = L["第2"],
        --     class = nil,
        --     spell = TJ.Board_TJ3
        -- },
        -- {
        --     title = L["第3"],
        --     class = nil,
        --     spell = TJ.Board_TJ3
        -- },
        -- {
        --     title = L["第4"],
        --     class = nil,
        --     spell = TJ.Board_TJ3
        -- },
        -- {
        --     title = L["第5"],
        --     class = nil,
        --     spell = TJ.Board_TJ3
        -- },
        -- {
        --     title = L["第6"],
        --     class = nil,
        --     spell = TJ.Board_TJ3
        -- },
        -- {
        --     title = L["第7"],
        --     class = nil,
        --     spell = TJ.Board_TJ3
        -- },
        -- {
        --     title = L["第8"],
        --     class = nil,
        --     spell = TJ.Board_TJ3
        -- },
        -- {
        --     title = L["第9"],
        --     class = nil,
        --     spell = TJ.Board_TJ3
        -- },
        -- {
        --     title = L["第10"],
        --     class = nil,
        --     spell = TJ.Board_TJ3
        -- },
        -- {
        --     title = L["第11"],
        --     class = nil,
        --     spell = TJ.Board_TJ3
        -- },
        -- {
        --     title = L["第12"],
        --     class = nil,
        --     spell = TJ.Board_TJ3
        -- },
    }
    local spellTbl3 = {
        {
            title = L["1/3"],
            class = { "PALADIN" },
            spell = TJ.Board_TJ4
        },
        {
            title = L["2/4"],
            class = { "PALADIN" },
            spell = TJ.Board_TJ4
        },
    }
    --[[
s1 大牺
s2 光掌
s3 吸血鬼
s4 魔法罩
s5 冰封
s6 小牺
s7 压制
s8 天使
s9 圣疗
s10 圣佑
s11 拯救
s12 自由
s13
]]
    local function AutoFuc()
        -- 外场
        local DK = TJ.SortRaidRosterInfo({ "DEATHKNIGHT", }, "tank", true)
        local v = DK[1]
        if v then
            TJ.SetBoardEditFormNum(v, 1, 1, s3, 1)
            TJ.SetBoardEditFormNum(v, 2, 1, s5, 1)
            TJ.SetBoardEditFormNum(v, 4, 1, s3, 1)
            TJ.SetBoardEditFormNum(v, 5, 1, s5, 1)
            TJ.SetBoardEditFormNum(v, 6, 1, s3, 1)
            TJ.SetBoardEditFormNum(v, 8, 1, s5, 1)
        end
        local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, "healer", true)
        for k, v in pairs(tbl) do
            if TuanJian.talentInfo[v.name] == 1 then
                TJ.SetBoardEditFormNum(v, 3, 1, s7, 1)
                TJ.SetBoardEditFormNum(v, 7, 1, s7, 1)
                break
            end
        end
        -- 内场
        local v = DK[2]
        if v then
            TJ.SetBoardEditFormNum(v, 1, 1, s3, 2)
            TJ.SetBoardEditFormNum(v, 2, 1, s5, 2)
            TJ.SetBoardEditFormNum(v, 3, 1, s3, 2)
            local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "dps", true)
            local v = tbl[1]
            if v then
                TJ.SetBoardEditFormNum(v, 1, 2, s6, 2)
                TJ.SetBoardEditFormNum(v, 3, 2, s1, 2)
                TJ.SetBoardEditFormNum(v, 1, 1, s12, 3)
            end
            local v = tbl[2]
            if v then
                TJ.SetBoardEditFormNum(v, 4, 1, s6, 2)
                TJ.SetBoardEditFormNum(v, 4, 2, s1, 2)
                TJ.SetBoardEditFormNum(v, 2, 1, s12, 3)
            end
        else
            local tbl = TJ.SortRaidRosterInfo({ "PALADIN", }, "tank", true)
            local v = tbl[1]
            if v then
                TJ.SetBoardEditFormNum(v, 1, 1, s10, 2)
                TJ.SetBoardEditFormNum(v, 2, 1, s11, 2)
                TJ.SetBoardEditFormNum(v, 2, 2, s1, 2)
            end
            local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "dps", true)
            local v = tbl[1]
            if v then
                TJ.SetBoardEditFormNum(v, 3, 1, s6, 2)
                TJ.SetBoardEditFormNum(v, 3, 2, s1, 2)
                TJ.SetBoardEditFormNum(v, 1, 1, s12, 3)
            end
            local v = tbl[2]
            if v then
                TJ.SetBoardEditFormNum(v, 4, 1, s6, 2)
                TJ.SetBoardEditFormNum(v, 4, 2, s1, 2)
                TJ.SetBoardEditFormNum(v, 2, 1, s12, 3)
            end
        end
    end
    local cd = 40
    local cd2 = 30
    local cd3 = 21
    local tbl = {
        {
            name = L["P3外场坦克减伤"],
            bossSpellID = 74648,
            arrange = 3,
            icon = "spell_fire_meteorstorm",
            id = 1,
            spell = spellTbl1,
            event = nil,
            canUpdate = false,
            autoNextSpell = false,
            startIndex = 1,
            bossTime = { 30, cd, cd, cd, cd, cd, cd, cd, cd, cd, cd, cd, },
        },
        {
            name = L["内场坦克减伤"],
            bossSpellID = 74769,
            arrange = 3,
            icon = "spell_shadow_shadowmend",
            id = 2,
            spell = spellTbl2,
            event = nil,
            canUpdate = false,
            autoNextSpell = false,
            startIndex = 1,
            bossTime = { cd2 + 5, cd2, cd2, cd2, cd2, cd2, cd2, cd2, cd2, cd2, cd2, cd2, cd2, cd2, },
        },
        {
            name = L["内场自由"],
            bossSpellID = 74792,
            arrange = 1,
            icon = "spell_holy_sealofvalor",
            id = 3,
            spell = spellTbl3,
            event = "SPELL_CAST_SUCCESS",
            canUpdate = false,
            autoNextSpell = true,
            startIndex = 1,
            bossTime = { 17, cd3, cd3, cd3, cd3, cd3, cd3, cd3, cd3, cd3, cd3, cd3, cd3, cd3, cd3, cd3, cd3, cd3, cd3, cd3, cd3, cd3, cd3, },
        },
        AutoFuc = AutoFuc,
    }
    TJ.CreateBoard(FB, bossIndex, tbl)

    local P3
    TJ.frame[FB][bossIndex].BOSS_SAY = function(msg, sender, ...)
        if msg:match(L["暮光的世界将会让你痛不欲生"]) then -- P2开始
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P2",
            })
            return
        end
    end
    local cd = {
        TwilightCutter = 0,
        Meteor = 0,
    }
    TJ.RegisterEvent("CHAT_MSG_ADDON", function(_, _, ...)
        local prefix, msg, distType, sender = ...
        if TJ.startTime and prefix == "D5" and distType == "RAID" then
            local info = TJ.Board_info
            if msg:find("TwilightCutter") and GetTime() - cd.TwilightCutter > 10 then
                cd.TwilightCutter = GetTime()
                local bossSpellID = 74769
                if info[bossSpellID] then
                    After(5, function()
                        TJ.Board_NextSpell(bossSpellID)
                    end)
                end
                if TJ.GetNewEvent() then
                    TJ.GetNewEvent()["SPELL_CAST_SUCCESS"] =
                        TJ.GetNewEvent()["SPELL_CAST_SUCCESS"] or {}
                    local tbl = {
                        TJ.GetDurTime() + 5,
                        "SPELL_CAST_SUCCESS",
                        nil,
                        "",
                        nil,
                        nil,
                        nil,
                        "",
                        nil,
                        nil,
                        nil,
                        74769,
                    }
                    tbl.i = 1
                    tinsert(TJ.GetNewEvent()["SPELL_CAST_SUCCESS"], tbl)
                end
            elseif msg:find("Meteor") and GetTime() - cd.Meteor > 10 then
                cd.Meteor = GetTime()
                local bossSpellID = 74648
                if P3 and info[bossSpellID] then
                    TJ.Board_NextSpell(bossSpellID)
                end
            end
        end
    end)

    TJ.frame[FB][bossIndex].ENCOUNTER_START = function(...)
        P3 = false
    end
    -- 流星打击施放后，把时间往前调5秒
    TJ.frame[FB][bossIndex].SPELL_CAST_SUCCESS = function(...)
        local tbl = { ... }
        local itemID = tbl[12]
        if itemID == 74648 then -- 流星打击
            After(0.5, function()
                local event = TJ.GetNewEvent()["SPELL_CAST_SUCCESS"]
                if event and TJ.startTime then
                    local count = #event
                    for i = count, max(count - 100, 1), -1 do
                        local v = event[i]
                        if v and v[12] == 74648 and math.abs((TJ.GetDurTime()) - v[1]) <= 5 then
                            event[i][1] = event[i][1] - 5
                            return
                        end
                    end
                end
            end)
        end
    end
    -- BOSS施放暮色笼罩，开始P2，射线战术板开始生效
    TJ.frame[FB][bossIndex].Board_SPELL_CAST_SUCCESS = function(info, ...)
        local tbl = { ... }
        local spellID = tbl[12]
        if spellID == 75476 then      -- 暮色笼罩
            local bossSpellID = 74769 -- 射线战术板开始生效
            if info[bossSpellID] then
                info[bossSpellID].canUpdate = true
                info[bossSpellID].updateFrame.t = 0
            end
            local bossSpellID = 74792 -- 自由战术板开始生效
            if info[bossSpellID] then
                info[bossSpellID].canUpdate = true
                info[bossSpellID].updateFrame.t = 0
            end
            return
        end
    end
    -- P3开始， P3流星战术板开始生效
    TJ.frame[FB][bossIndex].Board_SPELL_CAST_START = function(info, ...)
        local tbl = { ... }
        local itemID = tbl[12]
        if itemID == 75063 then       -- 暮光相位分裂术
            P3 = true
            local bossSpellID = 74648 -- P3流星战术板开始生效
            if info[bossSpellID] then
                info[bossSpellID].canUpdate = true
                info[bossSpellID].updateFrame.t = 0
            end
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P3",
            })
            return
        end
    end

    -- 灵魂石
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "tank", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local function updateFuc(index)
            local count = 0
            for i, v in ipairs(TJ.raidRosterInfo) do
                if count >= 3 then break end
                if v.role ~= "MAINASSIST" and v.class == "WARLOCK" then
                    count = count + 1
                    local name = "|c" .. select(4, GetClassColor(v.class)) .. TJ.GetIconAndName(v) .. "|r"
                    TJ.CreateEdit(FB, bossIndex, name, index)
                end
            end
        end
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = ns.sp["灵魂石"],
                    },
                },
            }
        }
        local text = L["绑定坦克。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_shadow_soulgem", L["灵魂石"],
            text, nil, updateFuc, info)
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 燃烧印记
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                74567
                            },
                            colorNum = 1
                        }
                    },
                },
                title = { name = L["燃烧印记"], icon = 74567 },
            },
            {
                dispel = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                74567, 74562,
                            },
                            colorNum = 1
                        }
                    },
                    sourceNpcType = { "Player" },
                },
                notShowDead = true,
                title = { name = L["驱散燃烧印记"], icon = 74567 },
            },
            isMany = true,
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_fire_sealoffire", L["燃烧印记"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 吞噬印记
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = ns.sp["自由"],
                            colorNum = 2
                        },
                        {
                            spellID = {
                                74795
                            },
                            colorNum = 1
                        }
                    },
                },
                title = { name = L["吞噬印记"], icon = 74795 },
            },
            {
                dispel = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                74795, 74792
                            },
                            colorNum = 1
                        }
                    },
                    sourceNpcType = { "Player" },
                },
                notShowDead = true,
                title = { name = L["驱散吞噬印记"], icon = 74795 },
            },
            isMany = true,
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_sealofkings", L["吞噬印记"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 暮光射线
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            74769,
                        },
                        colorNum = 1
                    },
                },
                destNpcType = { "Player" },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_shadowmend", L["暮光射线"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 坦克减伤
    do
        local info = {
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                74648
                            },
                            colorNum = 2
                        }
                    },
                },
                title = { name = L["流星打击"], icon = 74648 },
            },
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                74769, 74768
                            },
                            colorNum = 2
                        }
                    },
                },
                title = { name = L["暮光射线"], icon = 74769 },
            },
            isMany = true,
        }
        for i, v in ipairs(TJ.combatInfoTank) do
            tinsert(info, v)
        end
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_holy_restoration", L["坦克减伤"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 转火大火
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    40681,
                },
            },
            showRaidMember = true,
            canSend = "dps",
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_fire_elemental_totem", L["转火大火"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 转火小火
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    40683
                },
            },
            showRaidMember = true,
            canSend = "dps",
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_fire_lavaspawn", L["转火小火"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 招架
    do
        local info = {
            {
                parry = {
                    type = "s",
                    sourceNpcType = { "Player" },
                    destNPCID = { 39863, },
                },
                title = { name = L["海里昂招架（外场）"], icon = 3127 },
            },
            {
                parry = {
                    type = "s",
                    sourceNpcType = { "Player" },
                    destNPCID = { 40142, },
                },
                title = { name = L["海里昂招架（内场）"], icon = 3127 },
            },
            isMany = true,
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_parry", L["招架"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
end
