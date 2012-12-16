###
  HELPER FUNCTIONS TO MAP FROM SIMPLE GUI
###

class random
  @randrange = (min, max) ->
    return Math.floor(Math.random() * (max - min + 1)) + min

  @random = () ->
    Math.random()

window.random = random

window.str = (obj) ->
  obj.toString()

window.len = (obj) ->
  obj.length

window.Number.prototype.mod = (n) ->
  ((this%n)+n)%n

window.Array.prototype.remove = (item) ->
  for i in [0...this.length]
    if (this[i] == item)
      this.splice(i,1)
      break

window.Array.prototype.difference_update = (t) ->
  for e in t
    this.remove(e)

class simplesound
  set_volume: (new_volume) ->

  rewind: ()->

  play: ()->

  pause: ()->

class simplegui
  @load_image = (url, onload_cb) ->
    imageObj = new Image()
    imageObj.onload = onload_cb
    imageObj.src = url
    imageObj

  #(image, center_source, width_height_source, center_dest, width_height_dest)
  #ontext.drawImage(img,sx,sy,swidth,sheight,x,y,width,height);
  @draw_image = (context,img,source_pos,source_size,dest_pos,dest_size,rotate=0) ->

    context.save()

    hdw = Math.floor(dest_size[0]/2)
    hdh = Math.floor(dest_size[1]/2)

    cpx = dest_pos[0] - hdw
    cpy = dest_pos[1] - hdh

    spx = source_pos[0] - source_size[0]/2
    spy = source_pos[1] - source_size[1]/2

    context.translate(cpx,cpy)
    context.translate(hdw, hdh)
    context.rotate(rotate)
    context.translate(-cpx,-cpy)
    context.translate(-hdw, -hdh)
    context.drawImage(img,
    spx,
    spy,
    source_size[0],
    source_size[1],
    cpx,
    cpy,
    dest_size[0],
    dest_size[1])
    #context.drawImage(img,-dest_pos[0],-dest_pos[1])
    context.restore()

  #canvas.draw_text(text, point, font_size, font_color)
  @draw_text = (context, text, point, font_size, font_color) ->
    context.font      = "normal #{font_size}px Verdana"
    context.fillStyle = font_color
    context.fillText(text, point[0], point[1])

  @load_sound = (url, onload_cb) ->
    new simplesound()

  @KEY_MAP =
    'left': 37
    'right': 39
    'up': 38
    'space': 32

window.simplegui = simplegui

###
  END HELPER FUNCTIONS
###