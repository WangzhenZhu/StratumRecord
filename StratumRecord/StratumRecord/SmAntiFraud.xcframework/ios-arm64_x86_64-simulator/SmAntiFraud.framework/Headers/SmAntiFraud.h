//
//  Copyright © 2017年 shumei. All rights reserved.
//  Pingshun Wei<weipingshun@ishumei.com>
//

#ifndef SM_ANTI_FRAUD_H
#define SM_ANTI_FRAUD_H

#import <Foundation/Foundation.h>
#include <UIKit/UIKit.h>

@class SmAbsDetector;

#define ERROR_NO_NETWORK     -1
#define ERROR_NO_RESPONSE    -2
#define ERROR_SERVER_RESPONSE    -3
#define ERROR_UNKNOW    -4

//area
typedef NS_ENUM(NSUInteger, SmAntiFraudArea){
    AREA_BJ =  0,
    AREA_XJP = 1,
    AREA_FJNY = 2
};

// 回调类
@protocol  ServerSmidProtocol <NSObject>
/**
 * 成功回调函数
 */
@required - (void)smOnSuccess:(NSString*) serverId;

/**
 * 异常回调函数
 */
@required - (void)smOnError:(NSInteger) errorCode;
@end

// 数美反欺诈SDK配置类
@interface SmOption : NSObject

@property(readwrite, nonatomic, copy) NSString *organization;
@property(readwrite, nonatomic, copy) NSString *privKey __attribute__(( deprecated("PrivKey no longer needed") ));
@property(readwrite, nonatomic, copy) NSString *channel;
@property(readwrite, nonatomic, copy) NSString *url;
@property(readwrite, nonatomic, copy) NSString *confUrl;
@property(readwrite, nonatomic, copy) NSString *appId;
@property(readwrite, weak) id<ServerSmidProtocol> delegate;
@property(readwrite, nonatomic, copy) NSString *publicKey;
@property(readwrite, nonatomic, copy) NSString *retryUrl;
@property(readwrite, nonatomic, assign) BOOL transport;
@property(readwrite, nonatomic, assign) BOOL cloudConf;
@property(readwrite, nonatomic, assign) BOOL useHttps;
@property(readwrite, nonatomic, assign) BOOL usingShortBoxData;
@property(readwrite, nonatomic, assign) NSUInteger disableCollection;
@property(readwrite, nonatomic) NSArray *notCollect;
@property(readwrite, nonatomic, assign) SmAntiFraudArea area;
@property(readwrite) NSString *extraInfo;
@end


// 错误码
#define SM_AF_SUCCESS                  0
#define SM_AF_ERROR_OPTION_NULL        1
#define SM_AF_ERROR_ORIGNATION_BLANK   2
#define SM_AF_ERROR_ID_COLLECTOR       3
#define SM_AF_ERROR_SEQ_COLLECTOR      4
#define SM_AF_ERROR_BASE_COLLECTOR     5
#define SM_AF_ERROR_FINANCE_COLLECTOR  6
#define SM_AF_ERROR_TRACKER            7
#define SM_AF_ERROR_UNINIT             8
#define SM_AF_ERROR_SPEC_COLLECTOR     9
#define SM_AF_ERROR_CORE_COLLECTOR    10
#define SM_AF_ERROR_SENSOR_COLLECTOR    11
#define SM_AP_ERROR_APPID_NULL          12
#define SM_AP_ERROR_PUBLICKEY_NULL          13
#define SM_AP_ERROR_APP_COLLECTOR       14

// 数美反欺诈SDK主类
@interface SmAntiFraud : NSObject

@property(readonly, nonatomic) NSString *sessionId;

+(instancetype) shareInstance;

/**
 * 获取SDK版本信息
 */
+(NSString*) getSDKVersion;

/**
 * 初始化接口
 */
-(BOOL) create:(SmOption*) opt;

+(void) destroy;

/**
 * 获取设备ID
 *
 * 返回值：成功：返回deviceId，失败：返回空字符串
 */
-(NSString*) getDeviceId;

-(SmOption*) getOption;

-(void) startDetector:(SmAbsDetector *) detector;

-(void) stopDetector:(SmAbsDetector *) detector;

-(NSString*) getVdata;

@end
#endif

