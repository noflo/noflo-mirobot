noflo = require 'noflo'

class PixelsToPoints extends noflo.Component
  icon = 'file-image-o'
  description = 'Converts pixels to cartesian points collecting points for pixels equals to a given level.'

  constructor: ->
    @image = null
    @size = 10
    @level = 0
    @shuffle = false

    @inPorts =
      image: new noflo.Port 'object'
      size: new noflo.Port 'number'
      level: new noflo.Port 'number'
      shuffle: new noflo.Port 'boolean'

    @outPorts =
      points: new noflo.Port 'object'

    @inPorts.size.on 'data', (data) =>
      @size = data

    @inPorts.level.on 'data', (data) =>
      @level = data

    @inPorts.shuffle.on 'data', (data) =>
      @shuffle = data

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
        if data[i] is @level
          x = i/4 % width
          y = Math.floor(i/4 / width)
          points.push {'type': 'point', 'x': x, 'y': y}

      if @shuffle
        @outPorts.points.send @shuffleFY(points).slice(0, @size)
      else
        @outPorts.points.send points.slice(0, @size)

  # Fisher-Yates shuffle
  shuffleFY: (a) =>
    for i in [0...a.length]
      r = @randomInt i, a.length
      t = a[r]
      a[r] = a[i]
      a[i] = t
    return a

  randomInt: (min, max) =>
    return Math.floor((Math.random() * (max - min)) + min)

exports.getComponent = -> new PixelsToPoints



