local physics = require("physics")
local storyboard = require("storyboard")

physics.start()
physics.setDrawMode("normal") -- debug, normal, hybrid
physics.setGravity(0, 0)

local scene = storyboard.newScene()

--local constants
local BACKGROUND_LOOP_TIME = 30000
local mainBirdYLocation = _H * 0.85
local fallingDurationMin = 1000
local fallingDurationMax = 3000
local shooterAnimDurationMin = 2000
local shooterAnimDurationMax = 5000
local spawnTimerMin = 100
local spawnTimerMax = 1000
local count = 0
--local variable
local timerObject
local bgImage
local bgTransitionObject
local mainPlayerIcon
local isCrashedFlag = false
local globalGroupObject
local shootingImageArray

--local methods
local startBackGroundAnimation
local stopBackGroundAnimation
local setBirdIconOnTouchListener
local removeBirdIconOnTouchListener
local objectReachedBottom
local startGameTimer
local stopGameTimer
local spawnNewObject
local pauseGame
local resumeGame
local moveShooterRigth
local moveShooterLeft
local onCollisionDone
local gotoMenuScreen

local soundMissed = audio.loadSound("audio/missed.mp3")
local soundKilled = audio.loadSound("audio/lost.mp3")

function pauseGame()
    if (timerObject) then
        transition.pause()
    end
end

function resumeGame()
    if (timerObject) then
        transition.resume()
    end
end

function objectReachedBottom(event)
    local object = event.target
    count = count + 1
    audio.play(soundMissed)
    --    physics.removeBody(object)
    display.remove(object)
end

function spawnNewObject()
    local value = math.random(#FALL_IMAGE)
    local fallingDuration = math.random(fallingDurationMin, fallingDurationMax)
    local fallingImage = display.newImage(globalGroupObject, FALL_IMAGE[value])
    fallingImage.x = shootingImageArray[value].x
    shootingImageArray[value]:setSequence("shoot")
    shootingImageArray[value]:play()
    fallingImage.y = FALLING_OBJECT_HEIGHT
    physics.addBody(fallingImage, { density = 1.0, friction = 0.3, bounce = 0, isSensor = true })
    fallingImage.tans = transition.to(fallingImage, { y = _H + FALLING_OBJECT_HEIGHT, time = fallingDuration, onComplete = objectReachedBottom })
end

function moveShooterRigth(index)

    transition.to(shootingImageArray[index], {
        x = _W - SHOOT_OBJECT_WIDTH,
        time = math.random(shooterAnimDurationMin, shooterAnimDurationMax),
        onComplete = function(obj)
            moveShooterLeft(index)
        end
    })
end

function moveShooterLeft(index)
    transition.to(shootingImageArray[index], {
        x = SHOOT_OBJECT_WIDTH,
        time = math.random(shooterAnimDurationMin, shooterAnimDurationMax),
        onComplete = function(obj)
            moveShooterRigth(index)
        end
    })
end

function startGameTimer()
    local delay = math.random(spawnTimerMin, spawnTimerMax)
    timerObject = timer.performWithDelay(delay, spawnNewObject, -1)
    transition.to(shootingImageArray[1], {
        x = SHOOT_OBJECT_WIDTH,
        time = math.random(0, shooterAnimDurationMin),
        onComplete = function(obj)
            moveShooterRigth(1)
        end
    })
    transition.to(shootingImageArray[2], {
        x = _W - SHOOT_OBJECT_WIDTH,
        time = math.random(0, shooterAnimDurationMin),
        onComplete = function(obj)
            moveShooterLeft(2)
        end
    })
    transition.to(shootingImageArray[3], {
        x = SHOOT_OBJECT_WIDTH,
        time = math.random(0, shooterAnimDurationMax),
        onComplete = function(obj)
            moveShooterRigth(3)
        end
    })
    transition.to(shootingImageArray[4], {
        x = _W - SHOOT_OBJECT_WIDTH,
        time = math.random(0, shooterAnimDurationMax),
        onComplete = function(obj)
            moveShooterLeft(4)
        end
    })
    --    transition.to(shootingImageArray[5], {
    --        x = FALLING_OBJECT_WIDTH,
    --        time = math.random(shooterAnimDurationMin,shooterAnimDurationMax),
    --        onComplete = function(obj)
    --            moveShooterRigth(5)
    --        end
    --    })
    --    transition.to(shootingImageArray[6], {
    --        x = _W - FALLING_OBJECT_WIDTH,
    --        time = math.random(shooterAnimDurationMin,shooterAnimDurationMax),
    --        onComplete = function(obj)
    --            moveShooterLeft(6)
    --        end
    --    })
end

function gotoMenuScreen()
    local options = { effect = "fade", time = 300 }
    storyboard.gotoScene("MenuScreen", options)
end

function stopGameTimer()
    timer.cancel(timerObject)
    display.remove(mainPlayerIcon)
    transition.cancel()
    timer.performWithDelay(1000, gotoMenuScreen, 1)
end

local function whenTouched(event)
    if (mainPlayerIcon.x) then
        if (event.phase == "moved") then
            if (event.x > (mainPlayerIcon.x - PLAYER_IMAGE_W) and event.x < (mainPlayerIcon.x + PLAYER_IMAGE_W)) then
                if (event.x > (PLAYER_IMAGE_W / 1.5) and event.x < (_W - (PLAYER_IMAGE_W / 1.5))) then
                    mainPlayerIcon.x = event.x
                end
            end
        end
    end
end

function setBirdIconOnTouchListener()
    mainPlayerIcon.y = mainBirdYLocation;
    bgImage:addEventListener("touch", whenTouched)
end

function removeBirdIconOnTouchListener()
    bgImage:removeEventListener("touch", whenTouched)
end

function startBackGroundAnimation()
    if (bgImage) then
        bgImage.x = 0
        bgImage.y = 0
        bgTransitionObject = transition.to(bgImage, { y = -480, time = BACKGROUND_LOOP_TIME, onComplete = startBackGroundAnimation })
    end
end

function stopBackGroundAnimation()
    if (bgTransitionObject) then
        transition.cancel(bgTransitionObject)
    end
end

function onCollisionDone(event)
    if (event.phase == "began") then
        if (event.object1.tagName or event.object2.tagName) then
            audio.play(soundKilled)
            stopGameTimer()
        end
    end
end

function scene:createScene(event)
    local group = self.view
    globalGroupObject = group
    bgImage = display.newImageRect(group, BG_IMAGE, _W, 960)
    bgImage.anchorX = 0
    bgImage.anchorY = 0
    mainPlayerIcon = display.newImageRect(group, PLAYER_IMAGE, PLAYER_IMAGE_W, PLAYER_IMAGE_H)
    mainPlayerIcon.x = centerX;
    mainPlayerIcon.y = mainBirdYLocation;
    mainPlayerIcon.tagName = "player"
    local playerShape = { 11, -36, 14, -16, 14, -8, -2, 12, -17, 2, -15, -14, -16, -18, -11, -18, 18, 4, 6, 12, -2, 12, 14, -8 }
    physics.addBody(mainPlayerIcon, { density = 1.0, friction = 0.3, bounce = 0, isSensor = true, shape = playerShape })
    --init top shooting images
    local spriteDataShoot1 = { width = 80, height = 40, numFrames = 8 }
    local sequenceShoot1 = {
        { name = "shoot", start = 1, count = 8, time = 500, loopCount = 1 },
        { name = "move", start = 1, count = 1 }
    };

    local imageSheetShoot1 = graphics.newImageSheet("images/red_sprite_sheet.png", spriteDataShoot1)
    local shoot1 = display.newSprite(group, imageSheetShoot1, sequenceShoot1)
    shoot1.x = math.random(SHOOT_OBJECT_WIDTH, _W - SHOOT_OBJECT_WIDTH)
    shoot1.y = SHOOT_OBJECT_HEIGHT + 5
    shoot1:setSequence("move")
    shoot1:play()
    local imageSheetShoot2 = graphics.newImageSheet("images/blue_sprite_sheet.png", spriteDataShoot1)
    local shoot2 = display.newSprite(group, imageSheetShoot2, sequenceShoot1)
    shoot2.x = math.random(SHOOT_OBJECT_WIDTH, _W - SHOOT_OBJECT_WIDTH)
    shoot2.y = SHOOT_OBJECT_HEIGHT + 5
    shoot2:setSequence("move")
    shoot2:play()
    local imageSheetShoot3 = graphics.newImageSheet("images/pink_sprite_sheet.png", spriteDataShoot1)
    local shoot3 = display.newSprite(group, imageSheetShoot3, sequenceShoot1)
    shoot3.x = math.random(SHOOT_OBJECT_WIDTH, _W - SHOOT_OBJECT_WIDTH)
    shoot3.y = SHOOT_OBJECT_HEIGHT + 5
    shoot3:setSequence("move")
    shoot3:play()
    local imageSheetShoot4 = graphics.newImageSheet("images/grey_sprite_sheet.png", spriteDataShoot1)
    local shoot4 = display.newSprite(group, imageSheetShoot4, sequenceShoot1)
    shoot4.x = math.random(SHOOT_OBJECT_WIDTH, _W - SHOOT_OBJECT_WIDTH)
    shoot4.y = SHOOT_OBJECT_HEIGHT + 5
    shoot4:setSequence("move")
    shoot4:play()
    --    local shoot5 = display.newImageRect(group, SHOOT_IMAGE[5], FALLING_OBJECT_WIDTH * 2, FALLING_OBJECT_HEIGHT * 2)
    --    shoot5.x = math.random(FALLING_OBJECT_WIDTH, _W - FALLING_OBJECT_WIDTH)
    --    shoot5.y = FALLING_OBJECT_HEIGHT
    --    local shoot6 = display.newImageRect(group, SHOOT_IMAGE[6], FALLING_OBJECT_WIDTH * 2, FALLING_OBJECT_HEIGHT * 2)
    --    shoot6.x = math.random(FALLING_OBJECT_WIDTH, _W - FALLING_OBJECT_WIDTH)
    --    shoot6.y = FALLING_OBJECT_HEIGHT

    shootingImageArray = {
        shoot1, shoot2,
        shoot3, shoot4
    }
end

function scene:willEnterScene(event)
    local group = self.view
end

function scene:enterScene(event)
    local group = self.view
    startBackGroundAnimation()
    setBirdIconOnTouchListener()
    startGameTimer(1000)
    Runtime:addEventListener("collision", onCollisionDone)
end

function scene:exitScene(event)
    local group = self.view
    Runtime:removeEventListener("collision", onCollisionDone)
end

function scene:didExitScene(event)
    local group = self.view
    storyboard.removeScene("GameScreen");
end

function scene:destroyScene(event)
    local group = self.view
end

function scene:overlayBegan(event)
    local group = self.view
end

function scene:overlayEnded(event)
    local group = self.view
end

scene:addEventListener("createScene", scene)
scene:addEventListener("willEnterScene", scene)
scene:addEventListener("enterScene", scene)
scene:addEventListener("exitScene", scene)
scene:addEventListener("didExitScene", scene)
scene:addEventListener("destroyScene", scene)
scene:addEventListener("overlayBegan", scene)
scene:addEventListener("overlayEnded", scene)

return scene

