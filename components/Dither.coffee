noflo = require 'noflo'

class Dither extends noflo.Component
  icon = 'file-image-o'
  description = 'Dither filter.'
  
  constructor: ->
    @image = null
    @tone = null

    @inPorts =
      image: new noflo.Port 'object'

    @outPorts =
      canvas: new noflo.Port 'object'

    @inPorts.image.on 'data', (data) =>
      return unless @outPorts.canvas.isAttached()

      @image = data

      canvas = document.createElement 'canvas'
      width = canvas.width = @image.width
      height = canvas.height = @image.height
      image = @image

      ctx = canvas.getContext '2d'
      ctx.drawImage image, 0, 0
      imageData = ctx.getImageData 0, 0, width, height
      data = imageData.data

      h = height
      w = width
      img = image
      direction = 1
      error = (0 for i in [0...w])
      nexterror = (0 for i in [0...w])

      for currentPixel in [0...data.length] by 4
        x = currentPixel/4 % w
        y = Math.floor(currentPixel/4 / w)
        r = data[currentPixel]
        g = data[currentPixel+1]
        b = data[currentPixel+2]
        tone = (r + g + b) / 3

      # FIXME: @tone?
      tone /= w * h

      for y in [0...h]
        @ditherDirection img, y, error, nexterror, direction
        direction = direction > 0 ? -1 : 1
        tmp = error
        error = nexterror
        nexterror = tmp

      @outPorts.canvas.send img

  quantizeColor: (original) =>
    i = Math.min(Math.max(original, 0), 255)
    return (i > @tone) ? 255 : 0
  
  decode: (pixel) ->
    r = ((pixel >> 16) & 0xff)
    g = ((pixel >> 8) & 0xff)
    b = (pixel & 0xff)
    return (r + g + b) / 3

  encode: (i) ->
    return (0xff<<24) | (i<<16) | (i<<8) | i

  ditterDirection: (img, y, error, nexterror, direction) =>
    w = img.width

    for x in [0...w]
      nexterror[x] = 0

    if (direction > 0)
      start = 0
      end = w
    else
      start = w - 1
      end =- 1

    for x in [start...end] by direction
      r = 255
      g = 255
      b = 255
      oldPixel = ((r + g + b) / 3) + error[x]
      # oldPixel = @decode(@getRGB(img x, y)) + error[x]
      newPixel = @quantizeColor oldPixel
      # FIXME:
      # @setRGB(img, x, y, encode(newPixel))
      quant_error = oldPixel - newPixel
      nexterror[x] += 5.0 / 16.0 * quant_error
      if (x+direction>=0 and x+direction<w)
        error[x + direction] += 7.0/16.0 * quant_error
        nexterror[x + direction] += 1.0/16.0 * quant_error
      if (x-direction>=0 and x-direction<w)
        nexterror[x - direction] += 3.0/16.0 * quant_error


  # getRGB: (img, x, y) =>
  #   # get RGB of img at (x,y) point

  # setRGB: (img, x, y, color) =>
  #   # set ...

exports.getComponent = -> new Dither



