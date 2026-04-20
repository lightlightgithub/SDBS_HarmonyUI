// RotorSetModel: 与后端 JSON 字段名一致（小写）
export interface RotorSetModel {
  id: number;
  name: string;
  zcfs: number;
  jsms: number;
  clms: number;
  ccdw: number;
  yxldw: number;
  pmyyxl: number;
  pmeyxl: number;
  jyxl: number;
  a: number;
  b: number;
  c: number;
  r1: number;
  r2: number;
  speed: number;
  modifytime: string;
  timestamp?: string;
  start_test?: boolean;
  compesation?: boolean;
  axis1?: number;
  axis2?: number;
  axis3?: number;
  axis4?: number;
  axis5?: number;
  axis6?: number;
  axis7?: number;
  axis8?: number;
  axis9?: number;
  axis10?: number;
  pmy?: boolean;
  pme?: boolean;
  noweight?: boolean;
}