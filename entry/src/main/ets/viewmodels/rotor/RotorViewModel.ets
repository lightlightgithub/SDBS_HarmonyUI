// RotorViewModel
import { RotorApiService } from '../../services/api/RotorApiService';
import { PersistentConfig, SelectOption,BaseModelInput } from '../../models/global';
import { RotorSetModel } from '../../models/entity';
export class RotorViewModel
{
   rotorSetApiService: RotorApiService = new RotorApiService();
   rotorsetModel?: RotorSetModel;
   errorMessage: string = '';              // 提示文字
   operateType:number = 0;
   rotorList: RotorSetModel[] = [];
  // 表单字段（用于双向绑定）
  rotorName: string = '';
  rotorA: string = '';
  rotorB: string = '';
  rotorC: string = '';
  rotorR1: string = '';
  rotorR2: string = '';
  rotorSpeed: string = '';
  zcfs: number = 2;
  Jsms:number = 0;
  Clms:number = 0;
  plane1Allow: string = '';
  plane2Allow: string = '';
  staticAllow: string = '';
  measureMode: string = '双面动平衡';
  balanceMode: string = '硬支撑';
  unit: string = 'mm';
  allowUnit: string = 'g';
  selectRotor: string = '';
  // 当前选中的转子ID
  currentRotorId: number = 0;
  constructor() {
    this.loadRotorList();
    const persistentConfig = AppStorage.get<PersistentConfig>('persistentConfig');
    if(persistentConfig && persistentConfig.lastrotor!=0) {
      // 保存当前使用的转子ID到全局状态
      this.currentRotorId = persistentConfig.lastrotor;
      console.log(`lastRotorId:${persistentConfig.lastrotor}`)
      this.loadRotorById(persistentConfig.lastrotor);
    }
    else {
      console.log('没有读到持久化的rotorid')
      this.loadFirstRotor();
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
    this.zcfs = 2;
    this.plane1Allow = '';
    this.plane2Allow = '';
    this.staticAllow = '';
    this.measureMode = '双面动平衡';
    this.balanceMode = '硬支撑';
    this.unit = 'mm';
    this.allowUnit = 'g';
    this.currentRotorId = 0;
    this.selectRotor = '';
    this.errorMessage = '';
  }
  // 从模型填充表单
  private fillFormFromModel(model: RotorSetModel): void {
    this.currentRotorId = model.ID;
    this.rotorName = model.NAME;
    this.selectRotor = model.NAME;
    this.zcfs = model.Zcfs;
    this.Jsms = model.Jsms;
    this.balanceMode = model.Jsms === 0 ? '硬支撑' : '软支撑';
    this.rotorA = model.A.toString();
    this.rotorB = model.B.toString();
    this.rotorC = model.C.toString();
    this.rotorR1 = model.R1.toString();
    this.rotorR2 = model.R2.toString();
    this.rotorSpeed = model.Speed.toString();
    // 允许量
    this.staticAllow = model.Pmyyxl.toString();
    this.plane1Allow = model.Pmeyxl.toString();
    this.plane2Allow = model.Jyxl.toString();

    // 单位
    this.unit = model.Ccdw.toString();
    this.allowUnit = model.Yxldw.toString();

    // 测量模式
    this.Clms = model.Clms;
    this.measureMode = model.Clms === 1 ? '单面动平衡' : model.Clms === 2 ? '双面动平衡' : '动静平衡';
    this.rotorsetModel = model;
  }
  // 构建模型（用于提交）
  private buildModel(): RotorSetModel {
    return {
      ID: this.currentRotorId,
      NAME: this.rotorName,
      Zcfs: this.zcfs,
      Jsms: 0,
      Clms: 0,
      Ccdw: 0,
      Yxldw: 0,
      Pmyyxl: 0,
      Pmeyxl: 0,
      Jyxl: 0,
      A: parseFloat(this.rotorA) || 0,
      B: parseFloat(this.rotorB) || 0,
      C: parseFloat(this.rotorC) || 0,
      R1: parseFloat(this.rotorR1) || 0,
      R2: parseFloat(this.rotorR2) || 0,
      Speed: parseFloat(this.rotorSpeed) || 0,
      MODIFYTIME: new Date().toISOString()
    };
  }

  // 加载转子列表
  async loadRotorList(): Promise<boolean> {
    try {
      const resp = await this.rotorSetApiService.GetRotorList();
      if (resp.success && resp.respData) {
        this.rotorList = resp.respData;
        return true;
      }
      this.errorMessage = resp.message || '加载转子列表失败';
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
      const resp = await this.rotorSetApiService.GetRotorById(id);
      console.log('转子信息：',JSON.stringify(resp));
      if (resp.success && resp.respData) {
        this.fillFormFromModel(resp.respData);
        return true;
      }
      else {
        console.log('没有读取转子信息');
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
      return await this.loadRotorById(this.rotorList[0].ID);
    }
    return false;
  }

  // 新增转子
  async addRotor(): Promise<void> {
    this.initDefaultValues();
    this.errorMessage = '';
    console.log('新增：已清空表单，可直接输入保存');
  }

  // 保存转子
  async saveRotor(): Promise<boolean> {
    try {
      // 自动判断：ID=0 → 新增，否则 → 修改
      this.operateType = this.currentRotorId === 0 ? 1 : 2;
      const req: BaseModelInput<RotorSetModel> = {
        operateType: this.operateType,
        model: this.buildModel()
      };
      console.log('operateType：', this.operateType);
      console.log('保存内容：', JSON.stringify(req));
      const resp = await this.rotorSetApiService.RotorManage(req);
      console.log('保存结果：', JSON.stringify(resp));
      if (resp.success) {
        if (this.operateType === 1) {
          // 新增成功后，重新加载列表 & 获取最新ID
          const result = await this.loadRotorList();
          if (this.rotorList.length > 0) {
            // 按 ID 排序，取最大的 ID（最新的）
            const maxIdRot = this.rotorList.reduce((prev, curr) =>
            curr.ID > prev.ID ? curr : prev
            );
            this.currentRotorId = maxIdRot.ID;
            this.selectRotor = maxIdRot.NAME;

            AppStorage.set('lastrotor', this.currentRotorId);
          }
        }
        return true;
      }
      this.errorMessage = resp.message || '保存失败';
      return false;
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
    this.operateType = 3;
    const req: BaseModelInput<RotorSetModel> = {
      operateType: 3,
      model: this.buildModel()
    };
    const resp = await this.rotorSetApiService.RotorManage(req);
    return resp.success;
  }

  // 重置表单
  resetForm(): void {
    this.initDefaultValues();
  }

  getRotorOptions(): SelectOption[] {
    return this.rotorList.map(rotor => ({
      value: rotor.NAME,
      id: rotor.ID
    } as SelectOption));
  }
}