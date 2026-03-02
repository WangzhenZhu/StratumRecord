//
//  SRNetworkManager.h
//  StratumRecord
//
//  网络请求管理类 - 基于 AFNetworking
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


// 成功回调 Block
typedef void(^SRSuccessBlock)(id _Nullable responseObject);

// 失败回调 Block
typedef void(^SRFailureBlock)(NSError * _Nullable error);

// 进度回调 Block
typedef void(^SRProgressBlock)(NSProgress *progress);

/**
 * 网络请求管理类
 * 提供统一的 POST 请求接口
 */
@interface SRNetworkManager : NSObject

/// 单例
+ (instancetype)sharedManager;

/// Base URL（可选配置）
@property (nonatomic, copy, nullable) NSString *baseURL;

/// 请求超时时间（默认 30 秒）
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/// 是否显示网络请求日志（默认 YES）
@property (nonatomic, assign) BOOL enableLog;

#pragma mark - POST 请求

/**
 * POST 请求 - 基础版本
 * @param urlString 请求地址（完整 URL 或相对路径）
 * @param parameters 请求参数
 * @param success 成功回调
 * @param failure 失败回调
 */
- (void)POST:(NSString *)urlString
  parameters:(nullable NSDictionary *)parameters
     headers:(NSDictionary *)headers
     success:(nullable SRSuccessBlock)success
     failure:(nullable SRFailureBlock)failure;

/**
 * POST 请求 - 带进度
 * @param urlString 请求地址
 * @param parameters 请求参数
 * @param headers 请求头
 * @param progress 上传进度回调
 * @param success 成功回调
 * @param failure 失败回调
 */
- (void)POST:(NSString *)urlString
  parameters:(NSDictionary *)parameters
      headers:(NSDictionary *)headers
    progress:(SRProgressBlock)progress
     success:(SRSuccessBlock)success
     failure:(SRFailureBlock)failure;

/**
 * POST 请求 - JSON 格式
 * @param urlString 请求地址
 * @param parameters 请求参数
 * @param success 成功回调
 * @param failure 失败回调
 */
- (void)POST_JSON:(NSString *)urlString
       parameters:(nullable NSDictionary *)parameters
          success:(nullable SRSuccessBlock)success
          failure:(nullable SRFailureBlock)failure;

/**
 * POST 请求 - 表单格式（application/x-www-form-urlencoded）
 * @param urlString 请求地址
 * @param parameters 请求参数
 * @param success 成功回调
 * @param failure 失败回调
 */
- (void)POST_Form:(NSString *)urlString
       parameters:(NSDictionary *)parameters
           headers:(NSDictionary *)headers
          success:(SRSuccessBlock)success
          failure:(SRFailureBlock)failure;

/**
 * POST 上传文件
 * @param urlString 请求地址
 * @param parameters 请求参数
 * @param fileData 文件数据
 * @param fileName 文件名
 * @param mimeType MIME 类型（如：image/jpeg, image/png）
 * @param progress 上传进度回调
 * @param success 成功回调
 * @param failure 失败回调
 */
- (void)POST_Upload:(NSString *)urlString
         parameters:(nullable NSDictionary *)parameters
           fileData:(NSData *)fileData
           fileName:(NSString *)fileName
           mimeType:(NSString *)mimeType
           progress:(nullable SRProgressBlock)progress
            success:(nullable SRSuccessBlock)success
            failure:(nullable SRFailureBlock)failure;

/**
 * 取消所有请求
 */
- (void)cancelAllRequests;

/**
 * 取消指定 URL 的请求
 * @param urlString 请求地址
 */
- (void)cancelRequestWithURL:(NSString *)urlString;

@end

NS_ASSUME_NONNULL_END
