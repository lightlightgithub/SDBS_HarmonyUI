export interface PersistentConfig {
  lastrotor: number;
  jpmjqz:boolean, //静面加去重（false-加重，true-去重）
  pm1jqz:boolean,//平面一加去重（false-加重，true-去重）
  pm2jqz:boolean,//平面二加去重（（false-加重，true-去重）
  lastuser:string, //最后一次登录的操作者名称
  posatime:string,//加减速系数
  poscs:string,//转子槽数
  poszfz:string,// 转向（0-正转，1-反转）
  poskglx:string,//开关类型（0-光电开关，1-接近开关(数槽))
  warmtime:string,//设备预热时间（单位：秒）
  speedFactor:number,//转速系数（倍率，1为100%转速）
  phdj:number,//平衡等级(G)
  gzzs:number,//工作转速
  gjzl:number,//工件重量（单位：kg）
  startAngle1:number,//平面一(静平面)初始角度
  startAngle2:number,//平面二初始角度
  startAngleS:number,//静平面初始角度
  numberP1:number,// 平面一分度数量
  numberP2:number,//平面二分度数量
  numberS:number,//静平面分度数量
  isReCylinder:number // 0:松开气缸
  saveDisplayColumnSetting:string //纪录列表自定义列
  jjbc:boolean, //夹具补偿
}