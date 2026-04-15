/**
 * DashboardPage —— 主页 Shell 容器
 * 布局参照原项目 Main.xaml：顶部栏 | 内容区 | 底部工具栏
 * 底部工具栏始终可见，内容区根据选中按钮切换对应模块
 */

 import promptAction from '@ohos.promptAction';
 import router from '@ohos.router';
 import { SupportConfig, MeasurementMode, Margin, SelectOption } from './RotorSupportConfig';

/** 工具栏按钮描述（NavItem 避免与 ArkUI 内置 ToolbarItem 冲突） */
interface NavItem {
  id: string;      // 模块唯一标识
  label: string;   // 按钮文字
  imgOff: string;  // 未选中图片路径（rawfile 相对路径）
  imgOn: string;   // 选中图片路径（rawfile 相对路径）
}

/** 工具栏按钮列表（顺序与原项目 UniformGrid 一致） */
const TOOLBAR_ITEMS: NavItem[] = [
  { id: 'start',  label: '开始',   imgOff: 'image/main/btn_start_off.png',  imgOn: 'image/main/btn_start_on.png'  },
  { id: 'stop',   label: '暂停',   imgOff: 'image/main/btn_stop_off.png',   imgOn: 'image/main/btn_stop_on.png'   },
  { id: 'cal',    label: '标定',   imgOff: 'image/main/btn_cal_off.png',    imgOn: 'image/main/btn_cal_on.png'    },
  { id: 'rotor',  label: '转子设置', imgOff: 'image/main/btn_rotor_off.png', imgOn: 'image/main/btn_rotor_on.png' },
  { id: 'mach',   label: '机器设置', imgOff: 'image/main/btn_mach_off.png',  imgOn: 'image/main/btn_mach_on.png'  },
  { id: 'step',   label: '单步',   imgOff: 'image/main/btn_step_off.png',   imgOn: 'image/main/btn_step_on.png'   },
  { id: 'vib',    label: '转速振动', imgOff: 'image/main/btn_vib_off.png',   imgOn: 'image/main/btn_vib_on.png'   },
  { id: 'clamp',  label: '夹具补偿', imgOff: 'image/main/btn_clamp_off.png', imgOn: 'image/main/btn_clamp_on.png' },
  { id: 'pos',    label: '定位',   imgOff: 'image/main/btn_pos_off.png',    imgOn: 'image/main/btn_pos_on.png'    },
  { id: 'user',   label: '用户管理', imgOff: 'image/main/btn_user_off.png',  imgOn: 'image/main/btn_user_on.png'  },
  { id: 'print',  label: '打印',   imgOff: 'image/main/btn_print_off.png',  imgOn: 'image/main/btn_print_on.png'  },
  { id: 'record', label: '记录',   imgOff: 'image/main/btn_record_off.png', imgOn: 'image/main/btn_record_on.png' },
  { id: 'alarm',  label: '报警',   imgOff: 'image/main/btn_alarm_off.png',  imgOn: 'image/main/btn_alarm_on.png'  },
  { id: 'exit',   label: '退出',   imgOff: 'image/main/btn_exit_off.png',   imgOn: 'image/main/btn_exit_off.png'  },
];

@Entry
@Component
struct DashboardPage {
  @State private activeTab: string = 'start'; // 当前选中工具栏项
  @State private speed: number = 0;            // 转速显示（后续对接设备数据）
  @State private timeStr: string = '--:--:--';
  @State private dateStr: string = '----.--.--.';
  private timer: number = -1;

  /** 页面显示时启动时钟定时器 */
  aboutToAppear(): void {
    this.updateTime();
    this.timer = setInterval(() => {
      this.updateTime();
    }, 1000);
  }
     /** 页面销毁时清理定时器 */
  aboutToDisappear(): void {
    if (this.timer !== -1) {
      clearInterval(this.timer);
    }
  }

  /** 更新顶部时钟和日期文字 */
  private updateTime(): void {
    const now = new Date();
    const pad = (n: number): string => n.toString().padStart(2, '0');
    this.timeStr = `${pad(now.getHours())}:${pad(now.getMinutes())}:${pad(now.getSeconds())}`;
    this.dateStr = `${now.getFullYear()}.${pad(now.getMonth() + 1)}.${pad(now.getDate())}`;
  }

  /** 工具栏按钮点击：退出返回登录页，其余切换内容区 */
  private onToolbarClick(id: string): void {
    if (id === 'exit') {
      this.getUIContext().getRouter().replaceUrl({ url: 'pages/auth/LoginPage' })
        .catch((err: Error) => { console.error('replaceUrl failed:', err.message); });
      return;
    }
    this.activeTab = id;
  }

  /** 内容区：根据 activeTab 分发到对应模块 */
  @Builder
  buildContent() {
    if (this.activeTab === 'start' || this.activeTab === 'stop') {
      this.buildMeasureContent();
    } else if (this.activeTab === 'rotor') {
      RotorSettingsPanel();
    } else {
      Column() {
        Text(this.activeTab)
          .fontSize(22).fontColor('#2a5a8a').opacity(0.4)
      }
      .width('100%').height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
  }

  /** 测量主界面：进度条 + 左右平面 + 左右竖向电平柱 + 底部状态栏（参照 PageHorTwo.xaml） */
  @Builder
  buildMeasureContent() {
    Column() {
      // 顶部测量进度条
      Progress({ value: 0, total: 100, type: ProgressType.Linear })
        .width('70%').height(18)
        .color('#5ab5d0').backgroundColor('#c8e8f4')
        .margin({ top: 6, bottom: 2 })

      // 主内容：左偶郠检 + 双平面 + 右其郠检
      Row() {
        // 左側边栏（加重图标来自原项目 Measure/加重.png + 竖向分段电平）
        Column() {
          Image($rawfile('image/main/jiazhong.png'))
            .width(50).height(28).objectFit(ImageFit.Contain).margin({ bottom: 6 })
          this.buildVerticalBar(0)
        }
        .width(64).height('100%')
        .alignItems(HorizontalAlign.Center)
        .padding({ top: 8, bottom: 16 })

        // 左平面：靶图 + 表 + 底部滑块
        Column() {
          this.buildPolarChart()
          this.buildDataTable('校正平面1', 0.000, 0.000, 0.000, 0.000)
          Slider({ value: 0, min: 0, max: 100 })
            .width('100%').enabled(false)
            .trackThickness(6)
            .selectedColor('#5ab5d0').trackColor('#c0e8f4')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .padding({ left: 4, right: 8, top: 8, bottom: 8 })
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)

        // 右平面：靶图 + 表 + 底部滑块
        Column() {
          this.buildPolarChart()
          this.buildDataTable('校正平面2', 0.000, 0.000, 0.000, 0.000)
          Slider({ value: 0, min: 0, max: 100 })
            .width('100%').enabled(false)
            .trackThickness(6)
            .selectedColor('#5ab5d0').trackColor('#c0e8f4')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .padding({ left: 8, right: 4, top: 8, bottom: 8 })
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)

        // 右側边栏
        Column() {
          Image($rawfile('image/main/jiazhong.png'))
            .width(50).height(28).objectFit(ImageFit.Contain).margin({ bottom: 6 })
          this.buildVerticalBar(0)
        }
        .width(64).height('100%')
        .alignItems(HorizontalAlign.Center)
        .padding({ top: 8, bottom: 16 })
      }
      .width('100%').layoutWeight(1)

      // 底部状态栏（转子信息 + 在线状态）
      Row() {
        Text('转子名称:JP1;支撑方式:模式一;测量转速:700')
          .fontSize(13).fontColor('#2a5a8a')
        Blank()
        Row({ space: 20 }) {
          Row({ space: 4 }) {
            Circle({ width: 14, height: 14 }).fill('#80c8e8')
            Text('开启定位').fontSize(13).fontColor('#2a5a8a')
          }
          Row({ space: 4 }) {
            Circle({ width: 14, height: 14 }).fill('#80c8e8')
            Text('采集板在线').fontSize(13).fontColor('#2a5a8a')
          }
          Row({ space: 4 }) {
            Circle({ width: 14, height: 14 }).fill('#80c8e8')
            Text('控制板在线').fontSize(13).fontColor('#2a5a8a')
          }
        }
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 5, bottom: 5 })
      .backgroundColor('#ddeef8')
    }
    .width('100%').height('100%')
  }

  /** 左/右側面竖向分段电平柱（参照原项目 leftpro/rightpro ProgressBar） */
  @Builder
  buildVerticalBar(level: number) {
    Column({ space: 2 }) {
      ForEach(
        [11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0],
        (i: number) => {
          Row()
            .width(32).height(14)
            .backgroundColor(i < level ? '#4ab8d0' : '#c8eaf4')
            .border({ width: 1, color: '#90c8e0', radius: 1 })
        },
        (i: number) => i.toString()
      )
    }
    .layoutWeight(1)
  }

  /** 极坐标靶图：同心圆 + 十字线 + 角度标注 + 测量点 */
  @Builder
  buildPolarChart() {
    PolarChart();
  }

  /** 平面数据表：标题行 + 当前值行 + 上一次行 */
  @Builder
  buildDataTable(planeName: string, curVal: number, curAng: number, lastVal: number, lastAng: number) {
    Column() {
      // 表头（国标平面符号图标来自原项目 SDBS.Ucs/Image/mainljph1/2.png）
      Row() {
        Image($rawfile(planeName === '校正平面1'
          ? 'image/main/plane1_icon.png'
          : 'image/main/plane2_icon.png'))
          .width(22).height(22).objectFit(ImageFit.Contain).margin({ right: 4 })
        Text(planeName).fontSize(14).fontColor('#2a6a9a').layoutWeight(1)
        Text('量值[g]').fontSize(13).fontColor('#4a7a9a').width(80).textAlign(TextAlign.Center)
        Text('角度[°]').fontSize(13).fontColor('#4a7a9a').width(80).textAlign(TextAlign.Center)
        Text('4 Tol')
          .fontSize(12).fontColor(Color.White)
          .backgroundColor('#4a9ac0')
          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
          .borderRadius(4).margin({ left: 4 })
      }
      .width('100%').padding({ top: 6, bottom: 6, left: 8, right: 8 })
      .backgroundColor('#d0eaf8')
      .border({ width: { left: 3 }, color: '#4a9ac0' })

      // 当前值
      Row() {
        Text('当前值').fontSize(14).fontColor('#6a8aa0').width(60)
        Text(curVal.toFixed(3))
          .fontSize(26).fontColor('#1a80c0').fontWeight(FontWeight.Bold)
          .layoutWeight(1).textAlign(TextAlign.Center)
        Text(curAng.toFixed(3))
          .fontSize(26).fontColor('#1a80c0').fontWeight(FontWeight.Bold)
          .layoutWeight(1).textAlign(TextAlign.Center)
      }
      .width('100%').padding({ top: 10, bottom: 10, left: 8 })
      .backgroundColor('#f0f8fc')

      // 上一次
      Row() {
        Text('上一次').fontSize(14).fontColor('#6a8aa0').width(60)
        Text(lastVal.toFixed(3))
          .fontSize(26).fontColor('#1a80c0').fontWeight(FontWeight.Bold)
          .layoutWeight(1).textAlign(TextAlign.Center)
        Text(lastAng.toFixed(3))
          .fontSize(26).fontColor('#1a80c0').fontWeight(FontWeight.Bold)
          .layoutWeight(1).textAlign(TextAlign.Center)
      }
      .width('100%').padding({ top: 10, bottom: 10, left: 8 })
      .backgroundColor('#e4f4f8')
    }
    .width('100%')
    .border({ width: 1, color: '#a0cce0', radius: 4 })
    .margin({ top: 10 })
  }

  build() {
    Stack() {
      // 主体背景图
      Image($rawfile('image/main/bg.png'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

      Column() {

        // ── 顶部栏 ─────────────────────────────────────────────
        Row() {
          // 左：剑平 logo
          Image($rawfile('image/main/logo.png'))
            .width(240)
            .height(80)
            .objectFit(ImageFit.Contain)
            .padding({ left: 10 })

          // 中：菜单按钮 + 转速（参照 Main.xaml 顶栏五列布局）
          Row() {
            // 菜单扩展
            Text('菜单扩展')
              .fontSize(15).fontColor('#1a5a9a')
              .padding({ left: 18, right: 18, top: 7, bottom: 7 })
              .backgroundColor('#b8ddf0')
              .border({ width: 1, color: '#80c0e0', radius: 8 })
              .margin({ left: 10, right: 6 })
              .bindMenu([
                { value: '语言',     action: () => {} },
                { value: '主题颜色', action: () => {} },
                { value: '关于SDBS', action: () => {} },
              ])
            // 加去重
            Text('加去重')
              .fontSize(15).fontColor('#1a5a9a')
              .padding({ left: 18, right: 18, top: 7, bottom: 7 })
              .backgroundColor('#b8ddf0')
              .border({ width: 1, color: '#80c0e0', radius: 8 })
              .margin({ right: 6 })
              .bindMenu([
                { value: '平面1加重', action: () => {} },
                { value: '平面2加重', action: () => {} },
                { value: '静加重',   action: () => {} },
              ])
            // 转速（居中，占剩余空间）
            Row({ space: 6 }) {
              Text(this.speed.toString())
                .fontSize(52)
                .fontColor('#2a5a8a')
                .fontWeight(FontWeight.Bold)
              Text('r/min')
                .fontSize(28)
                .fontColor('#4a7a9a')
                .margin({ top: 16 })
            }
            .layoutWeight(1)
            .justifyContent(FlexAlign.Center)
            // 电补偿
            Text('电补偿')
              .fontSize(15).fontColor('#1a5a9a')
              .padding({ left: 18, right: 18, top: 7, bottom: 7 })
              .backgroundColor('#b8ddf0')
              .border({ width: 1, color: '#80c0e0', radius: 8 })
              .margin({ left: 6, right: 6 })
            // 帮助
            Text('帮助')
              .fontSize(15).fontColor('#1a5a9a')
              .padding({ left: 18, right: 18, top: 7, bottom: 7 })
              .backgroundColor('#b8ddf0')
              .border({ width: 1, color: '#80c0e0', radius: 8 })
              .margin({ right: 10 })
          }
          .layoutWeight(1)
          .alignItems(VerticalAlign.Center)

          // 右：时间 / 日期
          Column() {
            Text(this.timeStr)
              .fontSize(28)
              .fontColor('#2a5a8a')
              .fontWeight(FontWeight.Medium)
            Text(this.dateStr)
              .fontSize(20)
              .fontColor('#4a7a9a')
          }
          .width(240)
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
        }
        .width('100%')
        .height(80)

        // ── 内容区 ─────────────────────────────────────────────
        Column() {
          this.buildContent()
        }
        .width('100%')
        .layoutWeight(1)

        // ── 底部工具栏 ─────────────────────────────────────────
        Stack() {
          // 工具栏背景图
          Image($rawfile('image/main/toolbar_bg.png'))
            .width('100%')
            .height(120)
            .objectFit(ImageFit.Fill)

          // 按钮列表
          Row() {
            ForEach(TOOLBAR_ITEMS, (item: NavItem) => {
              Stack() {
                // 选中时显示高亮背景
                if (this.activeTab === item.id) {
                  Image($rawfile('image/main/btn_selected_bg.png'))
                    .width('100%')
                    .height(120)
                    .objectFit(ImageFit.Fill)
                }

                // 图标 + 文字
                Column({ space: 8 }) {
                  Image(this.activeTab === item.id
                    ? $rawfile(item.imgOn)
                    : $rawfile(item.imgOff))
                    .width(60)
                    .height(60)
                    .objectFit(ImageFit.Contain)
                  Text(item.label)
                    .fontSize(17)
                    .fontColor('#2a5a8a')
                    .fontWeight(this.activeTab === item.id ? FontWeight.Bold : FontWeight.Normal)
                }
                .width('100%')
                .height(120)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
              }
              .layoutWeight(1)
              .height(120)
              .onClick(() => {
                this.onToolbarClick(item.id);
              })
            }, (item: NavItem) => item.id)
          }
          .width('100%')
          .height(120)
        }
        .width('100%')
        .height(120)

      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }
}

@Component
struct RotorSettingsPanel {
  @State private zcfs: number = 2;
  @Watch('onStoredSupportModeChange')
  @StorageLink('rotorSupportSelectedMode') private storedSupportMode: number = 2;
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

  aboutToAppear(): void {
    this.storedSupportMode = this.zcfs;
    this.storedSupportJsms = this.balanceMode === '硬支撑' ? 0 : 1;
    SupportConfig.init();
    this.loadMode(this.zcfs);
  }

  private onStoredSupportModeChange(): void {
    if (this.storedSupportMode >= 1 && this.storedSupportMode <= 11 && this.storedSupportMode !== this.zcfs) {
      this.loadMode(this.storedSupportMode);
    }
  }

  private onStoredSupportJsmsChange(): void {
    const nextBalanceMode = this.storedSupportJsms === 0 ? '硬支撑' : '软支撑';
    if (this.balanceMode !== nextBalanceMode) {
      this.balanceMode = nextBalanceMode;
      this.syncSupportModeForBalanceMode();
    }
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
    if (this.balanceMode === '软支撑') {
      return allModes.filter((modeId: number): boolean => ![2, 4, 5, 7, 8, 9, 10].includes(modeId));
    }
    return allModes;
  }

  private syncSupportModeForBalanceMode(): void {
    const filteredModes = this.getFilteredModes();
    if (filteredModes.length === 0) {
      return;
    }
    if (!filteredModes.includes(this.zcfs)) {
      this.loadMode(filteredModes[0]);
    }
  }

  private openSupportWindow(): void {
    const filteredModes = this.getFilteredModes();
    if (filteredModes.length === 0) {
      promptAction.showToast({ message: '当前解算模式下无可选支撑方式', duration: 1200 });
      return;
    }
    this.storedSupportMode = filteredModes.includes(this.zcfs) ? this.zcfs : filteredModes[0];
    this.storedSupportJsms = this.balanceMode === '硬支撑' ? 0 : 1;
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
              this.renderFormItem('转子名称', this.rotorName, (v: string): void => { this.rotorName = v; });
              this.renderFormItem('允许量单位', this.allowUnit, (v: string): void => { this.allowUnit = v; }, this.allowUnitOptions);
              this.renderFormItem('静允许量', this.staticAllow, (v: string): void => { this.staticAllow = v; });
              this.renderFormItem('平面一允许量', this.plane1Allow, (v: string): void => { this.plane1Allow = v; });
              this.renderFormItem('平面二允许量', this.plane2Allow, (v: string): void => { this.plane2Allow = v; });
            }
            .width('50%')
            .alignItems(HorizontalAlign.Start)

            Column({ space: 20 }) {
              this.renderFormItem('选择转子', this.selectRotor, (v: string): void => { this.selectRotor = v; }, this.rotorOptions);
              this.renderFormItem('测量模式', this.measureMode, (v: string): void => { this.measureMode = v; }, this.measureModeOptions);
              this.renderFormItem('解算模式', this.balanceMode, (v: string): void => {
                this.balanceMode = v;
                this.storedSupportJsms = this.balanceMode === '硬支撑' ? 0 : 1;
                this.syncSupportModeForBalanceMode();
                this.storedSupportMode = this.zcfs;
              }, this.balanceModeOptions);
              this.renderFormItem('尺寸单位', this.unit, (v: string): void => { this.unit = v; }, this.unitOptions);
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

@Component
struct PolarChart {
  private canvasCtx: CanvasRenderingContext2D = new CanvasRenderingContext2D();

  private drawChart(): void {
    const canvasSize = 280;
    const center = canvasSize / 2;
    const radius = 130;
    const ringGradient = this.canvasCtx.createRadialGradient(center, center, 0, center, center, radius);
    ringGradient.addColorStop(0.0, '#c9e9f8');
    ringGradient.addColorStop(0.2, '#c9e9f8');
    ringGradient.addColorStop(0.2, '#ffffff');
    ringGradient.addColorStop(0.4, '#ffffff');
    ringGradient.addColorStop(0.4, '#c9e9f8');
    ringGradient.addColorStop(0.6, '#c9e9f8');
    ringGradient.addColorStop(0.6, '#ffffff');
    ringGradient.addColorStop(0.8, '#ffffff');
    ringGradient.addColorStop(0.8, '#c9e9f8');
    ringGradient.addColorStop(1.0, '#c9e9f8');

    this.canvasCtx.clearRect(0, 0, canvasSize, canvasSize);

    this.canvasCtx.beginPath();
    this.canvasCtx.arc(center, center, radius, 0, Math.PI * 2);
    this.canvasCtx.fillStyle = ringGradient;
    this.canvasCtx.fill();
    this.canvasCtx.lineWidth = 2;
    this.canvasCtx.strokeStyle = '#ffffff';
    this.canvasCtx.shadowColor = 'rgba(255,255,255,0.35)';
    this.canvasCtx.shadowBlur = 10;
    this.canvasCtx.stroke();
    this.canvasCtx.shadowBlur = 0;

    this.canvasCtx.strokeStyle = '#2196ff';
    this.canvasCtx.lineWidth = 1;
    const angles = [-90, -30, 30, 90, 150, 210];
    angles.forEach((angle: number): void => {
      const rad = angle * Math.PI / 180;
      const startX = center + 34 * Math.cos(rad);
      const startY = center + 34 * Math.sin(rad);
      const endX = center + radius * Math.cos(rad);
      const endY = center + radius * Math.sin(rad);
      this.canvasCtx.beginPath();
      this.canvasCtx.moveTo(startX, startY);
      this.canvasCtx.lineTo(endX, endY);
      this.canvasCtx.stroke();
    });

    const centerGradient = this.canvasCtx.createRadialGradient(center, center, 4, center, center, 35);
    centerGradient.addColorStop(0.0, '#e8fff1');
    centerGradient.addColorStop(0.55, '#a9efc0');
    centerGradient.addColorStop(1.0, 'rgba(0,255,72,0.5)');
    this.canvasCtx.beginPath();
    this.canvasCtx.arc(center, center, 35, 0, Math.PI * 2);
    this.canvasCtx.fillStyle = centerGradient;
    this.canvasCtx.fill();
    this.canvasCtx.lineWidth = 2;
    this.canvasCtx.strokeStyle = '#00ff48';
    this.canvasCtx.stroke();

    const pointGradient = this.canvasCtx.createRadialGradient(center, center, 1, center, center, 11);
    pointGradient.addColorStop(0.0, 'rgba(223,33,33,0.75)');
    pointGradient.addColorStop(0.6, 'rgba(223,33,33,0.75)');
    pointGradient.addColorStop(1.0, 'rgba(223,33,33,0)');
    this.canvasCtx.beginPath();
    this.canvasCtx.arc(center, center, 11, 0, Math.PI * 2);
    this.canvasCtx.fillStyle = pointGradient;
    this.canvasCtx.fill();
    this.canvasCtx.lineWidth = 2;
    this.canvasCtx.strokeStyle = '#df2121';
    this.canvasCtx.stroke();

    this.canvasCtx.beginPath();
    this.canvasCtx.moveTo(center - 4, center);
    this.canvasCtx.lineTo(center + 4, center);
    this.canvasCtx.moveTo(center, center - 4);
    this.canvasCtx.lineTo(center, center + 4);
    this.canvasCtx.lineWidth = 2;
    this.canvasCtx.strokeStyle = '#ffffff';
    this.canvasCtx.stroke();
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Canvas(this.canvasCtx)
        .width(280)
        .height(280)
        .onReady((): void => {
          this.drawChart();
        });

      Text('0°').fontSize(13).fontColor('#19253a').offset({ x: 0, y: -140 })
      Text('90°').fontSize(13).fontColor('#19253a').offset({ x: 142, y: 0 })
      Text('180°').fontSize(13).fontColor('#19253a').offset({ x: 0, y: 140 })
      Text('270°').fontSize(13).fontColor('#19253a').offset({ x: -144, y: 0 })
    }
    .width(280)
    .height(280)
  }
}
