-------------------------------------------------------------------------------
-- Title: Mik's Scrolling Battle Text Default Animation Styles
-- Author: Mikord
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Imports.
-------------------------------------------------------------------------------

-- Local references to various functions for faster access.
local math_floor = math.floor
local math_ceil = math.ceil
local math_random = math.random
local math_max = math.max
local math_abs = math.abs
local math_sqrt = math.sqrt


-------------------------------------------------------------------------------
-- Private constants.
-------------------------------------------------------------------------------

-- Sticky animation style constants.
local POW_FADE_IN_TIME = 0.17
local POW_DISPLAY_TIME = 1.5
local POW_FADE_OUT_TIME = 0.5
local POW_TEXT_DELTA = 0.7
local JIGGLE_DELAY_TIME = 0.05

-- Static animation style constants.
local STATIC_DISPLAY_TIME = 3.15

-- Angled animation style constants.
local ANGLED_HORIZONTAL_PHASE_TIME = 1
local ANGLED_FADE_OUT_TIME = 0.5
local ANGLED_WIDTH_PERCENT = 0.85


-- Default movement speed. (260 pixels every 3 seconds)
local MOVEMENT_SPEED = (3 / 260)

-- Minimum amount of space allowed between two strings.
local MIN_VERTICAL_SPACING = 8
local MIN_HORIZONTAL_SPACING = 10


-------------------------------------------------------------------------------
-- Private variables.
-------------------------------------------------------------------------------

-- Prevent tainting global _.
local _

-- Values used for previous events.
local lastAngledFinishPositionY = {}
local lastAngledDirection = {}
local lastHorizontalPositionY = {}
local lastHorizontalDirection = {}



-------------------------------------------------------------------------------
-- Pow Sticky functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Animates the passed display event using using the normal pow style.
-- ****************************************************************************
local function AnimatePowNormal(displayEvent, animationProgress)
 local fadeInPercent = POW_FADE_IN_TIME / displayEvent.scrollTime
 
 -- Scale the text height.
 if (animationProgress <= fadeInPercent) then
  displayEvent.fontString:SetTextHeight(displayEvent.fontSize * (1 + ((1 - animationProgress / fadeInPercent) * POW_TEXT_DELTA)))

 -- Reset the font properties to normal.
 else
  local fontPath, _, fontOutline = displayEvent.fontString:GetFont()
  displayEvent.fontString:SetFont(fontPath, displayEvent.fontSize, fontOutline)
 end
end


-- ****************************************************************************
-- Animates the passed display event using using the jiggle pow style.
-- ****************************************************************************
local function AnimatePowJiggle(displayEvent, animationProgress)
 local fadeInPercent = POW_FADE_IN_TIME / displayEvent.scrollTime

 -- Scale the text height.
 if (animationProgress <= fadeInPercent) then
  displayEvent.fontString:SetTextHeight(displayEvent.fontSize * (1 + ((1 - animationProgress / fadeInPercent) * POW_TEXT_DELTA)))
  return

 -- Jiggle the text around and reset the font properties to normal.
 elseif (animationProgress <= displayEvent.fadePercent) then
  local elapsedTime = displayEvent.elapsedTime
  if (elapsedTime - displayEvent.timeLastJiggled > JIGGLE_DELAY_TIME) then
   displayEvent.positionX = displayEvent.originalPositionX + math_random(-1, 1)
   displayEvent.positionY = displayEvent.originalPositionY + math_random(-1, 1)
   displayEvent.timeLastJiggled = elapsedTime
  end

  local fontPath, _, fontOutline = displayEvent.fontString:GetFont()
  displayEvent.fontString:SetFont(fontPath, displayEvent.fontSize, fontOutline)
 end
end


-- ****************************************************************************
-- Initialize the passed display event and reposition the ones that are
-- currently animating in the scroll area to prevent overlaps.
-- ****************************************************************************
local function InitPow(newDisplayEvent, activeDisplayEvents, direction, behavior)
 -- Calculate how long the animation should take by only scaling the display period and
 -- set the percent to start the fade out.
 local animationSpeed = newDisplayEvent.animationSpeed
 local scrollTime = POW_FADE_IN_TIME + (POW_DISPLAY_TIME / animationSpeed) + POW_FADE_OUT_TIME
 newDisplayEvent.scrollTime = scrollTime * animationSpeed
 newDisplayEvent.fadePercent = (POW_FADE_IN_TIME + (POW_DISPLAY_TIME / animationSpeed)) / scrollTime
 

 -- Choose the correct animation function.
 newDisplayEvent.animationHandler = (behavior == "Jiggle") and AnimatePowJiggle or AnimatePowNormal
 
 -- Set the new event's starting position.
 local anchorPoint = newDisplayEvent.anchorPoint
 if (anchorPoint == "BOTTOMLEFT") then
  newDisplayEvent.positionX = 0
 elseif (anchorPoint == "BOTTOM") then
  newDisplayEvent.positionX = newDisplayEvent.scrollWidth / 2
 elseif (anchorPoint == "BOTTOMRIGHT") then
  newDisplayEvent.positionX = newDisplayEvent.scrollWidth
 end
 newDisplayEvent.positionY = newDisplayEvent.scrollHeight / 2

 -- Save the original x and y positions for calculating the jiggle effect.
 newDisplayEvent.originalPositionX = newDisplayEvent.positionX
 newDisplayEvent.originalPositionY = newDisplayEvent.positionY
 newDisplayEvent.timeLastJiggled = 0
 
 -- Get the number of sticky display events that are currently animating.
 local numActiveAnimations = #activeDisplayEvents

 -- Exit if there is no need to check for collisions. 
 if (numActiveAnimations == 0) then return end

 
 -- Check if the text is scrolling down.
 if (direction == "Down") then
  -- Get the middle sticky.
  local middleSticky = math_floor((numActiveAnimations + 2) / 2)

  -- Set the middle sticky to the center of the scroll area.
  activeDisplayEvents[middleSticky].originalPositionY = newDisplayEvent.scrollHeight / 2
  activeDisplayEvents[middleSticky].positionY = activeDisplayEvents[middleSticky].originalPositionY
   
  -- Loop backwards from the middle sticky and move the animating display events so they don't collide.
  for x = middleSticky - 1, 1, -1 do
   activeDisplayEvents[x].originalPositionY = activeDisplayEvents[x+1].originalPositionY - activeDisplayEvents[x].fontSize - MIN_VERTICAL_SPACING
   activeDisplayEvents[x].positionY = activeDisplayEvents[x].originalPositionY
  end

  -- Loop forwards from the middle sticky and move the animating display events so they don't collide.
  for x = middleSticky + 1, numActiveAnimations do
   activeDisplayEvents[x].originalPositionY = activeDisplayEvents[x-1].originalPositionY + activeDisplayEvents[x-1].fontSize + MIN_VERTICAL_SPACING
   activeDisplayEvents[x].positionY = activeDisplayEvents[x].originalPositionY
  end

  -- Move the new display event so it doesn't collide.
  newDisplayEvent.originalPositionY = activeDisplayEvents[numActiveAnimations].originalPositionY + activeDisplayEvents[numActiveAnimations].fontSize + MIN_VERTICAL_SPACING
  newDisplayEvent.positionY = newDisplayEvent.originalPositionY

 -- Text is scrolling up.
 else
  -- Get the middle sticky.
  local middleSticky = math_ceil(numActiveAnimations / 2)

  -- Set the middle sticky to the center of the scroll area.
  activeDisplayEvents[middleSticky].originalPositionY = newDisplayEvent.scrollHeight / 2
  activeDisplayEvents[middleSticky].positionY = activeDisplayEvents[middleSticky].originalPositionY

  -- Loop backwards from the middle sticky and move the animating display events so they don't collide.
  for x = middleSticky - 1, 1, -1 do
   activeDisplayEvents[x].originalPositionY = activeDisplayEvents[x+1].originalPositionY + activeDisplayEvents[x+1].fontSize + MIN_VERTICAL_SPACING
   activeDisplayEvents[x].positionY = activeDisplayEvents[x].originalPositionY
  end

  -- Loop forwards from the middle sticky and move the animating display events so they don't collide.
  for x = middleSticky + 1, numActiveAnimations do
   activeDisplayEvents[x].originalPositionY = activeDisplayEvents[x-1].originalPositionY - activeDisplayEvents[x].fontSize - MIN_VERTICAL_SPACING
   activeDisplayEvents[x].positionY = activeDisplayEvents[x].originalPositionY
  end

  -- Move the new display event so it doesn't collide.
  newDisplayEvent.originalPositionY = activeDisplayEvents[numActiveAnimations].originalPositionY - activeDisplayEvents[numActiveAnimations].fontSize - MIN_VERTICAL_SPACING
  newDisplayEvent.positionY = newDisplayEvent.originalPositionY
 end
end


-------------------------------------------------------------------------------
-- Angled scroll functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Scrolls the passed display event angled to the left and upwards.
-- ****************************************************************************
local function ScrollLeftAngledUp(displayEvent, animationProgress)
 local linePhasePercent = displayEvent.linePhasePercent
 local horizontalPhasePercent = displayEvent.horizontalPhasePercent

 -- Move the event in an angled line.
 if (animationProgress <= linePhasePercent) then
  -- Calculate how far along the current phase is and set the x and y positions accordingly.
  local phaseProgress = animationProgress / linePhasePercent
  displayEvent.positionX = displayEvent.scrollWidth - (displayEvent.startPositionX + (displayEvent.finishPositionX - displayEvent.startPositionX) * phaseProgress)
  displayEvent.positionY = displayEvent.finishPositionY * phaseProgress

 -- Wait a bit at the finish position.
 elseif (animationProgress <= horizontalPhasePercent) then
  displayEvent.positionX = displayEvent.scrollWidth - displayEvent.finishPositionX
  displayEvent.positionY = displayEvent.finishPositionY

 -- Move the event horizontally to outer edge.
 else
  -- Calculate how far along the current phase is and set the x and y positions accordingly.
  local phaseProgress = (animationProgress - horizontalPhasePercent)  / (1 - horizontalPhasePercent)
  displayEvent.positionX = displayEvent.scrollWidth - (displayEvent.finishPositionX + ((displayEvent.scrollWidth - displayEvent.finishPositionX) * phaseProgress))
 end
end


-- ****************************************************************************
-- Scrolls the passed display event angled to the left and downwards.
-- ****************************************************************************
local function ScrollLeftAngledDown(displayEvent, animationProgress)
 local linePhasePercent = displayEvent.linePhasePercent
 local horizontalPhasePercent = displayEvent.horizontalPhasePercent

 -- Move the event in an angled line.
 if (animationProgress <= linePhasePercent) then
  -- Calculate how far along the current phase is and set the x and y positions accordingly.
  local phaseProgress = animationProgress / linePhasePercent
  displayEvent.positionX = displayEvent.scrollWidth - (displayEvent.startPositionX + (displayEvent.finishPositionX - displayEvent.startPositionX) * phaseProgress)
  displayEvent.positionY = displayEvent.scrollHeight - displayEvent.finishPositionY * phaseProgress

 -- Wait a bit at the finish position.
 elseif (animationProgress <= horizontalPhasePercent) then
  displayEvent.positionX = displayEvent.scrollWidth - displayEvent.finishPositionX
  displayEvent.positionY = displayEvent.scrollHeight - displayEvent.finishPositionY

 -- Move the event horizontally to outer edge.
 else
  -- Calculate how far along the current phase is and set the x and y positions accordingly.
  local phaseProgress = (animationProgress - horizontalPhasePercent)  / (1 - horizontalPhasePercent)
  displayEvent.positionX = displayEvent.scrollWidth - (displayEvent.finishPositionX + ((displayEvent.scrollWidth - displayEvent.finishPositionX) * phaseProgress))
 end
end


-- ****************************************************************************
-- Scrolls the passed display event angled to the right and upwards.
-- ****************************************************************************
local function ScrollRightAngledUp(displayEvent, animationProgress)
 local linePhasePercent = displayEvent.linePhasePercent
 local horizontalPhasePercent = displayEvent.horizontalPhasePercent

 -- Move the event in an angled line.
 if (animationProgress <= linePhasePercent) then
  -- Calculate how far along the current phase is and set the x and y positions accordingly.
  local phaseProgress = animationProgress / linePhasePercent
  displayEvent.positionX = displayEvent.startPositionX + (displayEvent.finishPositionX - displayEvent.startPositionX) * phaseProgress
  displayEvent.positionY = displayEvent.finishPositionY * phaseProgress

 -- Wait a bit at the finish position.
 elseif (animationProgress <= horizontalPhasePercent) then
  displayEvent.positionX = displayEvent.finishPositionX
  displayEvent.positionY = displayEvent.finishPositionY

 -- Move the event horizontally to outer edge.
 else
  -- Calculate how far along the current phase is and set the x and y positions accordingly.
  local phaseProgress = (animationProgress - horizontalPhasePercent)  / (1 - horizontalPhasePercent)
  displayEvent.positionX = displayEvent.finishPositionX + ((displayEvent.scrollWidth - displayEvent.finishPositionX) * phaseProgress)
 end
end


-- ****************************************************************************
-- Scrolls the passed display event angled to the right and downwards.
-- ****************************************************************************
local function ScrollRightAngledDown(displayEvent, animationProgress)
 local linePhasePercent = displayEvent.linePhasePercent
 local horizontalPhasePercent = displayEvent.horizontalPhasePercent

 -- Move the event in an angled line.
 if (animationProgress <= linePhasePercent) then
  -- Calculate how far along the current phase is and set the x and y positions accordingly.
  local phaseProgress = animationProgress / linePhasePercent
  displayEvent.positionX = displayEvent.startPositionX + (displayEvent.finishPositionX - displayEvent.startPositionX) * phaseProgress
  displayEvent.positionY = displayEvent.scrollHeight - displayEvent.finishPositionY * phaseProgress

 -- Wait a bit at the finish position.
 elseif (animationProgress <= horizontalPhasePercent) then
  displayEvent.positionX = displayEvent.finishPositionX
  displayEvent.positionY = displayEvent.scrollHeight - displayEvent.finishPositionY

 -- Move the event horizontally to outer edge.
 else
  -- Calculate how far along the current phase is and set the x and y positions accordingly.
  local phaseProgress = (animationProgress - horizontalPhasePercent)  / (1 - horizontalPhasePercent)
  displayEvent.positionX = displayEvent.finishPositionX + ((displayEvent.scrollWidth - displayEvent.finishPositionX) * phaseProgress)
 end
end


-- ****************************************************************************
-- Initialize the passed display event and reposition the ones that are
-- currently animating in the scroll area to prevent overlaps.
-- ****************************************************************************
local function InitAngled(newDisplayEvent, activeDisplayEvents, direction, behavior)
 -- Modify the direction and anchor if the direction is alternating.
 local startPositionX = 0
 local anchorPoint = newDisplayEvent.anchorPoint
 if (direction ~= "Left" and direction ~= "Right") then
  -- Select direction and anchor point based on the last event.
  direction = (lastAngledDirection[activeDisplayEvents] == "Left") and "Right" or "Left"
  lastAngledDirection[activeDisplayEvents] = direction
  anchorPoint = (direction == "Left") and "BOTTOMRIGHT" or "BOTTOMLEFT"
  newDisplayEvent.anchorPoint = anchorPoint

  -- Start at the scroll area's mid point.
  startPositionX = newDisplayEvent.scrollWidth / 2
 end

 -- Choose correct animation function.
 if (direction == "Right") then
  newDisplayEvent.animationHandler = (behavior == "AngleDown") and ScrollRightAngledDown or ScrollRightAngledUp
 else
  newDisplayEvent.animationHandler = (behavior == "AngleDown") and ScrollLeftAngledDown or ScrollLeftAngledUp
 end 

 -- Calculate the y finish position based on the last event.
 local finishPositionY
 finishPositionY = lastAngledFinishPositionY[activeDisplayEvents] or newDisplayEvent.scrollHeight
 finishPositionY = finishPositionY - newDisplayEvent.fontSize - MIN_VERTICAL_SPACING
 if (finishPositionY < 0) then finishPositionY = newDisplayEvent.scrollHeight end

 -- Calculate how long the animation should take based on the distance the text has to travel.
 local animationSpeed = newDisplayEvent.animationSpeed
 local finishPositionX = newDisplayEvent.scrollWidth * ANGLED_WIDTH_PERCENT
 local linePhaseTime = math_sqrt((finishPositionX - startPositionX) * (finishPositionX - startPositionX) + finishPositionY * finishPositionY) * MOVEMENT_SPEED
 local scrollTime = ((linePhaseTime + ANGLED_HORIZONTAL_PHASE_TIME) / animationSpeed) + ANGLED_FADE_OUT_TIME
 newDisplayEvent.scrollTime = scrollTime * animationSpeed
 newDisplayEvent.linePhasePercent = linePhaseTime / animationSpeed / scrollTime
 newDisplayEvent.horizontalPhasePercent = ((linePhaseTime + ANGLED_HORIZONTAL_PHASE_TIME) / animationSpeed) / scrollTime
 newDisplayEvent.fadePercent = 1 - (ANGLED_FADE_OUT_TIME / scrollTime)
 
 -- Initialize the new event's x and y positions.
 newDisplayEvent.positionX = startPositionX
 newDisplayEvent.positionY = 0
 newDisplayEvent.startPositionX = startPositionX
 newDisplayEvent.finishPositionX = newDisplayEvent.scrollWidth * ANGLED_WIDTH_PERCENT
 newDisplayEvent.finishPositionY = finishPositionY

 lastAngledFinishPositionY[activeDisplayEvents] = finishPositionY
end


-------------------------------------------------------------------------------
-- Straight scroll functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Scrolls the passed display event upwards.
-- ****************************************************************************
local function ScrollUp(displayEvent, animationProgress)
 -- Set the y position based on the percent completed.
 displayEvent.positionY = displayEvent.scrollHeight * animationProgress
end


-- ****************************************************************************
-- Scrolls the passed display event downwards.
-- ****************************************************************************
local function ScrollDown(displayEvent, animationProgress)
 -- Set the y position based on the percent completed.
 displayEvent.positionY = displayEvent.scrollHeight - displayEvent.scrollHeight * animationProgress
end


-- ****************************************************************************
-- Initialize the passed display event and reposition the ones that are
-- currently scrolling in the scroll area to prevent overlaps.
-- ****************************************************************************
local function InitStraight(newDisplayEvent, activeDisplayEvents, direction, behavior)
 -- Calculate how long the animation should take based on the height of the scroll area.
 newDisplayEvent.scrollTime = newDisplayEvent.scrollHeight * MOVEMENT_SPEED

 -- Set the new event's starting X position.
 local anchorPoint = newDisplayEvent.anchorPoint
 if (anchorPoint == "BOTTOMLEFT") then
  newDisplayEvent.positionX = 0
 elseif (anchorPoint == "BOTTOM") then
  newDisplayEvent.positionX = newDisplayEvent.scrollWidth / 2
 elseif (anchorPoint == "BOTTOMRIGHT") then
  newDisplayEvent.positionX = newDisplayEvent.scrollWidth
 end
 
 -- Get the number of display events that are currently scrolling for this style.
 local numActiveAnimations = #activeDisplayEvents

 -- Scroll text down.
 if (direction == "Down") then
  -- Choose the correct animation function.
  newDisplayEvent.animationHandler = ScrollDown

  -- Exit if there is no need to check for collisions. 
  if (numActiveAnimations == 0) then return end

  -- Scale the per pixel time based on the animation speed.
  local perPixelTime = MOVEMENT_SPEED / newDisplayEvent.animationSpeed
  local currentDisplayEvent = newDisplayEvent
  local prevDisplayEvent, topTimeCurrent

  -- Move events that are colliding.
  for x = numActiveAnimations, 1, -1 do
   prevDisplayEvent = activeDisplayEvents[x]

   -- Calculate the elapsed time for the top point of the current display event.
   topTimeCurrent = currentDisplayEvent.elapsedTime + (currentDisplayEvent.fontSize + MIN_VERTICAL_SPACING) * perPixelTime

   -- Adjust the elapsed time of the previous display event if the current one is colliding with it.
   if (prevDisplayEvent.elapsedTime < topTimeCurrent) then
    prevDisplayEvent.elapsedTime = topTimeCurrent
   else
    -- Don't continue checking if there is no need.
    break
   end

   currentDisplayEvent = prevDisplayEvent
  end

 -- Scroll text up.
 else
  -- Choose the correct animation function.
  newDisplayEvent.animationHandler = ScrollUp

  -- Exit if there is no need to check for collisions. 
  if (numActiveAnimations == 0) then return end

  -- Scale the per pixel time based on the animation speed.
  local perPixelTime = MOVEMENT_SPEED / newDisplayEvent.animationSpeed
  local currentDisplayEvent = newDisplayEvent
  local prevDisplayEvent, topTimePrev

  -- Move events that are colliding.
  for x = numActiveAnimations, 1, -1 do
   prevDisplayEvent = activeDisplayEvents[x]

   -- Calculate the elapsed time for the top point of the previous display event.
   topTimePrev = prevDisplayEvent.elapsedTime - (prevDisplayEvent.fontSize + MIN_VERTICAL_SPACING) * perPixelTime

   -- Adjust the elapsed time of the previous display event if the current one is colliding with it.
   if (topTimePrev < currentDisplayEvent.elapsedTime) then
    prevDisplayEvent.elapsedTime = currentDisplayEvent.elapsedTime + (prevDisplayEvent.fontSize + MIN_VERTICAL_SPACING) * perPixelTime
   else
    -- Exit if there is no need to continue checking for collisions. 
    return
   end

   currentDisplayEvent = prevDisplayEvent
  end
 end -- Direction.
end


-------------------------------------------------------------------------------
-- Parabola scroll functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Scrolls the passed display event in a left parabola upwards.
-- ****************************************************************************
local function ScrollLeftParabolaUp(displayEvent, animationProgress)
 -- Leverage the scroll up logic.
 ScrollUp(displayEvent, animationProgress)

 -- Calculate the new x position based on equation of a parabola.
 -- Equation of a parabola at vertex 0,0: x = y^2 / 4a
 local y = displayEvent.positionY - displayEvent.midPoint
 displayEvent.positionX = (y * y) / displayEvent.fourA
end


-- ****************************************************************************
-- Scrolls the passed display event in a left parabola downwards.
-- ****************************************************************************
local function ScrollLeftParabolaDown(displayEvent, animationProgress)
 -- Leverage the scroll down logic.
 ScrollDown(displayEvent, animationProgress)

 -- Calculate the new x position based on equation of a parabola.
 -- Equation of a parabola at vertex 0,0: x = y^2 / 4a
 local y = displayEvent.positionY - displayEvent.midPoint
 displayEvent.positionX = (y * y) / displayEvent.fourA
end


-- ****************************************************************************
-- Scrolls the passed display event in a right parabola upwards.
-- ****************************************************************************
local function ScrollRightParabolaUp(displayEvent, animationProgress)
 -- Leverage the scroll up logic.
 ScrollUp(displayEvent, animationProgress)

 -- Calculate the new x position based on equation of a parabola.
 -- Equation of a parabola at vertex 0,0: x = y^2 / 4a
 local y = displayEvent.positionY - displayEvent.midPoint
 displayEvent.positionX = displayEvent.scrollWidth - ((y * y) / displayEvent.fourA)
end


-- ****************************************************************************
-- Scrolls the passed display event in a right parabola downwards.
-- ****************************************************************************
local function ScrollRightParabolaDown(displayEvent, animationProgress)
 -- Leverage the scroll down logic.
 ScrollDown(displayEvent, animationProgress)

 -- Calculate the new x position based on equation of a parabola.
 -- Equation of a parabola at vertex 0,0: x = y^2 / 4a
 local y = displayEvent.positionY - displayEvent.midPoint
 displayEvent.positionX = displayEvent.scrollWidth - ((y * y) / displayEvent.fourA)
end


-- ****************************************************************************
-- Initialize the passed display event and reposition the ones that are
-- currently scrolling in the scroll area to prevent overlaps.
-- ****************************************************************************
local function InitParabola(newDisplayEvent, activeDisplayEvents, direction, behavior)
 -- Leverage the straight logic.
 InitStraight(newDisplayEvent, activeDisplayEvents, direction, behavior)

 -- Choose correction animation function. 
 if (direction == "Down") then
   newDisplayEvent.animationHandler = (behavior == "CurvedRight") and ScrollRightParabolaDown or ScrollLeftParabolaDown
 else
   newDisplayEvent.animationHandler = (behavior == "CurvedRight") and ScrollRightParabolaUp or ScrollLeftParabolaUp
 end

 -- Calculate the scroll area midpoint.
 local midPoint = newDisplayEvent.scrollHeight / 2
 newDisplayEvent.midPoint = midPoint
 
 -- Calculate the parabola focal point.
 -- Equation of a parabola at vertex 0,0: x = y^2 / 4a
 newDisplayEvent.fourA = (midPoint * midPoint) / newDisplayEvent.scrollWidth
end


-------------------------------------------------------------------------------
-- Horizontal scroll functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Scrolls the passed display event horizontally left.
-- ****************************************************************************
local function ScrollLeft(displayEvent, animationProgress)
 -- Set the x position based on the percent completed..
 displayEvent.positionX = displayEvent.scrollWidth - displayEvent.scrollWidth * animationProgress
end


-- ****************************************************************************
-- Scrolls the passed display event horizontally right.
-- ****************************************************************************
local function ScrollRight(displayEvent, animationProgress)
 -- Set the x position based on the percent completed..
 displayEvent.positionX = displayEvent.scrollWidth * animationProgress
end


-- ****************************************************************************
-- Reposition the passed display events to prevent overlaps.
-- ****************************************************************************
local function RepositionHorizontalRight(currentDisplayEvent, activeDisplayEvents, startEvent)
 -- Scale the per pixel time based on the animation speed.
 local perPixelTime = MOVEMENT_SPEED / currentDisplayEvent.animationSpeed

 -- Get the top and bottom points of the current display events.
 local topCurrent = currentDisplayEvent.positionY + currentDisplayEvent.fontSize
 local bottomCurrent = currentDisplayEvent.positionY

 local prevDisplayEvent, topPrev, bottomPrev
 local leftTimePrev, rightTimeCurrent
 for x = startEvent, 1, -1 do
  -- Get the top and bottom points of the previous display event.
  prevDisplayEvent = activeDisplayEvents[x]
  topPrev = prevDisplayEvent.positionY + prevDisplayEvent.fontSize
  bottomPrev = prevDisplayEvent.positionY

  -- Check for a vertical collision.
  if ((topCurrent >= bottomPrev and topCurrent <= topPrev) or (bottomCurrent >= bottomPrev and bottomCurrent <= topPrev)) then
   -- Calculate the elapsed time for the left and right points.
   leftTimePrev = prevDisplayEvent.elapsedTime + (prevDisplayEvent.offsetLeft or 0) * perPixelTime
   rightTimeCurrent = currentDisplayEvent.elapsedTime + ((currentDisplayEvent.offsetRight or 0) + MIN_HORIZONTAL_SPACING) * perPixelTime

   -- Adjust the elapsed time of the previous display event if the current one is colliding with it.
   if (leftTimePrev <= rightTimeCurrent) then
    prevDisplayEvent.elapsedTime = rightTimeCurrent + math_abs((prevDisplayEvent.offsetLeft or 0) * perPixelTime)

    -- Move events that are now colliding as a result of moving this one.
    RepositionHorizontalRight(prevDisplayEvent, activeDisplayEvents, x - 1)
   end -- Horizontal collision.
  end -- Vertical collision.
 end
end


-- ****************************************************************************
-- Reposition the passed display events to prevent overlaps.
-- ****************************************************************************
local function RepositionHorizontalLeft(currentDisplayEvent, activeDisplayEvents, startEvent)
 -- Scale the per pixel time based on the animation speed.
 local perPixelTime = MOVEMENT_SPEED / currentDisplayEvent.animationSpeed

 -- Get the top and bottom points of the current display events.
 local topCurrent = currentDisplayEvent.positionY + currentDisplayEvent.fontSize
 local bottomCurrent = currentDisplayEvent.positionY

 local prevDisplayEvent, topPrev, bottomPrev
 local rightTimePrev, leftTimeCurrent
 for x = startEvent, 1, -1 do
  -- Get the top and bottom points of the previous display event.
  prevDisplayEvent = activeDisplayEvents[x]
  topPrev = prevDisplayEvent.positionY + prevDisplayEvent.fontSize
  bottomPrev = prevDisplayEvent.positionY

  -- Check for a vertical collision.
  if ((topCurrent >= bottomPrev and topCurrent <= topPrev) or (bottomCurrent >= bottomPrev and bottomCurrent <= topPrev)) then
   -- Calculate the elapsed time for the left and right points.
   rightTimePrev = prevDisplayEvent.elapsedTime - ((prevDisplayEvent.offsetRight or 0) + MIN_HORIZONTAL_SPACING) * perPixelTime
   leftTimeCurrent =  currentDisplayEvent.elapsedTime - (currentDisplayEvent.offsetLeft or 0) * perPixelTime

   -- Adjust the elapsed time of the previous display event if the current one is colliding with it.
   if (rightTimePrev <= leftTimeCurrent) then
    prevDisplayEvent.elapsedTime = leftTimeCurrent + ((prevDisplayEvent.offsetRight or 0) + MIN_HORIZONTAL_SPACING) * perPixelTime

    -- Move events that are now colliding as a result of moving this one.
    RepositionHorizontalLeft(prevDisplayEvent, activeDisplayEvents, x - 1)
   end -- Horizontal collision.
  end -- Vertical collision.
 end
end


-- ****************************************************************************
-- Initialize the passed display event and reposition the ones that are
-- currently scrolling in the scroll area to prevent overlaps.
-- ****************************************************************************
local function InitHorizontal(newDisplayEvent, activeDisplayEvents, direction, behavior)
 -- Calculate how long the animation should take based on the width of the scroll area.
 newDisplayEvent.scrollTime = newDisplayEvent.scrollWidth * MOVEMENT_SPEED

 -- Modify the direction and anchor if the direction is alternating.
 local anchorPoint = newDisplayEvent.anchorPoint
 if (direction ~= "Left" and direction ~= "Right") then
  -- Select direction and anchor point based on the last event.
  direction = (lastHorizontalDirection[activeDisplayEvents] == "Left") and "Right" or "Left"
  lastHorizontalDirection[activeDisplayEvents] = direction
  anchorPoint = (direction == "Left") and "BOTTOMRIGHT" or "BOTTOMLEFT"
  newDisplayEvent.anchorPoint = anchorPoint

  -- Start at the scroll area's mid point.
  newDisplayEvent.elapsedTime = newDisplayEvent.scrollTime / 2
 end

 -- Calculate the left and right offsets from the anchor point.
 local fontStringWidth = newDisplayEvent.fontString:GetStringWidth()
 if (anchorPoint == "BOTTOMLEFT") then
  newDisplayEvent.offsetLeft = 0
  newDisplayEvent.offsetRight = fontStringWidth
 elseif (anchorPoint == "BOTTOM") then
  local halfWidth = fontStringWidth / 2
  newDisplayEvent.offsetLeft = -halfWidth
  newDisplayEvent.offsetRight = halfWidth
 elseif (anchorPoint == "BOTTOMRIGHT") then
  newDisplayEvent.offsetLeft = -fontStringWidth
  newDisplayEvent.offsetRight = 0
 end


 -- Check if the text is growing down.
 local positionY
 if (behavior == "GrowDown") then
  -- Calculate the y position based on the last event.
  positionY = lastHorizontalPositionY[activeDisplayEvents] or newDisplayEvent.scrollHeight
  positionY = positionY - newDisplayEvent.fontSize - MIN_VERTICAL_SPACING
  if (positionY < 0) then positionY = newDisplayEvent.scrollHeight end

 -- Text is growing up.
 else
  -- Calculate the y position based on the last event.
  positionY = lastHorizontalPositionY[activeDisplayEvents] or 0
  positionY = positionY + newDisplayEvent.fontSize + MIN_VERTICAL_SPACING
  if (positionY > newDisplayEvent.scrollHeight) then positionY = 0 end
 end

 -- Set the y position to the calculated value and save it for the next event.
 newDisplayEvent.positionY = positionY
 lastHorizontalPositionY[activeDisplayEvents] = positionY

 -- Get the number of display events that are currently scrolling for this style.
 local numActiveAnimations = #activeDisplayEvents

 -- Scroll text right.
 if (direction == "Right") then
  -- Choose the correct animation function.
  newDisplayEvent.animationHandler = ScrollRight

  -- Exit if there is no need to check for collisions. 
  if (numActiveAnimations == 0) then return end

  -- Move events that are colliding.
  RepositionHorizontalRight(newDisplayEvent, activeDisplayEvents, numActiveAnimations)

 -- Scroll text left.
 else
  -- Choose the correct animation function.
  newDisplayEvent.animationHandler = ScrollLeft

  -- Exit if there is no need to check for collisions. 
  if (numActiveAnimations == 0) then return end

  -- Move events that are colliding.
  RepositionHorizontalLeft(newDisplayEvent, activeDisplayEvents, numActiveAnimations)
 end   
end


-------------------------------------------------------------------------------
-- Static scroll functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Animates the passed display event using the static style.
-- ****************************************************************************
local function ScrollStatic(displayEvent, animationProgress)
 -- Nothing needs to be done.
end


-- ****************************************************************************
-- Initialize the passed display event and reposition the ones that are
-- currently scrolling in the scroll area to prevent overlaps.
-- ****************************************************************************
local function InitStatic(newDisplayEvent, activeDisplayEvents, direction, behavior)
 -- Set  how long the animation should take.
 newDisplayEvent.scrollTime = STATIC_DISPLAY_TIME
 
 -- Set the animation function.
 newDisplayEvent.animationHandler = ScrollStatic

 -- Set the new event's starting X position.
 local anchorPoint = newDisplayEvent.anchorPoint
 if (anchorPoint == "BOTTOMLEFT") then
  newDisplayEvent.positionX = 0
 elseif (anchorPoint == "BOTTOM") then
  newDisplayEvent.positionX = newDisplayEvent.scrollWidth / 2
 elseif (anchorPoint == "BOTTOMRIGHT") then
  newDisplayEvent.positionX = newDisplayEvent.scrollWidth
 end
 
 -- Get the number of display events that are currently animating for this style.
 local numActiveAnimations = #activeDisplayEvents
 local positionY
 
 -- Static display is growing downwards. 
 if (direction == "Down") then
  positionY = newDisplayEvent.scrollHeight

  -- Offset the new display event correctly if there are already animating events.
  if (numActiveAnimations > 0) then
   -- Set the next y position to after the last display event.
   positionY = activeDisplayEvents[numActiveAnimations].positionY - newDisplayEvent.fontSize - MIN_VERTICAL_SPACING

   -- Wrap the y position if it is outside the scroll area's height.
   if (positionY < 0) then positionY = newDisplayEvent.scrollHeight end 
  end
  
 -- Static display is growing upwards. 
 else
  positionY = 0
  
  -- Offset the new display event correctly if there are already animating events.
  if (numActiveAnimations > 0) then
   -- Set the next y position to before the last display event.
   positionY = activeDisplayEvents[numActiveAnimations].positionY + newDisplayEvent.fontSize + MIN_VERTICAL_SPACING
   
   -- Wrap the y position if it is outside the scroll area's height.
   if (positionY > newDisplayEvent.scrollHeight) then positionY = 0 end
  end
 end

 
 -- Check if there are already animating events.
 if (numActiveAnimations > 0) then
  -- Get the top and bottom points of the new display event.
  local topNew = positionY + newDisplayEvent.fontSize
  local bottomNew = positionY

  -- Loop through all the old display events to force old animations that the new one overlaps to complete.
  local oldDisplayEvent, topOld, bottomOld
  for x = 1, numActiveAnimations - 1 do
   -- Get the top and bottom points of the old display event.
   oldDisplayEvent = activeDisplayEvents[x]
   bottomOld = oldDisplayEvent.positionY
   topOld = bottomOld + oldDisplayEvent.fontSize

   -- Force the old animation to complete if the new display event is overlapping it.
   if ((topNew >= bottomOld and topNew <= topOld) or (bottomNew >= bottomOld and bottomNew <= topOld)) then
    oldDisplayEvent.elapsedTime = oldDisplayEvent.scrollTime
   end
  end
 end

 -- Set the y position to the calculated value. 
 newDisplayEvent.positionY = positionY
end


-------------------------------------------------------------------------------
-- Initialization.
-------------------------------------------------------------------------------

-- Register the default animation styles.
MikSBT.RegisterAnimationStyle("Angled", InitAngled, "Alternate;Left;Right", "AngleUp;AngleDown")
MikSBT.RegisterAnimationStyle("Straight", InitStraight, "Up;Down", nil)
MikSBT.RegisterAnimationStyle("Parabola", InitParabola, "Up;Down", "CurvedLeft;CurvedRight")
MikSBT.RegisterAnimationStyle("Horizontal", InitHorizontal, "Alternate;Left;Right", "GrowUp;GrowDown")
MikSBT.RegisterAnimationStyle("Static", InitStatic, "Up;Down", nil)


-- Register the default sticky animation styles.
MikSBT.RegisterStickyAnimationStyle("Pow", InitPow, "Up;Down", "Normal;Jiggle")
MikSBT.RegisterStickyAnimationStyle("Static", InitStatic, "Up;Down", nil)