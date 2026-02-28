//
//  SRAnalyticsManager.h
//  StratumRecord
//
//  神策数据分析管理类
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SRAnalyticsManager : NSObject

+ (instancetype)sharedManager;

/**
 初始化神策 SDK
 @param serverURL 数据接收地址
 */
- (void)setupWithServerURL:(NSString *)serverURL;

/**
 页面浏览开始
 @param pageName 页面名称
 */
- (void)trackPageViewBegin:(NSString *)pageName;

/**
 页面浏览结束
 @param pageName 页面名称
 */
- (void)trackPageViewEnd:(NSString *)pageName;

/**
 追踪事件
 @param eventName 事件名称
 */
- (void)trackEvent:(NSString *)eventName;

/**
 追踪事件（带属性）
 @param eventName 事件名称
 @param properties 事件属性
 */
- (void)trackEvent:(NSString *)eventName properties:(nullable NSDictionary *)properties;

/**
 设置用户ID
 @param userId 用户唯一标识
 */
- (void)login:(NSString *)userId;

/**
 清除登录状态
 */
- (void)logout;

/**
 设置用户属性
 @param properties 用户属性字典
 */
- (void)setUserProperties:(NSDictionary *)properties;

@end

NS_ASSUME_NONNULL_END
