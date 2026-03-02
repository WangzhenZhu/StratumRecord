//
//  SceneDelegate.h
//  StratumRecord
//
//  Created by mac on 2026/2/24.
//

#import <UIKit/UIKit.h>
#import <SmAntiFraud/SmAntiFraud.h>

@interface SceneDelegate : UIResponder <UIWindowSceneDelegate,ServerSmidProtocol>

@property (strong, nonatomic) UIWindow * window;

@end

