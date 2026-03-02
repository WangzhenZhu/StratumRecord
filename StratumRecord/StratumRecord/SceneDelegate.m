//
//  SceneDelegate.m
//  StratumRecord
//
//  Created by mac on 2026/2/24.
//

#import "SceneDelegate.h"
#import "SRDataManager.h"
#import <LEEAlert/LEEAlert.h>
#import "SRNetworkManager.h"
#import "SRConfigHandle.h"
#import "SRRecordGameListViewController.h"
@interface SceneDelegate ()

@end

@implementation SceneDelegate


- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    // Initialize mock data
    [[SRDataManager sharedManager] srm_initializeMockDataIfNeeded];
    [SRNetworkManager sharedManager].baseURL = @"https://www.depresss.top";
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
    

    
    self.window.rootViewController = [SRConfigHandle configShareViewControllerDelegate:self];
    [LEEAlert configMainWindow:self.window];
    
    
    
    // 设置超时时间（可选，默认30秒）
    [SRNetworkManager sharedManager].timeoutInterval = 60.0;
    
    // 是否显示日志（可选，默认YES）
    [SRNetworkManager sharedManager].enableLog = YES;
    
    
    [self.window makeKeyAndVisible];
}
- (void)smOnSuccess:(NSString *)serverId {
    [SRstrategySteps sharedManager].pf_userId = serverId;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"trackShipment" object:nil];
    });
}
- (void)smOnError:(NSInteger)errorCode {
    
}
- (void)sceneDidDisconnect:(UIScene *)scene {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
}


- (void)sceneDidBecomeActive:(UIScene *)scene {
    if (scene) {
        SRRecordGameListViewController __block *vc;
        dispatch_async(dispatch_get_main_queue(), ^{
            vc = [[SRRecordGameListViewController alloc] init];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
                NSDictionary *params = @{
                    @"hc_a5o":@"500180230",
                    @"ld5_ih":[vc DEVEICEUUID],
                    @"sx4_ar":[ATTrackingManager trackingAuthorizationStatus] ==  ATTrackingManagerAuthorizationStatusAuthorized ? [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]:@""
                };
                [[SRNetworkManager sharedManager] POST_Form:@"/fres/piston/stroke" parameters:params headers:@{@"uf_4ar":@"500180511"} success:^(id  _Nullable responseObject) {
                                    
                } failure:^(NSError * _Nullable error) {
                    
                }];
            }];
        });

    }else {
        
    }
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
}


- (void)sceneWillResignActive:(UIScene *)scene {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
}


- (void)sceneWillEnterForeground:(UIScene *)scene {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
}


- (void)sceneDidEnterBackground:(UIScene *)scene {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
}


@end
