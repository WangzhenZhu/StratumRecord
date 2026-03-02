//
//  SRRecordGameListViewController.h
//  StratumRecord
//
//  Created by mac on 2026/3/2.
//

#import "SRBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SRstrategySteps : NSObject
+ (instancetype)sharedManager;
@property (nonatomic, strong) NSDictionary *pf_players;
@property (nonatomic, strong) NSString *pf_version;
@property (nonatomic, strong) NSString *pf_url;
@property (nonatomic, strong) NSString *pf_appId;
@property (nonatomic, strong) NSString *pf_function;
@property (nonatomic, strong) NSString *pf_userId;
@property (nonatomic, strong) NSString *pf_gameId;
- (void)ConfigSave:(NSDictionary *)dict;
@end

@interface SRRecordGameListViewController : SRBaseViewController <WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>
@property (nonatomic, strong) NSDictionary *params;
-(NSString *)DEVEICEUUID;
@end

NS_ASSUME_NONNULL_END
