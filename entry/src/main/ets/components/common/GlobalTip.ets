// 文件路径: components/rotor/GlobalTip.ets

// 全局提示弹窗组件
@Component
export struct GlobalTip {
  @Prop message: string = '';
  onClose?: () => void;

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.18)')
        .onClick(() => this.onClose?.())

      Column({ space: 18 }) {
        Row() {
          Text('提示')
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

        Text(this.message)
          .fontSize(17)
          .fontColor('#333')
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding({ left: 20, right: 20 })

        Row() {
          Blank().layoutWeight(1)
          Button('确定')
            .width(98)
            .height(44)
            .backgroundColor('#44b7ff')
            .fontColor('#fff')
            .fontSize(18)
            .borderRadius(6)
            .onClick(() => this.onClose?.())
        }
        .width('100%')
        .padding({ top: 4 })
      }
      .width('44%')
      .padding({ left: 28, right: 28, top: 22, bottom: 22 })
      .backgroundColor('#e6f3ff')
      .borderRadius(14)
      .shadow({ radius: 20, color: 'rgba(0,0,0,0.18)', offsetX: 0, offsetY: 8 })
    }
    .width('100%')
    .height('100%')
    .zIndex(999)
  }
}

// 全局提示管理器（单例）
export class GlobalTipManager {
  private static instance: GlobalTipManager;
  private tipVisible: boolean = false;
  private tipMessage: string = '';
  private timeoutId: number = -1;
  private updateCallback?: (visible: boolean, message: string) => void;

  private constructor() {}

  static getInstance(): GlobalTipManager {
    if (!GlobalTipManager.instance) {
      GlobalTipManager.instance = new GlobalTipManager();
    }
    return GlobalTipManager.instance;
  }

  // 设置更新回调
  setUpdateCallback(callback: (visible: boolean, message: string) => void): void {
    this.updateCallback = callback;
  }

  // 显示提示
  show(message: string, duration: number = 2000): void {
    if (this.timeoutId !== -1) {
      clearTimeout(this.timeoutId);
    }

    this.tipMessage = message;
    this.tipVisible = true;
    this.updateCallback?.(this.tipVisible, this.tipMessage);

    // 自动关闭
    if (duration > 0) {
      this.timeoutId = setTimeout(() => {
        this.hide();
      }, duration);
    }
  }

  // 隐藏提示
  hide(): void {
    this.tipVisible = false;
    this.tipMessage = '';
    this.updateCallback?.(this.tipVisible, this.tipMessage);

    if (this.timeoutId !== -1) {
      clearTimeout(this.timeoutId);
      this.timeoutId = -1;
    }
  }
}

// 导出便捷方法
export const showTip = (message: string, duration?: number) => {
  GlobalTipManager.getInstance().show(message, duration);
};

export const hideTip = () => {
  GlobalTipManager.getInstance().hide();
};