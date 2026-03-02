//
//  SRBaseViewController.h
//  StratumRecord
//
//  Created by mac on 2026/3/2.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <Photos/Photos.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCrypto.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <AdSupport/AdSupport.h>
NS_ASSUME_NONNULL_BEGIN

// Screen dimensions
#define SR_SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SR_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

// Status bar and navigation bar heights
#define SR_STATUS_BAR_HEIGHT ([[UIApplication sharedApplication] statusBarFrame].size.height)
#define SR_NAVIGATION_BAR_HEIGHT 44.0
#define SR_TOP_HEIGHT (SR_STATUS_BAR_HEIGHT + SR_NAVIGATION_BAR_HEIGHT)

// Safe area insets
#define SR_BOTTOM_SAFE_HEIGHT ([UIApplication sharedApplication].windows.firstObject.safeAreaInsets.bottom)
#define SR_TOP_SAFE_HEIGHT ([UIApplication sharedApplication].windows.firstObject.safeAreaInsets.top)

// User defaults keys
#define SR_USER_ID_KEY @"SR_USER_ID_KEY"
#define SR_USER_INFO_KEY @"SR_USER_INFO_KEY"

#define PlayerUId @"fleetDataKey"
#define IDFAValue @"idfaValue"
#define IDFAKey   @"idfaKey"
#define PlayOneKey @"PlayOneKey"
#define PlayTwoKey @"PlayTwoKey"
#define UUIDName @"uuidname"
#define UUIDPassword @"uuidpassword"

static char PlayerIdKey;
typedef void (^buttonEvent)(UIButton *btn);
/**
 * 基础视图控制器
 * 提供统一的导航栏样式和基础功能
 */
@interface SRBaseViewController : UIViewController

/// 自定义导航栏视图
@property (nonatomic, strong) UIView *navigationView;

/// 标题标签
@property (nonatomic, strong) UILabel *titleLabel;

/// 返回按钮
@property (nonatomic, strong) UIButton *backButton;

/**
 * 返回事件处理
 * 子类可以重写此方法以自定义返回行为
 */
- (void)backEvent;

@end

NS_ASSUME_NONNULL_END
