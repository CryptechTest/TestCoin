Block = {}
function Block:new(index, previousHash, timestamp, data, minerAddress)
    local block = {
        index = index,
        previousHash = previousHash,
        timestamp = timestamp,
        data = data,
        minerAddress = minerAddress,
        nonce = 0,
        hash = ""
    }
    setmetatable(block, self)
    self.__index = self
    return block
end

Chain = {}
function Chain:new()
    local Chain = {
        chain = {},
        difficulty = 2,
        pendingTransactions = {},
        miningReward = 100,
        stakingReward = 10,
        stakeThreshold = 100,
        stakers = {},
        testCoinInventory = {}
    }
    setmetatable(Chain, self)
    self.__index = self
    return Chain
end

-- Define Chain methods
function Chain:getLatestBlock()
    return self.chain[#self.chain]
end

function Chain:minePendingTransactions(minerAddress)
    local block = Block:new(
        #self.chain + 1,
        self:getLatestBlock().hash,
        os.time(),
        self.pendingTransactions,
        minerAddress
    )
    while true do
        block.nonce = block.nonce + 1
        block.hash = sha256(block.index ..
            block.previousHash .. block.timestamp .. block.nonce .. block.data .. block.minerAddress)
        if string.sub(block.hash, 1, self.difficulty) == string.rep("0", self.difficulty) then
            table.insert(self.chain, block)
            break
        end
    end
    self.pendingTransactions = {}
    table.insert(self.testCoinInventory, { address = minerAddress, amount = self.miningReward })
    self:checkStakers(minerAddress)
end

function Chain:addTransaction(senderAddress, recipientAddress, amount)
    table.insert(self.pendingTransactions, { sender = senderAddress, recipient = recipientAddress, amount = amount })
end

function Chain:addStaker(address, amount)
    table.insert(self.stakers, { address = address, amount = amount, maturity = 0 })
end

function Chain:updateStakers()
    for i, staker in ipairs(self.stakers) do
        staker.maturity = staker.maturity + staker.amount
    end
end

function Chain:checkStakers(minerAddress)
    local totalStakingWeight = 0
    for i, staker in ipairs(self.stakers) do
        totalStakingWeight = totalStakingWeight + staker.amount
    end
    if totalStakingWeight >= self.stakeThreshold then
        local stakingTickets = {}
        for i, staker in ipairs(self.stakers) do
            for j = 1, staker.amount do
                table.insert(stakingTickets, staker.address)
            end
        end
        local winningTicket = stakingTickets[math.random(#stakingTickets)]
        for i, inventoryItem in ipairs(self.testCoinInventory) do
            if inventoryItem.address == winningTicket then
                inventoryItem.amount = inventoryItem.amount + self.stakingReward
            end
        end
        self:updateStakers()
    end
end
