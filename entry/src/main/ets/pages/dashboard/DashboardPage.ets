/**
 * DashboardPage —— 主界面壳层代码
 * 包含顶部区域、内容区和底部主菜单。
 */

import { SupportConfig, MeasurementMode, Margin, SelectOption } from '../rotor/RotorSupportConfig';
import { RotorSettingsPanel } from '../rotor/RotorSettingsPanel';
import { PersistentService } from '../../services/storage/PersistentService';
import { PersistentConfig } from '../../models/global';
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
  private persistentService: PersistentService = PersistentService.getInstance();
  @StorageLink('persistentConfig') persistentConfigJson: string = '';
  private showToast(message: string, duration: number = 1500): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message, duration });
    } catch (error) {
      console.error(`showToast failed: ${JSON.stringify(error)}`);
    }
  }

  /** 页面显示时启动时钟定时器 */
  aboutToAppear(): void {
    this.updateTime();
    this.timer = setInterval(() => {
      this.updateTime();
    }, 1000);
    // 使用 PersistentService 加载配置
    this.loadPersistentConfig();
  }
     /** 页面销毁时清理定时器 */
  aboutToDisappear(): void {
    if (this.timer !== -1) {
      clearInterval(this.timer);
    }
  }
  /** 加载持久化配置 */
  private async loadPersistentConfig(): Promise<void> {
    try {
      const success = await this.persistentService.loadFromServer();
      if (success) {
        console.log('DashboardPage: 持久化配置加载成功');
        const config = this.persistentService.getConfig();
        console.log('持久化缓存config:', JSON.stringify(config));
      } else {
        console.warn('DashboardPage: 持久化配置加载失败');
      }
    } catch (e) {
      console.error('DashboardPage: 加载配置异常:', e);
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
  private async  onToolbarClick(id: string): Promise<void> {
    if (id === 'exit') {
      // 退出前先保存持久化配置
      try {
        console.log('DashboardPage: 退出按钮点击，正在保存配置...');
        const success = await this.persistentService.saveToServer();
        if (success) {
          console.log('DashboardPage: 配置保存成功，准备退出');
        } else {
          console.warn('DashboardPage: 配置保存失败，仍然退出');
        }
      } catch (e) {
        console.error('DashboardPage: 保存配置异常:', e);
      }
      // 退出返回登录页
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
