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
    currentAnnotationLineGeometry:
      'M189,0 L189,182 M334,0 L334,47 M611,0 L611,182 M450,0 L450,47 M135,99 L290,99 M135,190 L166,190 M512,127 L665,127 M634,190 L665,190',
    currentAnnotationInLineGeometry:
      'M337,10 L446,10 M192,10 L330,10 M454,10 L607,10 M146,101 L146,188 M656,130 L656,188',
    currentAnnotationArrowGeometry:
      'M191,10 L195,13 L195,7 Z M336,10 L340,13 L340,7 Z M332,10 L328,13 L328,7 Z M452,10 L456,13 L456,7 Z M448,10 L444,13 L444,7 Z M608,10 L604,7 L604,13 Z M146,100 L143,104 L149,104 Z M146,189 L143,185 L149,185 Z M656,129 L653,133 L659,133 Z M656,189 L653,185 L659,185 Z',
    aPosition: { left: 212, top: -10 },
    bPosition: { left: 340, top: -10 },
    cPosition: { left: 483, top: -10 },
    r1Position: { left: 50, top: 121 },
    r2Position: { left: 662, top: 139 },
    speedPosition: { left: 340, top: 328 },
  },
  2: {
    currentAnnotationLineGeometry:
      'M156,-20 L156,49 M635,-20 L635,49 M283,25 L283,170 M513,25 L513,170 M70,99 L120,99 M70,190 L98,190 M670,99 L720,99 M694,190 L720,190',
    currentAnnotationInLineGeometry:
      'M158,10 L633,10 M158,40 L281,40 M515,40 L633,40 M86,101 L86,188 M706,101 L706,188',
    currentAnnotationArrowGeometry:
      'M157,10 L161,13 L161,7 Z M157,40 L161,43 L161,37 Z M282,40 L278,43 L278,37 Z M634,10 L630,13 L630,7 Z M634,40 L630,43 L630,37 Z M514,40 L518,43 L518,37 Z M86,100 L83,104 L89,104 Z M86,189 L83,185 L89,185 Z M706,100 L703,104 L709,104 Z M706,189 L703,185 L709,185 Z',
    aPosition: { left: 172, top: 20 },
    bPosition: { left: 345, top: -13 },
    cPosition: { left: 524, top: 20 },
    r1Position: { left: -14, top: 121 },
    r2Position: { left: 705, top: 121 },
    speedPosition: { left: 345, top: 320 },
  },
  3: {
    currentAnnotationLineGeometry:
      'M165,0 L165,172 M394,0 L394,47 M626,0 L626,172 M115,99 L290,99 M115,190 L134,190',
    currentAnnotationInLineGeometry:
      'M169,10 L390,10 M399,10 L620,10 M125,102 L125,187',
    currentAnnotationArrowGeometry:
      'M168,10 L172,13 L172,7 Z M397,10 L401,13 L401,7 Z M125,101 L122,104 L128,104 Z M391,10 L387,13 L387,7 Z M623,10 L619,7 L619,13 Z M125,188 L122,185 L128,185 Z',
    aPosition: { left: 230, top: -10 },
    bPosition: { left: 1000, top: 0 },
    cPosition: { left: 463, top: -10 },
    r1Position: { left: 31, top: 130 },
    r2Position: { left: 1000, top: 0 },
    speedPosition: { left: 345, top: 339 },
  },
  4: {
    currentAnnotationLineGeometry:
      'M164,-20 L164,47 M270,20 L270,170 M413,-20 L413,47 M580,20 L580,171 M470,117 L720,117 M680,190 L720,190 M80,190 L107,190 M80,98 L117,98',
    currentAnnotationInLineGeometry:
      'M169,8 L411,8 M169,38 L267,38 M417,38 L577,38 M95,102 L95,187 M695,120 L695,187',
    currentAnnotationArrowGeometry:
      'M168,38 L172,35 L172,41 Z M416,38 L420,35 L420,41 Z M95,101 L92,105 L98,105 Z M695,120 L692,124 L698,124 Z M268,38 L265,35 L265,41 Z M578,38 L574,35 L574,41 Z M95,188 L92,184 L98,184 Z M695,188 L692,184 L698,184 Z M168,8 L172,5 L172,11 Z M412,8 L408,5 L408,11 Z',
    aPosition: { left: 168, top: 18 },
    bPosition: { left: 292, top: -12 },
    cPosition: { left: 446, top: 18 },
    r1Position: { left: 0, top: 121 },
    r2Position: { left: 689, top: 130 },
    speedPosition: { left: 310, top: 339 },
  },
  5: {
    currentAnnotationLineGeometry:
      'M214,-20 L214,170 M378,20 L378,47 M626,20 L626,47 M520,-20 L520,171 M80,117 L330,117 M111,190 L80,190 M682,190 L720,190 M678,98 L710,98',
    currentAnnotationInLineGeometry:
      'M218,8 L518,8 M218,38 L375,38 M523,38 L622,38 M95,120 L95,187 M695,102 L695,187',
    currentAnnotationArrowGeometry:
      'M216,38 L219,35 L219,41 Z M522,38 L525,35 L525,41 Z M95,119 L92,122 L98,122 Z M695,101 L692,105 L698,105 Z M376,38 L373,35 L373,41 Z M624,38 L621,35 L621,41 Z M95,188 L92,185 L98,185 Z M695,188 L692,185 L698,185 Z M216,8 L219,5 L219,11 Z M519,8 L515,5 L515,11 Z',
    aPosition: { left: 244, top: 18 },
    bPosition: { left: 390, top: -14 },
    cPosition: { left: 522, top: 18 },
    r1Position: { left: -5, top: 130 },
    r2Position: { left: 695, top: 121 },
    speedPosition: { left: 395, top: 334 },
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
