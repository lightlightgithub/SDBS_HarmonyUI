// SettingsViewModel
import { SettingsApiService } from '../../services/api/SettingsApiService';
import { PersistentConfig } from '../../models/global';

export class SettingsViewModel
{
  settingsApiService: SettingsApiService = new SettingsApiService();
  persistentConfig?: PersistentConfig;
}