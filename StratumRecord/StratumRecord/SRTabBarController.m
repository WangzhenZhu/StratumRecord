//
//  SRTabBarController.m
//  StratumRecord
//

#import "SRTabBarController.h"
#import "SRRecordViewController.h"
#import "SRPlazaViewController.h"
#import "SRSettingsViewController.h"
#import "SRUserManager.h"
#import "SRLoginViewController.h"
#import "SRConstants.h"

@interface SRTabBarController () <UITabBarControllerDelegate>

@property (nonatomic, assign) BOOL srm_isPresentingLogin;

@end

@implementation SRTabBarController

static NSString * const kSRSkipLoginOnceKey = @"SR_SKIP_LOGIN_ONCE";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
    [self setupViewControllers];
    [self setupAppearance];
}

- (void)setupViewControllers {
    // Record ViewController
    SRRecordViewController *recordVC = [[SRRecordViewController alloc] init];
    UINavigationController *recordNav = [[UINavigationController alloc] initWithRootViewController:recordVC];
    recordNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Record" 
                                                        image:[UIImage imageNamed:@"tab_record"]
                                                          tag:0];
    
    // Plaza ViewController
    SRPlazaViewController *plazaVC = [[SRPlazaViewController alloc] init];
    UINavigationController *plazaNav = [[UINavigationController alloc] initWithRootViewController:plazaVC];
    plazaNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Plaza" 
                                                       image:[UIImage imageNamed:@"tab_plaza"]
                                                         tag:1];
    
    // Settings ViewController
    SRSettingsViewController *settingsVC = [[SRSettingsViewController alloc] init];
    UINavigationController *settingsNav = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    settingsNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Profile" 
                                                          image:[UIImage imageNamed:@"tab_mine"]
                                                            tag:2];
    
    self.viewControllers = @[recordNav, plazaNav, settingsNav];
}

- (void)setupAppearance {
    self.tabBar.tintColor = SR_COLOR_PRIMARY;
    self.tabBar.backgroundColor = [UIColor whiteColor];
    
    if (@available(iOS 15.0, *)) {
        UITabBarAppearance *appearance = [[UITabBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [UIColor whiteColor];
        self.tabBar.standardAppearance = appearance;
        self.tabBar.scrollEdgeAppearance = appearance;
    }
}

- (UIImage *)srm_imageWithSystemName:(NSString *)systemName {
    if (@available(iOS 13.0, *)) {
        return [UIImage systemImageNamed:systemName];
    } else {
        return nil;
    }
}

- (void)srm_presentLoginIfNeeded {
    if ([[SRUserManager sharedManager] isLoggedIn]) {
        return;
    }
    
    BOOL skipLoginOnce = [[NSUserDefaults standardUserDefaults] boolForKey:kSRSkipLoginOnceKey];
    if (skipLoginOnce) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kSRSkipLoginOnceKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return;
    }
    
    if (self.srm_isPresentingLogin || self.presentedViewController != nil) {
        return;
    }
    
    self.srm_isPresentingLogin = YES;
    SRLoginViewController *loginVC = [[SRLoginViewController alloc] init];
    loginVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:loginVC animated:YES completion:^{
        self.srm_isPresentingLogin = NO;
    }];
}

#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    NSUInteger profileTabIndex = 2;
    NSUInteger targetIndex = [tabBarController.viewControllers indexOfObject:viewController];
    if (targetIndex == profileTabIndex && ![[SRUserManager sharedManager] isLoggedIn]) {
        [self srm_presentLoginIfNeeded];
        return NO;
    }
    return YES;
}

@end
