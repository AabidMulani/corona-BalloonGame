local storyboard = require("storyboard")
local scene = storyboard.newScene()

function scene:createScene(event)
    local group = self.view
end

function scene:willEnterScene(event)
    local group = self.view
end

function scene:enterScene(event)
    local group = self.view
    local options = {effect = "fade",time=300 }
    local backGround = display.newImageRect(group, BG_IMAGE, _W, 960)
    backGround.anchorX = 0
    backGround.anchorY = 0

    local function onShareTap(event)
        print("Share Tapped")
    end
    local shareButton = display.newImage(group,"images/share_icon.png")
    shareButton.x = centerX
    shareButton.y = _H * 0.4
    shareButton:addEventListener("tap",onShareTap)

    local function onPlayTap(event)
        storyboard.gotoScene("GameScreen",options)
    end
    local playButton = display.newImage(group,"images/start_icon.png")
    playButton.x = centerX
    playButton.y = _H * 0.7
    playButton:addEventListener("tap",onPlayTap)

end

function scene:exitScene(event)
    local group = self.view
end

function scene:didExitScene(event)
    local group = self.view
    storyboard.removeScene("MenuScreen");
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
