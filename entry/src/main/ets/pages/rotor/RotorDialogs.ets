import { RotorViewModel } from '../../viewmodels/rotor/RotorViewModel';
import { showTip } from '../../components/common/GlobalTip';

// 支撑方式、ISO计算、分度设定、删除 弹窗
@Component
export struct SupportDialog {
  @Prop initialMode: number = 2;
  @Prop initialJsms: number = 0;
  @State private localMode: number = 2;
  @State private localJsms: number = 0;
  private videoController: VideoController = new VideoController();
  onConfirm?: (mode: number, jsms: number) => void;
  onClose?: () => void;

  aboutToAppear(): void {
    this.localMode = this.initialMode;
    this.localJsms = this.initialJsms;
  }

  private getFilteredSupportModes(): number[] {
    const all = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
    if (this.localJsms === 1) {
      return all.filter((i: number): boolean => ![2, 4, 5, 7, 8, 9, 10].includes(i));
    }
    return all;
  }

  private switchSupportDialogMode(modeId: number): void {
    if (this.localMode === modeId) return;
    try {
      this.videoController.pause();
    } catch (e) {}
    this.localMode = modeId;
    try {
      this.videoController.stop();
    } catch (e) {}
    setTimeout((): void => {
      try {
        this.videoController.start();
      } catch (e) {}
    }, 100);
  }

  private closeDialog(): void {
    try {
      this.videoController.pause();
      this.videoController.stop();
    } catch (e) {}
    this.onClose?.();
  }

  private confirmDialog(): void {
    this.onConfirm?.(this.localMode, this.localJsms);
    this.onClose?.();
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.18)')
        .onClick(() => this.closeDialog())

      Column({ space: 14 }) {
        Row() {
          Text('请选择支撑方式')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333')
          Blank().layoutWeight(1)
          Button() {
            Image($rawfile('image/login/icon_close.png'))
              .width(18)
              .height(18)
              .objectFit(ImageFit.Contain)
          }
          .width(34)
          .height(34)
          .padding(0)
          .backgroundColor(Color.Transparent)
          .border({ width: 0 })
          .borderRadius(0)
          .onClick(() => this.closeDialog())
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)

        Row({ space: 18 }) {
          Column() {
            Grid() {
              ForEach(this.getFilteredSupportModes(), (i: number) => {
                GridItem() {
                  Column({ space: 8 }) {
                    Image($r(`app.media.supportmodel${i}`))
                      .width(146)
                      .height(118)
                      .objectFit(ImageFit.Contain)
                    Text(`模式${i}`)
                      .fontSize(16)
                      .fontColor('#222')
                  }
                  .width('100%')
                  .padding({ left: 8, right: 8, top: 10, bottom: 10 })
                  .backgroundColor(this.localMode === i ? '#ccebff' : '#ffffff')
                  .border({
                    width: this.localMode === i ? 2 : 1,
                    color: this.localMode === i ? '#0099ff' : '#d6dee8'
                  })
                  .borderRadius(8)
                  .onClick(() => this.switchSupportDialogMode(i))
                }
              })
            }
            .columnsTemplate('1fr 1fr 1fr 1fr')
            .columnsGap(10)
            .rowsGap(10)
            .width('100%')
            .layoutWeight(1)
          }
          .width('60%')
          .height('100%')
          .padding({ top: 4, bottom: 4, left: 4, right: 4 })
          .backgroundColor('#e6f3ff')

          Column() {
            Video({
              src: $rawfile(`videomodel${this.localMode}.mp4`),
              controller: this.videoController
            })
              .width('100%')
              .height('100%')
              .autoPlay(true)
              .loop(true)
              .muted(true)
              .controls(false)
              .objectFit(ImageFit.Cover)
          }
          .width('40%')
          .height('100%')
          .backgroundColor('#d8edf7')
          .borderRadius(6)
          .clip(true)
          .justifyContent(FlexAlign.Center)
        }
        .width('100%')
        .layoutWeight(1)

        Row() {
          Blank().layoutWeight(1)
          Button('确认')
            .width(98)
            .height(44)
            .backgroundColor('#44b7ff')
            .fontColor('#ffffff')
            .fontSize(18)
            .borderRadius(6)
            .onClick(() => this.confirmDialog())
        }
        .width('100%')
        .padding({ top: 6, bottom: 4 })
      }
      .width('94%')
      .height('88%')
      .padding({ left: 24, right: 24, top: 18, bottom: 18 })
      .backgroundColor('#e6f3ff')
      .borderRadius(14)
      .shadow({ radius: 20, color: 'rgba(0,0,0,0.18)', offsetX: 0, offsetY: 8 })
    }
    .width('100%')
    .height('100%')
    .zIndex(20)
  }
}

// 分度设定弹窗
@Component
export struct IndexDialog {
  @ObjectLink vm: RotorViewModel;
  onClose?: () => void;

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.18)')
        .onClick(() => this.onClose?.())

      Column({ space: 16 }) {
        Row() {
          Text('分度设定')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333')
          Blank().layoutWeight(1)
          Button() {
            Image($rawfile('image/login/icon_close.png'))
              .width(18)
              .height(18)
              .objectFit(ImageFit.Contain)
          }
          .width(34)
          .height(34)
          .padding(0)
          .backgroundColor(Color.Transparent)
          .border({ width: 0 })
          .borderRadius(0)
          .onClick(() => this.onClose?.())
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)

        Scroll() {
          Grid() {
            GridItem() {
              Column({ space: 6 }) {
                Text('平面1起始角度').fontSize(15).fontColor('#555')
                TextInput({ text: this.vm.indexAngle1 })
                  .width('100%')
                  .height(44)
                  .backgroundColor('#ccebff')
                  .border({ width: 0 })
                  .borderRadius(8)
                  .fontSize(15)
                  .onChange((v: string): void => { this.vm.indexAngle1 = v })
              }.alignItems(HorizontalAlign.Start)
            }
            GridItem() {
              Column({ space: 6 }) {
                Text('平面1分度数量').fontSize(15).fontColor('#555')
                TextInput({ text: this.vm.indexNumber1 })
                  .width('100%')
                  .height(44)
                  .backgroundColor('#ccebff')
                  .border({ width: 0 })
                  .borderRadius(8)
                  .fontSize(15)
                  .onChange((v: string): void => { this.vm.indexNumber1 = v })
              }.alignItems(HorizontalAlign.Start)
            }
            GridItem() {
              Column({ space: 6 }) {
                Text('平面2起始角度').fontSize(15).fontColor('#555')
                TextInput({ text: this.vm.indexAngle2 })
                  .width('100%')
                  .height(44)
                  .backgroundColor('#ccebff')
                  .border({ width: 0 })
                  .borderRadius(8)
                  .fontSize(15)
                  .onChange((v: string): void => { this.vm.indexAngle2 = v })
              }.alignItems(HorizontalAlign.Start)
            }
            GridItem() {
              Column({ space: 6 }) {
                Text('平面2分度数量').fontSize(15).fontColor('#555')
                TextInput({ text: this.vm.indexNumber2 })
                  .width('100%')
                  .height(44)
                  .backgroundColor('#ccebff')
                  .border({ width: 0 })
                  .borderRadius(8)
                  .fontSize(15)
                  .onChange((v: string): void => { this.vm.indexNumber2 = v })
              }.alignItems(HorizontalAlign.Start)
            }
            GridItem() {
              Column({ space: 6 }) {
                Text('静平面起始角度').fontSize(15).fontColor('#555')
                TextInput({ text: this.vm.indexAngleS })
                  .width('100%')
                  .height(44)
                  .backgroundColor('#ccebff')
                  .border({ width: 0 })
                  .borderRadius(8)
                  .fontSize(15)
                  .onChange((v: string): void => { this.vm.indexAngleS = v })
              }.alignItems(HorizontalAlign.Start)
            }
            GridItem() {
              Column({ space: 6 }) {
                Text('静平面分度数量').fontSize(15).fontColor('#555')
                TextInput({ text: this.vm.indexNumberS })
                  .width('100%')
                  .height(44)
                  .backgroundColor('#ccebff')
                  .border({ width: 0 })
                  .borderRadius(8)
                  .fontSize(15)
                  .onChange((v: string): void => { this.vm.indexNumberS = v })
              }.alignItems(HorizontalAlign.Start)
            }
          }
          .columnsTemplate('1fr 1fr')
          .columnsGap(16)
          .rowsGap(14)
          .width('100%')
        }
        .width('100%')
        .constraintSize({ maxHeight: 400 })

        Row() {
          Blank().layoutWeight(1)
          Button('保存')
            .width(98)
            .height(44)
            .backgroundColor('#44b7ff')
            .fontColor('#fff')
            .fontSize(18)
            .borderRadius(6)
            .onClick(() => {
              this.vm.saveIndexSettings();
              this.onClose?.();
              showTip("分度设定保存成功");
            })
        }
        .width('100%')
        .padding({ top: 4 })
      }
      .width('58%')
      .padding({ left: 28, right: 28, top: 22, bottom: 22 })
      .backgroundColor('#e6f3ff')
      .borderRadius(14)
      .shadow({ radius: 20, color: 'rgba(0,0,0,0.18)', offsetX: 0, offsetY: 8 })
    }
    .width('100%')
    .height('100%')
    .zIndex(20)
  }
}

// ISO计算弹窗
@Component
export struct ISODialog {
  @ObjectLink vm: RotorViewModel;
  onClose?: () => void;

  private gradeOptions: SelectOption[] = [
    { value: '0.4' }, { value: '1' }, { value: '2.5' }, { value: '6.3' },
    { value: '16' }, { value: '40' }, { value: '100' }, { value: '250' },
    { value: '630' }, { value: '1600' }, { value: '4000' }
  ];

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.18)')
        .onClick(() => this.onClose?.())

      Column({ space: 18 }) {
        Row() {
          Text('ISO公差计算')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333')
          Blank().layoutWeight(1)
          Button() {
            Image($rawfile('image/login/icon_close.png'))
              .width(18)
              .height(18)
              .objectFit(ImageFit.Contain)
          }
          .width(34)
          .height(34)
          .padding(0)
          .backgroundColor(Color.Transparent)
          .border({ width: 0 })
          .borderRadius(0)
          .onClick(() => this.onClose?.())
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)

        Column({ space: 14 }) {
          Column({ space: 6 }) {
            Text('平衡等级 (G)').fontSize(15).fontColor('#555')
            Select(this.gradeOptions)
              .value(this.vm.isoGrade)
              .width('100%')
              .height(48)
              .backgroundColor('#ccebff')
              .border({ width: 0 })
              .borderRadius(8)
              .font({ size: 15 })
              .onSelect((_i: number, v: string): void => { this.vm.isoGrade = v })
          }.alignItems(HorizontalAlign.Start).width('100%')

          Column({ space: 6 }) {
            Text('工作转速 (r/min)').fontSize(15).fontColor('#555')
            TextInput({ text: this.vm.isoSpeed })
              .width('100%')
              .height(48)
              .backgroundColor('#ccebff')
              .border({ width: 0 })
              .borderRadius(8)
              .fontSize(15)
              .onChange((v: string): void => { this.vm.isoSpeed = v })
          }.alignItems(HorizontalAlign.Start).width('100%')

          Column({ space: 6 }) {
            Text('工件重量 (KG)').fontSize(15).fontColor('#555')
            TextInput({ text: this.vm.isoWeight })
              .width('100%')
              .height(48)
              .backgroundColor('#ccebff')
              .border({ width: 0 })
              .borderRadius(8)
              .fontSize(15)
              .onChange((v: string): void => { this.vm.isoWeight = v })
          }.alignItems(HorizontalAlign.Start).width('100%')
        }.width('100%')

        Row() {
          Blank().layoutWeight(1)
          Button('计算')
            .width(98)
            .height(44)
            .backgroundColor('#44b7ff')
            .fontColor('#fff')
            .fontSize(18)
            .borderRadius(6)
            .onClick(() => {
              this.vm.calcISO();
              this.onClose?.();
              showTip(this.vm.tipMessage);
            })
        }
        .width('100%')
        .padding({ top: 4 })
      }
      .width('46%')
      .padding({ left: 28, right: 28, top: 22, bottom: 22 })
      .backgroundColor('#e6f3ff')
      .borderRadius(14)
      .shadow({ radius: 20, color: 'rgba(0,0,0,0.18)', offsetX: 0, offsetY: 8 })
    }
    .width('100%')
    .height('100%')
    .zIndex(20)
  }
}

// 删除确认弹窗
@Component
export struct DeleteDialog {
  onConfirm?: () => void;
  onCancel?: () => void;

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.18)')
        .onClick(() => this.onCancel?.())

      Column({ space: 22 }) {
        Text('删除确认')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333')
          .width('100%')
        Text('确认删除当前转子？此操作不可撤销。')
          .fontSize(16)
          .fontColor('#555')
          .width('100%')

        Row({ space: 14 }) {
          Blank().layoutWeight(1)
          Button('取消')
            .width(88)
            .height(44)
            .backgroundColor('#ccc')
            .fontColor('#333')
            .fontSize(16)
            .borderRadius(6)
            .onClick(() => this.onCancel?.())
          Button('确认删除')
            .width(108)
            .height(44)
            .backgroundColor('#ff4d4f')
            .fontColor('#fff')
            .fontSize(16)
            .borderRadius(6)
            .onClick(() => this.onConfirm?.())
        }
        .width('100%')
      }
      .width('42%')
      .padding({ left: 28, right: 28, top: 26, bottom: 26 })
      .backgroundColor('#e6f3ff')
      .borderRadius(14)
      .shadow({ radius: 20, color: 'rgba(0,0,0,0.18)', offsetX: 0, offsetY: 8 })
    }
    .width('100%')
    .height('100%')
    .zIndex(20)
  }
}
