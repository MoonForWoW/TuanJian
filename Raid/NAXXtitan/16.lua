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
local FB = "OStitan"
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

    -- 自动标记
    local name = "rt" .. FB .. bossIndex
    do
        local instanceID = TJ.FBinfo[FB].ID
        TJ.autoRaidTargetInfo[instanceID] = TJ.autoRaidTargetInfo[instanceID] or {}
        TJ.autoRaidTargetInfo[instanceID][30452] = { -- 塔尼布隆
            [8] = true, np = true,
        }
        TJ.autoRaidTargetInfo[instanceID][30451] = { -- 沙德隆
            [7] = true, np = true,
        }
        TJ.autoRaidTargetInfo[instanceID][30449] = { -- 维斯匹隆
            [6] = true, np = true,
        }

        TJ.options[name .. "reset"] = 1
        TuanJian.options[name] = TuanJian.options[name] or TJ.options[name .. "reset"]
        local icon = TJ.SetRaidTargetingTex(8,7, 6)
        local ontext = {
        }
        local f = ns.O.CreateCheckButton(name, format(L["战斗中把3条中龙标记为%s（需要团长/助理）"], icon),
            mainFrame, 40, -150, ontext)
        f:ClearAllPoints()
        f:SetPoint("BOTTOMLEFT", TJ.spChild.title, "TOPRIGHT", 0, 15)
        f:SetHitRectInsets(0, 0, 0, 0)
    end

    -- 坦克
    do
        local function AutoFuc(title)
            local tank = TJ.SortRaidRosterInfo(title.classTbl, "tank", true)
            local tankCount = #tank
            local hasDKT
            for i, v in ipairs(tank) do
                if v.class == "DEATHKNIGHT" then
                    TJ.SetEditTextFormNum(v, title, 1)
                    tremove(tank, i)
                    hasDKT = true
                    break
                end
            end
            if tankCount > 2 then
                for i, v in ipairs(tank) do
                    if v.class == "PALADIN" then
                        TJ.SetEditTextFormNum(v, title, 4)
                        tremove(tank, i)
                        break
                    end
                end
                if not hasDKT then
                    for i, v in ipairs(tank) do
                        TJ.SetEditTextFormNum(v, title, 1)
                        tremove(tank, i)
                        break
                    end
                end
                for i, v in ipairs(tank) do
                    TJ.SetEditTextFormNum(v, title, 2)
                    TJ.SetEditTextFormNum(v, title, 3)
                    break
                end
            else
                -- 优先安排防骑做副T
                for i, v in ipairs(tank) do
                    if v.class == "PALADIN" then
                        TJ.SetEditTextFormNum(v, title, 2)
                        TJ.SetEditTextFormNum(v, title, 3)
                        TJ.SetEditTextFormNum(v, title, 4)
                        tremove(tank, i)
                        break
                    end
                end
                -- 没有DKT，则随便安排一个
                if not hasDKT then
                    for i, v in ipairs(tank) do
                        TJ.SetEditTextFormNum(v, title, 1)
                        tremove(tank, i)
                        break
                    end
                end
                for i, v in ipairs(tank) do
                    TJ.SetEditTextFormNum(v, title, 2)
                    TJ.SetEditTextFormNum(v, title, 3)
                    TJ.SetEditTextFormNum(v, title, 4)
                    break
                end
            end
        end
        local text = L["安排坦克。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "Spell_Deathknight_BloodPresence", L["坦克"],
            text, TJ.tankClass, nil, nil, nil,
            true)
        TJ.CreateEdit(FB, bossIndex, L["BOSS"])
        TJ.CreateEdit(FB, bossIndex, L["1龙"])
        TJ.CreateEdit(FB, bossIndex, L["2龙"])
        TJ.CreateEdit(FB, bossIndex, L["3龙"])
    end

    -- 治疗
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
                tremove(tbl, i)
                break
            end
            local tbl = TJ.SortRaidRosterInfo({ "PRIEST", "SHAMAN", "DRUID" }, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
                break
            end
        end
        local text = L["安排一个奶骑负责主坦克，安排一个其他治疗进内场。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "Spell_Holy_HolyBolt", L["治疗"],
            text, TJ.healerClass, nil, nil, nil,
            true)
        TJ.CreateEdit(FB, bossIndex, L["BOSS"])
        TJ.CreateEdit(FB, bossIndex, L["进内场"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 顺劈斩
    do
        local info = {
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                56909
                            },
                            combatRole = { "Isdps", "Ishealer" },
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L["受到%s伤害"]:format(L["顺劈斩"]) },
            },
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                58957,
                            },
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L["受到%s伤害"]:format(L["扫尾"]), icon = 55696 },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_warrior_cleave", L["顺劈斩"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 吐息
    do
        local info = {
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                58956
                            },
                            colorNum = 1
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L["受到%s伤害"]:format(L["萨塔里奥的烈焰吐息"]) },
            },
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                57570
                            },
                            colorNum = 1
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L["受到%s伤害"]:format(L["塔尼布隆的暗影吐息"]) },
            },
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                59126
                            },
                            colorNum = 1
                        },
                    },
                    sourceNPCID = { 30451 },
                    destNpcType = { "Player" },
                },
                title = { name = L["受到%s伤害"]:format(L["沙德隆的暗影吐息"]) },
            },
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                59126
                            },
                            colorNum = 1
                        },
                    },
                    sourceNPCID = { 30449 },
                    destNpcType = { "Player" },
                },
                title = { name = L["受到%s伤害"]:format(L["维斯匹隆的暗影吐息"]) },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_shadowandflame", L["吐息"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 火墙
    do
        local info = {
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                57491
                            },
                            colorNum = 1
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L["受到%s伤害"]:format(L["火墙"]) },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shaman_lavaflow", L["火墙"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 暮光裂隙
    do
        local info = {
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                59128
                            },
                            colorNum = 1
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L["受到%s伤害"]:format(L["暮光裂隙"]) },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_creepingplague", L["暮光裂隙"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转火小怪
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    31218,
                    31219,
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_misc_head_dragon_black", L["转火追随者"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转火小怪
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    31214,
                    30643,
                },
            },
            title = { name = L["转火熔岩烈焰&暮光雏龙"] },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_fire_elemental_totem", L["转火小怪"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    local ids = {
        [30452] = L["塔尼布隆"],
        [30451] = L["沙德隆"],
        [30449] = L["维斯匹隆"],
    }
    local count = 0
    mainFrame.UNIT_DIED = function(...)
        local tbl = { ... }
        if ids[TJ.GetNPCID(tbl[8])] then
            count = count + 1
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = count .. "龙死",
            })
        end
    end

    mainFrame.ENCOUNTER_START = function()
        count = 0
        TJ.setRTinCombat = TuanJian.options[name] == 1
    end
end
