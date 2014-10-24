noflo = require 'noflo'

class FloydSteinberg extends noflo.Component
  icon = 'file-image-o'
  description = 'Dithering using Floyd-Steinberg.'
  
  constructor: ->
    @image = null
    @tone = null

    lumR = []
    lumG = []
    lumB = []
    for i in [0...256]
      lumR[i] = i*0.299
      lumG[i] = i*0.587
      lumB[i] = i*0.114

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

      # Greyscale luminance (sets r pixels to luminance of rgb)
      for i in [0...imageDataLength] by 4
        imageData.data[i] = Math.floor(lumR[imageData.data[i]] + lumG[imageData.data[i+1]] + lumB[imageData.data[i+2]])

      w = imageData.width
      newPixel = null
      err = null

      for currentPixel in [0...imageDataLength] by 4
        newPixel = if imageData.data[currentPixel] < 129 then 0 else 255
        err = Math.floor((imageData.data[currentPixel] - newPixel) / 16)
        imageData.data[currentPixel] = newPixel

        imageData.data[currentPixel       + 4 ] += err*7
        imageData.data[currentPixel + 4*w - 4 ] += err*3
        imageData.data[currentPixel + 4*w     ] += err*5
        imageData.data[currentPixel + 4*w + 4 ] += err*1

        imageData.data[currentPixel + 1] = imageData.data[currentPixel + 2] = imageData.data[currentPixel]

      ctx.putImageData imageData, 0, 0

      @outPorts.canvas.send canvas

exports.getComponent = -> new FloydSteinberg



