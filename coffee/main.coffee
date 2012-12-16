width = 800
height = 600
score = 0
lives = 3
time = 0

# in coffeescript (and javascript) the symbols true and false are all lowercase
started = false

#java script does not have sets so we will just use a empty array
explosion_group = []

# semi colons are not required after control structors like class and ifs
class ImageInfo
#in coffeescript,  __init__ is replaced by the constructor.
# default values are handled the same way
  constructor: (@center, @size, @radius = 0, @lifespan = Infinity, @animated = false) ->

    #note in coffeescript, the last line of a function is always returned, so return is not necessary unless you wish to
    #return early
  get_center: (self) ->
    @center

  get_size: (self) ->
    @size

  get_radius: (self) ->
    @radius

  get_lifespan: (self) ->
    @lifespan

  get_animated: (self) ->
    @animated

# art assets created by Kim Lathrop, may be freely re-used in non-commercial projects, please credit Kim

# debris images - debris1_brown.png, debris2_brown.png, debris3_brown.png, debris4_brown.png
#                 debris1_blue.png, debris2_blue.png, debris3_blue.png, debris4_blue.png, debris_blend.png
debris_info = new ImageInfo([320, 240], [640, 480])
debris_image = simplegui.load_image("http://commondatastorage.googleapis.com/codeskulptor-assets/lathrop/debris2_blue.png")

# nebula images - nebula_brown.png, nebula_blue.png
nebula_info = new ImageInfo([400, 300], [800, 600])
nebula_image = simplegui.load_image("http://commondatastorage.googleapis.com/codeskulptor-assets/lathrop/nebula_blue.png")

# splash image
splash_info = new ImageInfo([200, 150], [400, 300])
splash_image = simplegui.load_image("http://commondatastorage.googleapis.com/codeskulptor-assets/lathrop/splash.png")

# ship image
ship_info = new ImageInfo([45, 45], [90, 90], 35)
ship_image = simplegui.load_image("http://commondatastorage.googleapis.com/codeskulptor-assets/lathrop/double_ship.png")

# missile image - shot1.png, shot2.png, shot3.png
missile_info = new ImageInfo([5, 5], [10, 10], 3, 50)
missile_image = simplegui.load_image("http://commondatastorage.googleapis.com/codeskulptor-assets/lathrop/shot2.png")

# asteroid images - asteroid_blue.png, asteroid_brown.png, asteroid_blend.png
asteroid_info = new ImageInfo([45, 45], [90, 90], 40)
asteroid_image = simplegui.load_image("http://commondatastorage.googleapis.com/codeskulptor-assets/lathrop/asteroid_blue.png")

# animated explosion - explosion_orange.png, explosion_blue.png, explosion_blue2.png, explosion_alpha.png
explosion_info = new ImageInfo([64, 64], [128, 128], 17, 24, true)
explosion_image = simplegui.load_image("http://commondatastorage.googleapis.com/codeskulptor-assets/lathrop/explosion_alpha.png")

# sound assets purchased from sounddogs.com, please do not redistribute
# .ogg versions of sounds are also available, just replace .mp3 by .ogg
# we don't actually load these as per above notice, inface sound isn't implemented at all
soundtrack = simplegui.load_sound("http://commondatastorage.googleapis.com/codeskulptor-assets/sounddogs/soundtrack.mp3")
missile_sound = simplegui.load_sound("http://commondatastorage.googleapis.com/codeskulptor-assets/sounddogs/missile.mp3")
missile_sound.set_volume(.5)
ship_thrust_sound = simplegui.load_sound("http://commondatastorage.googleapis.com/codeskulptor-assets/sounddogs/thrust.mp3")
explosion_sound = simplegui.load_sound("http://commondatastorage.googleapis.com/codeskulptor-assets/sounddogs/explosion.mp3")

# helper functions to handle transformations
angle_to_vector = (ang) ->
  [Math.cos(ang), Math.sin(ang)]

# in coffeescript ** is math.pow
dist = (p, q) ->
  Math.sqrt(Math.pow(p[0] - q[0], 2) + Math.pow(p[1] - q[1], 2))

process_sprite_group = (a_set, canvas)->
  for sprite in a_set
    if sprite?
      if sprite.update() == false
        a_set.remove(sprite)
      sprite.draw(canvas)

#checks for collisions between one set and one object
group_collide = (group_set, other_object) ->
  remove_collided = []
  for item in group_set
    if item.collide(other_object)
      remove_collided.push(item)
      new_explosion = new Sprite(item.pos, [0, 0], 0, 0, explosion_image, explosion_info, explosion_sound)
      explosion_group.push(new_explosion)
  if len(remove_collided) > 0
    group_set.difference_update(remove_collided)
  return len(remove_collided)

#checks for collisions between sets and removes collided objects
group_group_collide = (group_one, group_two) ->
  remove_collided = []
  for item in group_one
    if group_collide(group_two, item) > 0
      remove_collided.push(item)
  group_one.difference_update(remove_collided)
  return len(remove_collided)

reset = () ->
  started = false
  destroy = rock_group
  for item in destroy
    rock_group.remove(item)

start = () ->
  score = 0
  lives = 3
  time = 0
  my_ship.reset()
  soundtrack.rewind()
  soundtrack.play()

# Sprite class
class Sprite
  constructor: (pos, vel, ang, ang_vel, image, info, sound) ->
    @pos = [pos[0], pos[1]]
    @vel = [vel[0], vel[1]]
    @angle = ang
    @angle_vel = ang_vel
    @image = image
    @image_center = info.get_center()
    @image_size = info.get_size()
    @radius = info.get_radius()
    @lifespan = info.get_lifespan()
    @animated = info.get_animated()
    @age = 0
    if sound
      sound.rewind()
      sound.play()

  get_position: () ->
    return @pos

  collide: (other_object) ->
    if dist(@get_position(), other_object.get_position()) <= (@radius + other_object.radius)
      return true
    else
      return false

  draw: (context) ->
    if @animated
      simplegui.draw_image(context, @image, [@image_center[0] + (@image_size[0] * @age), @image_center[1]], @image_size, @pos, @image_size, @angle)
    else
      simplegui.draw_image(context, @image, @image_center, @image_size, @pos, @image_size, @angle)

  update: () ->
    # update angle
    @angle += @angle_vel

    # update position
    @pos[0] = (@pos[0] + @vel[0]).mod width
    @pos[1] = (@pos[1] + @vel[1]).mod height

    #update age
    @age += 1
    if @age < @lifespan
      return true
    else
      return false

# Ship class
class Ship
  constructor: (pos, vel, angle, image, info) ->
    @pos = [pos[0], pos[1]]
    @vel = [vel[0], vel[1]]
    @thrust = false
    @angle = angle
    @angle_vel = 0
    @image = image
    @image_center = info.get_center()
    @image_size = info.get_size()
    @radius = info.get_radius()

  draw: (context) ->
    if @thrust
      simplegui.draw_image(context, @image, [@image_center[0] + @image_size[0], @image_center[1]], @image_size, @pos, @image_size, @angle)
    else
      simplegui.draw_image(context, @image, @image_center, @image_size, @pos, @image_size, @angle)
  # canvas.draw_circle(@pos, @radius, 1, "White", "White")

  update: () ->
    # update angle
    @angle += @angle_vel

    # update position
    @pos[0] = (@pos[0] + @vel[0]).mod width
    @pos[1] = (@pos[1] + @vel[1]).mod height

    # update velocity
    if @thrust
      acc = angle_to_vector(@angle)
      @vel[0] += acc[0] * .1
      @vel[1] += acc[1] * .1

    @vel[0] *= .99
    @vel[1] *= .99

  get_position: () ->
    return @pos

  set_thrust: (thrust_on) ->
    @thrust = thrust_on
    if thrust_on
      ship_thrust_sound.rewind()
      ship_thrust_sound.play()
    else
      ship_thrust_sound.pause()

  increment_angle_vel: () ->
    @angle_vel += .05

  decrement_angle_vel: () ->
    @angle_vel -= .05

  shoot: () ->
    forward = angle_to_vector(@angle)
    missile_pos = [@pos[0] + @radius * forward[0], @pos[1] + @radius * forward[1]]
    missile_vel = [@vel[0] + 6 * forward[0], @vel[1] + 6 * forward[1]]
    a_missile = new Sprite(missile_pos, missile_vel, @angle, 0, missile_image, missile_info, missile_sound)
    missile_group.push(a_missile)

  reset: ()->
    @pos = [width / 2, height /2]
    @vel = [0,0]
    @thrust = false
    @angle = 0
    @angle_vel = 0


    #dirty hack to make keyevents work like simplegui, only matters for left and right
    keyleft = off
    keyright = off

    # key handlers to control ship
    keydown = (key) ->
    if key == simplegui.KEY_MAP['left'] and keyleft == off
    my_ship.decrement_angle_vel()
    keyleft = on
    else if key == simplegui.KEY_MAP['right'] and keyright == off
    my_ship.increment_angle_vel()
    keyright = on
    else if key == simplegui.KEY_MAP['up']
    my_ship.set_thrust(true)
    else if key == simplegui.KEY_MAP['space']
    my_ship.shoot()

    keyup = (key) ->
    if key == simplegui.KEY_MAP['left'] and keyleft == on
    console.log "left up"
    my_ship.increment_angle_vel()
    keyleft = off
    else if key == simplegui.KEY_MAP['right'] and keyright == on
    console.log "right up"
    my_ship.decrement_angle_vel()
    keyright = off
    else if key == simplegui.KEY_MAP['up']
    my_ship.set_thrust(false)

    # mouseclick handlers that reset UI and conditions whether splash image is drawn
    click = (pos) ->
    center = [width / 2, height / 2]
    size = splash_info.get_size()
    inwidth = (center[0] - size[0] / 2) < pos[0] < (center[0] + size[0] / 2)
    inheight = (center[1] - size[1] / 2) < pos[1] < (center[1] + size[1] / 2)
    if (not started) and inwidth and inheight
    started = true
    start()

    draw = (context) ->

    lives -= group_collide(rock_group, my_ship)
    if lives == 0
    reset()

    score += group_group_collide(missile_group, rock_group)

    # animiate background
    time += 1
    center = debris_info.get_center()
    size = debris_info.get_size()
    wtime = (time / 8).mod center[0]
    simplegui.draw_image(context,nebula_image, nebula_info.get_center(), nebula_info.get_size(), [width/2, height/2], [width, height])
    simplegui.draw_image(context,debris_image, [center[0]-wtime, center[1]], [size[0]-2*wtime, size[1]],[width/2+1.25*wtime, height/2], [width-2.5*wtime, height])
    simplegui.draw_image(context,debris_image, [size[0]-wtime, center[1]], [2*wtime, size[1]],[1.25*wtime, height/2], [2.5*wtime, height])

    # draw UI
    simplegui.draw_text(context,"Lives", [50, 50], 22, "White")
    simplegui.draw_text(context,"Score", [680, 50], 22, "White")
    simplegui.draw_text(context,str(lives), [50, 80], 22, "White")
    simplegui.draw_text(context,str(score), [680, 80], 22, "White")

    # draw ship and sprites
    my_ship.draw(context)
    process_sprite_group(rock_group, context)
    process_sprite_group(missile_group, context)
    process_sprite_group(explosion_group, context)

    # update ship and sprites
    my_ship.update()

    # draw splash screen if not started
    if not started
    simplegui.draw_image(context,splash_image, splash_info.get_center(),splash_info.get_size(), [width/2, height/2],splash_info.get_size())

    # timer handler that spawns a rock
    rock_spawner = () ->
    if started == true
    rock_pos = [random.randrange(0, width), random.randrange(0, height)]
    rock_vel = [random.random() * .6 - .3, random.random() * .6 - .3]
    rock_avel = random.random() * .2 - .1
    a_rock = new Sprite(rock_pos, rock_vel, 0, rock_avel, asteroid_image, asteroid_info)
    if len(rock_group) < 12 and started == true
    if dist(a_rock.pos, my_ship.get_position()) > 150
    rock_group.push(a_rock)

    # initialize stuff
    #frame = simplegui.create_frame("Asteroids", width, height)
    canvas = document.getElementById('game_canvas')
    my_context = canvas.getContext('2d')

    # initialize ship and two sprites
    my_ship = new Ship([width / 2, height / 2], [0, 0], 0, ship_image, ship_info)
    rock_group = []
    missile_group = []
    start()

    # register handlers

    #frame.set_keyup_handler(keyup)
    document.addEventListener 'keyup', (event) ->
    console.log event.keyCode
    keyup(event.keyCode)

    #frame.set_keydown_handler(keydown)
    document.addEventListener 'keydown', (event) ->
    console.log event.keyCode
    keydown(event.keyCode)

    #frame.set_mouseclick_handler(click)
    canvas.addEventListener 'click', (event) ->
    x = event.pageX - canvas.offsetLeft
    y = event.pageY - canvas.offsetTop
    click([x,y])

    # draw handler
    timer = setInterval(rock_spawner, 1000)
    gameloop = () ->
    canvas.width = canvas.width
    draw(my_context)
    webkitRequestAnimationFrame(gameloop)
    gameloop()
