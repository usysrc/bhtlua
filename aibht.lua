--
--  BehaviourTree
--
--  Created by Tilmann Hars on 2012-07-12.
--  Copyright (c) 2012 Headchant. All rights reserved.
--

require 'hump.class'

local READY = "ready"
local RUNNING = "running"
local FAILED = "failed"

Action = Class(function(self, task)
    self.task = task
    self.completed = false
end)

function Action:update(creatureAI)
    if self.completed then return READY end
    self.completed = self.task(creatureAI)
    return RUNNING
end

Condition = Class(function(self, condition)
    self.condition = condition
end)

function Condition:update(creatureAI)
    return self.condition(creatureAI) and READY or FAILED
end

Selector = Class(function(self, children)
    self.children = children
end)

function Selector:update(creatureAI)
    for i,v in ipairs(self.children) do
        local status = v:update(creatureAI)
        if status == RUNNING then
            return RUNNING
        elseif status == READY then
            if i == #self.children then
                self:resetChildren()
                return READY
            end
        end
    end
    return READY
end

function Selector:resetChildren()
    for ii,vv in ipairs(self.children) do
        vv.completed = false
    end
end

Sequence = Class(function(self, children)
    self.children = children
    self.last = nil
    self.completed = false
end)

function Sequence:update(creatureAI)
    if self.completed then return READY end
    
    local last = 1
    
    if self.last and self.last ~= #self.children then
        last = self.last + 1
    end
    
    for i = last, #self.children do
        local v = self.children[i]:update(creatureAI)
        if v == RUNNING then
            self.last = i
            return RUNNING
        elseif v == FAILED then
            self.last = nil
            self:resetChildren()
            return FAILED
        elseif v == READY then
            if i == #self.children then
                self.last = nil
                self:resetChildren()
                self.completed = true
                return READY
            end
        end
    end

end

function Sequence:resetChildren()
    for ii,vv in ipairs(self.children) do
        vv.completed = false
    end
end

---------------------------------------------------------------------------
-- Example

local TRUE = function() return true end
local FALSE = function() return false end

local isThiefNearTreasure = Condition(FALSE)
local stillStrongEnoughToCarryTreasure = Condition(TRUE)
local updated = false


local makeThiefFlee = Action(function() print("making the thief flee") return false end)
local chooseCastle = Action(function() print("choosing Castle") return true end)
local flyToCastle = Action(function() print("fly to Castle") return true end)
local fightAndEatGuards = Action(function() print("fighting and eating guards") return true end)
local takeGold = Action(function() print("picking up gold") return true end)
local flyHome = Action(function() print("flying home") return true end)
local putTreasureAway = Action(function() print("putting treasure away") return true end)
local postPicturesOfTreasureOnFacebook = Action(function() 
    print("posting pics on facebook")
    return true 
end)

-- testing subtree
local packStuffAndGoHome = Selector{
    Sequence{
        stillStrongEnoughToCarryTreasure,
        takeGold,
    
    },
    Sequence{
        flyHome,
        putTreasureAway,
    }
}

local simpleBehaviour = Selector{
                            Sequence{
                                isThiefNearTreasure,
                                makeThiefFlee,
                            },
                            Sequence{
                                chooseCastle,
                                flyToCastle,
                                fightAndEatGuards,
                                packStuffAndGoHome
            
                            },
                            Sequence{
                                postPicturesOfTreasureOnFacebook
                            }
                        }


function exampleLoop()
    for i=1,10 do
        simpleBehaviour:update()
    end
end

exampleLoop()