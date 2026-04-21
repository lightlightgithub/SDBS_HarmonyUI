// RotorApiService
import http from '@ohos.net.http';
import { ApiConstants } from '../../constants/ApiConstants';// RotorApiService
import { RespResult,BaseModelInput } from '../../models/global';
import { RotorSetModel } from '../../models/entity';
export  class  RotorApiService
{
  //增删改转子
  async RotorManage(req: BaseModelInput<RotorSetModel>): Promise<RespResult<number>>
  {
    const httpRequest = http.createHttp();
    try {
      console.log('转子管理参数',JSON.stringify(req));
      const resp = await httpRequest.request(
        ApiConstants.BASE_URL + ApiConstants.RotorManage,
        {
          method: http.RequestMethod.POST,
          header: { 'Content-Type': 'application/json' },
          extraData: JSON.stringify(req),
          connectTimeout: 10000,
          readTimeout: 10000,
        }
      );
      return JSON.parse(resp.result as string) as RespResult<number>;
    } catch (e) {
      throw new Error(e instanceof Error ? e.message : 'RotorSet request failed');
    } finally {
      httpRequest.destroy(); // 必须释放，防止资源泄漏
    }
  }
  // 获取所有转子列表
  async GetRotorList(): Promise<RespResult<RotorSetModel[]>> {
    const httpRequest = http.createHttp();
    try {
      const resp = await httpRequest.request(
        ApiConstants.BASE_URL + ApiConstants.GetRotorSetList,
        {
          method: http.RequestMethod.GET,
          header: { 'Content-Type': 'application/json' },
          connectTimeout: 10000,
          readTimeout: 10000,
        }
      );
      console.log('GetRotorList req',ApiConstants.BASE_URL + ApiConstants.GetRotorSetList);
      console.log('GetRotorList resp',JSON.stringify(resp.result));
      return JSON.parse(resp.result as string) as RespResult<RotorSetModel[]>;
    } catch (e) {
      console.log('GetRotorList err',e.message);
      throw new Error(e instanceof Error ? e.message : 'GetRotorList request failed');
    } finally {
      httpRequest.destroy();
    }
  }
  // 根据ID获取转子详情
  async GetRotorById(id: number): Promise<RespResult<RotorSetModel>> {
    const httpRequest = http.createHttp();
    try {
      const resp = await httpRequest.request(
        `${ApiConstants.BASE_URL + ApiConstants.GetRotorSetByID}?id=${id}`,
        {
          method: http.RequestMethod.GET,
          header: { 'Content-Type': 'application/json' },
          connectTimeout: 10000,
          readTimeout: 10000,
        }
      );
      return JSON.parse(resp.result as string) as RespResult<RotorSetModel>;
    } catch (e) {
      throw new Error(e instanceof Error ? e.message : 'GetRotorById request failed');
    } finally {
      httpRequest.destroy();
    }
  }
}