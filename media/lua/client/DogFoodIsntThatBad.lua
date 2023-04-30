local function adjustFoodNotPicky(item)
    print("adjust not picky")

    item:setUnhappyChange(math.min(item:getUnhappyChange(), 0))
    item:setBoredomChange(math.min(item:getBoredomChange(), 0))
end

local function adjustFoodVeryPicky(item)
    print("adjust very picky")

    local unhappyChange = item:getUnhappyChange()
    local boredomChange = item:getBoredomChange()

    -- Microwaved food is gross
    if item:isCookedInMicrowave() then
        unhappyChange = unhappyChange + 5
        boredomChange = boredomChange + 10
        print("microwaved")
    end

    -- Canned food is gross
    if string.match(item:getDisplayName(), "Canned ") then
        unhappyChange = unhappyChange + 5
        boredomChange = boredomChange + 10
        print("canned")
    end

    -- Dog food is very gross
    if string.match(item:getDisplayName(), "Dog Food") then
        unhappyChange = unhappyChange + 20
        print("dog food")
    end

    -- Tea Bag is very gross
    if item:getDisplayName() == "Tea Bag" then
        unhappyChange = unhappyChange + 20
        print("tea bag")
    end

    -- Dry Ramen Noodles are pretty gross
    if item:getDisplayName() == "Dry Ramen Noodles" then
        unhappyChange = unhappyChange + 10
        boredomChange = boredomChange + 10
        print("dry ramen")
    end

    -- Pickled jars are a little gross
    if string.match(item:getDisplayName(), "Jar of ") then
        unhappyChange = unhappyChange + 10
        boredomChange = boredomChange + 10
        print("jar")
    end

    -- Fried food is a little gross
    if string.match(item:getDisplayName(), "Fried ") then
        unhappyChange = unhappyChange + 10
        boredomChange = boredomChange + 10
        print("fried")
    end

    -- Beer is a little gross
    if item:getFoodType() == "Beer" then
        unhappyChange = unhappyChange + 10
        print("beer")
    end

    -- Wine is very good
    if item:getFoodType() == "Wine" then
        unhappyChange = unhappyChange - 15
        boredomChange = boredomChange - 5
        print("wine")
    end

    -- Vegetables are pretty good
    if item:getFoodType() == "Vegetables" then
        unhappyChange = unhappyChange - 5
        boredomChange = boredomChange - 10
        print("vegetables")
    end

    -- Fruits are pretty good
    if item:getFoodType() == "Fruits" then
        unhappyChange = unhappyChange - 5
        boredomChange = boredomChange - 10
        print("fruits")
    end

    -- Egg is pretty good
    if item:getFoodType() == "Egg" then
        unhappyChange = unhappyChange - 5
        print("egg")
    end

    -- Bread is pretty good
    if item:getFoodType() == "Bread" then
        unhappyChange = unhappyChange - 5
        print("bread")
    end

    -- Processed Cheese food is gross
    if item:getDisplayName() == "Processed Cheese" then
        unhappyChange = unhappyChange + 5
        boredomChange = boredomChange + 10
        print("processed cheese")
    end

    -- Candy is a little gross
    if item:getFoodType() == "Candy" then
        unhappyChange = unhappyChange + 5
        print("candy")
    end

    -- Dead critters are extremely gross
    if string.match(item:getDisplayName(), "Dead ") then
        unhappyChange = unhappyChange + 40
        print("dead")
    end

    -- Increase negative effects by 50%
    if unhappyChange > 0 then
        unhappyChange = unhappyChange * 1.5
    end
    if boredomChange > 0 then
        boredomChange = boredomChange * 1.5
    end

    item:setUnhappyChange(unhappyChange)
    item:setBoredomChange(boredomChange)
end

local base_tooltip_render = ISToolTipInv.render

function ISToolTipInv:render()
    local origUnhappyChange = self.item:getUnhappyChange()
    local origBoredomChange = self.item:getBoredomChange()

    -- Adjust food effects based on traits
    if self.item:getType() == "Food" then
        local traits = getPlayer():getTraits()
        if traits:contains("NotAPickyEater") then
            adjustFoodNotPicky(self.item)
        elseif traits:contains("RefinedPalate") then
            adjustFoodVeryPicky(self.item)
        end
    end

    -- Call original function
    base_tooltip_render(self)

    -- Reset food effects
    self.item:setUnhappyChange(origUnhappyChange)
    self.item:setBoredomChange(origBoredomChange)
end

local base_perform = ISEatFoodAction.perform

function ISEatFoodAction:perform()
    local origUnhappyChange = self.item:getUnhappyChange()
    local origBoredomChange = self.item:getBoredomChange()

    -- Adjust food effects based on traits
    local traits = getPlayer():getTraits()
    if traits:contains("NotAPickyEater") then
        adjustFoodNotPicky(self.item)
        print("negated negative emotional effects")
    elseif traits:contains("RefiendPalate") then
        adjustFoodVeryPicky(self.item)
        print("amplified negative emotional effects")
    end

    -- Call original function
    base_perform(self)

    -- Reset food effects
    self.item:setUnhappyChange(origUnhappyChange)
    self.item:setBoredomChange(origBoredomChange)
end
