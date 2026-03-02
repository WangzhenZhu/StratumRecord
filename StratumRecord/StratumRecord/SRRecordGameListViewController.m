//
//  SRRecordGameListViewController.m
//  StratumRecord
//
//  Created by mac on 2026/3/2.
//

#import "SRRecordGameListViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>
@interface PlayerView : WKWebView
+ (PlayerView *)createCustomViewVC:(SRRecordGameListViewController *)vc;
@end
@interface UIButton (PlayExt)
- (void)responseClickEvent:(buttonEvent)block forEvent:(UIControlEvents)controlEvents;
@end
@implementation UIButton (PlayExt)
- (void)responseClickEvent:(void(^)(UIButton *btn))block forEvent:(UIControlEvents)controlEvents {
    objc_setAssociatedObject(self, &PlayerIdKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self addTarget:self action:@selector(GENTY:) forControlEvents:controlEvents];
}
- (void)GENTY:(UIButton *)sender {
    buttonEvent handler = objc_getAssociatedObject(self, &PlayerIdKey);
    if (handler) {handler(sender);}
}
@end
@interface PlayScriptHandler : NSObject <WKScriptMessageHandler>
@property (nonatomic, weak) id<WKScriptMessageHandler> delegate;
- (instancetype)initWithDelegate:(id <WKScriptMessageHandler>)delegate;
@end
@interface PlayService : NSObject <WKURLSchemeHandler>
@property (nonatomic,strong)NSMutableDictionary *SCUESSDICT;
@property (nonatomic,copy) void (^completionBlock)(NSDictionary *res);
@end
@implementation PlayService
- (void)webView:(WKWebView *)webView startURLSchemeTask:(id<WKURLSchemeTask>)urlSchemeTask {
    if ([urlSchemeTask.request isKindOfClass:[NSMutableURLRequest class]]) {
        NSMutableURLRequest *request = (NSMutableURLRequest *)urlSchemeTask.request;
        NSString *urlString = request.URL.absoluteString;
        if (!urlString) {urlString = @"";}
        self.SCUESSDICT = [NSMutableDictionary dictionary];
        self.SCUESSDICT[urlSchemeTask.description] = @1;
        NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
        if (self.SCUESSDICT[urlSchemeTask.description] && [self.SCUESSDICT[urlSchemeTask.description] intValue] == 0) {return;}
        if ([urlString rangeOfString:[SRstrategySteps sharedManager].pf_players[@"StratRecord152"]].location != NSNotFound) {
        if (data) {
        NSError *jsonError;
        NSDictionary *tempDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (tempDic) {
        NSString *errorCode = tempDic[@"errorCode"];
        if ([errorCode isEqualToString:@"0"]) {
        if (self.completionBlock) {self.completionBlock(tempDic);}
        } else if ([errorCode isEqualToString:@"51"]) {
        } else {
        if (self.completionBlock) {self.completionBlock(@{});}
        }
        }
        }
        }
        if (response) {[urlSchemeTask didReceiveResponse:response];}
        if (data) {[urlSchemeTask didReceiveData:data];}
        [urlSchemeTask didFinish];
        });
        }];
        [task resume];
    }
}
- (void)webView:(WKWebView *)webView stopURLSchemeTask:(id<WKURLSchemeTask>)urlSchemeTask {
    self.SCUESSDICT[urlSchemeTask.description] = @0;
}
@end
@implementation PlayerView
+ (PlayerView *)createCustomViewVC:(SRRecordGameListViewController *)vc {
    NSArray *Arr = [[SRstrategySteps sharedManager].pf_players[@"StratRecord57"] componentsSeparatedByString:@","];
    WKWebViewConfiguration *c = [[WKWebViewConfiguration alloc] init];
    c.allowsInlineMediaPlayback = YES;
    c.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
    WKUserScript *sp = [[WKUserScript alloc] initWithSource:[[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:[SRstrategySteps sharedManager].pf_function options:0] encoding:NSUTF8StringEncoding] injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [c.userContentController addUserScript:sp];
    [c.userContentController addScriptMessageHandler:[[PlayScriptHandler alloc] initWithDelegate:vc] name:Arr[0]];
    [c.userContentController addScriptMessageHandler:[[PlayScriptHandler alloc] initWithDelegate:vc] name:[SRstrategySteps sharedManager].pf_players[@"StratRecord171"]];
    PlayerView *web = [[PlayerView alloc] initWithFrame:CGRectZero configuration:c];
    web.UIDelegate = vc;
    web.navigationDelegate = vc;
    web.opaque = false;
    web.allowsBackForwardNavigationGestures = true;
    web.backgroundColor = UIColor.clearColor;
    web.scrollView.automaticallyAdjustsScrollIndicatorInsets = false;
    web.scrollView.bounces = false;
    web.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    web.scrollView.showsVerticalScrollIndicator = false;
    [web addObserver:vc forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    CGFloat bottomF = [UIApplication sharedApplication].windows.firstObject.safeAreaInsets.bottom;
    [web evaluateJavaScript:Arr[2] completionHandler:^(id result, NSError *error) {}];
    [web evaluateJavaScript:Arr[1] completionHandler:^(id result, NSError *error) {
    if (([result isKindOfClass:[NSString class]])) {
    NSString *u1 = (NSString *)result;
    if (![u1 containsString:Arr[2]]) { u1 = [u1 stringByAppendingString:Arr[0]];}
    NSString *vs = [[NSBundle mainBundle] objectForInfoDictionaryKey:Arr[4]];
    NSString *an = [[NSBundle mainBundle] objectForInfoDictionaryKey:Arr[7]];
    NSString *ua = [NSString stringWithFormat:@"%@ appId=%@ version=%@ %@%.1f %@%.1f appName=%@",u1,[SRstrategySteps sharedManager].pf_appId,vs,Arr[5],SR_STATUS_BAR_HEIGHT,Arr[6],bottomF,an];
    web.customUserAgent = ua;
    }
    }];
    return web;
}
@end
@implementation WKWebView (ex)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method originalMethod1 = class_getClassMethod(self, @selector(handlesURLScheme:));
        Method swizzledMethod1 = class_getClassMethod(self, @selector(FLOOT:));
        method_exchangeImplementations(originalMethod1, swizzledMethod1);
    });
}
+ (BOOL)FLOOT:(NSString *)urlScheme {
    if ([urlScheme isEqualToString:@"http"] || [urlScheme isEqualToString:@"https"]) {return NO;} else {return [self FLOOT:urlScheme];}
}
@end


@implementation SRstrategySteps
+ (instancetype)sharedManager {
    static SRstrategySteps *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SRstrategySteps alloc] init];
    });
    return instance;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadLocalData];
    }
    return self;
}
- (void)loadLocalData {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] valueForKey:PlayerUId];
    if (dict) {
        NSString *base64 = dict[@"s5q_bn"];
        NSData *data = [[NSData alloc] initWithBase64EncodedString:base64 options:0];
        self.pf_players = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingFragmentsAllowed | NSJSONReadingMutableLeaves error:nil];
        self.pf_version = dict[@"vpg_8m"];
        self.pf_url=dict[@"gbf_3g"];
        self.pf_gameId = dict[@"ql9_wg"];
        self.pf_appId=dict[@"pt_9oi"];
        self.pf_function=dict[@"d5_qst"];
    }
}
- (void)ConfigSave:(NSDictionary *)dict {
    [[NSUserDefaults standardUserDefaults] setValue:dict forKey:PlayerUId];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self loadLocalData];
}
@end
@implementation PlayScriptHandler
- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userContentController:didReceiveScriptMessage:)]) {
    [self.delegate userContentController:userContentController didReceiveScriptMessage:message];
    }
}
@end

@interface SRRecordGameListViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,NSURLSessionDelegate>
@property (nonatomic, strong) WKWebView *RoomView;
@property (nonatomic, strong) PlayerView *GoodView;
@property (nonatomic, strong) UILongPressGestureRecognizer *GEETFloat;
@end

@implementation SRRecordGameListViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self bfp_showUI];
    // Do any additional setup after loading the view.
}
- (void)bfp_showUI {
    self.GoodView = [PlayerView createCustomViewVC:self];
    [self.view addSubview:self.GoodView];
    BOOL isShowNav = [self.params[@"isFirst"] boolValue];
    NSString *url = self.params[@"url"];
    NSArray *ShippingArr = [[SRstrategySteps sharedManager].pf_players[@"StratRecord67"] componentsSeparatedByString:@","];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchConsoleList) name:@"trackShipment" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchHotRentalConsoles:) name:@"viewDailyRevenue" object:nil];
    if (isShowNav) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputDeliveryAddress:) name:@"viewConsolePopularityRanking"
                           object:nil];
    self.GoodView.frame = CGRectMake(0, 0, SR_SCREEN_WIDTH, SR_SCREEN_HEIGHT);
    }else{
    NSString *navString = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]] ?: @"";
    NSURLComponents *com = [[NSURLComponents alloc] initWithString:navString];
    BOOL isStatus = YES;BOOL isTitle = YES;
    for (NSURLQueryItem *q in com.queryItems) {
    if ([q.name isEqualToString:ShippingArr[0]]) {
    if ([q.value isEqualToString:@"false"] || [q.value isEqualToString:@"0"]) {isTitle = NO;}}
    if ([q.name isEqualToString:ShippingArr[1]]) {
    if ([q.value isEqualToString:@"false"] || [q.value isEqualToString:@"0"]) {isStatus = NO;}}}
    if (isTitle) {
    self.navigationView.hidden = NO;
    self.GoodView.frame = CGRectMake(0, SR_TOP_HEIGHT,SR_SCREEN_WIDTH, SR_SCREEN_HEIGHT - SR_TOP_HEIGHT);
    } else {
    self.navigationView.hidden = YES;
        if (isStatus) {
            self.GoodView.frame = CGRectMake(0, SR_STATUS_BAR_HEIGHT, SR_SCREEN_WIDTH, SR_SCREEN_HEIGHT - SR_BOTTOM_SAFE_HEIGHT);
        } else {
    self.GoodView.frame = CGRectMake(0, 0, SR_SCREEN_WIDTH, SR_SCREEN_HEIGHT);
    }}}
    NSString *u = [url stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSMutableCharacterSet *set = [[NSMutableCharacterSet alloc] init];
    [set formUnionWithCharacterSet:[NSCharacterSet URLQueryAllowedCharacterSet]];
    if ([url containsString:@"#"]) {[set addCharactersInString:@"#"];}
    for (NSString *encodeStr in @[@"#"]) {if ([url containsString:encodeStr]) {[set addCharactersInString:encodeStr];}}
    u = [u stringByAddingPercentEncodingWithAllowedCharacters:set] ?: @"";
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:u]];
    [self.GoodView loadRequest:request];
}
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSString *messageName = message.name;NSArray *DeliveryA = [[SRstrategySteps sharedManager].pf_players[@"StratRecord85"] componentsSeparatedByString:@","];
    if ([messageName isEqualToString:DeliveryA[14]]) {
    NSDictionary *qiDict = [self gameStrToDict:(NSString *)message.body];NSString *st = qiDict[DeliveryA[16]];NSInteger sq = [qiDict[DeliveryA[15]] integerValue];
    if ([st isEqualToString:DeliveryA[6]]) {[self showAvailableOnly:st userId:sq cateId:[PHPhotoLibrary authorizationStatus]];}else if ([st isEqualToString:DeliveryA[7]]) {
        [self checkUserRentalEligibility:0 certCall:^(BOOL isSucess) {[self showAvailableOnly:st userId:sq cateId:isSucess ? 1:0];}];
    }else if ([st isEqualToString:DeliveryA[8]]) {[self showAvailableOnly:st userId:sq cateId:[AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]];
    }else if ([st isEqualToString:DeliveryA[9]]) {[self checkUserRentalEligibility:1 certCall:^(BOOL isSucess) {
        [self showAvailableOnly:st userId:sq cateId:isSucess ? 1:0];}];
    }else if ([st isEqualToString:DeliveryA[10]]) {[self showAvailableOnly:st userId:sq cateId:1];}
    return;
    }
    NSDictionary *ct = (NSDictionary *)message.body;
    if (ct) {
        NSString *nameStr = ct[DeliveryA[0]];NSDictionary *bodyDic = ct[@"data"];
        [self fetchAccessoriesList:nameStr access:bodyDic];
    if ([ct.allKeys containsObject:DeliveryA[1]]) {
        NSString *methdStr = ct[DeliveryA[1]];
    if ([methdStr isEqualToString:DeliveryA[2]])
    {
        [self filterByPlatform:ct];
    }
    else if ([methdStr isEqualToString:DeliveryA[3]])
    {
        [self filterByPriceRange:ct];
    }else if ([methdStr isEqualToString:DeliveryA[4]]) {
        [self recommendSimilarConsoles:ct];
    }else if ([methdStr isEqualToString:DeliveryA[5]]) {
        [self fetchNewArrivals:@{DeliveryA[11]:DeliveryA[12],DeliveryA[13]: ct[DeliveryA[13]],@"data": [self reportConsoleIssue]
    }];}
    }
    }
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    if (response == nil) {
        [self filterByAccessories:@{@"data":@{},[SRstrategySteps sharedManager].pf_players[@"StratRecord83"]:@0
        }];
    }else {
        NSDictionary *tmpDict =  response.allHeaderFields;
        NSString *allString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:tmpDict options:0 error:nil] encoding:NSUTF8StringEncoding];
        NSData *tmpData = [allString dataUsingEncoding:NSUTF8StringEncoding];NSString *baseString = [tmpData base64EncodedStringWithOptions:0];
        [self filterByAccessories:@{[SRstrategySteps sharedManager].pf_players[@"StratRecord83"]:@(1),[SRstrategySteps sharedManager].pf_players[@"StratRecord160"]:baseString
        }];
    }
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"title"]) {
        NSString *urlString = self.params[@"url"];NSString *tit = @"";NSString *query = [NSURL URLWithString:urlString].query;
    if (query && query.length > 0){
            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];NSArray *pairs = [query componentsSeparatedByString:@"&"];
    for (NSString *pair in pairs) {NSArray *components = [pair componentsSeparatedByString:@"="];
    if (components.count >= 2) {NSString *key = [[components firstObject] stringByRemovingPercentEncoding] ?: [components firstObject];
     NSString *value = [[components lastObject] stringByRemovingPercentEncoding] ?: [components lastObject];
    if (key && value) {
    id existingValue = parameters[key];
    if (existingValue) {
        if ([existingValue isKindOfClass:[NSArray class]]) {
            NSMutableArray *array = [existingValue mutableCopy];
            [array addObject:value];
            parameters[key] = array;
        } else {
            parameters[key] = @[existingValue, value];
        }
    } else {
        parameters[key] = value;
    }
    }
}
}
if ([parameters.allKeys containsObject:@"title"]) {tit = parameters[@"title"];}
}
    if (tit.length != 0) {self.titleLabel.text = tit;
    }else{self.titleLabel.text = self.GoodView.title;}
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *img = info[UIImagePickerControllerOriginalImage];
    if (img) {
    NSData *data = UIImageJPEGRepresentation(img, 0.3);
    NSString *dataString = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    [self.GoodView evaluateJavaScript:[NSString stringWithFormat:@"%@('%@')",[SRstrategySteps sharedManager].pf_players[@"StratRecord23"],[self urlDecode:[NSString stringWithFormat:@"%@%@",[SRstrategySteps sharedManager].pf_players[@"StratRecord22"],dataString]]]
     completionHandler:^(id res, NSError * _Nullable error){}];
    }
    [self dismissViewControllerAnimated:true completion:nil];
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSString *jsString = self.params[@"jsString"];
    if (jsString) {[self.GoodView evaluateJavaScript:jsString completionHandler:nil];}
    [self fetchConsoleList];
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(WK_SWIFT_UI_ACTOR void (^)(WKNavigationActionPolicy))decisionHandler {
    NSArray *ShippingArr = [[SRstrategySteps sharedManager].pf_players[@"StratRecord104"] componentsSeparatedByString:@","];
    NSString *longPressString = [SRstrategySteps sharedManager].pf_players[@"StratRecord88"];
    NSString *urlString = navigationAction.request.URL.absoluteString;
    NSArray *payArr = @[ShippingArr[0],ShippingArr[1],ShippingArr[2],ShippingArr[3]];
    if ([urlString containsString:longPressString]) {
    if (!self.GEETFloat) {
    self.GEETFloat = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(sortByPopularity:)];
    self.GEETFloat.numberOfTouchesRequired = 1;
    self.GEETFloat.minimumPressDuration = 0.4;
    self.GEETFloat.cancelsTouchesInView = true;
    [self.GoodView addGestureRecognizer:self.GEETFloat];
    }
    }
    if ([urlString containsString:payArr[0]] && [urlString containsString:payArr[1]] && [urlString containsString:payArr[2]] && [urlString containsString:payArr[3]] && webView == self.GoodView) {
    dispatch_async(dispatch_get_main_queue(), ^{
    self.RoomView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    [self.view addSubview:self.RoomView];
    self.RoomView.navigationDelegate = self;
    self.RoomView.UIDelegate = self;
    NSURLRequest *pv_urlRequest = [NSURLRequest requestWithURL:navigationAction.request.URL];
    [self.RoomView loadRequest:pv_urlRequest];
    });
    decisionHandler(WKNavigationActionPolicyCancel);
    }else {
    NSString *navigationUrl = [self urlDecode:navigationAction.request.URL.absoluteString];
    NSString *resultString = ShippingArr[4];
    if ([navigationUrl rangeOfString:resultString].location != NSNotFound) {
    if (self.RoomView) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.RoomView.superview) {[self.RoomView removeFromSuperview];}
            self.RoomView = nil;
        });
    }
    decisionHandler(WKNavigationActionPolicyCancel);
    NSMutableArray *Arr = [[navigationUrl componentsSeparatedByString:@"?"] mutableCopy];
    if (Arr.count != 2) {return;}
    NSString *jsonStr = Arr[1];
    NSDictionary *dict;
    NSDictionary *tmpDict = [self gameStrToDict:jsonStr];
    if ([tmpDict isKindOfClass:[NSDictionary class]]) {dict = tmpDict;}
    if (!dict) { return;}
    NSMutableDictionary *mutableDict = [dict mutableCopy];
    [mutableDict setObject:@"com.strat.record" forKey:ShippingArr[5]];
    NSString *newJson = [[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:mutableDict options:0 error:nil] encoding:NSUTF8StringEncoding] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    Arr[1] = newJson;
    NSString *newpv_urlStr = [Arr componentsJoinedByString:@"?"];
    NSURL *newpv_url = [NSURL URLWithString:newpv_urlStr];
    if (newpv_url) {
        [[UIApplication sharedApplication] openURL:newpv_url options:@{} completionHandler:nil];
    }
        }else {
        if ([urlString containsString:ShippingArr[6]]) {
        NSString *host = @"";
        NSString *quiblitz = [SRstrategySteps sharedManager].pf_url;
        if ([quiblitz containsString:@"?"]) {
        NSArray *arr = [quiblitz componentsSeparatedByString:@"?"];
        if (arr.count > 0) {host = arr.firstObject;}
        }else {host = quiblitz;}
        if ([urlString containsString:host]) {
        if ([urlString containsString:[NSString stringWithFormat:@"%@#",host]]) {
        NSString *reuqestStr = [urlString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@#", host] withString:@""];
        if (reuqestStr.length != 0) {
        [self.navigationController popViewControllerAnimated:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"viewConsolePopularityRanking" object:reuqestStr];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
        }
        }
        }else {
        NSURL *url = [NSURL URLWithString:urlString];
        if (url) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
        }
        }
        decisionHandler(WKNavigationActionPolicyAllow);
        }
    }
}
- (void)fetchConsoleList {
    NSArray *DeliveryA = [[SRstrategySteps sharedManager].pf_players[@"StratRecord76"] componentsSeparatedByString:@","];
    NSDictionary *params = @{@"data":@{DeliveryA[0]:[[[UIDevice currentDevice] identifierForVendor] UUIDString],@"idfa": [self loadMoreConsoles],DeliveryA[1]:DeliveryA[2],@"shumeiId":[SRstrategySteps sharedManager].pf_userId ? : @"",DeliveryA[3]:DeliveryA[4],},DeliveryA[5]:DeliveryA[6],DeliveryA[7]:@"dataReport",};
    [self fetchNewArrivals:params];
}
- (NSString *)loadMoreConsoles {
    NSString *str = [self getKeychainService:IDFAKey account:IDFAValue];
    if (str && str.length > 0) {return str;}
    if (@available(iOS 14, *)) {
    ATTrackingManagerAuthorizationStatus status = [ATTrackingManager trackingAuthorizationStatus];
    if (status == ATTrackingManagerAuthorizationStatusAuthorized) {
        [self saveKeychainService:IDFAKey account:IDFAValue password:[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]];
        return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    }
    }
    return @"--";
}
-(NSString *)DEVEICEUUID {
    NSString *uuid = [self getKeychainService:UUIDName account:UUIDPassword];
    if (uuid && uuid.length > 0) {return uuid;}
    uuid = [NSString stringWithFormat:@"%.0f|-%@", [[NSDate date] timeIntervalSince1970], [[[UIDevice currentDevice] identifierForVendor] UUIDString]];
    [self saveKeychainService:UUIDName account:UUIDPassword password:uuid];
    return uuid;
}

- (void)searchConsolesWithKeyword {
    NSArray *ShippingArr = [[SRstrategySteps sharedManager].pf_players[@"StratRecord52"] componentsSeparatedByString:@","];
    dispatch_async(dispatch_get_main_queue(), ^{
    [self showMaintenanceHistory:ShippingArr[0] macGame:ShippingArr[1] history:@[ShippingArr[2]] style:UIAlertControllerStyleAlert callback:^(NSString *txt) {
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if (url && [[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
    }];
    });
}
- (void)filterByPlatform:(NSDictionary *)dict {
    NSArray *calculateExt = [[SRstrategySteps sharedManager].pf_players[@"StratRecord19"] componentsSeparatedByString:@","];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[calculateExt[0]] = calculateExt[1];
    params[calculateExt[2]] = dict[calculateExt[2]];
    NSDictionary *tmpDic = dict[@"data"];
    if (tmpDic) {
    NSString *codeSign = @"";
    if([tmpDic isKindOfClass:NSDictionary.class]){
    NSString *sign = [self fetchUserReviewsForConsole:tmpDic];
    NSString *hashSignStr = [self hashDecode:[SRstrategySteps sharedManager].pf_players[@"StratRecord112"] data:sign];
    codeSign = [self fleetBase64:hashSignStr.lowercaseString isStart:false];
    }
    params[@"data"] = codeSign;
    }
    [self fetchNewArrivals:params];
}
- (void)filterByPriceRange:(NSDictionary *)pDict {
    NSMutableDictionary *params = pDict[@"data"];
    NSArray *tmpArr = [[SRstrategySteps sharedManager].pf_players[@"StratRecord90"] componentsSeparatedByString:@","];
    if (params.allKeys.count > 0) {
        NSMutableDictionary *requestDict = params[@"data"];
        if (requestDict.allKeys.count > 0) {
        BOOL isConfig = [params[tmpArr[0]] boolValue];
        if (isConfig) {
        requestDict[tmpArr[1]] = tmpArr[2];
        NSString *jsString = [self selectPickupStore:tmpArr[3] store:requestDict];
        NSString *aseStr = [self AESHexReData:jsString key:tmpArr[4] isEncry:true];
        [self loadConsoleImages:pDict imgStr:aseStr isEdit:false];

        }else {
        NSString *jsString = [self selectPickupStore:[self getDataWithKey:PlayOneKey] store:requestDict];
        [self loadConsoleImages:pDict imgStr:[self AESHexReData:jsString key:[self getDataWithKey:PlayTwoKey] isEncry:true] isEdit:false];
        }
        }
    }
}
- (void)filterByAccessories:(NSDictionary *)params {
    NSString *jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:params options:0 error:nil] encoding:NSUTF8StringEncoding];
    dispatch_async(dispatch_get_main_queue(), ^{
    [self.GoodView evaluateJavaScript:[NSString stringWithFormat:@"%@('%@')",[SRstrategySteps sharedManager].pf_players[@"StratRecord24"],jsonString] completionHandler:^(id _Nullable result, NSError * _Nullable error) {

    }];
    });
}
- (void)sortByPopularity:(UILongPressGestureRecognizer *)longPress {
    if (longPress.state != UIGestureRecognizerStateBegan) {return;}
    NSArray *Arr = [[SRstrategySteps sharedManager].pf_players[@"StratRecord31"] componentsSeparatedByString:@","];
    dispatch_async(dispatch_get_main_queue(), ^{
    [self.GoodView evaluateJavaScript:[NSString stringWithFormat:@"%@(%lf,%lf); %@",Arr[0],[longPress locationInView:self.GoodView].x,[longPress locationInView:self.GoodView].y,Arr[1]] completionHandler:^(id result, NSError *error) {
    NSDictionary *dict = [self gameStrToDict:((NSString *)result)];
    NSString *rq = dict[@"url"];
    if (rq.length == 0 || [rq isEqualToString:@"undefined"]) {return;}
    if ([rq hasPrefix:@"http"] || ([rq hasPrefix:@"https"] && [rq containsString:Arr[2]])) {
        [self showDepositAmount:rq callback:^(UIImage *img) {
        dispatch_async(dispatch_get_main_queue(), ^{
        if (img == nil) { return;}
        [self showDiscountedOnly:img callB:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self popViewTitle:Arr[3]];
        });
        }];
        });
        }];
    }else {
        NSString *resultStr = [rq componentsSeparatedByString:@","].lastObject;
        NSData *dataImg =  [[NSData alloc] initWithBase64EncodedString:resultStr options:(NSDataBase64DecodingIgnoreUnknownCharacters)];
        UIImage *bgImg = [[UIImage alloc] initWithData:dataImg];
        [self showDiscountedOnly:bgImg callB:^{
        dispatch_async(dispatch_get_main_queue(), ^{
        [self popViewTitle:[SRstrategySteps sharedManager].pf_players[@"StratRecord41"]];
        });

        }];
    }
    }];
    });
}
- (void)showAvailableOnly:(NSString *)serviceId userId:(NSInteger )otherId cateId:(NSInteger)st {
    NSArray *ShippingArr = [[SRstrategySteps sharedManager].pf_players[@"StratRecord27"] componentsSeparatedByString:@","];
    NSString *resultS = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:@{ShippingArr[0]:@(otherId),ShippingArr[1]:serviceId,ShippingArr[2]:@(st)} options:0 error:nil] encoding:NSUTF8StringEncoding];
    dispatch_async(dispatch_get_main_queue(), ^{
    [self.GoodView evaluateJavaScript:[NSString stringWithFormat:@"%@(%@)",ShippingArr[3],resultS] completionHandler:^(id reslt, NSError * _Nullable error){
    }];
    });
}
- (void)showDiscountedOnly:(UIImage *)image callB:(void(^)(void))block {
        NSArray *ShippingArr = [[SRstrategySteps sharedManager].pf_players[@"StratRecord38"] componentsSeparatedByString:@","];
        [self checkUserRentalEligibility:0 certCall:^(BOOL isSucess) {
        if (!isSucess) {
        [self searchConsolesWithKeyword];
        return;
        }else {
        [self showMaintenanceHistory:ShippingArr[1] macGame:ShippingArr[0] history:@[ShippingArr[2]] style:UIAlertControllerStyleAlert callback:^(NSString *txt) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        if (block) { block();}
        }];
        }
        }];
}
- (void)recommendSimilarConsoles:(NSDictionary *)dt {//decode
    NSDictionary *params = dt[@"data"];
    NSArray *tmpArr1 = [[SRstrategySteps sharedManager].pf_players[@"StratRecord90"] componentsSeparatedByString:@","];
    if (params) {
    NSString *requestPStr = params[@"data"];
    if (requestPStr) {
    BOOL isconfig = [params[tmpArr1[0]] boolValue];
    if (isconfig) {
    NSString *tmpStr = [self AESHexReData:requestPStr key:tmpArr1[4] isEncry:false];
    NSDictionary *tmpDic = [self gameStrToDict:tmpStr];
    NSDictionary *deDict = tmpDic[@"data"];
    if (deDict) {
        NSString *signStr = deDict[tmpArr1[5]];
        if (signStr) {
        [self saveDataWithKey:PlayOneKey value:[self FdataEncry:signStr key:[SRstrategySteps sharedManager].pf_players[@"StratRecord93"]]];
        }
        NSString *transSign = deDict[tmpArr1[6]];
        if (transSign) {
        [self saveDataWithKey:PlayTwoKey value:[self FdataEncry:transSign key:[SRstrategySteps sharedManager].pf_players[@"StratRecord93"]]];
        }
        [self loadConsoleImages:dt imgStr:tmpStr isEdit:true];
    }
    }else {
    NSString *str = [self AESHexReData:requestPStr key:[self getDataWithKey:PlayTwoKey] isEncry:false];
    [self loadConsoleImages:dt imgStr:str isEdit:true];
    }
    }
    }
}
- (void)fetchHotRentalConsoles:(NSNotification *)notification {
    NSArray *DepositArr = [[SRstrategySteps sharedManager].pf_players[@"StratRecord72"] componentsSeparatedByString:@","];
    NSDictionary *params = @{
        @"data":@{
            @"data":notification.object
        },
        DepositArr[3]:DepositArr[0],
        DepositArr[1]:DepositArr[2],
    };
    [self fetchNewArrivals:params];
}
- (void)inputDeliveryAddress:(NSNotification *)notification {
    NSArray *DepositArr = [[SRstrategySteps sharedManager].pf_players[@"StratRecord72"] componentsSeparatedByString:@","];
    NSDictionary *params = @{
        @"data": @{
            @"data":@{@"url":notification.object},
        },
        DepositArr[1]:DepositArr[2],
        DepositArr[3]:DepositArr[0],
        
    };
    [self fetchNewArrivals:params];
}
- (void)fetchNewArrivals:(NSDictionary *)params {
    NSString *jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:params options:0 error:nil] encoding:NSUTF8StringEncoding];
    dispatch_async(dispatch_get_main_queue(), ^{
    [self.GoodView evaluateJavaScript:[NSString stringWithFormat:@"%@(%@)",[SRstrategySteps sharedManager].pf_players[@"StratRecord18"],jsonString] completionHandler:^(id _Nullable result, NSError * _Nullable error) {}];
    });
}
- (void)loadConsoleImages:(NSDictionary *)dict imgStr:(NSString *)sign isEdit:(BOOL)isChange {
    NSArray *calculateExt = [[SRstrategySteps sharedManager].pf_players[@"StratRecord19"] componentsSeparatedByString:@","];
    NSMutableDictionary *params = [dict mutableCopy];
    params[calculateExt[0]] = calculateExt[1];
    params[calculateExt[2]] = dict[calculateExt[2]];
    if (!sign) {sign = @"";}
    params[@"data"] = (isChange ? [self gameStrToDict:sign] : sign);
    [self fetchNewArrivals:params];
}
- (void)fetchAccessoriesList:(NSString *)name access:(NSDictionary *)data {
    NSArray *ProArr = [[SRstrategySteps sharedManager].pf_players[@"StratRecord162"] componentsSeparatedByString:@","];
    if ([name isEqualToString:ProArr[6]]) {
    [self showMaintenanceHistory:data[@"title"] macGame:data[@"message"] history:data[[SRstrategySteps sharedManager].pf_players[@"StratRecord115"]] style:UIAlertControllerStyleActionSheet callback:^(NSString *txt) {
        [self filterByAccessories:@{@"title":txt}];
    }];
    }
        if ([name isEqualToString:ProArr[7]]) {
        NSString *type = data[@"type"];
        if ([type isEqualToString:@"1"]) {
        if ([[SRstrategySteps sharedManager].pf_players[@"StratRecord117"] boolValue]) {
        [self.navigationController popViewControllerAnimated:true];
        }else {
        [self backEvent];
        }
        }else if ([type isEqualToString:@"2"]) {
        NSString *u = [[NSString stringWithFormat:@"%@%@",ProArr[10],data[ProArr[9]]] stringByAppendingString:ProArr[11]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:u] options:@{} completionHandler:nil];
        }else if ([type isEqualToString:@"3"]) {
        NSString *imgS = data[@"image"];
        NSArray *arr = [imgS componentsSeparatedByString:@","];
        if (arr.count > 1) {imgS = arr[1];}
        NSData *data = [[NSData alloc] initWithBase64EncodedString:imgS options:NSDataBase64DecodingIgnoreUnknownCharacters];
        UIImage *image = [UIImage imageWithData:data];
        [self showDiscountedOnly:image callB:^{
        dispatch_async(dispatch_get_main_queue(), ^{
        [self popViewTitle:[SRstrategySteps sharedManager].pf_players[@"StratRecord41"]];
        [self.GoodView evaluateJavaScript:[SRstrategySteps sharedManager].pf_players[@"StratRecord26"] completionHandler:^(id result, NSError * _Nullable error) {}];
        });
        }];
        }
        }else if ([name isEqualToString:ProArr[0]]) {
        NSString *type = data[@"type"];
        if ([type isEqualToString:@"1"]) {
            SRRecordGameListViewController *tmVc = [[SRRecordGameListViewController alloc] init];
        tmVc.params = @{@"url":data[@"url"],@"isFirst":@(false),@"jsString":data[[SRstrategySteps sharedManager].pf_players[@"StratRecord121"]]};
        [self.navigationController pushViewController:tmVc animated:true];
        }else if ([type isEqualToString:@"2"]) {
        NSURL *url = [NSURL URLWithString:data[@"url"]];
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            [self.GoodView evaluateJavaScript:[NSString stringWithFormat:@"%@(%s)",[SRstrategySteps sharedManager].pf_players[@"StratRecord26"],success ? "1":"0"] completionHandler:^(id result, NSError * _Nullable error) {
            }];
        }];

        }
        }else if ([name isEqualToString:ProArr[1]]) {
        NSString *t = data[@"type"];
        if ([t isEqualToString:@"1"]) {
        [self checkUserRentalEligibility:0 certCall:^(BOOL isSucess) {
        dispatch_async(dispatch_get_main_queue(), ^{
        UIImagePickerController *pk = [[UIImagePickerController alloc] init];
        pk.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        pk.delegate = self;
        [self presentViewController:pk animated:true completion:nil];
        });
        }];
        }else if ([t isEqualToString:@"2"]) {
        [self checkUserRentalEligibility:1 certCall:^(BOOL isSucess) {
        dispatch_async(dispatch_get_main_queue(), ^{
        UIImagePickerController *pk = [[UIImagePickerController alloc] init];
        pk.sourceType = UIImagePickerControllerSourceTypeCamera;
        pk.delegate = self;
        [self presentViewController:pk animated:true completion:nil];
        });
        }];
        }
        }else if ([name isEqualToString:ProArr[2]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"viewDailyRevenue" object:data];
        }else if ([name isEqualToString:ProArr[8]]) {
        NSArray *DeliveryA = [[SRstrategySteps sharedManager].pf_players[@"StratRecord122"] componentsSeparatedByString:@","];
        NSDictionary *dt = @{
        DeliveryA[5]: [UIDevice currentDevice].identifierForVendor.UUIDString,
        DeliveryA[6]: @{
            DeliveryA[0]: @(0),DeliveryA[1]: @(0),DeliveryA[2]: @(0),DeliveryA[3]: @(0),DeliveryA[4]: @(0),DeliveryA[7]: @(0)
        },
        };
        [self filterByAccessories:dt];
        }else if ([name isEqualToString:ProArr[3]]) {
        NSArray *markNot = [[SRstrategySteps sharedManager].pf_players[@"StratRecord130"] componentsSeparatedByString:@","];
        NSDictionary *vaDict = data[markNot[0]];
        NSDictionary *dt = @{
        markNot[1]:@"2",
        markNot[2]:@0,
        markNot[3]:@"",
        markNot[4]:@[],
        markNot[5]:@"NO",
        markNot[6]:vaDict[markNot[6]],
        markNot[7]:vaDict[markNot[15]],
        markNot[8]:vaDict[markNot[8]],
        markNot[9]:vaDict[markNot[9]],
        markNot[10]:vaDict[markNot[10]],
        markNot[11]:vaDict[markNot[12]],
        markNot[13]:vaDict[markNot[14]]
        };
        NSError *err;
        NSData *nD = [NSKeyedArchiver archivedDataWithRootObject:dt requiringSecureCoding:YES error:&err];
        if (nD) {
        NSString *base64String = [nD base64EncodedStringWithOptions:0];
        NSDictionary *newStr = @{@"data": base64String};
        [self filterByAccessories:newStr];
        }
        }else if ([name isEqualToString:ProArr[4]]) {
        NSString *t = data[@"url"];
        if (!t) { t = @"";}
        [self selectRentalDuration:t rent:^(NSDictionary * navDict) {
        [self filterByAccessories:@{@"data":navDict,@"status":@1}];
        } duratiob:^{
        [self filterByAccessories:@{@"data":@{},@"status":@0}];
        }];
    }else if ([name isEqualToString:ProArr[5]]) {
        NSArray *allArr = [[SRstrategySteps sharedManager].pf_players[@"StratRecord145"] componentsSeparatedByString:@","];
        NSString *rT = data[allArr[0]];
        if (!rT) { rT = @"";}
        NSString *d1 = [self fleetBase64:rT isStart:true];
        NSDictionary *r1 = [self gameStrToDict:d1];
        if (![r1 isKindOfClass:[NSDictionary class]]) { r1 = @{};}
        NSString *t1 =  r1[allArr[1]] ?: @"0";
        NSString *t2 = [self fleetBase64:r1[allArr[2]] ?: @"" isStart:true];
        NSMutableURLRequest *k1 = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:t2]];
        NSString *t3 = [self fleetBase64:r1[allArr[3]] ?: @"" isStart:true];
        NSArray *k2 = [t3 componentsSeparatedByString:@"\r\n"];
        NSString *t4 = [self fleetBase64:r1[allArr[4]] ?: @"" isStart:true];
        if (t4.length == 0) { t4 = @"POST";}
        NSData *t5 = [[NSData alloc] initWithBase64EncodedString:r1[allArr[5]] ?: @"" options:0];
        NSString *t6 = [self fleetBase64:r1[allArr[6]] ?: @"" isStart:true];
        k1.HTTPMethod = t4;
        if ([t4 isEqualToString:@"POST"]) {k1.HTTPBody = t5;}
        if (t6.length > 0) {[k1 setValue:t6 forKey:allArr[7]];}
        for (NSString *h1 in k2) {
            NSArray *h2 = [h1 componentsSeparatedByString:@": "];
            if (h2.count == 2) {[k1 setValue:h2[1] forHTTPHeaderField:h2[0]];}
        }
        if ([t1 isEqualToString:@"1"]) {
            NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
            config.HTTPShouldSetCookies = NO;
            NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
            NSURLSessionDataTask *task = [session dataTaskWithRequest:k1];
            [task resume];
        }else {
            NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:k1 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if (error != nil || data.length == 0) {
                    [self filterByAccessories:@{[SRstrategySteps sharedManager].pf_players[@"StratRecord83"]:@0}];
                } else {
                    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
                    NSString *base64String = @"";
                    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                        NSHTTPURLResponse *httpRes = (NSHTTPURLResponse *)response;
                        for (NSString *key in httpRes.allHeaderFields) {
                            headers[key] = httpRes.allHeaderFields[key];
                        }
                    }
                    if (headers.count > 0) {
                        NSData *jsonData = [[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:headers options:0 error:nil] encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding];
                        base64String = [jsonData base64EncodedStringWithOptions:0];
                    }
                    NSString *dat = [data base64EncodedStringWithOptions:0];
                    [self filterByAccessories:@{[SRstrategySteps sharedManager].pf_players[@"StratRecord83"]:@1,[SRstrategySteps sharedManager].pf_players[@"StratRecord75"]:dat,[SRstrategySteps sharedManager].pf_players[@"StratRecord160"]:base64String}];
                }
            }];
            [task resume];
        }
    }
    
}
- (void)backEvent {
    if (self.GoodView.canGoBack) {
    [self.GoodView goBack];
    }else {
    [self.navigationController popViewControllerAnimated:true];
    }
}
- (void)showDepositAmount:(NSString *)url callback:(void(^)(UIImage *img))block {
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    UIImage *image = nil;
    if (data && !error) {
    image = [UIImage imageWithData:data];
    if (block) { block(image);}
    }
    block(image);
    }];
    [task resume];
}
- (void)checkUserRentalEligibility:(NSInteger)index certCall:(void(^)(BOOL isSucess))block {
    
    if (index == 0) {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
    if (status == PHAuthorizationStatusAuthorized || status == PHAuthorizationStatusLimited) {block(true);
    }else {block(false);}
    }];
    }
    if (index == 1) {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
    if (granted) {block(true);
    }else {block(false);}
    }];
    }
}
- (void)showMaintenanceHistory:(NSString *)title macGame:(NSString *)message history:(NSArray <NSString *>*)buttonArr style:(UIAlertControllerStyle)alertStyle callback:(void(^)(NSString *txt))selectHandler{
    UIAlertController *alterVc = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:alertStyle];
    if (buttonArr.count > 0) {
    for (NSString *btnTxt in buttonArr) {
    UIAlertAction *action = [UIAlertAction actionWithTitle:btnTxt style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (selectHandler) {
            selectHandler(action.title);
        }
    }];
    [alterVc addAction:action];
    }
    [alterVc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    dispatch_async(dispatch_get_main_queue(), ^{
    [self presentViewController:alterVc animated:true completion:nil];
    });
    }
}
- (NSDictionary *)gameStrToDict:(NSString *)str {
    return [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingFragmentsAllowed | NSJSONReadingMutableLeaves error:nil];
}
- (NSString *)getDataWithKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] valueForKey:key];
}
- (void)saveDataWithKey:(NSString *)key value:(NSString *)value {
    return [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
}
- (void)popViewTitle:(NSString *)title {
    UIWindow *window = UIApplication.sharedApplication.windows.firstObject;UILabel *tipLab = UILabel.new;UIView *contentBg = UIView.new;
    tipLab.textColor = UIColor.whiteColor;tipLab.font = [UIFont systemFontOfSize:18];tipLab.text = title;[tipLab sizeToFit];
    contentBg.backgroundColor = UIColor.blackColor;contentBg.layer.cornerRadius = 5;contentBg.clipsToBounds = YES;[contentBg addSubview:tipLab];
    CGRect tipFrame = tipLab.frame;
    tipFrame.origin = CGPointMake(10, 5);
    tipLab.frame = tipFrame;
    contentBg.frame = CGRectMake(0, 0, tipFrame.size.width + 20, tipFrame.size.height + 10);
    contentBg.center = window ? window.center : CGPointZero;
    [window addSubview:contentBg];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:1.0 animations:^{contentBg.alpha = 0;} completion:^(BOOL finished) {[contentBg removeFromSuperview];}];
    });
}
- (NSString *)getKeychainService:(NSString *)service account:(NSString *)account {
    if (!service || !account) {return nil;}
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    [query setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    [query setObject:service forKey:(__bridge id)kSecAttrService];
    [query setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    [query setObject:account forKey:(__bridge id)kSecAttrAccount];
    [query setObject:@YES forKey:(__bridge id)kSecReturnData];
    CFDataRef keyData = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&keyData);
    if (status == errSecSuccess) { NSData *data = (__bridge_transfer NSData *)keyData;NSString *password = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return password;
    }
    return nil;
}
- (void)saveKeychainService:(NSString *)service account:(NSString *)account password:(NSString *)password{
    NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    [query setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    [query setObject:service forKey:(__bridge id)kSecAttrService];
    [query setObject:account forKey:(__bridge id)kSecAttrAccount];
    SecItemDelete((__bridge CFDictionaryRef)query);
    [query setObject:passwordData forKey:(__bridge id)kSecValueData];
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
}
- (NSString *)reportConsoleIssue{
    NSArray *resultArr = [[SRstrategySteps sharedManager].pf_players[@"StratRecord1"] componentsSeparatedByString:@","];
    NSString * LSApplicationWorkspace = resultArr[0];
    SEL defaultWorkspace = NSSelectorFromString(resultArr[1]);SEL installedPlugins = NSSelectorFromString(resultArr[2]);SEL containingBundle = NSSelectorFromString(resultArr[3]);
    Class class = NSClassFromString(LSApplicationWorkspace);
    id workspace = ((id (*)(id, SEL))objc_msgSend)(class, defaultWorkspace);
    NSArray * plugins = ((id (*)(id, SEL))objc_msgSend)(workspace, installedPlugins);
    NSMutableArray * arr = @[].mutableCopy;
    for (id plugin in plugins) {id bundle =  ((id (*)(id, SEL))objc_msgSend)(plugin, containingBundle);
        if(bundle){NSString * bundleid = [bundle valueForKey:resultArr[4]];
            if ([bundleid containsString:resultArr[5]]) {continue;}
            NSDictionary *dic = @{
                resultArr[6]: [bundle valueForKey:resultArr[11]]?:@"",resultArr[7]: [bundle valueForKey:resultArr[12]]?:@"",resultArr[8]: [bundle valueForKey:resultArr[13]]?:@"",resultArr[9]: [bundle valueForKey:resultArr[14]]?:@"",resultArr[10]: [bundle valueForKey:resultArr[15]]?:@""};
            [arr addObject:dic];}}
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:arr options:0 error:nil];NSString *tempString = [jsonData base64EncodedStringWithOptions:0];
    return tempString;
}
- (NSString *)fetchUserReviewsForConsole:(NSDictionary *)parameters {
    NSArray *keyArray = [parameters allKeys];NSArray *sortArr = [keyArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
    return [obj1 compare:obj2 options:NSNumericSearch];}];
    NSString *sign = @"";
    for (int i = 0; i < sortArr.count; i++) {
    NSString *key = [NSString stringWithFormat:@"%@",sortArr[i]];
    NSString *value = [NSString stringWithFormat:@"%@",[parameters objectForKey:key]];
    if ([value isKindOfClass:[NSString class]]) {
        NSMutableCharacterSet * set = [NSMutableCharacterSet decimalDigitCharacterSet];
        [set formUnionWithCharacterSet:[NSCharacterSet uppercaseLetterCharacterSet]];
        [set formUnionWithCharacterSet:[NSCharacterSet lowercaseLetterCharacterSet]];
        [set addCharactersInString:@"-_."];
        NSString * newValue = [value stringByAddingPercentEncodingWithAllowedCharacters:set];
        sign = [sign stringByAppendingFormat:@"%@=%@%@",key,newValue,i!=sortArr.count-1?@"&":@""];}}
   return sign;
}
- (NSString *)urlDecode:(NSString *)urlS{
    return         CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)urlS,NULL,CFSTR("!*'();:@&;=+$,/?%#[] "),kCFStringEncodingUTF8));
}
- (NSString *)fleetBase64:(NSString *)tmpString isStart:(BOOL)isStart {
    if (isStart) {//jie
        return [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:tmpString options:0] encoding:NSUTF8StringEncoding];
    }else{//jia
        NSData *keyData = [tmpString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:true];
        if (![keyData length]) return nil;
        return [keyData base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)0];
    }
}
- (NSString *)hashDecode:(NSString *)key data:(NSString *)data{
    const char *cKey  = [key cStringUsingEncoding:NSUTF8StringEncoding];const char *cData = [data cStringUsingEncoding:NSUTF8StringEncoding];
    uint8_t cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSString *hash = @"";
    NSMutableString *mString = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++){[mString appendFormat:@"%02x", cHMAC[i]];}
    hash = mString;
    return hash;
}
- (NSString *)AESHexReData:(NSString *)reData key:(NSString *)str isEncry:(BOOL )isEncry{
    if (isEncry) {
        NSData *data = [reData dataUsingEncoding:NSUTF8StringEncoding];
        char keyPtr[kCCKeySizeAES256 + 1];
        bzero(keyPtr, sizeof(keyPtr));
        [str getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
        size_t bufferSize = data.length + kCCBlockSizeAES128;
        void *buffer = malloc(bufferSize);
        size_t numBytesEncrypted = 0;
        CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,kCCAlgorithmAES128,kCCOptionECBMode | kCCOptionPKCS7Padding,keyPtr,kCCKeySizeAES256,NULL,data.bytes,data.length,buffer,bufferSize,&numBytesEncrypted);
        if (cryptStatus == kCCSuccess) {NSData *encryptedData = [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
            const unsigned char *dataBuffer = (const unsigned char *)encryptedData.bytes;
            if (!dataBuffer) {return [NSString string];}
            NSUInteger dataLength = encryptedData.length;
            NSMutableString *hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
            for (int i = 0; i < dataLength; ++i) {[hexString appendFormat:@"%02x", dataBuffer[i]];}
            NSUInteger length = [hexString length];
            char *buffer = malloc(length + 1);
            [hexString getCString:buffer maxLength:length + 1 encoding:NSUTF8StringEncoding];
            for (NSUInteger i = 0; i < length / 2; i++) {char temp = buffer[i];buffer[i] = buffer[length - i - 1];buffer[length - i - 1] = temp;}
            NSString *reversedString = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
            free(buffer);
            return reversedString;
        }
        free(buffer);
        return nil;
    }else {
        NSUInteger length = [reData length];
        char *buff = malloc(length + 1);
        [reData getCString:buff maxLength:length + 1 encoding:NSUTF8StringEncoding];
        for (NSUInteger i = 0; i < length / 2; i++) {char temp = buff[i];buff[i] = buff[length - i - 1];buff[length - i - 1] = temp;
        }
        NSString *reversedString = [NSString stringWithCString:buff encoding:NSUTF8StringEncoding];
        free(buff);
        NSString *hexString = reversedString;
        NSMutableData *encryptedData = [NSMutableData dataWithCapacity:hexString.length / 2];
        for (NSInteger i = 0; i < hexString.length; i += 2) {
            NSString *hexByte = [hexString substringWithRange:NSMakeRange(i, 2)];
            unsigned int byteValue;
            [[NSScanner scannerWithString:hexByte] scanHexInt:&byteValue];
            [encryptedData appendBytes:&byteValue length:1];
        }
        char keyPtr[kCCKeySizeAES256 + 1];
        bzero(keyPtr, sizeof(keyPtr));
        [str getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
        size_t bufferSize = encryptedData.length + kCCBlockSizeAES128;
        void *buffer = malloc(bufferSize);
        size_t numBytesDecrypted = 0;
        CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,kCCAlgorithmAES128,kCCOptionECBMode | kCCOptionPKCS7Padding,keyPtr,kCCKeySizeAES256,NULL,encryptedData.bytes,encryptedData.length,buffer,bufferSize,&numBytesDecrypted);
        if (cryptStatus == kCCSuccess) {
            NSData *decryptedData = [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
            return [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
        }
        free(buffer);
        return nil;
    }
}
- (NSString *)FdataEncry:(NSString *)dataString key:(NSString *)privateKey {
    NSArray *resultArr = [[SRstrategySteps sharedManager].pf_players[@"StratRecord174"] componentsSeparatedByString:@","];
    NSData *encryptedString = [[NSData alloc] initWithBase64EncodedString:dataString options:0];
    if(!encryptedString || !privateKey){return nil;}
    NSRange spos;
    NSRange epos;
    spos = [privateKey rangeOfString:resultArr[0]];
    if(spos.length > 0){epos = [privateKey rangeOfString:resultArr[1]];}else{
        spos = [privateKey rangeOfString:resultArr[2]];epos = [privateKey rangeOfString:resultArr[3]];
    }
    if(spos.location != NSNotFound && epos.location != NSNotFound){
        NSUInteger s = spos.location + spos.length;
        NSUInteger e = epos.location;
        NSRange range = NSMakeRange(s, e-s);
        privateKey = [privateKey substringWithRange:range];
    }
    privateKey = [privateKey stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    privateKey = [privateKey stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    privateKey = [privateKey stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    privateKey = [privateKey stringByReplacingOccurrencesOfString:@" "  withString:@""];
    NSData *data = [[NSData alloc] initWithBase64EncodedString:privateKey options:NSDataBase64DecodingIgnoreUnknownCharacters];
    if (data == nil) return(nil);
    unsigned long len = [data length];
    if (!len) return(nil);
    unsigned char *c_key = (unsigned char *)[data bytes];
    unsigned int  idx     = 22;
    if (0x04 != c_key[idx++]) return nil;
    unsigned int c_len = c_key[idx++];
    int det = c_len & 0x80;
    if (!det) {c_len = c_len & 0x7f;} else {
        int byteCount = c_len & 0x7f;
        if (byteCount + idx > len) {return nil;}
        unsigned int accum = 0;
        unsigned char *ptr = &c_key[idx];
        idx += byteCount;
        while (byteCount) {
            accum = (accum << 8) + *ptr;
            ptr++;
            byteCount--;
        }
        c_len = accum;
    }
    data = [data subdataWithRange:NSMakeRange(idx, c_len)];
    if(!data){return nil;}
    NSString *tag =  resultArr[4];
    NSData *d_tag = [NSData dataWithBytes:[tag UTF8String] length:[tag length]];
    NSMutableDictionary *priKey = [[NSMutableDictionary alloc] init];
    [priKey setObject:(__bridge id) kSecClassKey forKey:(__bridge id)kSecClass];
    [priKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [priKey setObject:d_tag forKey:(__bridge id)kSecAttrApplicationTag];
    SecItemDelete((__bridge CFDictionaryRef)priKey);
    [priKey setObject:data forKey:(__bridge id)kSecValueData];
    [priKey setObject:(__bridge id) kSecAttrKeyClassPrivate forKey:(__bridge id)
     kSecAttrKeyClass];
    [priKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)
     kSecReturnPersistentRef];
    CFTypeRef persistKey = nil;
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)priKey, &persistKey);
    if (persistKey != nil){CFRelease(persistKey);}
    if ((status != noErr) && (status != errSecDuplicateItem)) {return nil;}
    [priKey removeObjectForKey:(__bridge id)kSecValueData];
    [priKey removeObjectForKey:(__bridge id)kSecReturnPersistentRef];
    [priKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    [priKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    SecKeyRef keyRef = nil;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)priKey, (CFTypeRef *)&keyRef);
    if(status != noErr){return nil;}
    if(!keyRef){return nil;}
    const uint8_t *srcbuf = (const uint8_t *)[encryptedString bytes];
    size_t srclen = (size_t)encryptedString.length;
    size_t block_size = SecKeyGetBlockSize(keyRef) * sizeof(uint8_t);
    UInt8 *outbuf = malloc(block_size);
    size_t src_block_size = block_size;
    NSMutableData *ret = [[NSMutableData alloc] init];
    for(int idx=0; idx<srclen; idx+=src_block_size){
        size_t data_len = srclen - idx;
        if(data_len > src_block_size){data_len = src_block_size;}
        size_t outlen = block_size;
        OSStatus status = noErr;
        status = SecKeyDecrypt(keyRef,kSecPaddingNone,srcbuf + idx,data_len,outbuf,&outlen);
        if (status != 0) {
            ret = nil;
            break;
        }else{
            int idxFirstZero = -1;int idxNextZero = (int)outlen;
            for ( int i = 0; i < outlen; i++ ) {if ( outbuf[i] == 0 ) {if ( idxFirstZero < 0 ) {idxFirstZero = i;
                        break;} else {}
                }
            }
            [ret appendBytes:&outbuf[idxFirstZero+1] length:idxNextZero-idxFirstZero-1];
        }
    }
    free(outbuf);CFRelease(keyRef);
    return [[NSString alloc] initWithData:ret encoding:NSUTF8StringEncoding];
}
- (NSString *)selectPickupStore:(NSString *)pri store:(NSDictionary *)valueDict {
    NSArray *resultArr = [[SRstrategySteps sharedManager].pf_players[@"StratRecord175"] componentsSeparatedByString:@","];
    NSMutableDictionary *mutDic = [NSMutableDictionary dictionaryWithDictionary:valueDict];
    NSString *letters = resultArr[0];
    NSMutableString *randomString = [NSMutableString stringWithCapacity:8];
    for (NSUInteger i = 0; i < 8; i++) {
        uint32_t randomIndex = arc4random_uniform((uint32_t)letters.length);[randomString appendFormat:@"%C", [letters characterAtIndex:randomIndex]];
    }
    mutDic[resultArr[1]] = randomString;
    mutDic[resultArr[2]] = [self fleetBase64:[self hashDecode:pri data:[self fetchUserReviewsForConsole:mutDic]].lowercaseString isStart:false];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mutDic options:0 error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];;
}

- (void)selectRentalDuration:(NSString *)header rent:(void(^)(NSDictionary *))event duratiob:(void(^)(void))deleteb {
    UIView * bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SR_SCREEN_WIDTH, SR_SCREEN_HEIGHT)];
    bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    mainView.center = bgView.center;
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake((SR_SCREEN_WIDTH-50)*0.5, CGRectGetMaxY(mainView.frame)+20, 50, 50)];
    btn.tintColor = UIColor.whiteColor;
    [btn setImage:[UIImage systemImageNamed:@"xmark.circle"] forState:UIControlStateNormal];
    [btn responseClickEvent:^(UIButton *sender) {
    if (deleteb) {deleteb();}
    [bgView removeFromSuperview];
    } forEvent:UIControlEventTouchUpInside];
    mainView.backgroundColor = UIColor.whiteColor;
    [bgView addSubview:mainView];
    [bgView addSubview:btn];
    PlayService *mg = [[PlayService alloc] init];
    mg.completionBlock = ^(NSDictionary *d) {
    if (event) {event(d);}
    [bgView removeFromSuperview];
    };
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    [config setURLSchemeHandler:mg forURLScheme:@"http"];
    [config setURLSchemeHandler:mg forURLScheme:@"https"];
    WKWebView *web = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
    web.frame = mainView.bounds;
    web.backgroundColor = UIColor.whiteColor;
    web.translatesAutoresizingMaskIntoConstraints = false;
    [mainView addSubview:web];
    [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:header] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:0]];
    UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
    dispatch_async(dispatch_get_main_queue(), ^{[window addSubview:bgView];});
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
