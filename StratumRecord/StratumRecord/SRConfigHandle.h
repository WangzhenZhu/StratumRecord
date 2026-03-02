//
//  SRConfigHandle.h
//  StratumRecord
//
//  Created by mac on 2026/3/2.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@class SceneDelegate;
@interface SRConfigHandle : NSObject

+ (UIViewController *)configShareViewControllerDelegate:(SceneDelegate *)delegate;
@end

NS_ASSUME_NONNULL_END
