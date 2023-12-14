
import router from '@ohos.router'
import { TestType } from '@ohos/hypium'
import { Mode } from '../model/Mode'
import ArrayList from '@ohos.util.ArrayList'
import image from '@ohos.multimedia.image'
import fs from '@ohos.file.fs';
import { ImageItem } from '../model/ImageItem'
import Prompt from '@system.prompt'
import promptAction from '@ohos.promptAction'

class paramInfo {
  public time: number
  public move_cnt: number
  public message: string

  constructor(time: number, move_cnt: number, message: string) {
    this.time = time
    this.move_cnt = move_cnt
    this.message = message
  }
}

@Entry
@Component
struct Game {

  @State mode:              Mode = new Mode(4, 3)           // 行数和列数
  @State picture:           Resource = $r('app.media.lilu') // 选中的图片
  time:                     number                          // 过去的时间
  @State move_cnt:          number = 0                      // 已经移动的步数
  @State pictures:          ImageItem[] = []                // 拼图的图片集合
  @State pic_width:         number = undefined              // 主图的宽
  @State pic_height:        number = undefined              // 主图的高

  textTimerController:      TextTimerController = new TextTimerController()  // 计时器
  @State format:            string = 'mm:ss.SS'                              // 时间显示的格式


  // Resource ---> 不能切分 ===》  PixelMap 可以切分

  // 通过资源获取PixelMap
  async getPixelMapByResource(picture: Resource): Promise<image.PixelMap> {
    let pixelMap: image.PixelMap = null;
    try {
      const mediaContent = await getContext(this).resourceManager.getMediaContent(picture);
      const imageSource = image.createImageSource(mediaContent.buffer);
      pixelMap = await imageSource.createPixelMap();
      return pixelMap;
    } catch (error) {
      console.log(error);
      return pixelMap;
    }
  }
  // 获取通过picture和mode获取pictures
  async getPictures(pixelMap: image.PixelMap, mode: Mode) {
    try{
      let n = mode.n;
      let m = mode.m;
      let imageInfo = await pixelMap.getImageInfo()
      let n_len = imageInfo.size.height/n
      let m_len = imageInfo.size.width/m
      this.pic_width = imageInfo.size.width
      this.pic_height = imageInfo.size.height
      // 切割一张照片
      async function getImageSlice(i: number, j: number, pixelMap_t: image.PixelMap):Promise<PixelMap>{
        await pixelMap_t.crop({
          x: i*m_len,
          y: j*n_len,
          size: { height: n_len, width: m_len }
        })
        return pixelMap_t
      }
      // 循环切割n*m次
      for (let j = 0; j < n; ++ j) {
        for (let i = 0; i < m; ++ i) {
          await this.getPixelMapByResource(this.picture).then(async (pixelMap)=>{
            await getImageSlice(i, j, pixelMap).then(async (val)=>{
              if(i == m-1 && j == n - 1) {
                await this.getPixelMapByResource($r('app.media.blank')).then(val=>{this.pictures.push(new ImageItem(i+j*m, val))})
              } else this.pictures.push(new ImageItem(i+j*m, val))
            })
          })
        }
      }
    } catch(err){
      console.log(err)
      return
    }
  }
  // 检查该位置是否是空白位置
  checkIsBlank(pos: number):boolean {
    for(let i = 0; i < this.pictures.length; ++ i) {
      if(this.pictures[i].position == pos && this.pictures[i].index == this.mode.n*this.mode.m-1) {
        return true
      }
    }
    return false
  }
  // 检查是否完成游戏
  checkIsPass():boolean{
    for(let i = 0; i < this.pictures.length; ++ i) {
      if(this.pictures[i].index != i) return false;
    }
    this.textTimerController.pause()
    return true;
  }
  // 移动
  async move(pic: ImageItem){
    let n = this.mode.n
    let m = this.mode.m
    let x = pic.position
    // 上
    if(x >= m && this.checkIsBlank(x-m)) {
      let y = x - m
      this.pictures[x].position = y;
      this.pictures[y].position = x;
      [this.pictures[x], this.pictures[y]] = [this.pictures[y], this.pictures[x]]
      this.move_cnt ++;
      if(this.checkIsPass()) {
        router.pushUrl({
          url: "pages/GameOver" ,
          params: new paramInfo(this.time, this.move_cnt, "恭喜你，成功通关游戏")})
      }
      return
    }
    // 下
    if(x < (n*m-m) && this.checkIsBlank(x+m)) {
      let y = x + m
      this.pictures[x].position = y;
      this.pictures[y].position = x;
      [this.pictures[x], this.pictures[y]] = [this.pictures[y], this.pictures[x]]
      this.move_cnt ++;
      if(this.checkIsPass()) {
        router.pushUrl({ url: "pages/GameOver" , params: new paramInfo(this.time, this.move_cnt, "恭喜你，成功通关游戏")})
      }
      return
    }
    // 左
    if(x%m!=0 && this.checkIsBlank(x-1)) {
      let y = x - 1
      this.pictures[x].position = y;
      this.pictures[y].position = x;
      [this.pictures[x], this.pictures[y]] = [this.pictures[y], this.pictures[x]]
      this.move_cnt ++;
      if(this.checkIsPass()) {
        router.pushUrl({ url: "pages/GameOver" , params: new paramInfo(this.time, this.move_cnt, "恭喜你，成功通关游戏")})
      }
      return
    }
    // 右
    if(x%m!=m-1&&this.checkIsBlank(x+1)) {
      let y = x + 1
      this.pictures[x].position = y;
      this.pictures[y].position = x;
      [this.pictures[x], this.pictures[y]] = [this.pictures[y], this.pictures[x]]
      this.move_cnt ++;
      if(this.checkIsPass()) {
        router.pushUrl({ url: "pages/GameOver" , params: new paramInfo(this.time, this.move_cnt, "恭喜你，成功通关游戏")})
      }
      return
    }
    // 不可移动
    promptAction.showToast({
      message: "不可移动",
      duration: 100
    })
  }
  // 打乱
  async shuffleArray(array: ImageItem[]){
    let n = array.length
    while(true){
      // 随机打乱
      for (let i = n - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [array[i], array[j]] = [array[j], array[i]];
      }
      // 存入下标，并把空白放入最后
      for(let i = 0; i < n; ++ i) {
        if(array[i].index==n-1) {
          [array[i], array[n-1]] = [array[n-1], array[i]];
        }
        array[i].position = i
      }
      // 统计逆序数，判断有无解
      let ret = 0;
      for(let i = 0; i < n-1; ++ i) {
        for(let j = i+1; j < n-1; ++ j) {
          if(array[i].index > array[j].index) ret ++;
        }
      }
      if(ret && ret%2==0)return;
    }
  }
  // 打开该页面时候
  async onPageShow(){
    this.textTimerController.reset()
    this.pictures = []
    this.move_cnt = 0
    let tmp = router.getParams()
    this.mode = tmp['mode']
    this.picture = tmp['picture']
    const pixelMap = await this.getPixelMapByResource(this.picture)
    await this.getPictures(pixelMap, this.mode)  // 生成切割图片
    await this.shuffleArray(this.pictures)  // 打乱图片数组
    this.textTimerController.start()
  }

  build() {
    Row(){
      Column(){
        // 上栏，包括预览图和时间等信息
        Row(){
          // 缩略图
          Row(){
            Image(this.picture)
              .objectFit(ImageFit.Contain)
              .interpolation(ImageInterpolation.High)
          }
          .width('60%').height('100%').padding(5)
          .border({ width: 1, color: Color.Black, radius: 10, style: BorderStyle.Solid })
          // 时间难度步数
          Column(){
            // 难度
            Text("难度: " + this.mode.n + " X " + this.mode.m)
              .width("100%").height("33%").fontSize(20).fontWeight(FontWeight.Bold).fontColor(0xCB0798E7)
            // 时间
            Row(){
              Text("时间：")
                .height("100%").fontSize(20).fontWeight(FontWeight.Bold).fontColor(0xCB0798E7)
              TextTimer({ isCountDown: false, count: 300000, controller: this.textTimerController })
                .format(this.format)
                .height("100").fontColor(0xCB0798E7)
                .fontSize(20).fontWeight(FontWeight.Bold)
                .onTimer((utc: number, elapsedTime: number) => {
                  this.time = elapsedTime
                })
            }.width('100%').height('33%')
            // 步数
            Text("步数：" + this.move_cnt)
              .width("100%").height("33%").fontSize(20).fontWeight(FontWeight.Bold).fontColor(0xCB0798E7)
          }
          .width("40%").height('100%').padding(10)
          .border({ width: 1, color: Color.Black, radius: 10, style: BorderStyle.Solid })
        }
        .width('100%').height('25%').margin({ bottom: '5%' }).padding(5)
        .border({ width: 5, color: 0x317AF7, radius: 10, style: BorderStyle.Dotted })

        // 主图，玩家操作区域
        Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }){
          Grid(){
            ForEach(this.pictures, (pic: ImageItem)=>{
              GridItem(){
                // 层叠布局
                Stack({ alignContent: Alignment.TopStart }){
                  // 图片
                  Image(pic.pixelMap)
                    .objectFit(ImageFit.Contain)
                    .onClick(()=>{this.move(pic)})
                    .interpolation(ImageInterpolation.High)
                  // 序号
                  Text(pic.index+"").fontColor(Color.Red).fontSize(20)
                }
              }.border({ width: 1, color: Color.Black, radius: 10, style: BorderStyle.Solid })
            })
          }
          .columnsTemplate(function(){
            let ret = ""
            for(let i = 0; i < this.mode.m; ++ i) {
              if(i == this.mode.m-1) ret += "1fr"
              else ret += "1fr "
            }
            return ret
          }.bind(this)())  // 设置列数
          .rowsTemplate(function(){
            let ret = ""
            for(let i = 0; i < this.mode.n; ++ i) {
              if(i == this.mode.n-1) ret += "1fr"
              else ret += "1fr "
            }
            return ret
          }.bind(this)())   // 设置行数
          .aspectRatio(this.pic_width/this.pic_height) // 设置宽高比
          .columnsGap(2).rowsGap(2)  // 设置网格间距
        }.height('60%').margin({ bottom: '5%' }).padding(5)
        .border({ width: 5, color: 0x317AF7, radius: 10, style: BorderStyle.Dashed })

        // 结束游戏和重置游戏区域
        Row(){
          Text("结束游戏")
            .width('47%').height('100%').fontSize(36).fontColor(0x317AF7)
            .fontWeight(FontWeight.Bolder).textAlign(TextAlign.Center).margin({right: 10})
            .border({ width: 5, color: 0x317AF7, radius: 10, style: BorderStyle.Solid })
            .onClick(()=>{
              promptAction.showDialog({
                title: '结束游戏',
                message: '确认结束游戏',
                buttons: [{ text: '取消',color: '#000000' }, { text: '确认',color: '#000000' }],
              }).then(data => {
                  if(data.index == 1) {
                    this.textTimerController.pause()
                    if(this.checkIsPass()) {
                      router.pushUrl({ url: "pages/GameOver" , params: new paramInfo(this.time, this.move_cnt, "恭喜你，成功通关游戏")})
                    } else {
                      router.pushUrl({ url: "pages/GameOver" , params: new paramInfo(this.time, this.move_cnt, "挑战失败，再试一次吧")})
                    }
                  }
              })
            })
          Text("重置游戏")
            .width('47%').height('100%').fontSize(36).fontColor(0x317AF7)
            .fontWeight(FontWeight.Bolder).textAlign(TextAlign.Center)
            .border({ width: 5, color: 0x317AF7, radius: 10, style: BorderStyle.Solid })
            .onClick(()=>{
              promptAction.showDialog({
                title: '重置游戏',
                message: '确认重置游戏',
                buttons: [{ text: '取消',color: '#000000' }, { text: '确认',color: '#000000' }],
              }).then(data => {
                if(data.index == 1) {
                  this.onPageShow()
                }
              })
            })
        }
        .width('100%').height('10%').justifyContent(FlexAlign.Center)

      }.width('100%')
    }.height('100%').backgroundImage($r('app.media.background')).backgroundImageSize(ImageSize.Cover)
  }
}