export interface PersistentConfig {
  lastrotor: number;
  Jpmjqz:boolean, //静面加去重（false-加重，true-去重）
  Pm1jqz:boolean,//平面一加去重（false-加重，true-去重）
  Pm2jqz:boolean,//平面二加去重（（false-加重，true-去重）
  lastuser:string, //最后一次登录的操作者名称
  Posatime:string,//加减速系数
  Poscs:string,//转子槽数
  Poszfz:string,// 转向（0-正转，1-反转）
  Poskglx:string,//开关类型（0-光电开关，1-接近开关(数槽))
  Warmtime:string,//设备预热时间（单位：秒）
  SpeedFactor:number,//转速系数（倍率，1为100%转速）
  Phdj:number,//平衡等级(G)
  Gzzs:number,//工作转速
  Gjzl:number,//工件重量（单位：kg）
  StartAngle1:number,//平面一(静平面)初始角度
  StartAngle2:number,//平面二初始角度
  StartAngleS:number,//静平面初始角度
  NumberP1:number,// 平面一分度数量
  NumberP2:number,//平面二分度数量
  NumberS:number,//静平面分度数量
  IsReCylinder:number // 0:松开气缸
  SaveDisplayColumnSetting:string //纪录列表自定义列
  jjbc:boolean, //夹具补偿
}