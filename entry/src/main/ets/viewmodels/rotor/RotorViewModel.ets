// RotorViewModel
import { RotorApiService } from '../../services/api/RotorApiService';
import { PersistentConfig, CustomSelectOption, BaseModelInput } from '../../models/global';
import { RotorSetModel } from '../../models/entity';
import { PersistentService } from '../../services/storage/PersistentService';

@Observed
export class RotorViewModel {
  private rotorSetApiService: RotorApiService = new RotorApiService();
  rotorsetModel?: RotorSetModel;
  errorMessage: string = '';  // 提示文字
  operateType: number = 0;
  rotorList: RotorSetModel[] = [];
  // 表单字段（用于双向绑定）
  rotorName: string = '';
  rotorA: string = '';
  rotorB: string = '';
  rotorC: string = '';
  rotorR1: string = '';
  rotorR2: string = '';
  rotorSpeed: string = '';
  zcfs: number = 1;
  Jsms: number = 0;
  Clms: number = 0;
  plane1Allow: string = '';
  plane2Allow: string = '';
  staticAllow: string = '';
  measureMode: string = '双面动平衡';
  balanceMode: string = '硬支撑';
  ccdw: string = 'mm';
  yxldw: string = 'g';
  selectRotor: string = '';
  currentRotorId: number = 0;
  persistentService = PersistentService.getInstance();
  //ISO表单字段
  isoGrade: string = '6.3';
  isoSpeed: string = '1000';
  isoWeight: string = '10';
  isoResult: string = '';
  //分度设定表单字段
  indexAngle1: string = '0';
  indexNumber1: string = '12';
  indexAngle2: string = '0';
  indexNumber2: string = '12';
  indexAngleS: string = '0';
  indexNumberS: string = '12';
  constructor() {

  }

  async initAsync(): Promise<void> {
    await this.loadRotorList();
    const persistentConfig = this.persistentService.getConfig();
    const lastRotorId = persistentConfig?.lastrotor ?? 0;

    if (lastRotorId !== 0) {
      await this.loadRotorById(lastRotorId);
    } else if (this.rotorList.length > 0) {
      await this.loadFirstRotor();
      if(persistentConfig){
        persistentConfig.lastrotor = this.currentRotorId;
        this.persistentService.setConfig(persistentConfig);
      }
    }
  }

  private initDefaultValues(): void {
    this.rotorName = '';
    this.rotorA = '';
    this.rotorB = '';
    this.rotorC = '';
    this.rotorR1 = '';
    this.rotorR2 = '';
    this.rotorSpeed = '';
    this.zcfs = 1;
    this.Jsms = 0;
    this.Clms = 0;
    this.plane1Allow = '';
    this.plane2Allow = '';
    this.staticAllow = '';
    this.measureMode = '双面动平衡';
    this.balanceMode = '硬支撑';
    this.ccdw = 'mm';
    this.yxldw = 'g';
    this.currentRotorId = 0;
    this.selectRotor = '';
    this.errorMessage = '';
  }
  // 从模型填充表单
  private fillFormFromModel(model: RotorSetModel): void {
    console.log('fillFormFromModel',JSON.stringify(model));
    this.currentRotorId = model.id;
    this.rotorName = model.name;
    this.selectRotor = model.name;
    this.zcfs = model.zcfs;
    this.Jsms = model.jsms;
    this.balanceMode = model.jsms === 0 ? '硬支撑' : '软支撑';
    this.rotorA = model.a.toString();
    this.rotorB = model.b.toString();
    this.rotorC = model.c.toString();
    this.rotorR1 = model.r1.toString();
    this.rotorR2 = model.r2.toString();
    this.rotorSpeed = model.speed.toString();
    // 允许量
    this.staticAllow = model.pmyyxl.toString();
    this.plane1Allow = model.pmeyxl.toString();
    this.plane2Allow = model.jyxl.toString();
    // 单位
    this.ccdw = RotorViewModel.codeToUnit(model.ccdw);
    this.yxldw = RotorViewModel.codeToAllowUnit(model.yxldw);
    // 测量模式
    this.Clms = model.clms;
    this.measureMode = model.clms === 1 ? '单面动平衡' : model.clms === 2 ? '双面动平衡' : '动静平衡';
    this.rotorsetModel = model;
  }
  // 构建模型（用于提交
  private buildModel(): RotorSetModel {
    return {
      id: this.currentRotorId,
      name: this.rotorName,
      zcfs: this.zcfs,
      jsms: this.Jsms,
      clms: this.Clms,
      ccdw: RotorViewModel.unitToCode(this.ccdw),
      yxldw: RotorViewModel.allowUnitToCode(this.yxldw),
      pmyyxl: parseFloat(this.staticAllow) || 0,
      pmeyxl: parseFloat(this.plane1Allow) || 0,
      jyxl: parseFloat(this.plane2Allow) || 0,
      a: parseFloat(this.rotorA) || 0,
      b: parseFloat(this.rotorB) || 0,
      c: parseFloat(this.rotorC) || 0,
      r1: parseFloat(this.rotorR1) || 0,
      r2: parseFloat(this.rotorR2) || 0,
      speed: parseFloat(this.rotorSpeed) || 0,
      modifytime: new Date().toISOString()
    };
  }

  // 加载转子列表
  async loadRotorList(): Promise<boolean> {
    try {
      const resp = await this.rotorSetApiService.GetRotorList();
      if (resp.success && resp.respData) {
        this.rotorList = resp.respData;
        console.log('loadRotorList success, count:', this.rotorList.length, 'data:', JSON.stringify(this.rotorList));
        return true;
      }
      this.errorMessage = resp.message || '加载转子列表失败';
      console.error('loadRotorList failed:', resp.message);
      return false;
    } catch (e) {
      console.error('加载转子列表异常：', e);
      this.errorMessage = '网络异常，请检查服务是否启动';
      return false;
    }
  }

  // 根据ID加载转子
  async loadRotorById(id: number): Promise<boolean> {
    try {
      console.log('loadRotorById',id);
      const resp = await this.rotorSetApiService.GetRotorById(id);
      console.log('loadRotorById resp',JSON.stringify(resp));
      if (resp.success && resp.respData) {
        this.fillFormFromModel(resp.respData);
        return true;
      }
      this.errorMessage = resp.message || '加载转子失败';
      return false;
    } catch (e) {
      console.error('加载转子失败：', e);
      this.errorMessage = '网络异常，请检查服务是否启动';
      return false;
    }
  }
  // 加载第一个转子
  async loadFirstRotor(): Promise<boolean> {
    if (this.rotorList.length > 0) {
      return await this.loadRotorById(this.rotorList[0].id);
    }
    return false;
  }

 //保存转子
  async saveRotor(): Promise<boolean> {
    try {
      // 自动判断：ID=0 → 新增，否则 → 修改
      this.operateType = this.currentRotorId === 0 ? 1 : 2;
      const req: BaseModelInput<RotorSetModel> = {
        operateType: this.operateType,
        model: this.buildModel()
      };
      console.log('saveRotor req',JSON.stringify(req));
      const resp = await this.rotorSetApiService.RotorManage(req);
      if (resp.success) {
        // 重新加载列表
        await this.loadRotorList();
        if (this.operateType === 1 && resp.respData) {
          this.currentRotorId = resp.respData;
        }
        const savedRotor = this.rotorList.find(r => r.id === this.currentRotorId);
        if (savedRotor) {
          this.selectRotor = savedRotor.name;
        }
        const config = this.persistentService.getConfig();
        if (config) {
          config.lastrotor = this.currentRotorId;
          this.persistentService.setConfig(config);
        }
        return true;
      }else {
        this.errorMessage = resp.message || '保存失败';
        return false;
      }

    } catch (e) {
      console.error('保存异常：', e);
      this.errorMessage = '网络异常，保存失败';
      return false;
    }
  }

  // 删除转子
  async deleteRotor(): Promise<boolean> {
    if (this.currentRotorId === 0) {
      this.errorMessage = '请先选择要删除的转子';
      return false;
    }
    if(this.rotorList.length == 1){
      this.errorMessage = '当前只有一个转子，不允许删除';
      return false;
    }
    try {
      const req: BaseModelInput<RotorSetModel> = {
        operateType: 3,
        model: this.buildModel()
      };
      const resp = await this.rotorSetApiService.RotorManage(req);
      if (resp.success) {
        await this.loadRotorList();
        if (this.rotorList.length > 0) {
          await this.loadRotorById(this.rotorList[0].id);
        } else {
          this.initDefaultValues();
        }
        return true;
      }
      this.errorMessage = resp.message || '删除失败';
      return false;
    } catch (e) {
      console.error('删除异常：', e);
      this.errorMessage = '网络异常，删除失败';
      return false;
    }
  }

  // 重置表单
  resetForm(): void {
    this.initDefaultValues();
  }
  //加载转子下拉框数据集
  getRotorOptions(): CustomSelectOption[] {
    return this.rotorList.map(rotor => ({
      value: rotor.id,
      text: rotor.name
    } as CustomSelectOption));
  }

  //根据转子名称匹配转子信息
  getRotorIdByName(name: string): number {
    const rotor = this.rotorList.find(r => r.name === name);
    return rotor ? rotor.id : 0;
  }

  //ISO计算
  calcISO(): void {
    const isoGrade = parseFloat(this.isoGrade);
    const isoSpeed = parseFloat(this.isoSpeed);
    const isoWeight = parseFloat(this.isoWeight);
    if (isNaN(isoGrade) || isNaN(isoSpeed) || isNaN(isoWeight) || isoSpeed <= 0) {
      this.isoResult = '请输入有效数值';
      setTimeout(() => {
        this.isoResult = '';
      }, 5000);
      return;
    }
    const r1 = parseFloat(this.rotorR1);
    const r2 = parseFloat(this.rotorR2);
    if (r1 != 0 && isoSpeed != 0)
      this.plane1Allow = (isoGrade * 1000 * 10 / isoSpeed * isoWeight / 2 / r1).toFixed(3).toString();
    else
      this.plane1Allow = "0";
    if (r2 != 0 && isoSpeed != 0)
      this.plane2Allow = (isoGrade * 1000 * 10 / isoSpeed * isoWeight / 2 / r2).toFixed(3).toString();
    else
      this.plane2Allow = "0";
    this.staticAllow = (parseFloat(this.plane1Allow) + parseFloat(this.plane2Allow)).toString();

    this.isoResult = '计算完成';
    setTimeout(() => {
      if (this.isoResult === '计算完成') {
        this.isoResult = '';
      }
    }, 5000);
    return;
  }

  //分度设定
   saveIndexSettings(): void {
     const config = this.persistentService.getConfig();
     if (config) {
       config.StartAngle1 = parseInt(this.indexAngle1);
       config.StartAngle2 = parseInt(this.indexAngle2);
       config.StartAngleS = parseInt(this.indexAngleS);
       config.NumberP1 = parseInt(this.indexNumber1);
       config.NumberP2 = parseInt(this.indexNumber2);
       config.NumberS  = parseInt(this.indexNumberS);
       this.persistentService.setConfig(config);
     }
  }
  static codeToUnit(code: number): string {
    const map: Record<number, string> = { 1: 'mm', 2: 'cm', 3: 'm', 4: 'inch', 5: 'foot' };
    return map[code] || 'mm';
  }

  static unitToCode(unit: string): number {
    const map: Record<string, number> = { 'mm': 1, 'cm': 2, 'm': 3, 'inch': 4, 'foot': 5 };
    return map[unit] || 0;
  }

  static codeToAllowUnit(code: number): string {
    const map: Record<number, string> = { 1: 'g', 2: 'mg', 3: 'g·mm', 4: 'g·cm' };
    return map[code] || 'g';
  }

  static allowUnitToCode(unit: string): number {
    const map: Record<string, number> = { 'g': 1, 'mg': 2, 'g·mm': 3, 'g·cm': 4 };
    return map[unit] || 0;
  }
}
