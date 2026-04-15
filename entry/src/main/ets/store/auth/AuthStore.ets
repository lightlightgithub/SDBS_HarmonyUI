/**
 * AuthStore —— 登录态全局存储
 * 封装 AppStorage 对 token 的读写操作，供全局使用
 * 注：目前后端登录尚未返回 JWT，此类预留备用
 */
export class AuthStore {
  /** 将 JWT token 写入全局内存 */
  static setToken(token: string): void {
    AppStorage.set('token', token);
  }

  /** 读取当前 token，未登录时返回空字符串 */
  static getToken(): string {
    return AppStorage.get<string>('token') ?? '';
  }

  /** 清除登录态（登出时调用） */
  static clear(): void {
    AppStorage.delete('token');
  }
}
