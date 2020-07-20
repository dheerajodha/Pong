Paddle = Class{}

function Paddle:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.dy = 0
end

function Paddle:reset(n)
    if n == 1 then
        self.x = 10
        self.y = 30
        self.width = 5
        self.height = 20
    else
        self.x = VIRTUAL_WIDTH-10
        self.y = VIRTUAL_HEIGHT - 30
        self.width = 5
        self.height = 20
    end
end

function Paddle:update(dt)
    if (self.y < 0) then
        self.y = 0
    elseif ((self.y + self.height) > VIRTUAL_HEIGHT) then
        self.y = VIRTUAL_HEIGHT - self.height
    else
        self.y = self.y + self.dy * dt
        self.dy = 0
    end
end

function Paddle:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height) 
end