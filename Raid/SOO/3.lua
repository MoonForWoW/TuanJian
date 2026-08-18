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
local FB = "SOO"
local bossIndex = 3
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

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 坦克机制
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 146124 }, -- 自惑
                            colorNum = 1,
                            combatRole = { "Istank" },
                        },
                    },
                    destNpcType = { "Player" },
                    showCount = true,
                },
                canSend = "count",
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 895885, L["自惑层数"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 融合
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = { 145132 },
                        colorNum = 1,
                    },
                },
                destNPCID = { 72276 }, -- 腐蚀混合物
                showCount = true,
            },
            canSend = "count",
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 651090, L["融合"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 射线
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = { 145227 },
                    },
                },
                destNpcType = { "Player" },
                showCount = true,
            },
            canSend = "count",
            title={name=L['受到射线伤害']}
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 651082, L["射线承伤"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 进内场
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 144849 }, -- 冷静的试炼
                            colorNum = 1,
                        },
                    },
                    destNpcType = { "Player" },
                    showCount = true,
                },
                canSend = "count",
                title = { name = L["冷静的试炼（DPS）"], icon = 897141 },
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 144851 }, -- 自信的试炼
                            colorNum = 1,
                        },
                    },
                    destNpcType = { "Player" },
                    showCount = true,
                },
                canSend = "count",
                title = { name = L["自信的试炼（坦克）"], icon = 144851 },
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 144850 }, -- 信赖的试炼
                            colorNum = 1,
                        },
                    },
                    destNpcType = { "Player" },
                    showCount = true,
                },
                canSend = "count",
                title = { name = L["信赖的试炼（治疗）"], icon = 144850 },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 897141, L["进内场"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转火
    do
        local info = {
            {
                dps = {
                    type = "s",
                    destNPCID = { 72264 }, -- 腐蚀具象
                },
                showRaidMember = true,
                title = { name = L["转火腐蚀具象"] }, 
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 'sha_spell_shadow_shadesofdarkness', L["转火具象"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    do
        local info = {
            {
                dps = {
                    type = "s",
                    destNPCID = { 72263 }, -- 腐蚀精华
                },
                showRaidMember = true,
                title = { name = L["转火腐蚀精华"], icon = 651094 }, -- 驱逐腐蚀
            },
            isMany = true,
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 897143, L["转火精华"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- mainFrame.BOSS_SAY = function(msg)
    --     if msg:match("") then
    --         tinsert(TJ.GetNewCombatLog().otherTime, {
    --             time = TJ.GetDurTime(),
    --             name = "P2",
    --         })
    --         return
    --     end
    -- end
end
