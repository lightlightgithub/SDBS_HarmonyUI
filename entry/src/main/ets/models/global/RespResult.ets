export interface RespResult<T> {
  success: boolean;
  respCode: number;
  respData: T;
  message: string;
}