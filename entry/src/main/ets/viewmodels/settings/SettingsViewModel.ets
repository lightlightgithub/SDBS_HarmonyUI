// SettingsViewModel
import { SettingsApiService } from '../../services/api/SettingsApiService';
import { PersistentConfig } from '../../models/global';
export class SettingsViewModel
{
  settingsApiService: SettingsApiService = new SettingsApiService();
  persistentConfig?:PersistentConfig;
  async getPersistentConfig(): Promise<void> {
    try {
      const resp = await this.settingsApiService.getPersistentConfig();
      console.log('持久化缓存：', JSON.stringify(resp));
      if (resp.success && resp.respData) {
        AppStorage.set('persistentConfig', resp.respData);
      }
    } catch {

    }
  }
}