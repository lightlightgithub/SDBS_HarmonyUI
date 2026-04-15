/**
 * ApiResult —— 预留的统一响应包装 DTO
 * 当后端升级为标准 REST 响应格式时启用（目前后端用 RespResult）
 */
export interface ApiResult<T> {
  code: number;      // HTTP 业务码
  message: string;   // 描述信息
  data: T;           // 响应数据体
  timestamp: number; // 服务器时间戳
}
