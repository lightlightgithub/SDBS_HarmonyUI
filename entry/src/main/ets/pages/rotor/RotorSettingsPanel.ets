import { SupportConfig, MeasurementMode, Margin, SelectOption } from './RotorSupportConfig';
import { RotorViewModel } from '../../viewmodels/rotor/RotorViewModel';
import { promptAction } from '@kit.ArkUI';

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
  // 转子选项 - 改为 @State 变量
  @State private rotorSelectOptions: SelectOption[] = [];
  private rotorNameToIdMap: Map<string, number> = new Map();
  // 弹窗相关状态
  @State private supportDialogVisible: boolean = false;
  @State private supportDialogMode: number = 2;
  @State private supportDialogJsms: number = 0;
  @State private indexDialogVisible: boolean = false;
  @State private isoDialogVisible: boolean = false;

  @State private addDialogVisible: boolean = false;
  @State private newRotorName: string = '';
  @State private deleteDialogVisible: boolean = false;

  private mainCanvasCtx: CanvasRenderingContext2D = new CanvasRenderingContext2D();
  private inCanvasCtx: CanvasRenderingContext2D = new CanvasRenderingContext2D();
  private arrowCanvasCtx: CanvasRenderingContext2D = new CanvasRenderingContext2D();
  private mainCanvasReady: boolean = false;
  private inCanvasReady: boolean = false;
  private arrowCanvasReady: boolean = false;
  private resizeTimer: number = -1;
  private supportVideoController: VideoController = new VideoController();

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

  @StorageLink('rotorSupportSelectedMode') private storedSupportMode: number = 2;
  @StorageLink('rotorSupportJsms') private storedSupportJsms: number = 0;

  aboutToAppear(): void {
    SupportConfig.init();
    if (this.vm.currentRotorId !== 0 && this.vm.rotorList.length > 0) {
      this.storedSupportMode = this.vm.zcfs;
      this.storedSupportJsms = this.vm.Jsms;
      this.loadMode(this.vm.zcfs);
      this.refreshRotorOptions();

      this.isDataLoaded = true;
    } else {
      this.loadData();
    }
  }
  async loadData(): Promise<void> {
    await this.vm.initAsync();
    this.storedSupportMode = this.vm.zcfs;
    this.storedSupportJsms = this.vm.Jsms;
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

  // 切换转子
  async onRotorSelect(rotorName: string): Promise<void> {
    const rotorId = this.rotorNameToIdMap.get(rotorName);
    if (rotorId) {
      const success = await this.vm.loadRotorById(rotorId);
      if (success) {
        this.storedSupportMode = this.vm.zcfs;
        this.storedSupportJsms = this.vm.Jsms;
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

  private saveSettings(): void {
    this.vm.saveRotor().then(ok => {
      this.refreshRotorOptions();
      if (ok) {
        this.storedSupportMode = this.vm.zcfs;
        this.storedSupportJsms = this.vm.Jsms;
        this.loadMode(this.vm.zcfs);

         promptAction.showDialog({
            title: '提示',
            message: '                           保存成功    ',
           buttons: [
              { text: '确定', color: '#007AFF' }
            ]
          });
        //this.showToast('保存成功');
      } else {
        promptAction.showToast({ message: this.vm.errorMessage });
      }
    });
  }
  private deleteRotor(): void {
    this.deleteDialogVisible = true;
  }

  private addRotor(): void {
    // 清空 ViewModel 数据
    this.vm.resetForm();
    this.isDataLoaded = false;
    this.storedSupportMode = this.vm.zcfs;
    this.storedSupportJsms = this.vm.Jsms;
    this.loadMode(this.vm.zcfs);
    this.refreshRotorOptions();
    setTimeout(() => {
      this.isDataLoaded = true;
      this.showToast('已新建转子，请输入参数后保存');
    }, 50);
  }

  private confirmDelete(): void {
    this.deleteDialogVisible = false;
    this.vm.deleteRotor().then(ok => {
      this.refreshRotorOptions();
      if (!ok) {
        this.showToast(this.vm.errorMessage);
      } else {
        this.showToast('转子已删除');
        this.storedSupportMode = this.vm.zcfs;
        this.storedSupportJsms = this.vm.Jsms;
        this.loadMode(this.vm.zcfs);
      }
    });
  }

  private confirmAddRotor(): void {
    if (this.newRotorName.trim().length === 0) {
      this.showToast('请输入转子名称');
      return;
    }
    this.vm.rotorName = this.newRotorName;
    this.vm.selectRotor = this.newRotorName;
    this.addDialogVisible = false;
    this.showToast('新增转子成功，请点击保存');
  }

  private openSupportWindow(): void {
    this.storedSupportMode = this.vm.zcfs;
    this.storedSupportJsms = this.vm.Jsms;
    this.supportDialogMode = this.vm.zcfs;
    this.supportDialogJsms = this.storedSupportJsms;
    this.supportDialogVisible = true;
  }

  private confirmSupportDialog(): void {
    this.vm.zcfs = this.supportDialogMode;
    this.vm.Jsms = this.supportDialogJsms;
    this.vm.balanceMode = this.supportDialogJsms === 0 ? '硬支撑' : '软支撑';
    this.storedSupportMode = this.supportDialogMode;
    this.storedSupportJsms = this.supportDialogJsms;
    this.loadMode(this.supportDialogMode);
    this.supportDialogVisible = false;
  }

  private showToast(message: string, duration: number = 1200): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message, duration });
    } catch (error) {
      console.error(`showToast failed: ${JSON.stringify(error)}`);
    }
  }

  private getFilteredSupportModes(): number[] {
    const all = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
    if (this.supportDialogJsms === 1) {
      return all.filter((i: number): boolean => ![2, 4, 5, 7, 8, 9, 10].includes(i));
    }
    return all;
  }

  private switchSupportDialogMode(modeId: number): void {
    if (this.supportDialogMode === modeId) return;
    try {
      this.supportVideoController.pause();
    } catch (e) {}
    this.supportDialogMode = modeId;
    try {
      this.supportVideoController.stop();
    } catch (e) {}
    setTimeout((): void => {
      try {
        this.supportVideoController.start();
      } catch (e) {}
    }, 100);
  }

  private closeSupportDialog(): void {
    try {
      this.supportVideoController.pause();
      this.supportVideoController.stop();
    } catch (e) {}
    this.supportDialogVisible = false;
  }

  private openIndexDialog(): void {
    this.indexDialogVisible = true;
  }

  private openISOCalculate(): void {
    this.vm.isoResult = '';
    this.isoDialogVisible = true;
  }

  @Builder
  private renderParamInput(label: string, value: string, onChange: (v: string) => void, pos: Margin) {
    Column({ space: 2 }) {
      TextInput({ text: value })
        .width(65)
        .height(40)
        .borderRadius(20)
        .backgroundColor('#ffffff')
        .border({ width: 1, color: '#00aaff' })
        .fontSize(14)
        .textAlign(TextAlign.Center)
        .onChange((val: string): void => { onChange(val); });
      Text(label)
        .fontSize(14)
        .fontColor('#333');
    }
    .position({ x: pos.left, y: pos.top })
    .zIndex(100);
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
                    this.storedSupportJsms = this.vm.Jsms;
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
                // 背景图片
                Image($rawfile(this.currentModeImage))
                  .width(this.displayWidth)
                  .height(this.displayHeight)
                  .objectFit(ImageFit.Fill)
                  .position({ x: this.offsetX, y: this.offsetY })
                  .zIndex(1)

                // 画布
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

                // ========== 输入框 A ==========
                Column({ space: 2 }) {
                  TextInput({ text: this.vm.rotorA })
                    .width(65)
                    .height(40)
                    .borderRadius(20)
                    .backgroundColor('#ffffff')
                    .border({ width: 1, color: '#00aaff' })
                    .fontSize(14)
                    .textAlign(TextAlign.Center)
                    .onChange(v => this.vm.rotorA = v)
                  Text('A')
                    .fontSize(14)
                    .fontColor('#333')
                }
                .position(this.aPos)
                .zIndex(100)

                // ========== 输入框 B ==========
                Column({ space: 2 }) {
                  TextInput({ text: this.vm.rotorB })
                    .width(65)
                    .height(40)
                    .borderRadius(20)
                    .backgroundColor('#ffffff')
                    .border({ width: 1, color: '#00aaff' })
                    .fontSize(14)
                    .textAlign(TextAlign.Center)
                    .onChange(v => this.vm.rotorB = v)
                  Text('B')
                    .fontSize(14)
                    .fontColor('#333')
                }
                .position(this.bPos)
                .zIndex(100)

                // ========== 输入框 C ==========
                Column({ space: 2 }) {
                  TextInput({ text: this.vm.rotorC })
                    .width(65)
                    .height(40)
                    .borderRadius(20)
                    .backgroundColor('#ffffff')
                    .border({ width: 1, color: '#00aaff' })
                    .fontSize(14)
                    .textAlign(TextAlign.Center)
                    .onChange(v => this.vm.rotorC = v)
                  Text('C')
                    .fontSize(14)
                    .fontColor('#333')
                }
                .position(this.cPos)
                .zIndex(100)

                // ========== 输入框 R1 ==========
                Column({ space: 2 }) {
                  TextInput({ text: this.vm.rotorR1 })
                    .width(65)
                    .height(40)
                    .borderRadius(20)
                    .backgroundColor('#ffffff')
                    .border({ width: 1, color: '#00aaff' })
                    .fontSize(14)
                    .textAlign(TextAlign.Center)
                    .onChange(v => this.vm.rotorR1 = v)
                  Text('R1')
                    .fontSize(14)
                    .fontColor('#333')
                }
                .position(this.r1Pos)
                .zIndex(100)

                // ========== 输入框 R2 ==========
                Column({ space: 2 }) {
                  TextInput({ text: this.vm.rotorR2 })
                    .width(65)
                    .height(40)
                    .borderRadius(20)
                    .backgroundColor('#ffffff')
                    .border({ width: 1, color: '#00aaff' })
                    .fontSize(14)
                    .textAlign(TextAlign.Center)
                    .onChange(v => this.vm.rotorR2 = v)
                  Text('R2')
                    .fontSize(14)
                    .fontColor('#333')
                }
                .position(this.r2Pos)
                .zIndex(100)

                // ========== 输入框 转速 ==========
                Column({ space: 2 }) {
                  TextInput({ text: this.vm.rotorSpeed })
                    .width(65)
                    .height(40)
                    .borderRadius(20)
                    .backgroundColor('#ffffff')
                    .border({ width: 1, color: '#00aaff' })
                    .fontSize(14)
                    .textAlign(TextAlign.Center)
                    .onChange(v => this.vm.rotorSpeed = v)
                  Text('转速')
                    .fontSize(14)
                    .fontColor('#333')
                }
                .position(this.speedPos)
                .zIndex(100)
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

      // 弹窗
      if (this.supportDialogVisible) {
        this.renderSupportDialog()
      }
      if (this.indexDialogVisible) {
        this.renderIndexDialog()
      }
      if (this.isoDialogVisible) {
        this.renderISODialog()
      }
      if (this.addDialogVisible) {
        this.renderAddDialog()
      }
      if (this.deleteDialogVisible) {
        this.renderDeleteDialog()
      }
    }
    .width('100%')
    .height('100%')
  }

  // 弹窗 Builder 方法
  @Builder
  private renderSupportDialog() {
    Stack({ alignContent: Alignment.Center }) {
      Column().width('100%').height('100%').backgroundColor('rgba(0,0,0,0.18)').onClick(() => this.closeSupportDialog())

      Column({ space: 14 }) {
        Row() {
          Text('请选择支撑方式').fontSize(20).fontWeight(FontWeight.Medium).fontColor('#333')
          Blank().layoutWeight(1)
          Button() {
            Image($rawfile('image/login/icon_close.png')).width(18).height(18).objectFit(ImageFit.Contain)
          }
          .width(34).height(34).padding(0).backgroundColor(Color.Transparent).border({ width: 0 }).borderRadius(0)
          .onClick(() => this.closeSupportDialog())
        }.width('100%').alignItems(VerticalAlign.Center)

        Row({ space: 18 }) {
          Column() {
            Grid() {
              ForEach(this.getFilteredSupportModes(), (i: number) => {
                GridItem() {
                  Column({ space: 8 }) {
                    Image($r(`app.media.supportmodel${i}`)).width(146).height(118).objectFit(ImageFit.Contain)
                    Text(`模式${i}`).fontSize(16).fontColor('#222')
                  }
                  .width('100%').padding({ left: 8, right: 8, top: 10, bottom: 10 })
                  .backgroundColor(this.supportDialogMode === i ? '#ccebff' : '#ffffff')
                  .border({
                    width: this.supportDialogMode === i ? 2 : 1,
                    color: this.supportDialogMode === i ? '#0099ff' : '#d6dee8'
                  }).borderRadius(8)
                  .onClick(() => this.switchSupportDialogMode(i))
                }
              })
            }
            .columnsTemplate('1fr 1fr 1fr 1fr').columnsGap(10).rowsGap(10).width('100%').layoutWeight(1)
          }
          .width('60%').height('100%').padding({ top: 4, bottom: 4, left: 4, right: 4 }).backgroundColor('#e6f3ff')

          Column() {
            Video({
              src: $rawfile(`videomodel${this.supportDialogMode}.mp4`),
              controller: this.supportVideoController
            })
              .width('100%').height('100%').autoPlay(true).loop(true).muted(true).controls(false).objectFit(ImageFit.Cover)
          }
          .width('40%').height('100%').backgroundColor('#d8edf7').borderRadius(6).clip(true).justifyContent(FlexAlign.Center)
        }.width('100%').layoutWeight(1)

        Row() {
          Blank().layoutWeight(1)
          Button('确认').width(98).height(44).backgroundColor('#44b7ff').fontColor('#ffffff').fontSize(18).borderRadius(6)
            .onClick(() => this.confirmSupportDialog())
        }.width('100%').padding({ top: 6, bottom: 4 })
      }
      .width('94%').height('88%').padding({ left: 24, right: 24, top: 18, bottom: 18 })
      .backgroundColor('#e6f3ff').borderRadius(14).shadow({ radius: 20, color: 'rgba(0,0,0,0.18)', offsetX: 0, offsetY: 8 })
    }
    .width('100%').height('100%').zIndex(20)
  }

  @Builder
  private renderIndexDialog() {
    Stack({ alignContent: Alignment.Center }) {
      Column().width('100%').height('100%').backgroundColor('rgba(0,0,0,0.18)').onClick(() => { this.indexDialogVisible = false })

      Column({ space: 16 }) {
        Row() {
          Text('分度设定').fontSize(20).fontWeight(FontWeight.Medium).fontColor('#333')
          Blank().layoutWeight(1)
          Button() {
            Image($rawfile('image/login/icon_close.png')).width(18).height(18).objectFit(ImageFit.Contain)
          }
          .width(34).height(34).padding(0).backgroundColor(Color.Transparent).border({ width: 0 }).borderRadius(0)
          .onClick(() => { this.indexDialogVisible = false })
        }.width('100%').alignItems(VerticalAlign.Center)

        // 用 Scroll 包裹 Grid
        Scroll() {
          Grid() {
            GridItem() {
              Column({ space: 6 }) {
                Text('平面1起始角度').fontSize(15).fontColor('#555')
                TextInput({ text: this.vm.indexAngle1 }).width('100%').height(44).backgroundColor('#ccebff')
                  .border({ width: 0 }).borderRadius(8).fontSize(15)
                  .onChange((v: string): void => { this.vm.indexAngle1 = v })
              }.alignItems(HorizontalAlign.Start)
            }
            GridItem() {
              Column({ space: 6 }) {
                Text('平面1分度数量').fontSize(15).fontColor('#555')
                TextInput({ text: this.vm.indexNumber1 }).width('100%').height(44).backgroundColor('#ccebff')
                  .border({ width: 0 }).borderRadius(8).fontSize(15)
                  .onChange((v: string): void => { this.vm.indexNumber1 = v })
              }.alignItems(HorizontalAlign.Start)
            }
            GridItem() {
              Column({ space: 6 }) {
                Text('平面2起始角度').fontSize(15).fontColor('#555')
                TextInput({ text: this.vm.indexAngle2 }).width('100%').height(44).backgroundColor('#ccebff')
                  .border({ width: 0 }).borderRadius(8).fontSize(15)
                  .onChange((v: string): void => { this.vm.indexAngle2 = v })
              }.alignItems(HorizontalAlign.Start)
            }
            GridItem() {
              Column({ space: 6 }) {
                Text('平面2分度数量').fontSize(15).fontColor('#555')
                TextInput({ text: this.vm.indexNumber2 }).width('100%').height(44).backgroundColor('#ccebff')
                  .border({ width: 0 }).borderRadius(8).fontSize(15)
                  .onChange((v: string): void => { this.vm.indexNumber2 = v })
              }.alignItems(HorizontalAlign.Start)
            }
            GridItem() {
              Column({ space: 6 }) {
                Text('静平面起始角度').fontSize(15).fontColor('#555')
                TextInput({ text: this.vm.indexAngleS }).width('100%').height(44).backgroundColor('#ccebff')
                  .border({ width: 0 }).borderRadius(8).fontSize(15)
                  .onChange((v: string): void => { this.vm.indexAngleS = v })
              }.alignItems(HorizontalAlign.Start)
            }
            GridItem() {
              Column({ space: 6 }) {
                Text('静平面分度数量').fontSize(15).fontColor('#555')
                TextInput({ text: this.vm.indexNumberS }).width('100%').height(44).backgroundColor('#ccebff')
                  .border({ width: 0 }).borderRadius(8).fontSize(15)
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
        .constraintSize({ maxHeight: 400 })  // 限制最大高度

        Row() {
          Blank().layoutWeight(1)
          Button('保存').width(98).height(44).backgroundColor('#44b7ff').fontColor('#fff').fontSize(18).borderRadius(6)
            .onClick(() => { this.vm.saveIndexSettings() })
        }.width('100%').padding({ top: 4 })
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

  @Builder
  private renderISODialog() {
    Stack({ alignContent: Alignment.Center }) {
      Column().width('100%').height('100%').backgroundColor('rgba(0,0,0,0.18)').onClick(() => { this.isoDialogVisible = false })

      Column({ space: 18 }) {
        Row() {
          Text('ISO公差计算').fontSize(20).fontWeight(FontWeight.Medium).fontColor('#333')
          Blank().layoutWeight(1)
          Button() {
            Image($rawfile('image/login/icon_close.png')).width(18).height(18).objectFit(ImageFit.Contain)
          }
          .width(34).height(34).padding(0).backgroundColor(Color.Transparent).border({ width: 0 }).borderRadius(0)
          .onClick(() => { this.isoDialogVisible = false })
        }.width('100%').alignItems(VerticalAlign.Center)

        Column({ space: 14 }) {
          Column({ space: 6 }) {
            Text('平衡等级 (G)').fontSize(15).fontColor('#555')
            Select([
              { value: '0.4' }, { value: '1' }, { value: '2.5' }, { value: '6.3' },
              { value: '16' }, { value: '40' }, { value: '100' }, { value: '250' },
              { value: '630' }, { value: '1600' }, { value: '4000' }
            ]).value(this.vm.isoGrade).width('100%').height(48).backgroundColor('#ccebff')
              .border({ width: 0 }).borderRadius(8).font({ size: 15 })
              .onSelect((_i: number, v: string): void => { this.vm.isoGrade = v })
          }.alignItems(HorizontalAlign.Start).width('100%')

          Column({ space: 6 }) {
            Text('工作转速 (r/min)').fontSize(15).fontColor('#555')
            TextInput({ text: this.vm.isoSpeed }).width('100%').height(48).backgroundColor('#ccebff')
              .border({ width: 0 }).borderRadius(8).fontSize(15)
              .onChange((v: string): void => { this.vm.isoSpeed = v })
          }.alignItems(HorizontalAlign.Start).width('100%')

          Column({ space: 6 }) {
            Text('工件重量 (KG)').fontSize(15).fontColor('#555')
            TextInput({ text: this.vm.isoWeight }).width('100%').height(48).backgroundColor('#ccebff')
              .border({ width: 0 }).borderRadius(8).fontSize(15)
              .onChange((v: string): void => { this.vm.isoWeight = v })
          }.alignItems(HorizontalAlign.Start).width('100%')

          if (this.vm.isoResult !== '') {
            Text(this.vm.isoResult).fontSize(17).fontColor('#0066cc').fontWeight(FontWeight.Medium).padding({ top: 4, bottom: 4 })
          }
        }.width('100%')

        Row() {
          Blank().layoutWeight(1)
          Button('计算').width(98).height(44).backgroundColor('#44b7ff').fontColor('#fff').fontSize(18).borderRadius(6)
            .onClick(() => { this.vm.calcISO() })
        }.width('100%').padding({ top: 4 })
      }
      .width('46%').padding({ left: 28, right: 28, top: 22, bottom: 22 })
      .backgroundColor('#e6f3ff').borderRadius(14).shadow({ radius: 20, color: 'rgba(0,0,0,0.18)', offsetX: 0, offsetY: 8 })
    }
    .width('100%').height('100%').zIndex(20)
  }

  @Builder
  private renderAddDialog() {
    Stack({ alignContent: Alignment.Center }) {
      Column().width('100%').height('100%').backgroundColor('rgba(0,0,0,0.18)').onClick(() => { this.addDialogVisible = false })

      Column({ space: 20 }) {
        Row() {
          Text('新增转子').fontSize(20).fontWeight(FontWeight.Medium).fontColor('#333')
          Blank().layoutWeight(1)
          Button() {
            Image($rawfile('image/login/icon_close.png')).width(18).height(18).objectFit(ImageFit.Contain)
          }
          .width(34).height(34).padding(0).backgroundColor(Color.Transparent).border({ width: 0 }).borderRadius(0)
          .onClick(() => { this.addDialogVisible = false })
        }.width('100%').alignItems(VerticalAlign.Center)

        Column({ space: 6 }) {
          Text('转子名称').fontSize(15).fontColor('#555')
          TextInput({ placeholder: '请输入转子名称', text: this.newRotorName })
            .width('100%').height(50).backgroundColor('#ccebff')
            .border({ width: 0 }).borderRadius(8).fontSize(16)
            .onChange((v: string): void => { this.newRotorName = v })
        }.alignItems(HorizontalAlign.Start).width('100%')

        Row() {
          Blank().layoutWeight(1)
          Button('确认').width(98).height(44).backgroundColor('#44b7ff').fontColor('#fff').fontSize(18).borderRadius(6)
            .onClick(() => this.confirmAddRotor())
        }.width('100%').padding({ top: 4 })
      }
      .width('44%').padding({ left: 28, right: 28, top: 22, bottom: 22 })
      .backgroundColor('#e6f3ff').borderRadius(14).shadow({ radius: 20, color: 'rgba(0,0,0,0.18)', offsetX: 0, offsetY: 8 })
    }
    .width('100%').height('100%').zIndex(20)
  }

  @Builder
  private renderDeleteDialog() {
    Stack({ alignContent: Alignment.Center }) {
      Column().width('100%').height('100%').backgroundColor('rgba(0,0,0,0.18)').onClick(() => { this.deleteDialogVisible = false })

      Column({ space: 22 }) {
        Text('删除确认').fontSize(20).fontWeight(FontWeight.Medium).fontColor('#333').width('100%')
        Text('确认删除当前转子？此操作不可撤销。').fontSize(16).fontColor('#555').width('100%')

        Row({ space: 14 }) {
          Blank().layoutWeight(1)
          Button('取消').width(88).height(44).backgroundColor('#ccc').fontColor('#333').fontSize(16).borderRadius(6)
            .onClick(() => { this.deleteDialogVisible = false })
          Button('确认删除').width(108).height(44).backgroundColor('#ff4d4f').fontColor('#fff').fontSize(16).borderRadius(6)
            .onClick(() => this.confirmDelete())
        }.width('100%')
      }
      .width('42%').padding({ left: 28, right: 28, top: 26, bottom: 26 })
      .backgroundColor('#e6f3ff').borderRadius(14).shadow({ radius: 20, color: 'rgba(0,0,0,0.18)', offsetX: 0, offsetY: 8 })
    }
    .width('100%').height('100%').zIndex(20)
  }
}