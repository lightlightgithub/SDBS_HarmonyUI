/**
 * LoginPage —— 登录页（路由入口）
 * 职责：UI 布局、用户事件转发给 LoginViewModel，不直接调用接口
 */
import { LoginViewModel } from '../../viewmodels/auth/LoginViewModel';

@Entry
@Component
struct LoginPage {
  @State private vm: LoginViewModel = new LoginViewModel(); // 页面状态由 ViewModel 管理
  @State private userNames: string[] = ['Administrator'];   // 用于下拉列表渲染的用户名数组

  /** 页面显示前从后端拉取用户列表，填充下拉框 */
  aboutToAppear(): void {
    this.vm.loadUsers()
      .then(() => {
        this.userNames = this.vm.userList.map(u => u.name);
        if (this.userNames.length === 0) {
          this.userNames = ['Administrator']; // 接口失败时保留默认值
        }
      })
      .catch((err: Error) => {
        this.userNames = ['Administrator']; // 异常时降级
      });
  }

  /** 点击登录：调用 ViewModel 验证，成功后跳转主页 */
  private async onLogin(): Promise<void> {
    const ok = await this.vm.login();
    if (ok) {
      this.getUIContext().getRouter().pushUrl({ url: 'pages/dashboard/DashboardPage' })
        .catch((err: Error) => { console.error('pushUrl failed:', err.message); });
    }
  }

  build() {
    Stack() {
      // 背景图（浅色）
      Image($rawfile('image/login/bg.jpg'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

      Column({ space: 0 }) {
        // 标题
        Text('Super Dynamic Balance System 3000')
          .fontSize(26)
          .fontColor('#2a5a8a')
          .fontWeight(FontWeight.Normal)
          .letterSpacing(2)
          .margin({ bottom: 50 })

        // 用户名下拉 —— 使用原项目输入框背景图
        Stack({ alignContent: Alignment.Start }) {
          Image($rawfile('image/login/input.png'))
            .width(320)
            .height(52)
            .objectFit(ImageFit.Fill)

          Row() {
            Image($rawfile('image/login/icon_user.png'))
              .width(24)
              .height(24)
              .margin({ left: 16, right: 8 })
              .objectFit(ImageFit.Contain)

            Select(this.userNames.map(n => ({ value: n } as SelectOption)))
              .selected(this.userNames.indexOf(this.vm.selectedUser))
              .value(this.vm.selectedUser)
              .font({ size: 16 })
              .fontColor('#2a5a8a')
              .backgroundColor(Color.Transparent)
              .onSelect((idx: number) => {
                this.vm.selectedUser = this.userNames[idx];
              })
              .layoutWeight(1)
          }
          .width(320)
          .height(52)
        }
        .margin({ bottom: 16 })

        // 密码输入 —— 使用原项目输入框背景图
        Stack({ alignContent: Alignment.Start }) {
          Image($rawfile('image/login/input.png'))
            .width(320)
            .height(52)
            .objectFit(ImageFit.Fill)

          Row() {
            Image($rawfile('image/login/icon_psd.png'))
              .width(24)
              .height(24)
              .margin({ left: 16, right: 8 })
              .objectFit(ImageFit.Contain)

            TextInput({ placeholder: '', text: this.vm.password })
              .type(this.vm.showPassword ? InputType.Normal : InputType.Password)
              .showPasswordIcon(false)
              .layoutWeight(1)
              .fontSize(16)
              .fontColor('#2a5a8a')
              .backgroundColor(Color.Transparent)
              .border({ width: 0 })
              .onChange((val: string) => {
                this.vm.password = val;
              })
              .onSubmit(() => {
                this.onLogin(); // 回车键触发登录，与登录按钮行为一致
              })

            Image($rawfile('image/login/icon_eye.png'))
              .width(24)
              .height(24)
              .margin({ right: 14 })
              .objectFit(ImageFit.Contain)
              .onClick(() => {
                this.vm.showPassword = !this.vm.showPassword;
              })
          }
          .width(320)
          .height(52)
        }
        .margin({ bottom: 8 })

        // 错误提示
        Text(this.vm.errorMessage)
          .fontSize(13)
          .fontColor('#cc3333')
          .height(20)
          .margin({ bottom: 20 })

        // 登录按钮 —— 使用原项目登录按钮图片
        Stack() {
          Image($rawfile('image/login/btn.png'))
            .width(320)
            .height(52)
            .objectFit(ImageFit.Fill)
            .opacity(this.vm.loading ? 0.6 : 1.0)

          Row({ space: 8 }) {
            if (this.vm.loading) {
              LoadingProgress()
                .width(20)
                .height(20)
                .color('#2a5a8a')
            }
            Text('登 录(Enter)')
              .fontSize(18)
              .fontColor('#2a5a8a')
              .fontWeight(FontWeight.Medium)
          }
        }
        .width(320)
        .height(52)
        .enabled(!this.vm.loading)
        .onClick(() => {
          this.onLogin();
        })

        // 版权
        Text('© Shanghai Jianping Dynamic Balancing Machine Manufacturing Co.,L')
          .fontSize(12)
          .fontColor('#7799aa')
          .margin({ top: 60 })
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
  }
}
