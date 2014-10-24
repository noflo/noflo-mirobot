noflo = require 'noflo'

class ThresholdFilter extends noflo.Component
  icon = 'file-image-o'
  description = 'Converts an image to black and white given a threshold value.'
  
  constructor: ->
    @image = null
    @threshold = 10

    @inPorts =
      image: new noflo.Port 'object'
      threshold: new noflo.Port 'number'

    @outPorts =
      canvas: new noflo.Port 'object'

    @inPorts.threshold.on 'data', (data) =>
      @threshold = data

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

      
      for i in [0...imageDataLength] by 4
        r = imageData.data[i]
        g = imageData.data[i+1]
        b = imageData.data[i+2]
        v = if (0.2126*r + 0.7152*g + 0.0722*b >= @threshold) then 255 else 0
        imageData.data[i] = imageData.data[i+1] = imageData.data[i+2] = v

      ctx.putImageData imageData, 0, 0

      @outPorts.canvas.send canvas

exports.getComponent = -> new ThresholdFilter



