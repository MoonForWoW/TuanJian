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
local FB = "模版"
local bossIndex = 12
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
