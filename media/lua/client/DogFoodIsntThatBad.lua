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

    -- Candy is disgusting
    if item:getFoodType() == "Candy" then
        unhappyChange = unhappyChange + 10
    end

    -- Sugar is disgusting
    if item:getFoodType() == "Sugar" then
        boredomChange = boredomChange + 10
    end

    -- Appreciation of wine
    if item:getFoodType() == "Wine" then
        unhappyChange = unhappyChange - 10
    end

    -- Specific foods are gross
    local grossFoods = {
        { "^(BakingSoda|GravyMix|PancakeMix)$",                 20 },
        { "^(Rice)?Vinegar$",                                   20 },
        { "^(Ramen|Cereal|Butter|Corndog|Macandcheese|Smore)$", 10 },
        { "^(Chicken|Fish|Oysters|Tofu)Fried$",                 10 },
        { "^Crisps",                                            5 },
        { "^(Processedcheese|RefriedBeans)$",                   5 }
    }
    for _, food in ipairs(grossFoods) do
        if item:getName():find(food[1]) then
            unhappyChange = unhappyChange + food[2]
        end
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

local base_perform = ISEatFoodAction.perform

function ISEatFoodAction:perform()
    local origUnhappyChange = self.item:getUnhappyChangeUnmodified()
    local origBoredomChange = self.item:getBoredomChangeUnmodified()

    -- Adjust food effects based on traits
    local traits = getPlayer():getTraits()
    if traits:contains("NotAPickyEater") then
        adjustFoodNotPicky(self.item)
    elseif traits:contains("RefiendPalate") then
        adjustFoodVeryPicky(self.item)
    end

    -- Call original function
    base_perform(self)

    -- Reset food effects
    self.item:setUnhappyChange(origUnhappyChange)
    self.item:setBoredomChange(origBoredomChange)
end
