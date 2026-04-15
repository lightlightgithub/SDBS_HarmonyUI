import promptAction from '@ohos.promptAction';
import { SupportConfig, MeasurementMode, Margin, SelectOption } from './RotorSupportConfig';

@Component
export struct RotorSettingsPanel {
  @State private zcfs: number = 2;
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
  @State private rotorA: string = '21';
  @State private rotorB: string = '22';
  @State private rotorC: string = '10';
  @State private rotorR1: string = '30';
  @State private rotorR2: string = '30';
  @State private rotorSpeed: string = '700';
  @State private rotorName: string = 'jP1';
  @State private balanceMode: string = '硬支撑';
  @State private selectRotor: string = 'jP1';
  @State private unit: string = 'mm';
  @State private measureMode: string = '双面动平衡';
  @State private allowUnit: string = 'g';
  @State private plane1Allow: string = '4';
  @State private staticAllow: string = '22';
  @State private plane2Allow: string = '4';

  private readonly CANVAS_EXTEND: number = 90;
  private mainCanvasCtx: CanvasRenderingContext2D = new CanvasRenderingContext2D();
  private inCanvasCtx: CanvasRenderingContext2D = new CanvasRenderingContext2D();
  private arrowCanvasCtx: CanvasRenderingContext2D = new CanvasRenderingContext2D();
  private mainCanvasReady: boolean = false;
  private inCanvasReady: boolean = false;
  private arrowCanvasReady: boolean = false;

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
  private supportModeOptions: SelectOption[] = [
    { value: '模式1' },
    { value: '模式2' },
    { value: '模式3' },
    { value: '模式4' },
    { value: '模式5' },
    { value: '模式6' },
    { value: '模式7' },
    { value: '模式8' },
    { value: '模式9' },
    { value: '模式10' },
    { value: '模式11' }
  ];

  aboutToAppear(): void {
    SupportConfig.init();
    this.loadMode(this.zcfs);
  }

  private loadMode(modeId: number): void {
    const mode = SupportConfig.AllModes[modeId];
    if (mode === undefined) {
      return;
    }
    let width = 638;
    let height = 305;
    if (modeId === 7 || modeId === 8) {
      width = 669;
    }
    mode.setImageSize(width, height);
    this.zcfs = modeId;
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

    const scale = containerW / imgW;
    const displayW = containerW;
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

  private cycleMode(): void {
    const nextMode = this.zcfs >= 11 ? 1 : this.zcfs + 1;
    this.loadMode(nextMode);
    promptAction.showToast({ message: `支撑方式切换到模式${nextMode}`, duration: 1200 });
  }

  private saveSettings(): void {
    promptAction.showToast({ message: '转子设置已保存', duration: 1200 });
  }

  private deleteRotor(): void {
    promptAction.showToast({ message: '删除功能待接接口', duration: 1200 });
  }

  private addRotor(): void {
    promptAction.showToast({ message: '新增功能待接接口', duration: 1200 });
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
        .fontColor('#2f4f6a');
      if (options !== undefined && options.length > 0) {
        Select(options)
          .value(value)
          .width(136)
          .height(38)
          .backgroundColor('#ccebff')
          .border({ width: 0 })
          .borderRadius(8)
          .font({ size: 14 })
          .onSelect((index: number, val: string): void => { onChange(val); });
      } else {
        TextInput({ text: value })
          .width(136)
          .height(38)
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
  private renderParamInput(label: string, value: string, onChange: (v: string) => void, pos: Margin) {
    if (pos.left < 900) {
      Column({ space: 2 }) {
        TextInput({ text: value })
          .width(56)
          .height(34)
          .borderRadius(17)
          .backgroundColor('#ffffff')
          .border({ width: 1, color: '#00aaff' })
          .fontSize(13)
          .textAlign(TextAlign.Center)
          .onChange((val: string): void => { onChange(val); });
        Text(label)
          .fontSize(13)
          .fontColor('#2f4f6a');
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
          .width(42)
          .height(42)
          .objectFit(ImageFit.Contain);
        Text(text)
          .fontSize(12)
          .fontColor('#1181c7')
          .textAlign(TextAlign.Center);
      }
    }
    .width(92)
    .height(86)
    .backgroundColor('#d7efff')
    .borderRadius(10)
    .onClick((): void => { onClick(); });
  }

  build() {
    Row() {
      Column() {
        Row() {
          Column({ space: 20 }) {
            this.renderFormItem('转子名称', this.rotorName, (v: string): void => { this.rotorName = v; });
            this.renderFormItem('允许量单位', this.allowUnit, (v: string): void => { this.allowUnit = v; }, this.allowUnitOptions);
            this.renderFormItem('静允许量', this.staticAllow, (v: string): void => { this.staticAllow = v; });
            this.renderFormItem('平面一允许量', this.plane1Allow, (v: string): void => { this.plane1Allow = v; });
            this.renderFormItem('平面二允许量', this.plane2Allow, (v: string): void => { this.plane2Allow = v; });
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Column({ space: 20 }) {
            this.renderFormItem('选择转子', this.selectRotor, (v: string): void => { this.selectRotor = v; }, this.rotorOptions);
            this.renderFormItem('测量模式', this.measureMode, (v: string): void => { this.measureMode = v; }, this.measureModeOptions);
            this.renderFormItem('解算模式', this.balanceMode, (v: string): void => { this.balanceMode = v; }, this.balanceModeOptions);
            this.renderFormItem('尺寸单位', this.unit, (v: string): void => { this.unit = v; }, this.unitOptions);
            this.renderFormItem('支撑模式', `模式${this.zcfs}`, (v: string): void => {
              const modeId = parseInt(v.replace('模式', ''), 10);
              if (!Number.isNaN(modeId)) {
                this.loadMode(modeId);
              }
            }, this.supportModeOptions)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
      }
      .width(360)
      .padding({ left: 18, right: 18, top: 24, bottom: 24 })
      .backgroundColor('#eef8ff')
      .borderRadius(12)
      .margin({ right: 14 })

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

            this.renderParamInput('A', this.rotorA, (v: string): void => { this.rotorA = v; }, this.aPos);
            this.renderParamInput('B', this.rotorB, (v: string): void => { this.rotorB = v; }, this.bPos);
            this.renderParamInput('C', this.rotorC, (v: string): void => { this.rotorC = v; }, this.cPos);
            this.renderParamInput('R1', this.rotorR1, (v: string): void => { this.rotorR1 = v; }, this.r1Pos);
            this.renderParamInput('R2', this.rotorR2, (v: string): void => { this.rotorR2 = v; }, this.r2Pos);
            this.renderParamInput('转速', this.rotorSpeed, (v: string): void => { this.rotorSpeed = v; }, this.speedPos);
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
      .padding({ left: 26, right: 26, top: 10, bottom: 10 })
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .clip(false)

      Column({ space: 14 }) {
        this.renderActionButton('分度设定', 'image/rotor/correct.jpg', (): void => { this.openIndexDialog(); });
        this.renderActionButton(`支撑方式\n模式${this.zcfs}`, 'image/rotor/support.jpg', (): void => { this.cycleMode(); });
        this.renderActionButton('新增', 'image/rotor/add.png', (): void => { this.addRotor(); });
        this.renderActionButton('ISO计算', 'image/rotor/calcu.png', (): void => { this.openISOCalculate(); });
        this.renderActionButton('保存', 'image/rotor/save.png', (): void => { this.saveSettings(); });
        this.renderActionButton('删除', 'image/rotor/dele.jpg', (): void => { this.deleteRotor(); });
      }
      .width(110)
      .padding({ top: 24, bottom: 24, left: 8, right: 8 })
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Start)
    }
    .width('100%')
    .height('100%')
    .padding({ left: 10, right: 10, top: 10, bottom: 10 });
  }
}
