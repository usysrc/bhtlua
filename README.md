#Behaviour Trees in Lua

A first approach to [behaviour trees](http://www.altdevblogaday.com/2011/02/24/introduction-to-behavior-trees) in Lua. Implements Actions, Conditions, Selectors and Sequences. Requires [hump.class](http://vrld.github.com/hump/).

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
