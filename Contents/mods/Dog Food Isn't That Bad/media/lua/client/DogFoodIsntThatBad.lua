local function adjustFoodNotPicky(item)
    -- Cancel out any negative effects
    if item:getUnhappyChange() > 0 then
        item:setUnhappyChange(item:getUnhappyChangeUnmodified() - item:getUnhappyChange())
    end
    if item:getBoredomChange() > 0 then
        item:setBoredomChange(item:getBoredomChangeUnmodified() - item:getBoredomChange())
    end
end

local function adjustFoodVeryPicky(item)
    local unhappyChange = item:getUnhappyChangeUnmodified()
    local boredomChange = item:getBoredomChangeUnmodified()

    -- Increase existng negative effects by 50%
    if item:getUnhappyChange() > 0 then
        unhappyChange = unhappyChange + item:getUnhappyChange() * 0.5
    end
    if item:getBoredomChange() > 0 then
        boredomChange = boredomChange + item:getBoredomChange() * 0.5
    end

    -- Microwaved food is dull
    if item:isCookedInMicrowave() then
        boredomChange = boredomChange + 10
    end

    -- Uncooked food which ought to be cooked is disgusting
    if item:isCookable() and not item:isCooked() then
        unhappyChange = unhappyChange + 10
    end

    -- Canned food is disgusting
    if item:getEatType() == "can" then
        unhappyChange = unhappyChange + 10
    end

    -- Adjust food groups
    local foodGroupAdjustments = {
        ["Candy"] = 15,
        ["SoftDrink"] = 10,
        ["Sugar"] = 10,
        ["Wine"] = -10,
    }
    if foodGroupAdjustments[item:getFoodType()] then
        unhappyChange = unhappyChange + foodGroupAdjustments[item:getFoodType()]
    end

    -- Adjust specific foods
    local foodAdjustments = {
        ["BakingSoda"] = 20,
        ["Butter"] = 10,
        ["Candycane"] = 5,
        ["Cereal"] = 10,
        ["ChickenFried"] = 10,
        ["ChocoCakes"] = 15,
        ["CocoaPowder"] = 10,
        ["CookiesSugar"] = 5,
        ["Corndog"] = 10,
        ["Cornflour"] = 20,
        ["Crisps"] = 5,
        ["Crisps2"] = 5,
        ["Crisps3"] = 5,
        ["Crisps4"] = 5,
        ["FishFried"] = 10,
        ["GravyMix"] = 20,
        ["Gum"] = 10,
        ["HiHis"] = 15,
        ["Icecream"] = 10,
        ["JuiceBox"] = 10,
        ["Lollipop"] = 15,
        ["Macandcheese"] = 20,
        ["MintCandy"] = 15,
        ["OystersFried"] = 10,
        ["PancakeMix"] = 20,
        ["Plonkies"] = 15,
        ["Popcorn"] = 5,
        ["Processedcheese"] = 5,
        ["QuaggaCakes"] = 15,
        ["RefriedBeans"] = 5,
        ["Smore"] = 10,
        ["SnoGlobes"] = 15,
        ["TofuFried"] = 10,
    }
    if foodAdjustments[item:getType()] then
        unhappyChange = unhappyChange + foodAdjustments[item:getType()]
    end

    item:setUnhappyChange(unhappyChange)
    item:setBoredomChange(boredomChange)
end

local base_tooltip_render = ISToolTipInv.render

function ISToolTipInv:render()
    local origUnhappyChange
    local origBoredomChange

    if self.item:IsFood() then
        origUnhappyChange = self.item:getUnhappyChangeUnmodified()
        origBoredomChange = self.item:getBoredomChangeUnmodified()

        -- Adjust food effects based on traits
        local traits = getPlayer():getTraits()
        if traits:contains("NotAPickyEater") then
            adjustFoodNotPicky(self.item)
        elseif traits:contains("RefinedPalate") then
            adjustFoodVeryPicky(self.item)
        end
    end

    -- Call original function
    base_tooltip_render(self)

    if self.item:IsFood() then
        -- Reset food effects
        self.item:setUnhappyChange(origUnhappyChange)
        self.item:setBoredomChange(origBoredomChange)
    end
end

local base_eat_start = ISEatFoodAction.start

function ISEatFoodAction:start()
    self.origUnhappyChange = self.item:getUnhappyChangeUnmodified()
    self.origBoredomChange = self.item:getBoredomChangeUnmodified()

    -- Adjust food effects based on traits
    local traits = self.character:getTraits()
    if traits:contains("NotAPickyEater") then
        adjustFoodNotPicky(self.item)
    elseif traits:contains("RefiendPalate") then
        adjustFoodVeryPicky(self.item)
    end

    -- Call original function
    base_eat_start(self)
end

local base_eat_stop = ISEatFoodAction.stop

function ISEatFoodAction:stop()
    -- Call original function
    base_eat_stop(self)

    -- Reset food effects
    self.item:setUnhappyChange(self.origUnhappyChange)
    self.item:setBoredomChange(self.origBoredomChange)
end

local base_eat_perform = ISEatFoodAction.perform

function ISEatFoodAction:perform()
    -- Call original function
    base_eat_perform(self)

    -- Reset food effects
    self.item:setUnhappyChange(self.origUnhappyChange)
    self.item:setBoredomChange(self.origBoredomChange)
end
