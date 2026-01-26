/// <reference types="@citizenfx/server" />
/// <reference types="image-js" />
/// <reference types="axios" />
/// <reference types="form-data" />

const { Image } = require('image-js')
const axios = require('axios')
let FormData = require('form-data')
let fs = require('fs')

async function removeGreenScreen(inputPath) {
  const image = await Image.load(inputPath)

  const width = image.width
  const height = image.height
  const newImage = new Image(width, height, { kind: 'RGBA' })

  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      const [r, g, b] = image.getPixelXY(x, y)

      const isGreenScreen =
        g > r + 20 && g > b + 20 && g > 100 && r < 120 && b < 120

      if (isGreenScreen) {
        newImage.setPixelXY(x, y, [0, 0, 0, 0])
      } else {
        newImage.setPixelXY(x, y, [r, g, b, 255])
      }
    }
  }

  return newImage.toDataURL()
}

async function Screenshot(source) {
  return new Promise((resolve, _) => {
    if (GetResourceState('screencapture') === 'started') {
      exports.screencapture.serverCapture(
        source,
        { encoding: 'png' },
        (data) => {
          resolve(data)
        }
      )
    } else if (GetResourceState('screenshot') === 'started') {
      exports.screenshot.TakeScreenshot(source, (data) => {
        resolve(data)
      })
    } else if (GetResourceState('screenshot-basic') === 'started') {
      exports['screenshot-basic'].requestClientScreenshot(
        source,
        {
          encoding: 'png',
          quality: 1.0,
        },
        async (err, filename) => {
          if (err) {
            console.error('Error taking screenshot:', err)
            resolve(null)
          }
          resolve(filename)
        }
      )
    }
  })
}

async function TakeScreenShot(source, upload) {
  try {
    console.log('Taking screenshot for source:', source)
    const base64 = await Screenshot(source)

    const img = await removeGreenScreen(base64)

    let data = JSON.stringify({
      file: img,
    })

    const buffer = Buffer.from(img.split(',')[1], 'base64')

    const formData = new FormData()

    // Attach the file
    formData.append('file', buffer, { filename: 'image.png' })

    // Optional message
    formData.append(
      'payload_json',
      JSON.stringify({ content: 'Here is the image!' })
    )
    // Optional metadata field (JSON string)
    formData.append(
      'metadata',
      JSON.stringify({
        name: 'My image',
        description: 'This is my image',
      })
    )

    if (
      upload.screenshot == 'fivemanage' ||
      upload.screenshot == 'discord' ||
      upload.screenshot == 'standalone'
    ) {
      const res = await axios.post(upload.server, formData, {
        headers: upload.headers,
      })

      return {
        success: true,
        data:
          upload.screenshot == 'discord'
            ? res.data.attachments[0].proxy_url
            : res.data.url || upload.server + res.data.filename,
      }
    } else {
      let config = {
        method: 'post',
        maxBodyLength: Infinity,
        url: upload.server,
        headers: upload.headers,
        data: data,
      }

      const response = await axios.request(config)

      if (img) {
        return {
          success: true,
          data: response.data.url,
        }
      }
    }
  } catch (error) {
    console.error('Error in TakeScreenShot:', error)
    return {
      success: false,
      error: error.message,
    }
  }
}

exports('TakeScreenShot', TakeScreenShot)
