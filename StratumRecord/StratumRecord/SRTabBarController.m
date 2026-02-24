//
//  SRTabBarController.m
//  StratumRecord
//

#import "SRTabBarController.h"
#import "SRRecordViewController.h"
#import "SRPlazaViewController.h"
#import "SRSettingsViewController.h"
#import "SRConstants.h"

@interface SRTabBarController ()

@end

@implementation SRTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViewControllers];
    [self setupAppearance];
}

- (void)setupViewControllers {
    // Record ViewController
    SRRecordViewController *recordVC = [[SRRecordViewController alloc] init];
    UINavigationController *recordNav = [[UINavigationController alloc] initWithRootViewController:recordVC];
    recordNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Record" 
                                                        image:[self imageWithSystemName:@"pencil"] 
                                                          tag:0];
    
    // Plaza ViewController
    SRPlazaViewController *plazaVC = [[SRPlazaViewController alloc] init];
    UINavigationController *plazaNav = [[UINavigationController alloc] initWithRootViewController:plazaVC];
    plazaNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Plaza" 
                                                       image:[self imageWithSystemName:@"compass"] 
                                                         tag:1];
    
    // Settings ViewController
    SRSettingsViewController *settingsVC = [[SRSettingsViewController alloc] init];
    UINavigationController *settingsNav = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    settingsNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Settings" 
                                                          image:[self imageWithSystemName:@"gearshape"] 
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

- (UIImage *)imageWithSystemName:(NSString *)systemName {
    if (@available(iOS 13.0, *)) {
        return [UIImage systemImageNamed:systemName];
    } else {
        return nil;
    }
}

@end
