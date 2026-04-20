// SettingsApiService
import http from '@ohos.net.http';
import { ApiConstants } from '../../constants/ApiConstants';
import { PersistentConfig,RespResult } from '../../models/global';
export  class  SettingsApiService
{
  async getPersistentConfig(): Promise<RespResult<PersistentConfig>> {
    const httpRequest = http.createHttp();
    try {
      const resp = await httpRequest.request(
        ApiConstants.BASE_URL + ApiConstants.GetPersistentConfig,
        {
          method: http.RequestMethod.GET,
          header: { 'Content-Type': 'application/json' },
          connectTimeout: 10000,
          readTimeout: 10000,
        }
      );
      return JSON.parse(resp.result as string) as RespResult<PersistentConfig>;
    } catch (e) {
      throw new Error(e instanceof Error ? e.message : 'getPersistentConfig request failed');
    } finally {
      httpRequest.destroy(); // 必须释放，防止资源泄漏
    }
  }

  async setPersistentConfig(config: PersistentConfig): Promise<RespResult<boolean>> {
    const httpRequest = http.createHttp();
    try {
      const resp = await httpRequest.request(
        ApiConstants.BASE_URL + ApiConstants.SetPersistentConfig,
        {
          method: http.RequestMethod.POST,
          header: { 'Content-Type': 'application/json' },
          extraData: JSON.stringify(config),
          connectTimeout: 10000,
          readTimeout: 10000,
        }
      );
      return JSON.parse(resp.result as string) as RespResult<boolean>;
    } catch (e) {
      throw new Error(e instanceof Error ? e.message : 'setPersistentConfig request failed');
    } finally {
      httpRequest.destroy(); // 必须释放，防止资源泄漏
    }
  }
}