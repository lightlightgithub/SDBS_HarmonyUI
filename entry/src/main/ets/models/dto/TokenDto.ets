/**
 * TokenDto —— JWT 登录凭证 DTO（预留，后端引入 JWT 后启用）
 */
export interface TokenDto {
  token: string;    // JWT 字符串
  expireAt: number; // 过期时间戳（秒级）
}
