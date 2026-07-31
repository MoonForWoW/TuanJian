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
local FB = "ZUGtitan"
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
    local mainFrame = TJ.frame[FB][bossIndex]

    local instanceID = TJ.FBinfo[FB].ID
    TJ.autoRaidTargetInfo[instanceID] = TJ.autoRaidTargetInfo[instanceID] or {}
    TJ.autoRaidTargetInfo[instanceID][14750] = {
        [8] = true,
        [7] = true,
        [6] = true,
        [5] = true,
        np = true,
    }

    -- 坦克
    do
        local function AutoFuc(title)
            local dk = TJ.SortRaidRosterInfo({ "DEATHKNIGHT" }, "tank", true)
            for i, v in ipairs(dk) do
                TJ.SetEditTextFormNum(v, title, 1)
                tremove(dk, i)
                break
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
            for i, v in ipairs(dk) do
                TJ.SetEditText(v, title)
            end
            for i, v in ipairs(fq) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["安排坦克。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "Spell_Deathknight_BloodPresence", L["坦克"],
            text, TJ.tankClass, nil, nil, nil,
            true)
        TJ.CreateEdit(FB, bossIndex, L["BOSS"])
        TJ.CreateEdit(FB, bossIndex, L["小怪"])
    end

    -- 打断
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
            local done = {}
            for _, v in ipairs(tbl) do
                for _, i in ipairs({ 1, 3, 5, 2, 4, 6 }) do
                    if not done[i] then
                        TJ.SetEditTextFormNum(v, title, i)
                        done[i] = true
                        break
                    end
                end
            end
        end
        local text = L["优先安排DK/盗贼/战士/增强萨。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_holy_heal", L["打断治疗术"],
            text, nil, nil, nil, nil,
            true)
        TJ.CreateEdit(FB, bossIndex, L["打断"])
        TJ.CreateEdit(FB, bossIndex, L["打断"])
        TJ.CreateEdit(FB, bossIndex, L["打断"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 顺劈斩
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            23919
                        },
                        combatRole = { "Isdps", "Ishealer" },
                    },
                },
                destNpcType = { "Player" },
            },
            title = { name = L["受到%s伤害"]:format(L["飞扑"]) },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_warrior_cleave", L["顺劈斩"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 刺穿护甲
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            12097,
                        },
                        colorNum = 1,
                    }
                },
                destNpcType = { "Player" },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_vampiricaura", L["刺穿护甲"],
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
                            spellID = {
                                22911,
                            },
                            colorNum = 1,
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = L["点名"],
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_warrior_charge", L["冲锋"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 音爆
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            23918,
                        },
                        colorNum = 1,
                    }
                },
                destNpcType = { "Player" },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_teleport", L["音爆"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 心灵尖啸
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            22884,
                        },
                        colorNum = 1,
                    }
                },
                destNpcType = { "Player" },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_psychicscream", L["心灵尖啸"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 打断
    do
        local info = {
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = { 23954 },
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
                            spellID = { 23954 },
                        },
                    },
                },
                title = { name = L["成功打断"] }
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_holy_heal", L["打断治疗术"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转火小怪
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    14965,
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_hunter_pet_bat", L["转火小怪"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    TJ.AddDispelInfo(23918, 1, FB, bossIndex) -- 音爆
    TJ.AddDispelInfo(23952, 1, FB, bossIndex) -- 暗言术：痛
    TJ.AddDispelInfo(16098, 2, FB, bossIndex) -- 血之诅咒
    
    mainFrame.BOSS_SAY = function(msg)
        if msg:match("") then
            return
        end
    end
end
