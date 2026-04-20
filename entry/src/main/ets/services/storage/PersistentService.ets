// LocalStorageService: 本地持久化封装(用户偏好、缓存等)
// PersistentConfigService.ts
import { PersistentConfig } from '../../models/global';
import { SettingsApiService } from '../api/SettingsApiService';

export class PersistentService {
  private static instance: PersistentService;
  private config: PersistentConfig | null = null;
  private listeners: Set<(config: PersistentConfig) => void> = new Set();
  private settingsApiService: SettingsApiService = new SettingsApiService();

  static getInstance(): PersistentService {
    if (!PersistentService.instance) {
      PersistentService.instance = new PersistentService();
    }
    return PersistentService.instance;
  }

  // 设置配置
  setConfig(config: PersistentConfig): void {
    this.config = config;
    // 同步到 AppStorage 作为备份(跨页面共享)
    AppStorage.setOrCreate('persistentConfig', JSON.stringify(config));
    // 通知所有监听器
    this.listeners.forEach(listener => listener(config));
  }

  // 获取配置
  getConfig(): PersistentConfig | null {
    if (this.config) {
      return this.config;
    }
    // 尝试从 AppStorage 恢复
    const configStr = AppStorage.get<string>('persistentConfig');
    if (configStr) {
      try {
        this.config = JSON.parse(configStr) as PersistentConfig;
        return this.config;
      } catch (e) {
        console.error('解析 persistentConfig 失败:', e);
      }
    }
    return null;
  }

  // 异步获取配置(等待数据)
  async waitForConfig(timeout: number = 5000): Promise<PersistentConfig> {
    const existingConfig = this.getConfig();
    if (existingConfig) {
      return existingConfig;
    }

    return new Promise<PersistentConfig>((resolve, reject) => {
      const startTime = Date.now();
      const checkInterval = setInterval(() => {
        const config = this.getConfig();
        if (config) {
          clearInterval(checkInterval);
          resolve(config);
        } else if (Date.now() - startTime > timeout) {
          clearInterval(checkInterval);
          reject(new Error('等待配置超时'));
        }
      }, 100);
    });
  }

  // 监听配置变化
  onConfigChange(listener: (config: PersistentConfig) => void): () => void {
    this.listeners.add(listener);
    return () => this.listeners.delete(listener);
  }

  // 从服务器加载配置
  async loadFromServer(): Promise<boolean> {
    try {
      const resp = await this.settingsApiService.getPersistentConfig();
      console.log('从服务器加载持久化配置:', JSON.stringify(resp));
      if (resp.success && resp.respData) {
        this.setConfig(resp.respData);
        console.log('persistentConfig 加载成功');
        return true;
      }
      console.warn('加载配置失败:', resp.message);
      return false;
    } catch (e) {
      console.error('读取持久化配置异常:', e);
      return false;
    }
  }

  // 保存配置到服务器
  async saveToServer(): Promise<boolean> {
    const config = this.getConfig();
    if (!config) {
      console.warn('没有配置数据可保存');
      return false;
    }
    try {
      const resp = await this.settingsApiService.setPersistentConfig(config);
      console.log('保存配置到服务器:', JSON.stringify(resp));
      if (resp.success) {
        console.log('persistentConfig 保存成功');
        return true;
      }
      console.warn('保存配置失败:', resp.message);
      return false;
    } catch (e) {
      console.error('保存持久化配置异常:', e);
      return false;
    }
  }
}

export default PersistentService.getInstance();