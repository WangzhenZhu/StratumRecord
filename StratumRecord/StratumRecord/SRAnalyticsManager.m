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
    
    // 打开自动采集
    options.autoTrackEventType = SensorsAnalyticsEventTypeAppStart |
                                  SensorsAnalyticsEventTypeAppEnd |
                                  SensorsAnalyticsEventTypeAppViewScreen |
                                  SensorsAnalyticsEventTypeAppClick;
    
    // 打开 Debug 模式（发布时需要关闭）
    options.debugMode = SensorsAnalyticsDebugOff;
    
    // 开启日志
    options.enableLog = YES;
    
    // 初始化 SDK
    [SensorsAnalyticsSDK startWithConfigOptions:options];
    
    NSLog(@"✅ 神策分析 SDK 初始化成功");
}

- (void)trackPageViewBegin:(NSString *)pageName {
    [[SensorsAnalyticsSDK sharedInstance] trackViewScreen:pageName properties:@{
        @"page_start": @YES
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
