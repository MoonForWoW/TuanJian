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
local FB = "TKtitan"
local bossIndex = 4
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
    -- 火女坦克
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo({ "DEATHKNIGHT" }, "tank", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
            local tbl = TJ.SortRaidRosterInfo({ "WARLOCK" }, nil, true)
            for i, v in ipairs(tbl) do
                if TuanJian.talentInfo[v.name] == 2 then
                    TJ.SetEditText(v, title)
                end
            end
        end
        local text = TJ.IsTBC and L["安排恶魔术。"] or L["优先安排DKT，其次恶魔术。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_fire_incinerate", L["火女坦"],
            text, nil, nil, nil, nil,
            nil)
        TJ.CreateEdit(FB, bossIndex, L["火女坦"])
    end
    -- 七武器坦克
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo({ "DEATHKNIGHT" }, "tank", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditTextFormNum(v, title, 1)
            end
            local fq = TJ.SortRaidRosterInfo({ "PALADIN" }, "tank", true)
            for i, v in ipairs(fq) do
                TJ.SetEditTextFormNum(v, title, 2)
                tremove(fq, i)
                break
            end
            local tbl = TJ.SortRaidRosterInfo({ "WARRIOR", "DRUID" }, "tank", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
            for i, v in ipairs(fq) do
                TJ.SetEditText(v, title)
            end
        end
        local text = TJ.IsTBC and L["其他武器优先安排防骑"] or L["毁灭优先安排DKT，其他武器优先安排防骑。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "inv_axe_68", L["七武器坦克"],
            text, TJ.tankClass, nil, nil, nil,
            true)
        TJ.CreateEdit(FB, bossIndex, L["毁灭(双手斧)"])
        TJ.CreateEdit(FB, bossIndex, L["其他武器"])
    end
    -- 打断小怪
    do
        local function AutoFuc(title)
            local tbl = CopyTable(TJ.SortRaidRosterInfo({ "DEATHKNIGHT", "ROGUE", "WARRIOR", "SHAMAN" }, "dps1", true))
            for i, v in ipairs(tbl) do
                if v.class == "DEATHKNIGHT" then
                    tbl[i].index = 1
                elseif v.class == "ROGUE" then
                    tbl[i].index = 2
                elseif v.class == "WARRIOR" then
                    tbl[i].index = 3
                elseif v.class == "SHAMAN" then
                    tbl[i].index = 4
                end
            end
            sort(tbl, function(a, b)
                if a.index and b.index then
                    return a.index < b.index
                end
                return false
            end)
            for _, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local info = {
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = { 36983 },
                        },
                    },
                },
                title = { name = L["漏打断"], color = { 1, 0, 0 } },
                canSend = "count",
            },
            {
                interrupt = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                36983
                            },
                        },
                    },
                },
                title = { name = L["成功打断"] }
            },
        }
        local text = TJ.IsTBC and L["优先安排盗贼/战士/增强萨。"] or L["优先安排DK/盗贼/战士/增强萨。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_holy_holybolt", L["打断奶锤加血"],
            text, nil, nil, info, nil,
            true)
        TJ.CreateEdit(FB, bossIndex, L["1断"])
        TJ.CreateEdit(FB, bossIndex, L["2断"])
        TJ.CreateEdit(FB, bossIndex, L["3断"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 转火凝视男
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    20064
                },
                startTime = "P3",
                endTime = "P4",
                endTime2 = "duration",
            },
            title = { name = L["转火凝视男（P3阶段）"] },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_mindsteal", L["转火凝视男"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 燃烧
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            37018,
                        },
                        colorNum = 1,
                    }
                },
                destNpcType = { "Player" },
                showCount = true,
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_fire_incinerate", L["燃烧"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 烈焰风暴
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            36731,
                        },
                        colorNum = 1,
                    }
                },
                destNpcType = { "Player" },
                showCount = true,
            },
            title = { name = L["受到%s伤害"]:format(L["烈焰风暴"]) },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_fire_selfdestruct", L["烈焰风暴"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 冲击屏障
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                36815,
                            },
                            colorNum = 1,
                        }
                    },
                    showCount = true,
                },
                title = { name = L["Boss施放冲击屏障"] },
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                36481,
                            },
                            colorNum = 1,
                            combatRole = { "Istank" },
                        }
                    },
                    showCount = true,
                },
                title = { name = L["坦克使用武器特效，吸收10万伤害"], icon = 36481 },
            },
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                36819
                            },
                        },
                    },
                },
                title = { name = L["受到%s伤害"]:format(L["炎爆术"]), icon = 11366 },
            },
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = { 36819 },
                            tooltip = "castSuccess+damageHarm",
                        },
                    },
                },
                title = { name = L["Boss成功施放炎爆术"], icon = 11366, color = { 1, 0, 0 } },
                notShowDead = true,
            },
            {
                interrupt = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                36819
                            },
                        },
                    },
                },
                title = { name = L["成功打断炎爆术"], icon = 11366 }
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_lightningshield", L["冲击屏障"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 打盾伤害
    do
        local info = {
        }
        for i = 1, 6 do
            tinsert(info, {
                dps = {
                    type = "s",
                    destNPCID = {
                        19622
                    },
                    phase = "d" .. i,
                },
                canSend = "dps",
                title = { name = format(L["P4第%s个冲击屏障伤害排名"], i) }
            })
        end
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_lightningshield", L["打盾伤害"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 精神控制
    do
        local info = {
            {
                dispel = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                36797,
                            },
                            colorNum = 1,
                        },
                    },
                    sourceNpcType = { "Player" },
                },
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                36797,
                            },
                            colorNum = 1,
                        }
                    },
                    destNpcType = { "Player" },
                    showCount = true,
                },
                title = { name = L["被心控"] }
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_charm", L["心控救人"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 虚空雾气
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            35859,
                        },
                        colorNum = 1,
                    }
                },
                destNpcType = { "Player" },
                showCount = true,
            },
            title = { name = L["%s层数"]:format(L["虚空雾气"]) },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_gathershadows", L["虚空雾气"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    local start, isP5
    local count = 0
    TJ.frame[FB][bossIndex].SPELL_AURA_APPLIED = function(...)
        local tbl = { ... }
        local spellID = tbl[12]
        if spellID == 36815 and not isP5 then
            start = TJ.GetDurTime()
        end
    end
    TJ.frame[FB][bossIndex].SPELL_AURA_REMOVED = function(...)
        local tbl = { ... }
        local spellID = tbl[12]
        if spellID == 36815 then
            if start then
                count = count + 1
                tinsert(TJ.GetNewCombatLog().otherTime, {
                    startTime = start,
                    endTime = TJ.GetDurTime(),
                    name = "d" .. count,
                })
                start = nil
            end
        end
    end
    TJ.frame[FB][bossIndex].ENCOUNTER_START = function(...)
        start = nil
        isP5 = nil
        count = 0
    end
    TJ.frame[FB][bossIndex].ENCOUNTER_END = function(...)
        if start then
            count = count + 1
            tinsert(TJ.GetNewCombatLog().otherTime, {
                startTime = start,
                endTime = TJ.GetDurTime(),
                name = "d" .. count,
            })
            start = nil
        end
    end

    TJ.frame[FB][bossIndex].BOSS_SAY = function(msg)
        if msg:match(L["有许多武器"]) then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P2",
            })
            return
        end
        if msg:match(L["低估了你们"]) then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P3",
            })
            return
        end
        if msg:match(L["亲自解决"]) then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P4",
            })
            return
        end
        if msg:match(L["真正的力量"]) then
            isP5 = true
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P5",
            })
            return
        end
    end
end
