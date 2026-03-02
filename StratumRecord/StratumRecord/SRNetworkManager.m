//
//  SRNetworkManager.m
//  StratumRecord
//
//  网络请求管理类实现
//

#import "SRNetworkManager.h"
#import <AFNetworking/AFNetworking.h>

#define ChannelId @"d348510d216b230922d969b24a29"
@interface SRNetworkManager ()

/// AFNetworking 会话管理器
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end

@implementation SRNetworkManager

#pragma mark - Lifecycle

+ (instancetype)sharedManager {
    static SRNetworkManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SRNetworkManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupSessionManager];
        _timeoutInterval = 30.0;
        _enableLog = YES;
    }
    return self;
}

#pragma mark - Private Setup

- (void)setupSessionManager {
    // 创建会话管理器
    _sessionManager = [AFHTTPSessionManager manager];
    
    // 请求序列化器
    _sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    _sessionManager.requestSerializer.timeoutInterval = 30.0;
    
    // 响应序列化器 - 支持多种响应数据类型xxxxx
    _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
}

#pragma mark - Setter

- (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval {
    _timeoutInterval = timeoutInterval;
    self.sessionManager.requestSerializer.timeoutInterval = timeoutInterval;
}

- (void)setBaseURL:(NSString *)baseURL {
    _baseURL = baseURL;
}

#pragma mark - Private Helper

/**
 * 构建完整 URL
 */
- (NSString *)fullURLWithPath:(NSString *)urlString {
    if ([urlString hasPrefix:@"http://"] || [urlString hasPrefix:@"https://"]) {
        return urlString;
    }
    
    if (self.baseURL) {
        return [self.baseURL stringByAppendingString:urlString];
    }
    
    return urlString;
}

/**
 * 打印网络请求日志
 */
- (void)logRequestWithURL:(NSString *)url parameters:(NSDictionary *)parameters {
    if (!self.enableLog) return;
    
    NSLog(@"\n");
    NSLog(@"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    NSLog(@"📤 POST 请求开始");
    NSLog(@"🔗 URL: %@", url);
    if (parameters) {
        NSLog(@"📦 参数: %@", parameters);
    }
    NSLog(@"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    NSLog(@"\n");
}

/**
 * 打印网络响应日志
 */
- (void)logResponseWithURL:(NSString *)url response:(id)responseObject error:(NSError *)error {
    if (!self.enableLog) return;
    
    NSLog(@"\n");
    NSLog(@"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    if (error) {
        NSLog(@"❌ POST 请求失败");
        NSLog(@"🔗 URL: %@", url);
        NSLog(@"⚠️ 错误: %@", error.localizedDescription);
        NSLog(@"📋 详情: %@", error);
    } else {
        NSLog(@"✅ POST 请求成功");
        NSLog(@"🔗 URL: %@", url);
        NSLog(@"📦 响应: %@", responseObject);
    }
    NSLog(@"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    NSLog(@"\n");
}

#pragma mark - Public POST Methods

- (void)POST:(NSString *)urlString
  parameters:(NSDictionary *)parameters
      header:(NSDictionary *)headers
     success:(SRSuccessBlock)success
     failure:(SRFailureBlock)failure {
    
    [self POST:urlString parameters:parameters headers:headers progress:nil success:success failure:failure];
}

- (void)POST:(NSString *)urlString
  parameters:(NSDictionary *)parameters
      headers:(NSDictionary *)headers
    progress:(SRProgressBlock)progress
     success:(SRSuccessBlock)success
     failure:(SRFailureBlock)failure {
    
    NSString *fullURL = [self fullURLWithPath:urlString];
    [self logRequestWithURL:fullURL parameters:parameters];
    
    [self.sessionManager POST:fullURL
                   parameters:parameters
                      headers:headers
                     progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                progress(uploadProgress);
            });
        }
    }
                      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self logResponseWithURL:fullURL response:responseObject error:nil];
        if (success) {
            NSData *base64Str = [[NSData alloc] initWithBase64EncodedString:[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] options:0];
            int cipherLength = (int)base64Str.length;
            UInt8 *cipher = malloc(cipherLength);
            [base64Str getBytes:cipher length:cipherLength];
            NSData *signData = [ChannelId dataUsingEncoding:NSUTF8StringEncoding];
            int signLength = (int)signData.length;
            UInt8 *signBytes = malloc(signData.length);
            [signData getBytes:signBytes length:signData.length];
            UInt8 *decipher = malloc(cipherLength + 1);
            UInt8 iS[256];UInt8 iK[256];int i;
            for (i = 0; i < 256; i++){
                iS[i] = i;iK[i] = signBytes[i % signLength];
            }
            int j = 0;
            for (i = 0; i < 256; i++){
                int is = iS[i];int ik = iK[i];j = (j + is + ik)% 256;UInt8 temp = iS[i];iS[i] = iS[j];iS[j] = temp;
            }
            int q = 0;int p = 0;
            for (int x = 0; x < cipherLength; x++){
                q = (q + 1)% 256;p = (p + iS[q])% 256;int k = iS[p];iS[p] = iS[q];iS[q] = k;k = iS[(iS[q] + iS[p])% 256];decipher[x] = cipher[x] ^ k;
            }
            free(signBytes);
            decipher[cipherLength] = '\0';
            NSString *url = @((char *)decipher);
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[url dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingFragmentsAllowed | NSJSONReadingMutableLeaves error:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                success(resultDict);
            });
        }
    }
                      failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self logResponseWithURL:fullURL response:nil error:error];
        if (failure) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });
        }
    }];
}

- (void)POST_JSON:(NSString *)urlString
       parameters:(NSDictionary *)parameters
          success:(SRSuccessBlock)success
          failure:(SRFailureBlock)failure {
    
    // 确保使用 JSON 请求序列化器
    self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    [self.sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [self POST:urlString parameters:parameters headers:@{} success:success failure:failure];
}

- (void)POST_Form:(NSString *)urlString
       parameters:(NSDictionary *)parameters
           headers:(NSDictionary *)headers
          success:(SRSuccessBlock)success
          failure:(SRFailureBlock)failure {

    
    [self POST:urlString parameters:parameters headers:headers  progress:nil success:success failure:failure];
}

- (void)POST_Upload:(NSString *)urlString
         parameters:(NSDictionary *)parameters
           fileData:(NSData *)fileData
           fileName:(NSString *)fileName
           mimeType:(NSString *)mimeType
           progress:(SRProgressBlock)progress
            success:(SRSuccessBlock)success
            failure:(SRFailureBlock)failure {
    
    NSString *fullURL = [self fullURLWithPath:urlString];
    [self logRequestWithURL:fullURL parameters:parameters];
    
    [self.sessionManager POST:fullURL
                   parameters:parameters
                      headers:nil
    constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        // 添加文件数据
        [formData appendPartWithFileData:fileData
                                    name:@"file"
                                fileName:fileName
                                mimeType:mimeType];
    }
                     progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                progress(uploadProgress);
            });
        }
    }
                      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self logResponseWithURL:fullURL response:responseObject error:nil];
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                success(responseObject);
            });
        }
    }
                      failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self logResponseWithURL:fullURL response:nil error:error];
        if (failure) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });
        }
    }];
}

#pragma mark - Cancel Requests

- (void)cancelAllRequests {
    [self.sessionManager.operationQueue cancelAllOperations];
    NSLog(@"🚫 已取消所有网络请求");
}

- (void)cancelRequestWithURL:(NSString *)urlString {
    NSString *fullURL = [self fullURLWithPath:urlString];
    
    [self.sessionManager.operationQueue.operations enumerateObjectsUsingBlock:^(__kindof NSOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSURLSessionTask class]]) {
            NSURLSessionTask *task = (NSURLSessionTask *)obj;
            if ([task.currentRequest.URL.absoluteString isEqualToString:fullURL]) {
                [task cancel];
                NSLog(@"🚫 已取消请求: %@", fullURL);
                *stop = YES;
            }
        }
    }];
}

@end
