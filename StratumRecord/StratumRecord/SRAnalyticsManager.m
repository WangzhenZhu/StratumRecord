//
//  SRAnalyticsManager.m
//  StratumRecord
//
//  神策数据分析管理类
//

#import "SRAnalyticsManager.h"
#import <SensorsAnalyticsSDK/SensorsAnalyticsSDK.h>

@implementation SRAnalyticsManager

+ (instancetype)sharedManager {
    static SRAnalyticsManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SRAnalyticsManager alloc] init];
    });
    return instance;
}

- (void)setupWithServerURL:(NSString *)serverURL {
    SAConfigOptions *options = [[SAConfigOptions alloc] initWithServerURL:serverURL launchOptions:nil];
    
    // 配置安全策略 - 允许所有证书（开发/测试环境使用）
    // 生产环境建议使用 [SASecurityPolicy policyWithPinningMode:SASSLPinningModePublicKey]
    SASecurityPolicy *securityPolicy = [SASecurityPolicy policyWithPinningMode:SASSLPinningModeNone];
    securityPolicy.allowInvalidCertificates = YES; // 允许无效证书（仅开发/测试环境）
    securityPolicy.validatesDomainName = NO; // 不验证域名（仅开发/测试环境）
    options.securityPolicy = securityPolicy;
    
//    // 打开自动采集
//    options.autoTrackEventType = SensorsAnalyticsEventTypeAppStart |
//                                  SensorsAnalyticsEventTypeAppEnd |
//                                  SensorsAnalyticsEventTypeAppViewScreen |
//                                  SensorsAnalyticsEventTypeAppClick;
    
    // 开启日志
    options.enableLog = false;
    
    // 初始化 SDK
    [SensorsAnalyticsSDK startWithConfigOptions:options];
    
    NSLog(@"✅ 神策分析 SDK 初始化成功（已配置宽松的SSL策略）");
}

- (void)trackPageViewBegin:(NSString *)pageName {
    [[SensorsAnalyticsSDK sharedInstance] track:@"PageViewBegin" withProperties:@{
        @"page_name": pageName
    }];
    NSLog(@"📊 神策页面埋点: %@ (开始)", pageName);
}

- (void)trackPageViewEnd:(NSString *)pageName {
    [[SensorsAnalyticsSDK sharedInstance] track:@"PageViewEnd" withProperties:@{
        @"page_name": pageName
    }];
    NSLog(@"📊 神策页面埋点: %@ (结束)", pageName);
}

- (void)trackEvent:(NSString *)eventName {
    [self trackEvent:eventName properties:nil];
}

- (void)trackEvent:(NSString *)eventName properties:(NSDictionary *)properties {
    [[SensorsAnalyticsSDK sharedInstance] track:eventName withProperties:properties];
    NSLog(@"📊 神策事件埋点: %@ 属性: %@", eventName, properties);
}

- (void)login:(NSString *)userId {
    [[SensorsAnalyticsSDK sharedInstance] login:userId];
    NSLog(@"👤 神策用户登录: %@", userId);
}

- (void)logout {
    [[SensorsAnalyticsSDK sharedInstance] logout];
    NSLog(@"👤 神策用户登出");
}

- (void)setUserProperties:(NSDictionary *)properties {
    [[SensorsAnalyticsSDK sharedInstance] set:properties];
    NSLog(@"👤 神策设置用户属性: %@", properties);
}

@end
