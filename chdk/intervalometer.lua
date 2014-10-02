--[[
Author: Dennis Baldwin
YouTube: https://www.youtube.com/user/dennisbaldwin
Email: db@unmannedairlines.com

Feel free to customize the parameters below. The 5 second delays are just for demonstration purposes and you'll likely want to increase those to fit your needs. I generally set the focus delay to 10000 (10 seconds) so I can find a faraway object to focus and set expores. Then I set the delay before shooting to 120000 (2 minutes) so I can get in the air and engage the autopilot. The delay between photos is 2000 (2 seconds) and is very dependent on your Canon camera model. The camera will do its best to take a photo every 2 seconds, but there's a good chance it will be slower.

This script is a work in progress and I'm ultimately going to modify it to take pictures based on distance controlled by Pixhawk. I'm also going to try to configure it to shut down and retract the lens automatically before some distance from the landing waypoint.
--]]

--[[
@title Intervalometer & Remote Turn Off
@param p number of photos
@default p 500
@param f delay seconds to set focus and exposure
@default f 5000
@param s delay seconds before shooting
@default s 5000
@param n delay seconds between photos
@default n 2000
--]]

-- Get into shooting mode and open the lens
if ( get_mode() == false ) then
  sleep(1000)
  set_record(1)
  while ( get_mode() == false) do
    sleep(100)
  end
end

-- Delay so we can set focus and exposure on object far away
sleep(f)
press("shoot_half")
repeat
  sleep(50)
until get_shooting() == true	
release("shoot_half")
set_aflock(1)

-- Pause so we can get in the air before starting to take photos
sleep(s)
z = get_day_seconds()

-- Begin taking photos
for i=1, p, 1 do
  u=get_usb_power(1)
  print("USB Power is", u)
  -- USB applied so let's shut down the camera, which will retract the lens
  if(u>0) then
    shut_down()
  -- Continue shooting phtos on an interval
  else
    ecnt=get_exp_count()
    press("shoot_full_only")
    repeat
      sleep(n)
    until(get_exp_count()~=ecnt)
    release("shoot_full_only")
    print("Photo", i, "at", get_day_seconds()-z, "seconds")
  end
end