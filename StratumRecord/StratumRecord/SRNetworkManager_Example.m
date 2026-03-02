//
//  SRNetworkManager 使用示例
//  StratumRecord
//
//  演示如何使用网络请求管理类
//

// #import "ViewController.h"
// #import "SRNetworkManager.h"

/**
 * 【使用示例】- SRNetworkManager POST 请求类
 * 
 * 这个文件展示了如何在项目中使用 SRNetworkManager 进行网络请求
 * 
 * 注意：本文件仅作为使用示例参考，不会被编译到项目中。
 * 如需使用，请将相应代码复制到您的实际文件中。
 */

#if 0  // 禁用编译，仅作为示例参考

#pragma mark - 1. 基础设置（在 AppDelegate 中配置）

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 设置 Base URL（可选）
    [SRNetworkManager sharedManager].baseURL = @"https://api.example.com";
    
    // 设置超时时间（可选，默认30秒）
    [SRNetworkManager sharedManager].timeoutInterval = 60.0;
    
    // 是否显示日志（可选，默认YES）
    [SRNetworkManager sharedManager].enableLog = YES;
    
    return YES;
}
 
 
 #pragma mark - 2. 基础 POST 请求
 
 - (void)exampleBasicPOST {
     // 准备参数
     NSDictionary *params = @{
         @"username": @"testuser",
         @"password": @"123456"
     };
     
     // 发起 POST 请求
     [[SRNetworkManager sharedManager] POST:@"/api/login"
                                 parameters:params
                                    success:^(id responseObject) {
         NSLog(@"登录成功: %@", responseObject);
         
         // 解析响应数据
         if ([responseObject isKindOfClass:[NSDictionary class]]) {
             NSDictionary *result = (NSDictionary *)responseObject;
             NSString *token = result[@"token"];
             NSString *userId = result[@"userId"];
             // 保存token和userId
         }
     }
                                    failure:^(NSError *error) {
         NSLog(@"登录失败: %@", error.localizedDescription);
         // 显示错误提示
     }];
 }
 
 
 #pragma mark - 3. 带进度的 POST 请求
 
 - (void)examplePOSTWithProgress {
     NSDictionary *params = @{
         @"title": @"新策略",
         @"content": @"策略内容...",
         @"gameName": @"League of Legends"
     };
     
     [[SRNetworkManager sharedManager] POST:@"/api/strategy/create"
                                 parameters:params
                                   progress:^(NSProgress *progress) {
         // 更新上传进度
         CGFloat percent = progress.fractionCompleted * 100;
         NSLog(@"上传进度: %.1f%%", percent);
         
         // 更新 UI 进度条
         dispatch_async(dispatch_get_main_queue(), ^{
             // self.progressView.progress = progress.fractionCompleted;
         });
     }
                                    success:^(id responseObject) {
         NSLog(@"发布成功: %@", responseObject);
     }
                                    failure:^(NSError *error) {
         NSLog(@"发布失败: %@", error.localizedDescription);
     }];
 }
 
 
 #pragma mark - 4. JSON 格式 POST 请求
 
 - (void)exampleJSONPOST {
     NSDictionary *params = @{
         @"userId": @"12345",
         @"strategyId": @"67890",
         @"action": @"like"
     };
     
     [[SRNetworkManager sharedManager] POST_JSON:@"/api/strategy/like"
                                       parameters:params
                                          success:^(id responseObject) {
         NSLog(@"点赞成功");
     }
                                          failure:^(NSError *error) {
         NSLog(@"点赞失败");
     }];
 }
 
 
 #pragma mark - 5. 表单格式 POST 请求
 
 /*
  POST 表单请求 - 使用 application/x-www-form-urlencoded 格式
  适用场景：传统表单提交、部分老旧 API
  */
 - (void)exampleFormPOST {
     NSDictionary *params = @{
         @"username": @"player123",
         @"password": @"password123",
         @"device_id": @"iPhone-X"
     };
     
     [[SRNetworkManager sharedManager] POST_Form:@"/api/user/login"
                                       parameters:params
                                          success:^(id responseObject) {
         NSLog(@"表单登录成功: %@", responseObject);
         // 处理登录结果
         NSDictionary *data = responseObject[@"data"];
         NSString *token = data[@"token"];
         // 保存 token
     }
                                          failure:^(NSError *error) {
         NSLog(@"表单登录失败: %@", error.localizedDescription);
     }];
 }
 
 
 #pragma mark - 6. 上传文件
 
 - (void)exampleUploadFile {
     // 准备图片数据
     UIImage *image = [UIImage imageNamed:@"avatar"];
     NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
     
     // 其他参数
     NSDictionary *params = @{
         @"userId": @"12345",
         @"description": @"头像上传"
     };
     
     [[SRNetworkManager sharedManager] POST_Upload:@"/api/user/uploadAvatar"
                                         parameters:params
                                           fileData:imageData
                                           fileName:@"avatar.jpg"
                                           mimeType:@"image/jpeg"
                                           progress:^(NSProgress *progress) {
         // 上传进度
         CGFloat percent = progress.fractionCompleted * 100;
         NSLog(@"上传进度: %.1f%%", percent);
     }
                                            success:^(id responseObject) {
         NSLog(@"上传成功: %@", responseObject);
         
         // 获取图片URL
         if ([responseObject isKindOfClass:[NSDictionary class]]) {
             NSString *imageURL = responseObject[@"imageUrl"];
             NSLog(@"图片URL: %@", imageURL);
         }
     }
                                            failure:^(NSError *error) {
         NSLog(@"上传失败: %@", error.localizedDescription);
     }];
 }
 
 
 #pragma mark - 7. 使用完整 URL
 
 - (void)exampleFullURL {
     // 不使用 baseURL，直接传完整地址
     [[SRNetworkManager sharedManager] POST:@"https://api.example.com/v1/login"
                                 parameters:@{@"username": @"test"}
                                    success:^(id responseObject) {
         NSLog(@"请求成功");
     }
                                    failure:^(NSError *error) {
         NSLog(@"请求失败");
     }];
 }
 
 
 #pragma mark - 8. 取消请求
 
 - (void)exampleCancelRequest {
     // 取消所有请求
     [[SRNetworkManager sharedManager] cancelAllRequests];
     
     // 取消指定URL的请求
     [[SRNetworkManager sharedManager] cancelRequestWithURL:@"/api/strategy/list"];
 }
 
 
 #pragma mark - 9. 实际业务示例 - 用户登录
 
 - (void)login {
     // 显示加载指示器
     // [SVProgressHUD show];
     
     NSDictionary *params = @{
         @"email": @"user@example.com",
         @"verificationCode": @"123456"
     };
     
     [[SRNetworkManager sharedManager] POST:@"/api/user/login"
                                 parameters:params
                                    success:^(id responseObject) {
         // 隐藏加载指示器
         // [SVProgressHUD dismiss];
         
         // 解析响应
         if ([responseObject[@"code"] integerValue] == 0) {
             NSDictionary *data = responseObject[@"data"];
             NSString *userId = data[@"userId"];
             NSString *token = data[@"token"];
             
             // 保存用户信息
             [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"userId"];
             [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"token"];
             
             // 跳转到主页
             // [self navigateToMainPage];
             
             NSLog(@"登录成功，用户ID: %@", userId);
         } else {
             NSString *message = responseObject[@"message"];
             NSLog(@"登录失败: %@", message);
             // [SVProgressHUD showError:message];
         }
     }
                                    failure:^(NSError *error) {
         // [SVProgressHUD dismiss];
         NSLog(@"网络错误: %@", error.localizedDescription);
         // [SVProgressHUD showError:@"网络连接失败，请检查网络设置"];
     }];
 }
 
 
 #pragma mark - 10. 实际业务示例 - 获取策略列表
 
 - (void)fetchStrategyList {
     NSDictionary *params = @{
         @"page": @1,
         @"pageSize": @20,
         @"gameName": @"League of Legends"
     };
     
     [[SRNetworkManager sharedManager] POST:@"/api/strategy/list"
                                 parameters:params
                                    success:^(id responseObject) {
         if ([responseObject[@"code"] integerValue] == 0) {
             NSArray *strategies = responseObject[@"data"][@"list"];
             NSLog(@"获取到 %ld 条策略", (long)strategies.count);
             
             // 刷新UI
             // [self.tableView reloadData];
         }
     }
                                    failure:^(NSError *error) {
         NSLog(@"获取失败: %@", error);
     }];
 }
 
 
 #pragma mark - 11. 实际业务示例 - 点赞策略
 
 - (void)likeStrategy:(NSString *)strategyId {
     NSDictionary *params = @{
         @"strategyId": strategyId,
         @"action": @"like"  // like 或 unlike
     };
     
     [[SRNetworkManager sharedManager] POST:@"/api/strategy/like"
                                 parameters:params
                                    success:^(id responseObject) {
         if ([responseObject[@"code"] integerValue] == 0) {
             NSLog(@"点赞成功");
             // 更新UI
             // [self updateLikeButtonState:YES];
         }
     }
                                    failure:^(NSError *error) {
         NSLog(@"点赞失败");
     }];
 }
 
 
 #pragma mark - 常见 MIME 类型参考
 
 /*
  图片类型：
  - image/jpeg
  - image/png
  - image/gif
  
  视频类型：
  - video/mp4
  - video/mpeg
  
  文档类型：
  - application/pdf
  - application/msword
  - application/vnd.ms-excel
  
  其他：
  - text/plain
  - application/json
  - application/octet-stream (二进制数据)
  */

#endif  // 示例代码结束

/*
 注意：本文件仅作为使用示例，不需要添加到项目编译目标中。
 如需使用，请将相应代码复制到您的实际文件中。
 */
