/**
 * AuthApiService —— 登录相关 HTTP 接口封装
 * 对应后端 UserController，只负责通信细节，不包含业务判断
 */
import http from '@ohos.net.http';
import { ApiConstants } from '../../constants/ApiConstants';

/** 登录请求体，与后端 LoginRequest 字段一一对应 */
export interface LoginRequest {
  name: string;
  psd: string;
  remember: boolean;
}

/** 后端统一响应包装格式，对应 RespResult<T> */
export interface RespResult<T> {
  success: boolean;
  respCode: number;
  respData: T;
  message: string;
}

/** 用户列表项 */
export interface UserItem {
  id: number;
  name: string;
  permission: number;
}

export class AuthApiService {
  /** POST /api/User/Login —— 登录验证，返回是否成功 */
  async login(req: LoginRequest): Promise<RespResult<boolean>> {
    const httpRequest = http.createHttp();
    try {
      console.log('login',ApiConstants.BASE_URL + ApiConstants.LOGIN);
      const resp = await httpRequest.request(
        ApiConstants.BASE_URL + ApiConstants.LOGIN,
        {
          method: http.RequestMethod.POST,
          header: { 'Content-Type': 'application/json' },
          extraData: JSON.stringify(req),
          connectTimeout: 10000,
          readTimeout: 10000,
        }
      );
      console.log('login resp',resp);
      return JSON.parse(resp.result as string) as RespResult<boolean>;
    } catch (e) {
      throw new Error(e instanceof Error ? e.message : 'login request failed');
    } finally {
      httpRequest.destroy(); // 必须释放，防止资源泄漏
    }
  }

  /** GET /api/User/GetUser —— 获取所有用户列表，用于登录页下拉框 */
  async getUsers(): Promise<RespResult<UserItem[]>> {
    const httpRequest = http.createHttp();
    try {
      const resp = await httpRequest.request(
        ApiConstants.BASE_URL + ApiConstants.GET_USERS,
        {
          method: http.RequestMethod.GET,
          header: { 'Content-Type': 'application/json' },
          connectTimeout: 10000,
          readTimeout: 10000,
        }
      );
      return JSON.parse(resp.result as string) as RespResult<UserItem[]>;
    } catch (e) {
      throw new Error(e instanceof Error ? e.message : 'getUsers request failed');
    } finally {
      httpRequest.destroy(); // 必须释放，防止资源泄漏
    }
  }
}
