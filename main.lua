--[[
    GD50 2018
    Pong Remake

    pong-0
    "The Day-0 Update"

    -- Main Program --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Originally programmed by Atari in 1972. Features two
    paddles, controlled by players, with the goal of getting
    the ball past your opponent's edge. First to 10 points wins.

    This version is built to more closely resemble the NES than
    the original Pong machines or the Atari 2600 in terms of
    resolution, though in widescreen (16:9) so it looks nicer on 
    modern systems.
]]
push = require 'push'
Class = require 'class'
require 'Paddle'
require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

--[[
    Runs when the game first starts up, only once; used to initialize the game.
]]
function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setTitle('Pong')

    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })

    math.randomseed(os.time())

    tinyFont = love.graphics.newFont("font.ttf", 4)
    smallFont = love.graphics.newFont("font.ttf", 8)
    bigFont = love.graphics.newFont("font.ttf", 16)
    scoreFont = love.graphics.newFont("font.ttf", 32)

    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }

    love.graphics.setFont(smallFont)

    -- initialize window with virtual resolution
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })

    player1Score = 0
    player2Score = 0

    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH-10, VIRTUAL_HEIGHT/2, 5, 20)
    ball = Ball(VIRTUAL_WIDTH/2-2, VIRTUAL_HEIGHT/2-2, 4, 4)

    gameState = 'welcome'
    initialPlay = true
    servingPlayer = 1
    winScore = 2

end

function love.update(dt)


    if (gameState == 'play') then

        initialPlay = false

        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.05
            ball.x = ball.x + 5

            --to randomize the direction of ball after collision
            if ball.dy > 0 then
                ball.dy = math.random(10, 150)
            else 
                ball.dy = -math.random(10, 150)
            end

            sounds['paddle_hit']:play()
        end

        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.05
            ball.x = ball.x - 5

            --to randomize the direction of ball after collision
            if ball.dy > 0 then
                ball.dy = math.random(10, 150)
            else 
                ball.dy = -math.random(10, 150)
            end

            sounds['paddle_hit']:play()
        end

        if ball.x < 0 then
            player2Score = player2Score + 1
            servingPlayer = 2
            gameState = 'serve'
            ball:reset()
            sounds['score']:play()
        end

        if ball.x > VIRTUAL_WIDTH then
            player1Score = player1Score + 1
            servingPlayer = 1
            gameState = 'serve'
            ball:reset()
            sounds['score']:play()
        end

        if player1Score == winScore then
            won = true
            p = 1
            player1Score = 0
            player2Score = 0
            gameState = 'result'
        elseif player2Score == winScore then
            won = true
            p = 2
            player1Score = 0
            player2Score = 0
            gameState = 'result'
        else
            p = 0
            won = false
        end

        if(ball.y <= 0) then
            ball.dy = -ball.dy
            ball.y = 0
            sounds['wall_hit']:play()
        end

        if(ball.y >= VIRTUAL_HEIGHT - 7) then
            ball.dy = -ball.dy
            ball.y = VIRTUAL_HEIGHT - ball.height - 3
            sounds['wall_hit']:play()
        end
        
        ball:update(dt)

    elseif gameState == 'serve' then

        player2.y = VIRTUAL_HEIGHT / 2

        if initialPlay == true then
            player1Score = 0
            player2Score = 0
            ball.dx = math.random(50, 150)
            ball.dy = math.random(-50, 50)
        end

        if servingPlayer == 1 then
            ball.dx = math.random(50, 150)
            ball.dy = math.random(-50, 50)
        else
            ball.dx = -math.random(50, 150)
            ball.dy = math.random(-50, 50)
        end

    elseif gameState == 'welcome' then
        initialPlay = true
    end
    
    --Player 1's position update
    if love.keyboard.isDown('w') then        
        player1.dy = -PADDLE_SPEED
    end

    if love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    end

    if gameState == 'play' then
        --Player 2's position update
        if ball.dy > 0 then
            player2.dy = ball.dy + math.random(-1, 1)
        else
            player2.dy = ball.dy + math.random(-1, 1)
        end
    end

    player1:update(dt)
    player2:update(dt)  
end


function love.keypressed(key)
    -- keys can be accessed by string name
    if key == 'escape' then
        -- function LÖVE gives us to terminate application
        love.event.quit()
    end

    if key == 'enter' or key == 'return' then
        if gameState == 'start' then
           gameState = 'serve'
           ball:reset()
        elseif gameState == 'play' then
            if won == false then
                ball:reset()
            end
        elseif gameState == 'welcome' then
            gameState = 'start'
            ball:reset()
        elseif gameState == 'serve' then
            gameState = 'play'
        end
    end

    if key == 'y' or key == 'Y' then
        gameState = 'start'
        ball:reset()
    elseif key == 'n' or key == 'N' then
        love.event.quit()
    end
end

--[[
    Called after update by LÖVE2D, used to draw anything to the screen, updated or otherwise.
]]
function love.draw()
    push:apply('start')
    love.graphics.clear(40, 45, 52, 255)


    if gameState == 'welcome' then
        love.graphics.setFont(scoreFont)
        love.graphics.printf("Welcome to PONG !", 0, 60, VIRTUAL_WIDTH,'center')

        love.graphics.setFont(smallFont)
        love.graphics.printf("Press ENTER to continue", 0, 150, VIRTUAL_WIDTH,'center')

        love.graphics.setFont(smallFont)
        love.graphics.printf("< Created By : Dheeraj Singh Jodha >", 0, 230, VIRTUAL_WIDTH, 'center')

    elseif gameState == 'start' then
        love.graphics.setFont(bigFont)
        love.graphics.printf("Press ENTER to Play", 0, 20, VIRTUAL_WIDTH,'center')
        player1:render()
        player2:render()
        ball:render()

    elseif gameState == 'serve' then
        if initialPlay == true then
            love.graphics.setFont(bigFont)
            love.graphics.printf("Player 1's serve", 0, 20, VIRTUAL_WIDTH, 'center')  
        else
            love.graphics.setFont(bigFont)
            love.graphics.printf("Player " .. tostring(servingPlayer) .. "'s serve", 0, 20, VIRTUAL_WIDTH, 'center')  
        end

        love.graphics.setFont(smallFont)
        love.graphics.printf("Press ENTER to start", 0, 50, VIRTUAL_WIDTH,'center')

        love.graphics.setFont(scoreFont)
        love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH/2 - 50, VIRTUAL_HEIGHT/3)
        love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH/2 + 30, VIRTUAL_HEIGHT/3)

        player1:render()
        player2:render()
        ball:render()

    elseif gameState == 'play' then
        love.graphics.setFont(scoreFont)
        love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH/2 - 50, VIRTUAL_HEIGHT/3)
        love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH/2 + 30, VIRTUAL_HEIGHT/3)

        player1:render()
        player2:render()
        ball:render()
    
    elseif gameState == 'result' then
        love.graphics.setFont(scoreFont)
        love.graphics.printf("Player " .. tostring(p) .." won", 0, 70, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf("DO you want to play again?", 0, 130, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Yes : Press 'y' or 'Y'", 0, 150, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("No : Press 'n' or 'N'", 0, 165, VIRTUAL_WIDTH, 'center')

    end

    push:apply('end')

end 