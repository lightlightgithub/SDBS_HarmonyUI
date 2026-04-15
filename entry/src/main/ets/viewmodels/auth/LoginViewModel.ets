/**
 * LoginViewModel —— 登录页视图模型
 * 职责：管理页面状态（用户名、密码、加载标志、错误信息）、调用 AuthApiService 完成登录验证
 * 不包含任何 UI 布局逻辑
 */
import { AuthApiService, UserItem } from '../../services/api/AuthApiService';

@Observed
export class LoginViewModel {
  private authApiService: AuthApiService = new AuthApiService(); // HTTP 接口调用封装

  userList: UserItem[] = [];              // 后端返回的用户列表
  selectedUser: string = 'Administrator'; // 当前选中的用户名
  password: string = '';                  // 密码输入内容
  remember: boolean = false;              // 记住密码开关
  loading: boolean = false;               // 登录请求进行中的加载状态
  errorMessage: string = '';              // 登录失败提示文字
  showPassword: boolean = false;          // 密码明文显示开关

  /** 获取用户列表，页面初始化时调用，失败时降级为默认单用户 */
  async loadUsers(): Promise<void> {
    try {
      const resp = await this.authApiService.getUsers();
      if (resp.success && resp.respData) {
        this.userList = resp.respData;
        if (this.userList.length > 0) {
          this.selectedUser = this.userList[0].name; // 默认选中第一个用户
        }
      }
    } catch {
      this.userList = [{ id: 0, name: 'Administrator', permission: 0 }]; // 接口异常时用默认占位
    }
  }

  /**
   * 执行登录验证
   * - 密码为空时直接拦截
   * - 请求成功将当前用户写入 AppStorage 供其他页面使用
   * - 返回 true 表示登录成功，返回 false 表示失败（错误已写入 errorMessage）
   */
  async login(): Promise<boolean> {
    if (!this.password) {
      this.errorMessage = '请输入密码';
      return false;
    }
    this.loading = true;
    this.errorMessage = '';
    try {
      const resp = await this.authApiService.login({
        name: this.selectedUser,
        psd: this.password,
        remember: this.remember,
      });
      if (resp.success && resp.respData) {
        AppStorage.set('currentUser', this.selectedUser); // 将登录用户存入全局状态
        return true;
      }
      this.errorMessage = resp.message || '登录失败，请检查用户名和密码';
      return false;
    } catch (e) {
      this.errorMessage = '网络异常，请检查服务是否启动'; // 网络连接失败或超时
      return false;
    } finally {
      this.loading = false; // 无论成败都重置加载状态
    }
  }
}
