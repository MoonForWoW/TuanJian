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
    TJ.autoRaidTargetInfo[instanceID][20034] = { [8] = true, [7] = true }  -- 星占师
    TJ.autoRaidTargetInfo[instanceID][20033] = { [6] = true, [5] = true, } -- 星术师
    TJ.autoRaidTargetInfo[instanceID][20031] = { [4] = true, [3] = true, } -- 血警卫军团士兵

    TJ.autoRaidTargetInfo[instanceID][20045] = { [8] = true, [7] = true }  -- 虚空占卜者

    TJ.autoRaidTargetInfo[instanceID][20048] = { [8] = true, [7] = true }  -- 炽手百夫长
    TJ.autoRaidTargetInfo[instanceID][20035] = { [6] = true, [5] = true }  -- 血警卫典狱长
    
    -- 坦克
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo({ "WARRIOR", "DRUID" }, "tank", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
            local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "tank", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditTextFormNum(v, title, 3)
                tremove(tbl, i)
                break
            end
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
            local tbl = TJ.SortRaidRosterInfo({ "DEATHKNIGHT" }, "tank", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["主副坦克优先安排防战和熊德，小怪坦克优先安排防骑。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "Spell_Deathknight_BloodPresence", L["坦克"],
            text, TJ.tankClass, nil, nil, nil,
            nil)
        TJ.CreateEdit(FB, bossIndex, L["主坦克"])
        TJ.CreateEdit(FB, bossIndex, L["副坦克"])
        TJ.CreateEdit(FB, bossIndex, L["小怪坦克"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)
    -- 烈焰飞羽
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            34274, 34273, 34275,
                        },
                    },
                },
                destNpcType = { "Player" },
            },
            title = { name = L["受到%s伤害"]:format(L["烈焰飞羽"]) },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_fire_flare", L["烈焰飞羽"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 俯冲轰炸
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            35181
                        },
                    },
                },
                destNpcType = { "Player" },
            },
            title = { name = L["受到%s伤害"]:format(L["俯冲轰炸"]) },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_fire_fireball02", L["俯冲轰炸"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 烈焰之地
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            35383,
                        },
                        colorNum = 1,
                    }
                },
                destNpcType = { "Player" },
            },
            title = { name = L["%s层数"]:format(L["烈焰之地"]) },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_fire_lavaspawn", L["烈焰之地"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 换嘲
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = { 35410 },
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
                notShowCount = true,
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_fire_immolation", L["换嘲"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    mainFrame.SPELL_CAST_SUCCESS = function(...)
        local tbl = { ... }
        local spellID = tbl[12]
        if spellID == 34342 then -- 复生
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P2",
            })
        end
    end
end
