export interface Margin {
  left: number;
  top: number;
}

export interface SelectOption {
  value: string;
}

export interface AnnotationConfig {
  currentAnnotationLineGeometry: string;
  currentAnnotationInLineGeometry: string;
  currentAnnotationArrowGeometry: string;
  aPosition: Margin;
  bPosition: Margin;
  cPosition: Margin;
  r1Position: Margin;
  r2Position: Margin;
  speedPosition: Margin;
}

export class MeasurementMode {
  annotationGroups: AnnotationConfig;
  imageWidth: number;
  imageHeight: number;

  constructor(config: AnnotationConfig) {
    this.annotationGroups = config;
    this.imageWidth = 0;
    this.imageHeight = 0;
  }

  setImageSize(width: number, height: number): void {
    this.imageWidth = width;
    this.imageHeight = height;
  }

  scalePathCommands(cmd: string, scale: number, offsetX: number, offsetY: number): string {
    if (!cmd) {
      return '';
    }
    let index = 0;
    return cmd.replace(/-?\d+(?:\.\d+)?/g, (match: string) => {
      const value = parseFloat(match);
      const isX = index % 2 === 0;
      const scaled = isX ? value * scale + offsetX : value * scale + offsetY;
      index++;
      return scaled.toFixed(1);
    });
  }
}

const MODES_CONFIG: Record<number, AnnotationConfig> = {
  1: {
    // ==================== 灰色粗主线 ====================
    currentAnnotationLineGeometry:
    'M95,-50 L95,140 ' +  // 左侧外竖线
      'M250,-50 L250,-3 ' +   // 左侧内竖线
      'M550,-50 L550,140 ' +  // 右侧外竖线
      'M376,-50 L376,-3 ' +   // 右侧内竖线
      'M40,56 L197,56 ' +  // 左侧水平标注线
      'M40,150 L71,150 ' +// 左侧底部短标注线
      'M447,85 L600,85 ' +// 右侧水平标注线
      'M575,150 L605,150',  // 右侧底部短标注线

    // ==================== 蓝色辅助细线 ====================
    currentAnnotationInLineGeometry:
    'M210,-40 L270,-40 ' +  // 顶部：左内竖线 → 右内竖线 连线
      'M99,-40 L128,-40 ' +  // 顶部：左外竖线 → 左内竖线 连线
      'M354,-40 L545,-40 ' +  // 顶部：右内竖线 → 右外竖线 连线
      'M57,59 L57,146 ' +// 左侧垂直辅助线
      'M586,88 L586,147',  // 右侧垂直辅助线

    // ==================== 蓝色小箭头 ====================
    currentAnnotationArrowGeometry:
    // 顶部：左外竖线 → 左内竖线 连线 (M99,-40 到 M128,-40) - 水平线，y=-40
    'M99,-40 L103,-43 L103,-37 Z ' +          // 左端箭头（指向右）
      'M128,-40 L124,-43 L124,-37 Z ' +         // 右端箭头（指向左）

      // 顶部：左内竖线 → 右内竖线 连线 (M210,-40 到 M270,-40) - 水平线，y=-40
      'M210,-40 L214,-43 L214,-37 Z ' +         // 左端箭头（指向右）
      'M270,-40 L266,-43 L266,-37 Z ' +         // 右端箭头（指向左）

      // 顶部：右内竖线 → 右外竖线 连线 (M354,-40 到 M545,-40) - 水平线，y=-40
      'M354,-40 L358,-43 L358,-37 Z ' +         // 左端箭头（指向右）
      'M545,-40 L541,-43 L541,-37 Z ' +         // 右端箭头（指向左）

      // 左侧垂直辅助线 (M57,59 到 M57,146) - 垂直线，x=57
      'M57,59 L54,63 L60,63 Z ' +               // 上端箭头（指向下）—— 尖端 y=59，底角 y=63
      'M57,146 L54,142 L60,142 Z ' +            // 下端箭头（指向上）—— 尖端 y=146，底角 y=142

      // 右侧垂直辅助线 (M586,88 到 M586,147) - 垂直线，x=586
      'M586,88 L583,92 L589,92 Z ' +            // 上端箭头（指向下）—— 尖端 y=88，底角 y=92
      'M586,147 L583,143 L589,143 Z',           // 下端箭头（指向上）—— 尖端 y=147，底角 y=143

    // ==================== 输入框位置 ====================
    aPosition: { left: 130, top: -60 },      // 输入框A 位置（左右外竖线之间上方）
    bPosition: { left: 275, top: -60 },      // 输入框B 位置（左内竖线上方）
    cPosition: { left: 428, top: -60 },      // 输入框C 位置（右内竖线上方）
    r1Position: { left: -20, top: 75 },      // 输入框R1 位置（最左侧）
    r2Position: { left: 593, top: 90 },     // 输入框R2 位置（最右侧）
    speedPosition: { left: 280, top: 300 },  // 转速输入框 位置（整体下方中间）
  },
  2: {
    // ==================== 灰色粗主线 ====================
    currentAnnotationLineGeometry:
    'M65,-70 L65,-1 ' +   // 左侧外竖线
      'M572,-70 L572,-1 ' +   // 右侧外竖线
      'M200,-33 L200,127 ' +   // 左侧内竖线
      'M436,-33 L436,127 ' +   // 右侧内竖线
      'M-24,57 L26,57 ' +     // 左上水平标注线
      'M-24,152 L4,152 ' +    // 左下短标注线
      'M620,57 L670,57 ' +    // 右上水平标注线
      'M634,152 L660,152',    // 右下短标注线
    // ==================== 蓝色辅助细线 ====================
    currentAnnotationInLineGeometry:
    'M73,-50 L562,-50 ' +    // 顶部：左右外竖线 连线
      'M73,-20 L196,-20 ' +    // 顶部：左外竖线 → 左内竖线 连线
      'M444,-20 L562,-20 ' +    // 顶部：右内竖线 → 右外竖线 连线
      'M-7,61 L-7,148 ' +    // 左侧垂直辅助线
      'M645,65 L645,143',    // 右侧垂直辅助线
    // ==================== 【已修复】蓝色小箭头（完全匹配新坐标） ====================
    currentAnnotationArrowGeometry:
    // 顶部外连线 (M73,-50 到 M562,-50) - 水平线，y=-50
    'M73,-50 L77,-53 L77,-47 Z ' +           // 左端箭头（指向右）
      'M562,-50 L558,-53 L558,-47 Z ' +        // 右端箭头（指向左）

      // 顶部左内连线 (M73,-20 到 M196,-20) - 水平线，y=-20
      'M73,-20 L77,-23 L77,-17 Z ' +           // 左端箭头（指向右）
      'M196,-20 L192,-23 L192,-17 Z ' +        // 右端箭头（指向左）

      // 顶部右内连线 (M444,-20 到 M562,-20) - 水平线，y=-20
      'M444,-20 L448,-23 L448,-17 Z ' +        // 左端箭头（指向右）
      'M562,-20 L558,-23 L558,-17 Z ' +        // 右端箭头（指向左）

      // 左侧垂直辅助线 (M-7,61 到 M-7,148) - 垂直线，x=-7
      'M-7,63 L-10,67 L-4,67 Z ' +             // 上端箭头（指向上）
      'M-7,148 L-10,144 L-4,144 Z ' +          // 下端箭头（指向下）

      // 右侧垂直辅助线 (M645,65 到 M645,143) - 垂直线，x=645
      'M645,65 L642,69 L648,69 Z ' +           // 上端箭头（指向下）—— 尖端 y=65，底角 y=69
      'M645,143 L642,139 L648,139 Z',          // 下端箭头（指向上）—— 尖端 y=143，底角 y=139
    aPosition: { left: 100, top: -40 },
    bPosition: { left: 300, top: -78 },
    cPosition: { left: 462, top: -40 },
    r1Position: { left: -90, top: 80 },
    r2Position: { left: 652, top: 80 },
    speedPosition: { left: 275, top: 270 },
  },
  3: {
    // ==================== 灰色粗主线 ====================
    currentAnnotationLineGeometry:
    'M68,-42 L68,130 ' +      // 左侧外竖线
      'M320,-50 L320,-3 ' +       // 左侧内竖线
      'M555,-42 L555,130 ' +      // 右侧外竖线
      'M15,53 L190,53 ' +      // 左侧水平标注线
      'M15,150 L34,150',      // 左侧底部短标注线

    // ==================== 蓝色辅助细线 ====================
    currentAnnotationInLineGeometry:
    'M78,-30 L312,-30 ' +      // 顶部：左外竖线 → 左内竖线 连线
      'M329,-30 L550,-30 ' +      // 顶部：左内竖线 → 右外竖线 连线
      'M25,60 L25,145',      // 左侧垂直辅助线

    // ==================== 蓝色小箭头 ====================
    currentAnnotationArrowGeometry:
    // 顶部：左外竖线 → 左内竖线 连线 (M78,-30 到 M312,-30) - 水平线，y=-30
    'M78,-30 L82,-33 L82,-27 Z ' +           // 左端箭头（指向右）
      'M312,-30 L308,-33 L308,-27 Z ' +        // 右端箭头（指向左）

      // 顶部：左内竖线 → 右外竖线 连线 (M329,-30 到 M550,-30) - 水平线，y=-30
      'M329,-30 L333,-33 L333,-27 Z ' +        // 左端箭头（指向右）
      'M550,-30 L546,-33 L546,-27 Z ' +        // 右端箭头（指向左）

      // 左侧垂直辅助线 (M25,60 到 M25,145) - 垂直线，x=25
      'M25,60 L22,64 L28,64 Z ' +              // 上端箭头（指向下）—— 尖端 y=60，底角 y=64
      'M25,145 L22,141 L28,141 Z',             // 下端箭头（指向上）—— 尖端 y=145，底角 y=141

    // ==================== 输入框位置 ====================
    aPosition: { left: 180, top: -55 },      // 输入框A 位置（左侧区域上方）
    bPosition: { left: 1000, top: 0 },       // 输入框B 隐藏（坐标超出可视区）
    cPosition: { left: 378, top: -55 },      // 输入框C 位置（右侧区域上方）
    r1Position: { left: -60, top: 80 },      // 输入框R1 位置（左侧标注线旁）
    r2Position: { left: 1000, top: 0 },      // 输入框R2 隐藏（坐标超出可视区）
    speedPosition: { left: 285, top: 339 },  // 转速输入框 位置（下方中间）
  },
  4: {
    // ==================== 灰色粗主线 ====================
    currentAnnotationLineGeometry:
    'M74,-72 L74,-5 ' +      // 左侧外竖线
      'M185,-55 L185,130 ' +      // 左侧内竖线
      'M536,-55 L536,130 ' +      // 右侧外竖线
      'M335,-72 L335,-5 ' +      // 右侧内竖线
      'M400,75 L650,75 ' +     // 右侧水平标注线
      'M626,150 L666,150 ' +     // 右侧底部短标注线
      'M-27,240 L10,240 ' +      // 左侧底部短标注线
      'M-27,60 L10,60',          // 左侧水平标注线

    // ==================== 蓝色辅助细线 ====================
    currentAnnotationInLineGeometry:
    'M82,-60 L324,-60 ' +         // 顶部：左右外竖线 连线
      'M82,-28 L182,-28 ' +       // 顶部：左外竖线 → 左内竖线 连线
      'M340,-28 L536,-28 ' +       // 顶部：右外竖线 → 右内竖线 连线
      'M-5,64 L-5,232 ' +       // 左侧垂直辅助线
      'M640,80 L640,147',       // 右侧垂直辅助线

    // ==================== 蓝色小箭头 ====================
    currentAnnotationArrowGeometry:
    // 顶部：左右外竖线连线 (M82,-60 到 M324,-60) - 水平线，y=-60
    'M82,-60 L86,-63 L86,-57 Z ' +            // 左端箭头（指向右）
      'M324,-60 L320,-63 L320,-57 Z ' +         // 右端箭头（指向左）

      // 顶部：左外竖线 → 左内竖线连线 (M82,-28 到 M182,-28) - 水平线，y=-28
      'M82,-28 L86,-31 L86,-25 Z ' +            // 左端箭头（指向右）
      'M182,-28 L178,-31 L178,-25 Z ' +         // 右端箭头（指向左）

      // 顶部：右外竖线 → 右内竖线连线 (M340,-28 到 M536,-28) - 水平线，y=-28
      'M340,-28 L344,-31 L344,-25 Z ' +         // 左端箭头（指向右）
      'M536,-28 L532,-31 L532,-25 Z ' +         // 右端箭头（指向左）

      // 左侧垂直辅助线 (M-5,64 到 M-5,232) - 垂直线，x=-5
      'M-5,64 L-8,68 L-2,68 Z ' +               // 上端箭头（指向下）
      'M-5,232 L-8,228 L-2,228 Z ' +            // 下端箭头（指向上）

      // 右侧垂直辅助线 (M640,80 到 M640,147) - 垂直线，x=640
      'M640,80 L637,84 L643,84 Z ' +            // 上端箭头（指向下）
      'M640,147 L637,143 L643,143 Z',           // 下端箭头（指向上）

    // ==================== 输入框位置 ====================
    aPosition: { left: 95, top: -48 },        // 输入框A 位置（左外竖线右侧）
    bPosition: { left: 210, top: -88 },       // 输入框B 位置（左内竖线上方）
    cPosition: { left: 400, top: -48 },        // 输入框C 位置（右外竖线左侧）
    r1Position: { left: -90, top: 121 },        // 输入框R1 位置（最左侧）
    r2Position: { left: 649, top: 80 },      // 输入框R2 位置（最右侧）
    speedPosition: { left: 180, top: 330 },    // 转速输入框 位置（下方中间）
  },
  5: {
    // ==================== 灰色粗主线 ====================
    currentAnnotationLineGeometry:
    'M124,-60 L124,130 ' +      // 左侧外竖线
      'M300,-29 L300,-2 ' +        // 左侧内竖线
      'M566,-29 L566,-2 ' +        // 右侧外竖线
      'M450,-60 L450,130 ' +      // 右侧内竖线
      'M-30,73 L230,73 ' +       // 左侧水平标注线
      'M-20,150 L11,150 ' +       // 左侧底部短标注线
      'M622,150 L670,150 ' +      // 右侧底部短标注线
      'M622,55 L654,55',          // 右侧水平标注线

    // ==================== 蓝色辅助细线 ====================
    currentAnnotationInLineGeometry:
    'M129,-55 L443,-55 ' +          // 顶部：左右外竖线 连线
      'M129,-20 L295,-20 ' +        // 顶部：左外竖线 → 左内竖线 连线
      'M455,-20 L560,-20 ' +        // 顶部：右外竖线 → 右内竖线 连线
      'M0,76 L0,147 ' +        // 左侧垂直辅助线
      'M645,60 L645,147',        // 右侧垂直辅助线

    // ==================== 蓝色小箭头 ====================
    currentAnnotationArrowGeometry:
    // 顶部：左右外竖线连线 (M129,-55 到 M443,-55) - 水平线，y=-55
    'M129,-55 L133,-58 L133,-52 Z ' +         // 左端箭头（指向右）
      'M443,-55 L439,-58 L439,-52 Z ' +         // 右端箭头（指向左）

      // 顶部：左外竖线 → 左内竖线连线 (M129,-20 到 M295,-20) - 水平线，y=-20
      'M129,-20 L133,-23 L133,-17 Z ' +         // 左端箭头（指向右）
      'M295,-20 L291,-23 L291,-17 Z ' +         // 右端箭头（指向左）

      // 顶部：右外竖线 → 右内竖线连线 (M455,-20 到 M560,-20) - 水平线，y=-20
      'M455,-20 L459,-23 L459,-17 Z ' +         // 左端箭头（指向右）
      'M560,-20 L556,-23 L556,-17 Z ' +         // 右端箭头（指向左）

      // 左侧垂直辅助线 (M0,76 到 M0,147) - 垂直线，x=0
      'M0,76 L-3,80 L3,80 Z ' +                // 上端箭头（指向下）—— 尖端 y=76，底角 y=80
      'M0,147 L-3,143 L3,143 Z ' +             // 下端箭头（指向上）—— 尖端 y=147，底角 y=143

      // 右侧垂直辅助线 (M645,60 到 M645,147) - 垂直线，x=645
      'M645,60 L642,64 L648,64 Z ' +           // 上端箭头（指向下）—— 尖端 y=60，底角 y=64
      'M645,147 L642,143 L648,143 Z',          // 下端箭头（指向上）—— 尖端 y=147，底角 y=143

    // ==================== 输入框位置 ====================
    aPosition: { left: 175, top: -43 },        // 输入框A 位置（左外竖线右侧）
    bPosition: { left: 330, top: -80 },       // 输入框B 位置（左内竖线上方）
    cPosition: { left: 472, top: -43 },        // 输入框C 位置（右外竖线左侧）
    r1Position: { left: -85, top: 83 },       // 输入框R1 位置（最左侧）
    r2Position: { left: 655, top: 83 },      // 输入框R2 位置（最右侧）
    speedPosition: { left: 395, top: 294 },   // 转速输入框 位置（下方中间）
  },
  6: {
    currentAnnotationLineGeometry: 'M212,20 L212,50 M398,20 L398,47',
    currentAnnotationInLineGeometry: 'M216,30 L395,30',
    currentAnnotationArrowGeometry: 'M215,30 L219,27 L219,33 Z M397,30 L393,27 L393,33 Z',
    aPosition: { left: 1000, top: 0 },
    bPosition: { left: 1000, top: 0 },
    cPosition: { left: 1000, top: 0 },
    r1Position: { left: 260, top: -17 },
    r2Position: { left: 1000, top: 0 },
    speedPosition: { left: 345, top: 339 },
  },
  7: {
    currentAnnotationLineGeometry:
      'M139,20 L139,54 M219,20 L219,54 M139,328 L139,360 M395,328 L395,360 M503,20 L503,165 M55,104 L100,104 M55,190 L100,190 M240,120 L715,120 M695,190 L715,190',
    currentAnnotationInLineGeometry:
      'M141,35 L217,35 M221,35 L501,35 M75,106 L75,188 M706,188 L706,122 M141,345 L393,345',
    currentAnnotationArrowGeometry:
      'M140,35 L144,32 L144,38 Z M218,35 L214,32 L214,38 Z M220,35 L224,32 L224,38 Z M502,35 L498,32 L498,38 Z M141,345 L145,342 L145,348 Z M393,345 L389,342 L389,348 Z M75,105 L72,109 L78,109 Z M75,189 L72,185 L78,185 Z M706,189 L703,185 L709,185 Z M706,121 L703,125 L709,125 Z',
    aPosition: { left: 212, top: 324 },
    bPosition: { left: 130, top: -8 },
    cPosition: { left: 307, top: -8 },
    r1Position: { left: 1, top: 127 },
    r2Position: { left: 681, top: 135 },
    speedPosition: { left: 345, top: 256 },
  },
  8: {
    currentAnnotationLineGeometry:
      'M241,20 L241,166 M571,20 L571,54 M55,190 L96,190 M55,120 L553,120 M349,328 L349,360 M651,328 L651,360 M651,20 L651,54 M690,104 L715,104 M695,190 L715,190',
    currentAnnotationInLineGeometry:
      'M244,35 L568,35 M575,35 L648,35 M75,123 L75,188 M706,188 L706,106 M352,345 L649,345',
    currentAnnotationArrowGeometry:
      'M243,35 L247,32 L247,38 Z M570,35 L566,32 L566,38 Z M572,35 L576,32 L576,38 Z M650,35 L646,32 L646,38 Z M351,345 L355,342 L355,348 Z M649,345 L645,342 L645,348 Z M75,122 L72,126 L78,126 Z M75,189 L72,185 L78,185 Z M706,189 L703,185 L709,185 Z M706,105 L703,109 L709,109 Z',
    aPosition: { left: 365, top: 13 },
    bPosition: { left: 562, top: -13 },
    cPosition: { left: 452, top: 324 },
    r1Position: { left: 689, top: 126 },
    r2Position: { left: 0, top: 138 },
    speedPosition: { left: 292, top: 255 },
  },
  9: {
    currentAnnotationLineGeometry:
      'M171,20 L171,150 M534.5,20 L534.5,165 M441,130 L441,165 M55,190 L106,190 M55,98 L120,98',
    currentAnnotationInLineGeometry:
      'M175,35 L531,35 M175,148 L439,148 M75,100 L75,188',
    currentAnnotationArrowGeometry:
      'M172,35 L176,32 L176,38 Z M533,35 L529,32 L529,38 Z M75,99 L72,103 L78,103 Z M75,189 L72,185 L78,185 Z M440,148 L436,145 L436,151 Z M174,148 L178,145 L178,151 Z',
    aPosition: { left: 257, top: 127 },
    bPosition: { left: 1000, top: 0 },
    cPosition: { left: 301, top: 14 },
    r1Position: { left: 12, top: 125 },
    r2Position: { left: 1000, top: 0 },
    speedPosition: { left: 349, top: 260 },
  },
  10: {
    currentAnnotationLineGeometry:
      'M311,20 L311,164 M405,120 L405,164 M618.5,20 L618.5,164 M645,98 L718,98 M684,190 L718,190',
    currentAnnotationInLineGeometry:
      'M314,35 L618,35 M410,148 L617,148 M700,100 L700,188',
    currentAnnotationArrowGeometry:
      'M313,35 L317,32 L317,38 Z M619,35 L615,32 L615,38 Z M700,99 L697,103 L703,103 Z M700,189 L697,185 L703,185 Z M407,148 L411,145 L411,151 Z M618,148 L614,145 L614,151 Z',
    aPosition: { left: 420, top: 15 },
    bPosition: { left: 1000, top: 0 },
    cPosition: { left: 460, top: 129 },
    r1Position: { left: 679, top: 125 },
    r2Position: { left: 1000, top: 0 },
    speedPosition: { left: 307, top: 264 },
  },
  11: {
    currentAnnotationLineGeometry:
      'M394,20 L394,270 M602.5,20 L602.5,58 M555,240 L555,270 M668,283 L718,283 M645,110 L718,110 M72,110 L145,110 M72,283 L122,283 M645,206 L718,206',
    currentAnnotationInLineGeometry:
      'M397,35 L600,35 M397,255 L553,255 M690,112 L690,204 M690,211 L690,280 M100,112 L100,280',
    currentAnnotationArrowGeometry:
      'M396,35 L400,32 L400,38 Z M601,35 L597,32 L597,38 Z M397,255 L401,258 L401,252 Z M554,255 L550,258 L550,252 Z M690,111 L687,115 L693,115 Z M690,205 L687,201 L693,201 Z M690,207 L687,211 L693,211 Z M690,282 L687,278 L693,278 Z M100,112 L103,116 L97,116 Z M100,281 L103,277 L97,277 Z',
    aPosition: { left: 52, top: 174 },
    bPosition: { left: 671, top: 142 },
    cPosition: { left: 672, top: 224 },
    r1Position: { left: 456, top: 15 },
    r2Position: { left: 423, top: 239 },
    speedPosition: { left: 345, top: 337 },
  }
};

export class SupportConfig {
  static AllModes: Record<number, MeasurementMode> = {};

  static init(): void {
    const modeIds = Object.keys(MODES_CONFIG).map(Number);
    for (const modeId of modeIds) {
      SupportConfig.AllModes[modeId] = new MeasurementMode(MODES_CONFIG[modeId]);
    }
  }
}
