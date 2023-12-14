import image from '@ohos.multimedia.image'
export class ImageItem {
  public index: number
  public pixelMap: image.PixelMap
  public position: number  // 当前我在哪里

  constructor(index: number, pixelMap: image.PixelMap) {
    this.index = index
    this.pixelMap = pixelMap
  }
}