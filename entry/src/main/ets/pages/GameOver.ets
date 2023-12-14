
import router from '@ohos.router'
@Entry
@Component
struct GamePass{
  @State time: number = 0
  @State move_cnt: number = undefined
  @State message: string = undefined
  onPageShow(){
    let info = router.getParams()
    this.time = info['time']
    this.move_cnt = info['move_cnt']
    this.message = info['message']
  }
  build(){
    Row(){
      Column(){
        // 信息
        Column(){
          // 提示信息
          Text(this.message)
            .width("100%").height("33%").fontSize(30).fontWeight(FontWeight.Bold).fontColor(0xCB0798E7)
          // 时间
          Text("时间："+Math.floor(this.time/1000)+"."+Math.floor((this.time-this.time/1000)/100)+" s")
            .width('100%').height("33%").fontSize(30).fontWeight(FontWeight.Bold).fontColor(0xCB0798E7)
          // 步数
          Text("步数：" + this.move_cnt)
            .width("100%").height("33%").fontSize(30).fontWeight(FontWeight.Bold).fontColor(0xCB0798E7)
        }
        .width("85%").height('30%').padding(10)
        .border({ width: 1, color: Color.Black, radius: 10, style: BorderStyle.Solid })
        // 再来一次
        Text("再来一次").height('10%')
          .fontSize(40).textAlign(TextAlign.Center)
          .fontColor(0x317AF7)
          .fontWeight(FontWeight.Bolder).textAlign(TextAlign.Center)
          .border({ width: 5, color: 0x317AF7, radius: 10, style: BorderStyle.Solid })
          .margin({top: "20%"})
          .onClick(()=>{
            router.pushUrl({url: "pages/Index"})
          })
      }.width('100%')
    }.height('100%').backgroundImage($r('app.media.background')).backgroundImageSize(ImageSize.Cover)
  }
}