_W=display.contentWidth
_H=display.contentHeight

centerX = _W/2
centerY = _H/2

FALLING_OBJECT_WIDTH = 13/2
FALLING_OBJECT_HEIGHT = 60/2

SHOOT_OBJECT_WIDTH = 80/2
SHOOT_OBJECT_HEIGHT = 40/2

FALL_IMAGE = {
  "images/arrow_1.png","images/arrow_2.png",
  "images/arrow_3.png","images/arrow_4.png"
};


SHOOT_IMAGE = {
  "images/bow_1.png","images/bow_2.png",
  "images/bow_3.png","images/bow_4.png"
};

BG_IMAGE = "images/blue_sky.png"

PLAYER_IMAGE_W = 40
PLAYER_IMAGE_H = 74
PLAYER_IMAGE = "images/balloon_image.png"

local storyboard = require ( "storyboard" )
storyboard.purgeOnSceneChange = true

--local GGData=require ( "GGData" )

--databaseBox=GGData:new("ChidiaUddi")

display.setStatusBar ( display.HiddenStatusBar )

storyboard.gotoScene("MenuScreen")
