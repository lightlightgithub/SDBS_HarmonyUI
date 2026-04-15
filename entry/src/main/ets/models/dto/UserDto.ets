/**
 * UserDto —— 用户信息 DTO，对应后端 T_USER 表的视图层字段
 */
export interface UserDto {
  id: number;       // 用户 ID
  username: string; // 用户名
  role: string;     // 角色（对应 PERMISSION 字段，前后端升级后映射）
}
