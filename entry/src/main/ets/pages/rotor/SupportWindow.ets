// 支撑方式选择界面代码
import { SupportConfig } from './RotorSupportConfig';
import router from '@ohos.router';

interface RouterParams {
  zcfs?: number;
  jsms?: number;
}

@Entry
@Component
struct SupportWindow {
  @State selectedMode: number = 3;
  @State jsms: number = 0;
  @State videoSrc: string = '';
  @State isPlaying: boolean = false;
  private videoController: VideoController = new VideoController();

  private showToast(message: string, duration: number = 2000): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message, duration });
    } catch (error) {
      console.error(`showToast failed: ${JSON.stringify(error)}`);
    }
  }

  aboutToAppear() {
    try {
      const params = router.getParams() as Record<string, number | string>;
      if (params) {
        this.selectedMode = typeof params.zcfs === 'number' ? params.zcfs :
          typeof params.zcfs === 'string' ? parseInt(params.zcfs) : 3;
        this.jsms = typeof params.jsms === 'number' ? params.jsms :
          typeof params.jsms === 'string' ? parseInt(params.jsms) : 0;
      }
      console.info(`接收到参数 - selectedMode: ${this.selectedMode}, jsms: ${this.jsms}`);
      SupportConfig.init();
      this.updateVideoPath();
    } catch (e) {
      console.error('获取参数失败', e);
      this.selectedMode = 3;
      this.jsms = 0;
      this.updateVideoPath();
    }
  }

  updateVideoPath() {
    this.videoSrc = `videomodel${this.selectedMode}.mp4`;
    console.info(`视频路径: ${this.videoSrc}`);
  }

  switchMode(modeId: number) {
    if (this.selectedMode === modeId) {
      return;
    }

    try {
      this.videoController.pause();
    } catch (e) {
    }

    this.selectedMode = modeId;
    this.updateVideoPath();

    try {
      this.videoController.stop();
    } catch (e) {
    }

    setTimeout(() => {
      try {
        this.videoController.start();
      } catch (e) {
        console.error(`播放失败: ${JSON.stringify(e)}`);
      }
    }, 100);
  }

  confirmSelection() {
    try {
      AppStorage.set('rotorSupportSelectedMode', this.selectedMode);
      AppStorage.set('rotorSupportJsms', this.jsms);
      router.back();
      console.info(`返回参数 - selectedMode: ${this.selectedMode}, jsms: ${this.jsms}`);
    } catch (error) {
      console.error(`返回失败: ${JSON.stringify(error)}`);
      router.back();
    }
  }

  closeWindow() {
    console.info('关闭窗口');
    router.back();
  }

  getFilteredModes(): number[] {
    const all = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
    if (this.jsms === 1) {
      return all.filter(i => ![2, 4, 5, 7, 8, 9, 10].includes(i));
    }
    return all;
  }

  build() {
    Flex({
      direction: FlexDirection.Row,
      alignItems: ItemAlign.Start,
      justifyContent: FlexAlign.SpaceBetween
    }) {
      Column() {
        Text('请选择支撑方式')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .margin({ left: 10, top: 10, bottom: 10 });

        Scroll() {
          Grid() {
            ForEach(this.getFilteredModes(), (i: number) => {
              GridItem() {
                Column({ space: 5 }) {
                  Image($r(`app.media.supportmodel${i}`))
                    .width(138)
                    .height(112)
                    .objectFit(ImageFit.Contain);
                  Text(`模式${i}`)
                    .fontSize(17);
                }
                .padding(12)
                .backgroundColor(this.selectedMode === i ? '#ccebff' : '#fff')
                .border({
                  width: this.selectedMode === i ? 2 : 1,
                  color: this.selectedMode === i ? '#0099ff' : '#ccc'
                })
                .borderRadius(6)
                .onClick(() => {
                  this.switchMode(i);
                })
              }
            })
          }
          .columnsTemplate('1fr 1fr 1fr 1fr')
          .columnsGap(10)
          .rowsGap(10)
          .width('100%')
          .padding(10)
        }
        .scrollBar(BarState.Auto)
        .scrollable(ScrollDirection.Vertical)
        .layoutWeight(1)
      }
      .width('60%')
      .backgroundColor('#e6f3ff')
      .padding(10)
      .height('100%');

      Column() {
        Flex({ justifyContent: FlexAlign.SpaceBetween }) {
          Button('取消')
            .width(80)
            .height(40)
            .backgroundColor('#0099ff')
            .fontColor('#fff')
            .fontSize(16)
            .borderRadius(20)
            .onClick(() => {
              this.closeWindow();
            });

          Button('确认')
            .width(80)
            .height(40)
            .backgroundColor('#0099ff')
            .fontColor('#fff')
            .fontSize(16)
            .borderRadius(20)
            .onClick(() => {
              this.confirmSelection();
            });
        }
        .width('100%')
        .margin({ bottom: 16 });

        Text(`模式${this.selectedMode} 演示视频`)
          .fontSize(14)
          .fontColor('#666')
          .margin({ bottom: 10 });

        Column() {
          Video({
            src: $rawfile(`videomodel${this.selectedMode}.mp4`),
            controller: this.videoController
          })
            .width('100%')
            .height('100%')
            .autoPlay(true)
            .loop(true)
            .muted(true)
            .controls(false)
            .objectFit(ImageFit.Cover)
            .onError((error) => {
              console.error(`视频加载错误: ${JSON.stringify(error)}`);
              this.showToast(`视频加载失败，请检查文件: videomodel${this.selectedMode}.mp4`, 2000);
            });
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor('#e6f3ff')
        .borderRadius(8)
        .border({ width: 1, color: '#ccebff' })
        .justifyContent(FlexAlign.Center);
      }
      .width('40%')
      .backgroundColor('#e6f3ff')
      .padding(10)
      .height('100%')
      .alignItems(HorizontalAlign.Center);
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#e6f3ff');
  }
}
