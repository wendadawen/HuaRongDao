import router from '@ohos.router'
import { Mode } from '../model/Mode'
import picker from '@ohos.file.picker'
import image from '@ohos.multimedia.image'
import fs from '@ohos.file.fs';

class ParamInfo {
  mode: Mode
  picture:Resource

  constructor(mode: Mode, picture:Resource) {
    this.mode = mode
    this.picture = picture
  }
}

@Entry
@Component
struct Choice {

  @State mode:             Mode = new Mode(4, 3)  // 游戏模式（难度）： 4 x 3
  @State picture:          Resource = $r('app.media.hutao')  // 主图，我选中的图片
  @State default_pictures: Resource[] = [$r('app.media.hutao'), $r('app.media.keqing'), $r('app.media.leisheng'),
      $r('app.media.lilu'), $r('app.media.linghua'), $r('app.media.maomao'), $r('app.media.xiaogong'),
      $r('app.media.xinganye'), $r('app.media.ye')]  // 可选择的图片

  build() {
    Row(){
      Column(){
        // 选中的图片
       Column(){
          Image(this.picture)
            .objectFit(ImageFit.Contain)
            .interpolation(ImageInterpolation.High)
        }
        .height('50%').margin({ bottom: '5%' }).width('100%').padding(5)
        .border({ width: 1, color: Color.Black, radius: 10, style: BorderStyle.Solid })

        // 行数列数，开始游戏
        Column(){
          // 选择难度
          Row(){
            Column() {
              // 选择行数的选择条
              Select([{ value: '行数：2'}, { value: '行数：3'}, { value: '行数：4'}, { value: '行数：5'}])
                .selected(1).value('选择行数')
                .font({ size: 20, weight: 500 }).fontColor(0xCB0798E7)
                .selectedOptionFont({ size: 20, weight: 400 }).optionFont({ size: 20, weight: 400 })
                .onSelect((index: number) => {
                  this.mode.n = index + 2
                })
            }.width('50%').height('100%')
            .alignItems(HorizontalAlign.Center).justifyContent(FlexAlign.Center)

            Column() {
              // 选择列数的选择条
              Select([{ value: '列数：2'}, { value: '列数：3'}, { value: '列数：4'}, { value: '列数：5'}])
                .selected(1).value('选择列数')
                .font({ size: 20, weight: 500 }).fontColor(0xCB0798E7)
                .selectedOptionFont({ size: 20, weight: 400 }).optionFont({ size: 20, weight: 400 })
                .onSelect((index: number) => {
                  this.mode.m = index + 2
                })
            }.width('50%').height('100%')
            .alignItems(HorizontalAlign.Center).justifyContent(FlexAlign.Center)

          }.width('100%').height('50%')
          // 开始游戏
          Row(){
            Column(){
              Text("开始游戏").fontSize(30).fontColor(0x317AF7).fontWeight(FontWeight.Bolder)
                .textAlign(TextAlign.Center)
                .onClick(()=>{
                  router.pushUrl({
                    url: "pages/Game",
                    params: new ParamInfo(this.mode, this.picture)
                  })
                })
                .border({ width: 5, color: 0x317AF7, radius: 10, style: BorderStyle.Solid })
            }.width('100%').height('100%').justifyContent(FlexAlign.Center)
          }.width('100%').height('50%')
        }.width('100%').height('15%').margin({bottom: '5%'})

        // 下滑图片
        Column(){
          List({space: 10}) {  // 设置主轴间距
            ForEach(this.default_pictures, (picture: Resource)=>{
              ListItem(){
                Image(picture)
                  .objectFit(ImageFit.Contain)  // 图片填充方式
                  .onClick(async ()=>{
                    this.picture = picture
                  })
                  .interpolation(ImageInterpolation.High)
              }.border({ width: 1, color: Color.Black, radius: 10, style: BorderStyle.Solid })
            })
          }
          .listDirection(Axis.Horizontal)  // 主轴为水平轴
          .scrollBar(BarState.Auto)  // 滚动条
          .width("100%").height("100%")
        }.width('100%').height('30%')

      }.width("100%")
    }.height('100%').backgroundImage($r('app.media.background')).backgroundImageSize(ImageSize.Cover)
  }
}