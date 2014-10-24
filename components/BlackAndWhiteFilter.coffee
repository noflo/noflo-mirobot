noflo = require 'noflo'

class BlackAndWhiteFilter extends noflo.Component
  icon = 'file-image-o'
  description = 'Black and white filter.'
  
  constructor: ->
    @image = null

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

      imageDataLength = imageData.data.length

      max_intensity = -1000
      min_intensity = 1000

      # Finds the min/max intensity and updates with avg
      for i in [0...imageDataLength] by 4
        x = i/4 % width
        y = Math.floor(i/4 / width)
        r = imageData.data[i]
        g = imageData.data[i+1]
        b = imageData.data[i+2]
        c = (r + g + b) / 3
        if max_intensity < c
          max_intensity = c
        if min_intensity > c
          min_intensity = c

        imageData.data[i] = c
        imageData.data[i+1] = c
        imageData.data[i+2] = c

      for i in [0...imageDataLength] by 4
        r = imageData.data[i]
        g = imageData.data[i+1]
        b = imageData.data[i+2]
        c = (r + g + b) / 3

        a = (c - min_intensity) / (max_intensity - min_intensity)
        b = a * 95.0 + 200.0
        if (b>255)
          b = 255
        imageData.data[i] = b
        imageData.data[i+1] = b
        imageData.data[i+2] = b

      ctx.putImageData imageData, 0, 0

      @outPorts.canvas.send canvas

exports.getComponent = -> new BlackAndWhiteFilter



