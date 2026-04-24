import { SupportConfig, MeasurementMode, Margin, SelectOption } from './RotorSupportConfig';
import { RotorViewModel } from '../../viewmodels/rotor/RotorViewModel';
import {
  SupportDialog, IndexDialog, ISODialog, DeleteDialog, TipDialog
} from './RotorDialogs';

@Component
export struct RotorSettingsPanel {

  @State private vm: RotorViewModel = new RotorViewModel();
  @State private isDataLoaded: boolean = false;
  // UI 相关状态
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
  // 转子选项
  @State private rotorSelectOptions: SelectOption[] = [];
  private rotorNameToIdMap: Map<string, number> = new Map();
  // 弹窗状态
  @State private supportDialogVisible: boolean = false;
  @State private indexDialogVisible: boolean = false;
  @State private isoDialogVisible: boolean = false;
  @State private deleteDialogVisible: boolean = false;
  @State private tipDialogVisible: boolean = false;
  @State private tipMessage: string = '';

  private mainCanvasCtx: CanvasRenderingContext2D = new CanvasRenderingContext2D();
  private inCanvasCtx: CanvasRenderingContext2D = new CanvasRenderingContext2D();
  private arrowCanvasCtx: CanvasRenderingContext2D = new CanvasRenderingContext2D();
  private mainCanvasReady: boolean = false;
  private inCanvasReady: boolean = false;
  private arrowCanvasReady: boolean = false;
  private resizeTimer: number = -1;

  // 选项配置
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

  aboutToAppear(): void {
    SupportConfig.init();
    if (this.vm.currentRotorId !== 0 && this.vm.rotorList.length > 0) {
      this.loadMode(this.vm.zcfs);
      this.refreshRotorOptions();
      this.isDataLoaded = true;
    } else {
      this.loadData();
    }
  }

  async loadData(): Promise<void> {
    await this.vm.initAsync();
    this.loadMode(this.vm.zcfs);
    this.refreshRotorOptions();
    this.isDataLoaded = true;
  }

  private refreshRotorOptions(): void {
    this.rotorNameToIdMap.clear();
    this.rotorSelectOptions = [];
    this.vm.rotorList.forEach(rotor => {
      this.rotorNameToIdMap.set(rotor.name, rotor.id);
      this.rotorSelectOptions.push({ value: rotor.name } as SelectOption);
    });
  }

  async onRotorSelect(rotorName: string): Promise<void> {
    const rotorId = this.rotorNameToIdMap.get(rotorName);
    if (rotorId) {
      const success = await this.vm.loadRotorById(rotorId);
      if (success) {
        this.loadMode(this.vm.zcfs);
        this.recalculateLayout(this.containerWidth, this.containerHeight);
        setTimeout(() => this.drawLines(), 30);
      }
    }
  }

  private loadMode(modeId: number): void {
    const mode = SupportConfig.AllModes[modeId];
    if (mode === undefined) return;

    let width = 638;
    let height = 305;
    if (modeId === 7 || modeId === 8) {
      width = 669;
    }
    mode.setImageSize(width, height);
    this.currentMode = mode;
    this.currentModeImage = `image/rotor/rtsetmodel${modeId}.png`;

    if (this.containerWidth > 0 && this.containerHeight > 0) {
      this.recalculateLayout(this.containerWidth, this.containerHeight);
      setTimeout((): void => {
        if (this.mainCanvasReady && this.inCanvasReady && this.arrowCanvasReady) {
          this.drawLines();
        }
      }, 100);
    }
  }

  private recalculateLayout(containerW: number, containerH: number): void {
    if (this.currentMode === null) return;

    const imgW = this.currentMode.imageWidth;
    const imgH = this.currentMode.imageHeight;
    if (imgW === 0 || imgH === 0) return;

    const DISPLAY_RATIO: number = 0.78;
    const displayW: number = containerW * DISPLAY_RATIO;
    const scale: number = displayW / imgW;
    const displayH: number = imgH * scale;

    const imageOffsetX: number = (containerW - displayW) / 2;
    const imageOffsetY: number = (containerH - displayH) / 2;
    const canvasW: number = containerW;
    const canvasH: number = containerH;
    const canvasX: number = 0;
    const canvasY: number = 0;
    const lineBaseX: number = imageOffsetX;
    const lineBaseY: number = imageOffsetY;

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

    const HIDDEN_THRESHOLD: number = 900;
    this.aPos = anno.aPosition.left >= HIDDEN_THRESHOLD ? { left: -9999, top: -9999 } :
      { left: anno.aPosition.left * scale + imageOffsetX, top: anno.aPosition.top * scale + imageOffsetY };
    this.bPos = anno.bPosition.left >= HIDDEN_THRESHOLD ? { left: -9999, top: -9999 } :
      { left: anno.bPosition.left * scale + imageOffsetX, top: anno.bPosition.top * scale + imageOffsetY };
    this.cPos = anno.cPosition.left >= HIDDEN_THRESHOLD ? { left: -9999, top: -9999 } :
      { left: anno.cPosition.left * scale + imageOffsetX, top: anno.cPosition.top * scale + imageOffsetY };
    this.r1Pos = anno.r1Position.left >= HIDDEN_THRESHOLD ? { left: -9999, top: -9999 } :
      { left: anno.r1Position.left * scale + imageOffsetX, top: anno.r1Position.top * scale + imageOffsetY };
    this.r2Pos = anno.r2Position.left >= HIDDEN_THRESHOLD ? { left: -9999, top: -9999 } :
      { left: anno.r2Position.left * scale + imageOffsetX, top: anno.r2Position.top * scale + imageOffsetY };
    this.speedPos = anno.speedPosition.left >= HIDDEN_THRESHOLD ? { left: -9999, top: -9999 } :
      { left: anno.speedPosition.left * scale + imageOffsetX, top: anno.speedPosition.top * scale + imageOffsetY };

    this.drawAllLinesIfReady();
  }

  private drawAllLinesIfReady(): void {
    if (this.mainCanvasReady && this.inCanvasReady && this.arrowCanvasReady) {
      this.drawLines();
    }
  }

  private drawLines(): void {
    this.clearCanvases();
    this.drawPath(this.mainCanvasCtx, this.mainLine, '#888888', 1.5, false);
    this.drawPath(this.inCanvasCtx, this.inLine, '#87CEEB', 1, false);
    this.drawPath(this.arrowCanvasCtx, this.arrowLine, '#87CEEB', 1, true);
  }

  private clearCanvases(): void {
    this.mainCanvasCtx.clearRect(0, 0, this.canvasWidth, this.canvasHeight);
    this.inCanvasCtx.clearRect(0, 0, this.canvasWidth, this.canvasHeight);
    this.arrowCanvasCtx.clearRect(0, 0, this.canvasWidth, this.canvasHeight);
  }

  private drawPath(ctx: CanvasRenderingContext2D, cmd: string, color: string, lineWidth: number, isFill: boolean): void {
    if (cmd === '') return;

    ctx.save();
    ctx.strokeStyle = color;
    ctx.lineWidth = lineWidth;
    if (isFill) {
      ctx.fillStyle = color;
    }

    const parts = cmd.split(/(?=[MLZ])/);
    let hasPath = false;
    for (let i = 0; i < parts.length; i++) {
      const part = parts[i].trim();
      if (part === '') continue;

      const type = part[0];
      if (type === 'M') {
        if (hasPath) ctx.stroke();
        const match = part.match(/M\s*([\d.-]+)[\s,]+([\d.-]+)/);
        if (match !== null) {
          ctx.beginPath();
          ctx.moveTo(parseFloat(match[1]), parseFloat(match[2]));
          hasPath = true;
        }
      } else if (type === 'L') {
        const match = part.match(/L\s*([\d.-]+)[\s,]+([\d.-]+)/);
        if (match !== null) {
          ctx.lineTo(parseFloat(match[1]), parseFloat(match[2]));
        }
      } else if (type === 'Z') {
        ctx.closePath();
        if (isFill) ctx.fill();
        ctx.stroke();
        hasPath = false;
      }
    }
    if (hasPath) ctx.stroke();
    ctx.restore();
  }

  // 业务方法
  private saveSettings(): void {
    this.vm.saveRotor().then(ok => {
      if (ok) {
        this.refreshRotorOptions();
        this.loadMode(this.vm.zcfs);
      }
      this.showTip(this.vm.tipMessage);
    });
  }

  private deleteRotor(): void {
    this.deleteDialogVisible = true;
  }

  private addRotor(): void {
    this.vm.resetForm();
    this.isDataLoaded = false;
    this.loadMode(this.vm.zcfs);
    this.refreshRotorOptions();
    setTimeout(() => {
      this.isDataLoaded = true;
      this.showTip('已重置转子表单，请输入参数后保存');
    }, 50);
  }

  private confirmDelete(): void {
    this.deleteDialogVisible = false;
    this.vm.deleteRotor().then(ok => {
      this.refreshRotorOptions();
      if (!ok) {
        this.showTip(this.vm.tipMessage);
      } else {
        this.showTip('转子已删除');
        this.loadMode(this.vm.zcfs);
      }
    });
  }

  private openSupportWindow(): void {
    this.supportDialogVisible = true;
  }

  private openIndexDialog(): void {
    this.indexDialogVisible = true;
  }

  private openISOCalculate(): void {
    this.vm.tipMessage = '';
    this.isoDialogVisible = true;
  }

  private showTip(message: string): void {
    this.tipMessage = message;
    this.tipDialogVisible = true;
  }

  private closeTip(): void {
    this.tipDialogVisible = false;
  }

  @Builder
  private renderFunctionButton(text: string, iconPath: string, onClick: () => void) {
    Button({ type: ButtonType.Normal }) {
      Column({ space: 8 }) {
        Image($rawfile(iconPath))
          .width(46)
          .height(46)
          .objectFit(ImageFit.Contain)
          .blendMode(BlendMode.MULTIPLY);
        Text(text)
          .fontSize(14)
          .fontColor('#0066cc');
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
    }
    .layoutWeight(1)
    .height('100%')
    .backgroundColor('#ccebff')
    .borderRadius(8)
    .onClick((): void => { onClick(); });
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      if (!this.isDataLoaded) {
        Column() {
          LoadingProgress()
            .width(60)
            .height(60)
            .color('#44b7ff')
          Text('加载中...')
            .fontSize(16)
            .fontColor('#666')
            .margin({ top: 12 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#e6f3ff')
      } else {
        Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Stretch }) {
          // 左侧表单区域
          Column({ space: 26 }) {
            Row({ space: 10 }) {
              Column() {
                Text('转子名称').fontSize(16).fontColor('#555').margin({ bottom: 8 })
                TextInput({ text: this.vm.rotorName })
                  .width('100%').height(48).backgroundColor('#ccebff')
                  .border({ width: 0 }).borderRadius(8).fontSize(15)
                  .onChange((v: string): void => { this.vm.rotorName = v; })
              }.layoutWeight(1)

              Column() {
                Text('解算模式').fontSize(16).fontColor('#555').margin({ bottom: 8 })
                Select(this.balanceModeOptions)
                  .value(this.vm.balanceMode)
                  .width('100%').height(48).backgroundColor('#ccebff')
                  .border({ width: 0 }).borderRadius(8).font({ size: 15 })
                  .onSelect((_i: number, v: string): void => {
                    this.vm.balanceMode = v;
                    this.vm.Jsms = v === '硬支撑' ? 0 : 1;
                  })
              }.layoutWeight(1)
            }.width('100%')

            Row({ space: 10 }) {
              Column() {
                Text('尺寸单位').fontSize(16).fontColor('#555').margin({ bottom: 8 })
                Select(this.unitOptions)
                  .value(this.vm.ccdw)
                  .width('100%').height(48).backgroundColor('#ccebff')
                  .border({ width: 0 }).borderRadius(8).font({ size: 15 })
                  .onSelect((_i: number, v: string): void => { this.vm.ccdw = v; })
              }.layoutWeight(1)

              Column() {
                Text('测量模式').fontSize(16).fontColor('#555').margin({ bottom: 8 })
                Select(this.measureModeOptions)
                  .value(this.vm.measureMode)
                  .width('100%').height(48).backgroundColor('#ccebff')
                  .border({ width: 0 }).borderRadius(8).font({ size: 15 })
                  .onSelect((_i: number, v: string): void => { this.vm.measureMode = v; })
              }.layoutWeight(1)
            }.width('100%')

            Row({ space: 10 }) {
              Column() {
                Text('允许量单位').fontSize(16).fontColor('#555').margin({ bottom: 8 })
                Select(this.allowUnitOptions)
                  .value(this.vm.yxldw)
                  .width('100%').height(48).backgroundColor('#ccebff')
                  .border({ width: 0 }).borderRadius(8).font({ size: 15 })
                  .onSelect((_i: number, v: string): void => { this.vm.yxldw = v; })
              }.layoutWeight(1)

              Column() {
                Text('平面一允许量').fontSize(16).fontColor('#555').margin({ bottom: 8 })
                TextInput({ text: this.vm.plane1Allow })
                  .width('100%').height(48).backgroundColor('#ccebff')
                  .border({ width: 0 }).borderRadius(8).fontSize(15)
                  .onChange((v: string): void => { this.vm.plane1Allow = v; })
              }.layoutWeight(1)
            }.width('100%')

            Row({ space: 10 }) {
              Column() {
                Text('静允许量').fontSize(16).fontColor('#555').margin({ bottom: 8 })
                TextInput({ text: this.vm.staticAllow })
                  .width('100%').height(48).backgroundColor('#ccebff')
                  .border({ width: 0 }).borderRadius(8).fontSize(15)
                  .onChange((v: string): void => { this.vm.staticAllow = v; })
              }.layoutWeight(1)

              Column() {
                Text('平面二允许量').fontSize(16).fontColor('#555').margin({ bottom: 8 })
                TextInput({ text: this.vm.plane2Allow })
                  .width('100%').height(48).backgroundColor('#ccebff')
                  .border({ width: 0 }).borderRadius(8).fontSize(15)
                  .onChange((v: string): void => { this.vm.plane2Allow = v; })
              }.layoutWeight(1)
            }.width('100%')
          }
          .width('32%')
          .padding({ left: 20, right: 12, top: 28, bottom: 16 })
          .alignItems(HorizontalAlign.Start)
          .margin({ right: 8 })

          // 中间图形区域
          Column() {
            Column({ space: 8 }) {
              Text('选择转子').fontSize(16).fontColor('#555')
              Select(this.rotorSelectOptions)
                .value(this.vm.selectRotor)
                .width(180).height(48).backgroundColor('#ccebff')
                .border({ width: 0 }).borderRadius(8).font({ size: 15 })
                .onSelect(async (_i: number, val: string): Promise<void> => {
                  this.vm.selectRotor = val;
                  await this.onRotorSelect(val);
                })
            }
            .alignItems(HorizontalAlign.Start)
            .padding({ top: 28, left: 10 })

            Stack({ alignContent: Alignment.TopStart }) {
              if (this.displayWidth > 0 && this.displayHeight > 0) {
                Image($rawfile(this.currentModeImage))
                  .width(this.displayWidth)
                  .height(this.displayHeight)
                  .objectFit(ImageFit.Fill)
                  .position({ x: this.offsetX, y: this.offsetY })
                  .zIndex(1)

                Canvas(this.mainCanvasCtx)
                  .width(this.canvasWidth)
                  .height(this.canvasHeight)
                  .position({ x: this.canvasOffsetX, y: this.canvasOffsetY })
                  .backgroundColor(Color.Transparent)
                  .onReady(() => {
                    this.mainCanvasReady = true
                    this.drawAllLinesIfReady()
                  })
                  .zIndex(2)

                Canvas(this.inCanvasCtx)
                  .width(this.canvasWidth)
                  .height(this.canvasHeight)
                  .position({ x: this.canvasOffsetX, y: this.canvasOffsetY })
                  .backgroundColor(Color.Transparent)
                  .onReady(() => {
                    this.inCanvasReady = true
                    this.drawAllLinesIfReady()
                  })
                  .zIndex(3)

                Canvas(this.arrowCanvasCtx)
                  .width(this.canvasWidth)
                  .height(this.canvasHeight)
                  .position({ x: this.canvasOffsetX, y: this.canvasOffsetY })
                  .backgroundColor(Color.Transparent)
                  .onReady(() => {
                    this.arrowCanvasReady = true
                    this.drawAllLinesIfReady()
                  })
                  .zIndex(4)

                // 输入框组件
                Column({ space: 2 }) {
                  TextInput({ text: this.vm.rotorA })
                    .width(65).height(40).borderRadius(20).backgroundColor('#ffffff')
                    .border({ width: 1, color: '#00aaff' }).fontSize(14).textAlign(TextAlign.Center)
                    .onChange(v => this.vm.rotorA = v)
                  Text('A').fontSize(14).fontColor('#333')
                }.position(this.aPos).zIndex(100)

                Column({ space: 2 }) {
                  TextInput({ text: this.vm.rotorB })
                    .width(65).height(40).borderRadius(20).backgroundColor('#ffffff')
                    .border({ width: 1, color: '#00aaff' }).fontSize(14).textAlign(TextAlign.Center)
                    .onChange(v => this.vm.rotorB = v)
                  Text('B').fontSize(14).fontColor('#333')
                }.position(this.bPos).zIndex(100)

                Column({ space: 2 }) {
                  TextInput({ text: this.vm.rotorC })
                    .width(65).height(40).borderRadius(20).backgroundColor('#ffffff')
                    .border({ width: 1, color: '#00aaff' }).fontSize(14).textAlign(TextAlign.Center)
                    .onChange(v => this.vm.rotorC = v)
                  Text('C').fontSize(14).fontColor('#333')
                }.position(this.cPos).zIndex(100)

                Column({ space: 2 }) {
                  TextInput({ text: this.vm.rotorR1 })
                    .width(65).height(40).borderRadius(20).backgroundColor('#ffffff')
                    .border({ width: 1, color: '#00aaff' }).fontSize(14).textAlign(TextAlign.Center)
                    .onChange(v => this.vm.rotorR1 = v)
                  Text('R1').fontSize(14).fontColor('#333')
                }.position(this.r1Pos).zIndex(100)

                Column({ space: 2 }) {
                  TextInput({ text: this.vm.rotorR2 })
                    .width(65).height(40).borderRadius(20).backgroundColor('#ffffff')
                    .border({ width: 1, color: '#00aaff' }).fontSize(14).textAlign(TextAlign.Center)
                    .onChange(v => this.vm.rotorR2 = v)
                  Text('R2').fontSize(14).fontColor('#333')
                }.position(this.r2Pos).zIndex(100)

                Column({ space: 2 }) {
                  TextInput({ text: this.vm.rotorSpeed })
                    .width(65).height(40).borderRadius(20).backgroundColor('#ffffff')
                    .border({ width: 1, color: '#00aaff' }).fontSize(14).textAlign(TextAlign.Center)
                    .onChange(v => this.vm.rotorSpeed = v)
                  Text('转速').fontSize(14).fontColor('#333')
                }.position(this.speedPos).zIndex(100)
              }
            }
            .width('100%')
            .layoutWeight(1)
            .clip(false)
            .onAreaChange((_oldArea: Area, newArea: Area): void => {
              const width = newArea.width as number;
              const height = newArea.height as number;
              if (width > 0 && height > 0 && (width !== this.containerWidth || height !== this.containerHeight)) {
                this.containerWidth = width;
                this.containerHeight = height;
                if (this.resizeTimer !== -1) clearTimeout(this.resizeTimer);
                this.resizeTimer = setTimeout((): void => {
                  this.recalculateLayout(width, height);
                  this.resizeTimer = setTimeout((): void => {
                    if (this.mainCanvasReady && this.inCanvasReady && this.arrowCanvasReady) {
                      this.drawLines();
                    }
                    this.resizeTimer = -1;
                  }, 150);
                }, 80);
              }
            })
          }
          .layoutWeight(1)
          .padding({ left: 10, right: 10 })
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Start)
          .clip(false)

          // 右侧按钮区域
          Column({ space: 12 }) {
            Row({ space: 10 }) {
              this.renderFunctionButton('分度设定', 'image/rotor/correct.jpg', (): void => { this.openIndexDialog(); })
              this.renderFunctionButton('新增', 'image/rotor/add.png', (): void => { this.addRotor(); })
            }.width('100%').layoutWeight(1)

            Row({ space: 10 }) {
              this.renderFunctionButton('支撑方式', 'image/rotor/support.jpg', (): void => { this.openSupportWindow(); })
              this.renderFunctionButton('ISO计算', 'image/rotor/calcu.png', (): void => { this.openISOCalculate(); })
            }.width('100%').layoutWeight(1)

            Row({ space: 10 }) {
              this.renderFunctionButton('保存', 'image/rotor/save.png', (): void => { this.saveSettings(); })
              this.renderFunctionButton('删除', 'image/rotor/dele.jpg', (): void => { this.deleteRotor(); })
            }.width('100%').layoutWeight(1)
          }
          .width('19.2%')
          .height('92%')
          .padding({ top: 24, bottom: 24, left: 10, right: 10 })
          .margin({ left: 8, top: 10, bottom: 10 })
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#e6f3ff')
        .padding({ left: 16, right: 16, top: 16, bottom: 16 })
      }

      // 弹窗 - 使用条件渲染
      if (this.supportDialogVisible) {
        SupportDialog({
          initialMode: this.vm.zcfs,
          initialJsms: this.vm.Jsms,
          onConfirm: (mode: number, jsms: number) => {
            // 直接更新 ViewModel
            console.log('SupportDialog mode',mode);
            this.vm.zcfs = mode;
            this.vm.Jsms = jsms;
            this.vm.balanceMode = jsms === 0 ? '硬支撑' : '软支撑';
            this.loadMode(mode);
          },
          onClose: () => {
            this.supportDialogVisible = false;
          }
        })
      }

      if (this.indexDialogVisible) {
        IndexDialog({
          vm: this.vm,
          onClose: () => {
            this.indexDialogVisible = false;
            this.showTip("保存成功");
          }
        })
      }

      if (this.isoDialogVisible) {
        ISODialog({
          vm: this.vm,
          onClose: () => {
            this.isoDialogVisible = false;
            this.showTip(this.vm.tipMessage);
          }
        })
      }

      if (this.deleteDialogVisible) {
        DeleteDialog({
          onConfirm: () => this.confirmDelete(),
          onCancel: () => this.deleteDialogVisible = false
        })
      }

      if (this.tipDialogVisible) {
        TipDialog({
          message: this.tipMessage,
          onClose: () => this.closeTip()
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}