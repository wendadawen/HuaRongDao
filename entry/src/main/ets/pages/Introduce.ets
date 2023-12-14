
import router from '@ohos.router'

@Entry
@Component
struct Introduce {
  build(){
    Row(){
      Column(){
        // 游戏介绍
        Column(){
          Text("游戏介绍")
            .width("100%").height("100%")
            .fontSize(40).textAlign(TextAlign.Center)
        }
        .width("90%").height('10%')

        // 游戏详细介绍
        Column(){
          Text($r('app.string.introduce'))
            .width("100%").height("100%").fontSize(25)
            .textAlign(TextAlign.Center)
        }
        .width("90%").height('40%')

      }.width('100%')
    }.height("100%").backgroundImage($r('app.media.background')).backgroundImageSize(ImageSize.Cover)
  }
}