import router from '@ohos.router'
import app from '@system.app'
import prompt from '@ohos.prompt'


@Entry
@Component
struct Index {
  build(){
    Row(){
      Column(){
        // 游戏名字：“拼图华容道”
        Column(){
          Text("拼图华容道")
            .width("100%").height("100%")
            .fontSize(50).textAlign(TextAlign.Center)
            .fontColor(0xCB0798E7)
            .fontWeight(FontWeight.Bolder)
        }
        .width("90%").height('10%').margin("10%")

        // 开始游戏按钮
        Column(){
          Text("开始游戏")
            .fontSize(40).textAlign(TextAlign.Center)
            .fontColor(0x317AF7)
            .fontWeight(FontWeight.Bolder).textAlign(TextAlign.Center)
            .border({ width: 5, color: 0x317AF7, radius: 10, style: BorderStyle.Solid })
            .onClick(()=>{
              router.pushUrl({url:'pages/Select'})
            })
        }
        .width("90%").height('10%').margin("5%").justifyContent(FlexAlign.Center)

        // 游戏介绍按钮
        Column(){
          Text("游戏介绍")
            .fontSize(40).textAlign(TextAlign.Center)
            .fontColor(0x317AF7)
            .fontWeight(FontWeight.Bolder).textAlign(TextAlign.Center)
            .border({ width: 5, color: 0x317AF7, radius: 10, style: BorderStyle.Solid })
            .onClick(()=>{
              router.pushUrl({url:"pages/Introduce"})
            })
        }
        .width("90%").height('10%').justifyContent(FlexAlign.Center)

      }.width('100%')
    }.height("100%").backgroundImage($r('app.media.background')).backgroundImageSize(ImageSize.Cover)
  }

}
