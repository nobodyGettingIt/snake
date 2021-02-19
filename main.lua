local Block = {}
local Apple = {}
local TailBlock = {}

local mapSize = 40

local isLoser = false

local toTop = 1
local toRight = 2
local toBottom = 3
local toLeft = 4


local points = 0


function Block:new(px, py)
    local private = {}
    
        private.px = px
        private.py = py

        private.sx = 10
        private.sy = 10

        private.queueForSideToMove = toBottom
        private.sideToMove = toBottom

    local public = {}
        
        
        function public:draw()
            love.graphics.setColor(255, 0, 0)
            love.graphics.rectangle("fill", private.px*10, private.py*10, private.sx, private.sy)
        end
        

        function public:getSideToMove()
            return private.sideToMove
        end

        function public:changeSideToMove(side)
            if private.sideToMove ~= side-2 and private.sideToMove ~= side+2 then
                private.queueForSideToMove = side
            end
        end

        function public:move()
            private.sideToMove = private.queueForSideToMove            

            if private.sideToMove == toBottom then
                private.py = private.py + 1
            elseif private.sideToMove == toTop then
                private.py = private.py - 1
            elseif private.sideToMove == toLeft then 
                private.px = private.px - 1
            elseif private.sideToMove == toRight then
                private.px = private.px + 1
            end

            if private.px < 0 then 
                private.px = mapSize
            elseif private.px > mapSize then 
                private.px = 0
            end 

            if private.py < 0 then 
                private.py = mapSize
            elseif private.py > mapSize then 
                private.py = 0
            end 
            
        end

        function public:checkTouchWithTail(tail)
            local tailBlocks = tail:getBlocks()
            for k, v in pairs(tailBlocks) do
                if public:checkTouch(v) then
                    isLoser = true
                end
            end
        end

        function public:checkTouch(object)
            local ox, oy = object.getPos()
            
            if private.px == ox and private.py == oy then
                return true
            end


            return false

        end

        function public:getPos()
            return private.px, private.py
        end


    setmetatable(public, self)
    self.__index = self; return public 

end


function Apple:new(px, py)
    local private = {}

        private.px = px
        private.py = py

        private.sx = 10
        private.sy = 10


    local public = {}

        function public:draw()
            love.graphics.setColor(0, 255, 0)
            love.graphics.rectangle("fill", private.px*10, private.py*10, private.sx, private.sy)
        end


        function public:getPos()
            return private.px, private.py
        end


    setmetatable(public, self)
    self.__index = self; return public
end


function TailBlock:new(px,py, target)
    
    local private = {}
        
        private.px = px
        private.py = py

        private.target = target

        private.sx = 10
        private.sy = 10

    local public = {}

        function public:draw()
            love.graphics.setColor(0, 0, 255)
            love.graphics.rectangle("fill", private.px*10, private.py*10, private.sx, private.sy)
        end

        function public:getPos()
            return private.px, private.py
        end
        
        function public:move()
            private.px, private.py = private.target:getPos()
        end

    setmetatable(public, self)
    self.__index = self; return public
end


local sumdt = 0
local b = Block:new(1, 1)   
local apple = Apple:new(10, 10)

local Tail = {}

function Tail:new(target)
    local private = {}

        private.blocks = {TailBlock:new(0,1, target)}
        private.blocks[#private.blocks + 1] = TailBlock:new(0,0, private.blocks[#private.blocks]) 

    
    local public = {}

        function public:draw()
            for k, v in pairs(private.blocks) do
                v:draw()
            end
        end

        function public:getBlocks()
            return private.blocks
        end

        function public:move()
            for i = #private.blocks, 1, -1  do
                local v = private.blocks[i]
                v:move()
            end
        end

        function public:addNew()
            local target = private.blocks[#private.blocks]
            local px, py = target:getPos()
            private.blocks[#private.blocks + 1] = TailBlock:new(px, py, target)
        end

    setmetatable(public, self)
    self.__index = self; return public
end


local t = Tail:new(b)

canvas = love.graphics.newCanvas(800, 600)

function love.draw()

    if not isLoser then
        love.graphics.setCanvas(canvas)
        love.graphics.clear()
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(tostring(points), 0, 0)
        t:draw()
        b:draw()  
        apple:draw()

        love.graphics.setColor(255, 0, 255)
        love.graphics.rectangle("fill", 0, mapSize*10+10, mapSize*10+20, 10)
        love.graphics.rectangle("fill", mapSize*10+10, 0, 10, mapSize*10+10)
        love.graphics.setColor(255, 255, 255)
        
        love.graphics.setCanvas()

        love.graphics.draw(canvas)
    else
        love.graphics.setColor(0, 0, 0)
        love.graphics.print("U lose, your score is " .. tostring(points) .. "\nPress any button", 0, 0)
    end
end


function love.load()

    love.graphics.setColor(0,0,0)
    love.graphics.setBackgroundColor(255,255,255)

end

function love.update(dt)
    if not isLoser then
        sumdt = sumdt + dt
        
        if sumdt >= 0.1 then

            t:move()
            b:move()
            
            b:checkTouchWithTail(t)

            if b:checkTouch(apple) then
                apple = Apple:new(math.random(mapSize), math.random(mapSize))
                t:addNew()
                points = points + 1
            end

            sumdt = 0
        end
    end
    
end


local control = {
                w = (function() b:changeSideToMove(toTop) end); 
                s = (function() b:changeSideToMove(toBottom) end);
                d = (function() b:changeSideToMove(toRight) end);
                a = (function() b:changeSideToMove(toLeft) end);
}

function love.keypressed(key)
    if not isLoser then
        local f = control[key]
        if f then
            f()
        end
    else
        b = Block:new(1, 1)
        t = Tail:new(b)
        points = 0
        isLoser = false
    end
end
