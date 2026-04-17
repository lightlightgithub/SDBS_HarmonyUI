import { promptAction } from '@kit.ArkUI';
import { SupportConfig, MeasurementMode, Margin } from './RotorSupportConfig';
import { PersistentConfig, SelectOption } from '../../models/global';
import { RotorViewModel } from '../../viewmodels/rotor/RotorViewModel';
import router from '@ohos.router';
@Component
export struct RotorSettingsPage {
  @Watch('onStoredSupportModeChange')
  @StorageLink('rotorSupportSelectedMode') private storedSupportMode: number = 1; //全局存储找不到默认是支撑方式1
  @Watch('onStoredSupportJsmsChange')
  @StorageLink('rotorSupportJsms') private storedSupportJsms: number = 0;
  @State private currentMode: MeasurementMode | null = null;
  @State private currentModeImage: string = 'image/rotor/rtsetmodel1.png';
  @State private displayWidth: number = 0;
  @State private displayHeight: number = 0;
  @State private offsetX: number = 0;
  @State private offsetY: number = 0;
  @State private containerWidth: number = 0;
  @State private containerHeight: number = 0;
  @State private canvasWidth: number = 0;
  @State private canvasHeight: number = 0;
  @State private canvasOffsetX: number = 0;
  @State private canvasOffsetY: number = 0;
  @State private mainLine: string = '';
  @State private inLine: string = '';
  @State private arrowLine: string = '';
  @State private aPos: Margin = { left: 0, top: 0 };
  @State private bPos: Margin = { left: 0, top: 0 };
  @State private cPos: Margin = { left: 0, top: 0 };
  @State private r1Pos: Margin = { left: 0, top: 0 };
  @State private r2Pos: Margin = { left: 0, top: 0 };
  @State private speedPos: Margin = { left: 0, top: 0 };

  private readonly CANVAS_EXTEND: number = 90;
  private mainCanvasCtx: CanvasRenderingContext2D = new CanvasRenderingContext2D();
  private inCanvasCtx: CanvasRenderingContext2D = new CanvasRenderingContext2D();
  private arrowCanvasCtx: CanvasRenderingContext2D = new CanvasRenderingContext2D();
  private mainCanvasReady: boolean = false;
  private inCanvasReady: boolean = false;
  private arrowCanvasReady: boolean = false;
  @State private vm: RotorViewModel = new RotorViewModel();
  private balanceModeOptions: SelectOption[] = [{ value: '硬支撑' }, { value: '软支撑' }];
  private unitOptions: SelectOption[] = [{ value: 'mm' }, { value: 'cm' }, { value: 'm' }, { value: 'inch' }, { value: 'foot' }];
  private measureModeOptions: SelectOption[] = [
    { value: '双面动平衡' },
    { value: '单面动平衡' },
    { value: '动静平衡' },
    { value: '立式双面动平衡' },
    { value: '立式动静平衡' }
  ];
  private allowUnitOptions: SelectOption[] = [{ value: 'g' }, { value: 'mg' }, { value: 'g·mm' }, { value: 'g·cm' }];
  private rotorOptions: SelectOption[] = [{ value: 'jP1' }, { value: 'jP2' }, { value: 'jP3' }];

  aboutToAppear(): void {
    this.storedSupportMode = this.vm.zcfs ;
    this.storedSupportJsms = this.vm.Jsms;
    SupportConfig.init();
    this.loadMode(this.vm.zcfs);
  }

  private onStoredSupportModeChange(): void {
    if (this.storedSupportMode >= 1 && this.storedSupportMode <= 11 && this.storedSupportMode !== this.vm.zcfs) {
      this.vm.zcfs = this.storedSupportMode; //  写 vm
      this.loadMode(this.vm.zcfs); //  从 vm 读
    }
  }

  private onStoredSupportJsmsChange(): void {
    const nextBalanceMode = this.storedSupportJsms === 0 ? '硬支撑' : '软支撑';
    if (this.vm.balanceMode !== nextBalanceMode) {
      this.vm.balanceMode = nextBalanceMode; // 写 vm
      this.syncSupportModeForBalanceMode();
    }
  }

  private loadMode(modeId: number): void {
    const mode = SupportConfig.AllModes[modeId];
    if (!mode) return;
    let width = 638;
    let height = 305;
    if (modeId === 7 || modeId === 8) {
      width = 669;
    }
    mode.setImageSize(width, height);
    this.vm.zcfs = modeId;
    this.currentMode = mode;
    this.currentModeImage = `image/rotor/rtsetmodel${modeId}.png`;
    this.mainCanvasReady = false;
    this.inCanvasReady = false;
    this.arrowCanvasReady = false;
    if (this.containerWidth > 0 && this.containerHeight > 0) {
      this.recalculateLayout(this.containerWidth, this.containerHeight);
    }
  }

  private recalculateLayout(containerW: number, containerH: number): void {
    if (this.currentMode === null) {
      return;
    }
    const imgW = this.currentMode.imageWidth;
    const imgH = this.currentMode.imageHeight;
    if (imgW === 0 || imgH === 0) {
      return;
    }

    const availableW = containerW;
    const availableH = containerH;
    const scale = Math.min(availableW / imgW, availableH / imgH);
    const displayW = imgW * scale;
    const displayH = imgH * scale;
    const canvasTopExtend = 80;
    const canvasBottomExtend = 80;
    const lineHorizontalShift = -63;
    const lineVerticalShift = -100;
    const imageOffsetX = (containerW - displayW) / 2;
    const imageOffsetY = (containerH - displayH) / 2;
    const canvasW = displayW + this.CANVAS_EXTEND * 2;
    const canvasH = displayH + canvasTopExtend + canvasBottomExtend;
    const canvasX = -this.CANVAS_EXTEND;
    const canvasY = imageOffsetY - canvasTopExtend;
    const lineBaseX = canvasX + lineHorizontalShift + this.CANVAS_EXTEND * 2;
    const lineBaseY = canvasY + lineVerticalShift + canvasTopExtend;

    this.displayWidth = displayW;
    this.displayHeight = displayH;
    this.offsetX = imageOffsetX;
    this.offsetY = imageOffsetY;
    this.canvasWidth = canvasW;
    this.canvasHeight = canvasH;
    this.canvasOffsetX = canvasX;
    this.canvasOffsetY = canvasY;

    const anno = this.currentMode.annotationGroups;
    this.mainLine = this.currentMode.scalePathCommands(anno.currentAnnotationLineGeometry, scale, lineBaseX, lineBaseY);
    this.inLine = this.currentMode.scalePathCommands(anno.currentAnnotationInLineGeometry, scale, lineBaseX, lineBaseY);
    this.arrowLine = this.currentMode.scalePathCommands(anno.currentAnnotationArrowGeometry, scale, lineBaseX, lineBaseY);
    this.aPos = { left: anno.aPosition.left * scale + imageOffsetX, top: anno.aPosition.top * scale + imageOffsetY };
    this.bPos = { left: anno.bPosition.left * scale + imageOffsetX, top: anno.bPosition.top * scale + imageOffsetY };
    this.cPos = { left: anno.cPosition.left * scale + imageOffsetX, top: anno.cPosition.top * scale + imageOffsetY };
    this.r1Pos = { left: anno.r1Position.left * scale + imageOffsetX, top: anno.r1Position.top * scale + imageOffsetY };
    this.r2Pos = { left: anno.r2Position.left * scale + imageOffsetX, top: anno.r2Position.top * scale + imageOffsetY };
    this.speedPos = { left: anno.speedPosition.left * scale + imageOffsetX, top: anno.speedPosition.top * scale + imageOffsetY };
    this.drawAllLinesIfReady();
  }

  private drawAllLinesIfReady(): void {
    if (this.mainCanvasReady && this.inCanvasReady && this.arrowCanvasReady) {
      this.drawLines();
    }
  }

  private drawLines(): void {
    this.clearCanvases();
    this.drawPath(this.mainCanvasCtx, this.mainLine, '#2d3a4a', 2, false);
    this.drawPath(this.inCanvasCtx, this.inLine, '#5bb7ff', 1.5, false);
    this.drawPath(this.arrowCanvasCtx, this.arrowLine, '#5bb7ff', 1.5, true);
  }

  private clearCanvases(): void {
    this.mainCanvasCtx.clearRect(0, 0, this.canvasWidth, this.canvasHeight);
    this.inCanvasCtx.clearRect(0, 0, this.canvasWidth, this.canvasHeight);
    this.arrowCanvasCtx.clearRect(0, 0, this.canvasWidth, this.canvasHeight);
  }

  private drawPath(ctx: CanvasRenderingContext2D, cmd: string, color: string, lineWidth: number, isFill: boolean): void {
    if (cmd === '') {
      return;
    }
    ctx.save();
    ctx.beginPath();
    ctx.strokeStyle = color;
    ctx.lineWidth = lineWidth;
    if (isFill) {
      ctx.fillStyle = color;
    }
    const parts = cmd.split(/(?=[MLZ])/);
    let firstPoint = true;
    for (let i = 0; i < parts.length; i++) {
      const part = parts[i].trim();
      if (part === '') {
        continue;
      }
      const type = part[0];
      if (type === 'M' || type === 'L') {
        const match = part.match(/([ML])\s*([\d.-]+)[\s,]+([\d.-]+)/);
        if (match !== null) {
          const x = parseFloat(match[2]);
          const y = parseFloat(match[3]);
          if (type === 'M') {
            if (!firstPoint) {
              ctx.stroke();
            }
            ctx.beginPath();
            ctx.moveTo(x, y);
            firstPoint = false;
          } else {
            ctx.lineTo(x, y);
          }
        }
      } else if (type === 'Z') {
        ctx.closePath();
      }
    }
    ctx.stroke();
    if (isFill) {
      ctx.fill();
    }
    ctx.restore();
  }

  private getFilteredModes(): number[] {
    const allModes: number[] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
    if (this.vm.balanceMode === '软支撑') {
      return allModes.filter((modeId: number): boolean => ![2, 4, 5, 7, 8, 9, 10].includes(modeId));
    }
    return allModes;
  }

  private syncSupportModeForBalanceMode(): void {
    const filteredModes = this.getFilteredModes();
    if (filteredModes.length > 0) {
      if (!filteredModes.includes(this.vm.zcfs)) { //  读 vm
        this.vm.zcfs = filteredModes[0]; //  写 vm
        this.loadMode(this.vm.zcfs);
      }
    }
  }

  private openSupportWindow(): void {
    const filteredModes = this.getFilteredModes();
    if (filteredModes.length === 0) {
      promptAction.showToast({ message: '当前解算模式下无可选支撑方式', duration: 1200 });
      return;
    }
    this.storedSupportMode = filteredModes.includes(this.vm.zcfs) ? this.vm.zcfs : filteredModes[0];
    this.storedSupportJsms = this.vm.balanceMode === '硬支撑' ? 0 : 1;
    router.pushUrl({
      url: 'pages/dashboard/SupportWindow',
      params: {
        zcfs: this.storedSupportMode,
        jsms: this.storedSupportJsms
      }
    }).catch(() => {
      promptAction.showToast({ message: '页面跳转失败', duration: 2000 });
    });
  }

  private saveSettings(): void {
    this.vm.saveRotor().then(success => {
      if (success) {
        promptAction.showToast({ message: '保存成功' });
      } else {
        promptAction.showToast({ message: this.vm.errorMessage });
        //promptAction.showToast({ message: '转子设置已保存', duration: 1200 });
      }
    });
  }

  private deleteRotor(): void {
    this.vm.deleteRotor().then(success => {
      promptAction.showToast({ message: success ? '删除成功' : this.vm.errorMessage });
    });
  }

  private addRotor(): void {
    this.vm.addRotor();
    promptAction.showToast({ message: '请输入转子信息后保存' });
  }

  private openIndexDialog(): void {
    promptAction.showToast({ message: '分度设定功能开发中', duration: 1200 });
  }

  private openISOCalculate(): void {
    promptAction.showToast({ message: 'ISO计算功能开发中', duration: 1200 });
  }

  @Builder
  private renderFormItem(label: string, value: string, onChange: (v: string) => void, options?: SelectOption[]) {
    Column({ space: 8 }) {
      Text(label)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333');
      if (options !== undefined && options.length > 0) {
        Select(options)
          .value(value)
          .width(120)
          .height(36)
          .backgroundColor('#ccebff')
          .border({ width: 0 })
          .borderRadius(8)
          .font({ size: 14 })
          .onSelect((index: number, val: string): void => { onChange(val); });
      } else {
        TextInput({ text: value })
          .width(120)
          .height(36)
          .backgroundColor('#ccebff')
          .border({ width: 0 })
          .borderRadius(8)
          .fontSize(14)
          .onChange((val: string): void => { onChange(val); });
      }
    }
    .alignItems(HorizontalAlign.Start);
  }

  @Builder
  private renderTriggerFormItem(label: string, value: string, onClick: () => void) {
    Column({ space: 8 }) {
      Text(label)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333');
      Button({ type: ButtonType.Normal }) {
        Row() {
          Text(value)
            .fontSize(14)
            .fontColor('#333');
          Text('选择')
            .fontSize(12)
            .fontColor('#1181c7');
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween);
      }
      .width(120)
      .height(36)
      .backgroundColor('#ccebff')
      .border({ width: 0 })
      .borderRadius(8)
      .padding({ left: 10, right: 10 })
      .onClick((): void => { onClick(); });
    }
    .alignItems(HorizontalAlign.Start);
  }

  @Builder
  private renderParamInput(label: string, value: string, onChange: (v: string) => void, pos: Margin) {
    if (pos.left < 900) {
      Column({ space: 2 }) {
        TextInput({ text: value })
          .width(55)
          .height(34)
          .borderRadius(17)
          .backgroundColor('#ffffff')
          .border({ width: 1, color: '#00aaff' })
          .fontSize(13)
          .textAlign(TextAlign.Center)
          .onChange((val: string): void => { onChange(val); });
        Text(label)
          .fontSize(13)
          .fontColor('#333');
      }
      .position({ x: pos.left - 30, y: pos.top - 25 })
      .zIndex(100);
    }
  }

  @Builder
  private renderActionButton(text: string, iconPath: string, onClick: () => void) {
    Button({ type: ButtonType.Normal }) {
      Column({ space: 6 }) {
        Image($rawfile(iconPath))
          .width(48)
          .height(48)
          .objectFit(ImageFit.Contain);
        Text(text)
          .fontSize(13)
          .fontColor('#06c')
          .textAlign(TextAlign.Center);
      }
    }
    .width('100%')
    .height('auto')
    .backgroundColor('#ccebff')
    .borderRadius(8)
    .onClick((): void => { onClick(); });
  }

  build() {
    Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Stretch }) {
      Column() {
        Row() {
          Column({ space: 20 }) {
            this.renderFormItem('转子名称', this.vm.rotorName, (v: string): void => { this.vm.rotorName = v; });
            this.renderFormItem('允许量单位', this.vm.allowUnit, (v: string): void => { this.vm.allowUnit = v; }, this.allowUnitOptions);
            this.renderFormItem('静允许量', this.vm.staticAllow, (v: string): void => { this.vm.staticAllow = v; });
            this.renderFormItem('平面一允许量', this.vm.plane1Allow, (v: string): void => { this.vm.plane1Allow = v; });
            this.renderFormItem('平面二允许量', this.vm.plane2Allow, (v: string): void => { this.vm.plane2Allow = v; });
          }
          .width('50%')
          .alignItems(HorizontalAlign.Start)

          Column({ space: 20 }) {
            this.renderFormItem('选择转子', this.vm.selectRotor, (v: string): void => { this.vm.selectRotor = v; }, this.vm.getRotorOptions());
            this.renderFormItem('测量模式', this.vm.measureMode, (v: string): void => { this.vm.measureMode = v; }, this.measureModeOptions);
            this.renderFormItem('解算模式', this.vm.balanceMode, (v: string): void => {
              this.vm.balanceMode = v;
              this.storedSupportJsms = this.vm.balanceMode === '硬支撑' ? 0 : 1;
              this.syncSupportModeForBalanceMode();
              this.storedSupportMode = this.vm.zcfs;
            }, this.balanceModeOptions);
            this.renderFormItem('尺寸单位', this.vm.unit, (v: string): void => { this.vm.unit = v; }, this.unitOptions);
          }
          .width('50%')
          .alignItems(HorizontalAlign.Start)
        }
        .width(260)
        .alignItems(VerticalAlign.Top)
      }
      .padding({ left: 16, right: 16, top: 20, bottom: 20 })
      .margin({ right: 12 })

      Column() {
        Stack({ alignContent: Alignment.TopStart }) {
          if (this.displayWidth > 0 && this.displayHeight > 0) {
            Image($rawfile(this.currentModeImage))
              .width(this.displayWidth)
              .height(this.displayHeight)
              .objectFit(ImageFit.Fill)
              .position({ x: this.offsetX, y: this.offsetY })
              .zIndex(1);

            Canvas(this.mainCanvasCtx)
              .width(this.canvasWidth)
              .height(this.canvasHeight)
              .position({ x: this.canvasOffsetX, y: this.canvasOffsetY })
              .backgroundColor(Color.Transparent)
              .onReady((): void => {
                this.mainCanvasReady = true;
                this.drawAllLinesIfReady();
              })
              .zIndex(2);

            Canvas(this.inCanvasCtx)
              .width(this.canvasWidth)
              .height(this.canvasHeight)
              .position({ x: this.canvasOffsetX, y: this.canvasOffsetY })
              .backgroundColor(Color.Transparent)
              .onReady((): void => {
                this.inCanvasReady = true;
                this.drawAllLinesIfReady();
              })
              .zIndex(3);

            Canvas(this.arrowCanvasCtx)
              .width(this.canvasWidth)
              .height(this.canvasHeight)
              .position({ x: this.canvasOffsetX, y: this.canvasOffsetY })
              .backgroundColor(Color.Transparent)
              .onReady((): void => {
                this.arrowCanvasReady = true;
                this.drawAllLinesIfReady();
              })
              .zIndex(4);

            this.renderParamInput('A', this.vm.rotorA, (v: string): void => { this.vm.rotorA = v; }, this.aPos);
            this.renderParamInput('B', this.vm.rotorB, (v: string): void => { this.vm.rotorB = v; }, this.bPos);
            this.renderParamInput('C', this.vm.rotorC, (v: string): void => { this.vm.rotorC = v; }, this.cPos);
            this.renderParamInput('R1', this.vm.rotorR1, (v: string): void => { this.vm.rotorR1 = v; }, this.r1Pos);
            this.renderParamInput('R2', this.vm.rotorR2, (v: string): void => { this.vm.rotorR2 = v; }, this.r2Pos);
            this.renderParamInput('转速', this.vm.rotorSpeed, (v: string): void => { this.vm.rotorSpeed = v; }, this.speedPos);
          }
        }
        .width('100%')
        .height('100%')
        .clip(false)
        .onAreaChange((oldArea: Area, newArea: Area): void => {
          const width = newArea.width as number;
          const height = newArea.height as number;
          if (width > 0 && height > 0 && (width !== this.containerWidth || height !== this.containerHeight)) {
            this.containerWidth = width;
            this.containerHeight = height;
            this.mainCanvasReady = false;
            this.inCanvasReady = false;
            this.arrowCanvasReady = false;
            setTimeout((): void => {
              this.recalculateLayout(width, height);
            }, 50);
          }
        });
      }
      .layoutWeight(1)
      .padding({ left: 50, right: 80 })
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .clip(false)

      Column({ space: 14 }) {
        this.renderActionButton('分度设定', 'image/rotor/correct.jpg', (): void => { this.openIndexDialog(); });
        this.renderActionButton('支撑方式', 'image/rotor/support.jpg', (): void => { this.openSupportWindow(); });
        this.renderActionButton('新增', 'image/rotor/add.png', (): void => { this.addRotor(); });
        this.renderActionButton('ISO计算', 'image/rotor/calcu.png', (): void => { this.openISOCalculate(); });
        this.renderActionButton('保存', 'image/rotor/save.png', (): void => { this.saveSettings(); });
        this.renderActionButton('删除', 'image/rotor/dele.jpg', (): void => { this.deleteRotor(); });
      }
      .width(90)
      .padding({ top: 16, bottom: 16, left: 8, right: 8 })
      .margin({ left: 8 })
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Start)
    }
  }
  // .width('100%')
  // .height('100%')
  // .backgroundColor('#e6f3ff')
  // .padding({ left: 16, right: 16, top: 16, bottom: 16 });
  // }
}
