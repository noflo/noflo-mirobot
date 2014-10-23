noflo = require 'noflo'

class PixelsToPoints extends noflo.Component
  icon = 'file-image-o'
  description = 'Converts pixels to cartesian points.'

  constructor: ->
    @image = null
    @size = 10

    @inPorts =
      image: new noflo.Port 'object'
      size: new noflo.Port 'number'

    @outPorts =
      points: new noflo.Port 'object'

    @inPorts.size.on 'data', (data) =>
      @size = data

    @inPorts.image.on 'data', (data) =>
      return unless @outPorts.points.isAttached()
      @image = data
      canvas = document.createElement 'canvas'
      width = canvas.width = @image.width
      height = canvas.height = @image.height
      image = @image

      ctx = canvas.getContext '2d'
      ctx.drawImage image, 0, 0
      imageData = ctx.getImageData 0, 0, width, height
      data = imageData.data

      points = []
      console.log 'points', points
      for i in [0...data.length] by 4
        if data[i] is 255
          x = i/4 % width
          y = Math.floor(i/4 / width)
          points.push {'type': 'point', 'x': x, 'y': y}

      @outPorts.points.send @shuffle(points).slice(0, @size)

  # Fisher-Yates shuffle
  shuffle: (a) =>
    for i in [0...a.length]
      r = @randomInt i, a.length
      t = a[r]
      a[r] = a[i]
      a[i] = t
    return a

  randomInt: (min, max) =>
    return Math.floor((Math.random() * (max - min)) + min)

exports.getComponent = -> new PixelsToPoints



