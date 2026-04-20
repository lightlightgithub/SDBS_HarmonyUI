/**
 * ApiConstants —— 后端接口地址常量
 * BASE_URL 开发时填写局域网 IP，部署后改为生产地址
 */
export class ApiConstants {
  /** 后端服务地址，物理设备需使用局域网 IP，不能用 localhost */
  //static readonly BASE_URL = 'http://192.168.10.91:5279';
  static readonly BASE_URL = 'http://192.168.11.65:5010';
  static readonly LOGIN = '/api/User/Login';               // 登录验证
  static readonly GET_USERS = '/api/User/GetUser';         // 获取用户列表
  static readonly GET_CURRENT_USER = '/api/User/GetCurrentUser'; // 获取当前用户
  static readonly  GetRotorSetList = '/api/RotorSet/GetRotorSet';  //查询转子列表
  static readonly GetRotorSetByID = '/api/RotorSet/GetRotorByID';  //根据ID查询转子
  static readonly RotorManage = '/api/RotorSet/RotorManage';  //转子管理
  static readonly GetPersistentConfig = '/api/Setting/GetPersistentConfig';  //查询持久化配置
  static readonly UpdatePersistentConfig = '/api/Setting/UpdatePersistentConfig'; //更新持久化配置
}
