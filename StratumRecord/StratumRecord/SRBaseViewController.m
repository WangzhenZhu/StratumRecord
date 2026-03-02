//
//  SRBaseViewController.m
//  StratumRecord
//
//  Created by mac on 2026/3/2.
//

#import "SRBaseViewController.h"
#import "SRAnalyticsManager.h"
#import "SRConstants.h"

@interface SRBaseViewController ()

@end

@implementation SRBaseViewController

#pragma mark - Lifecycle Methods

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 隐藏系统导航栏
    self.navigationController.navigationBar.hidden = YES;
    
    // 神策页面统计 - 页面开始
    [[SRAnalyticsManager sharedManager] trackPageViewBegin:NSStringFromClass([self class])];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // 神策页面统计 - 页面结束
    [[SRAnalyticsManager sharedManager] trackPageViewEnd:NSStringFromClass([self class])];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    // 确保导航栏在最上层
    [self.view bringSubviewToFront:self.navigationView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置背景色
    self.view.backgroundColor = SR_COLOR_BACKGROUND;
    
    // 初始化自定义导航栏
    [self setupNavigationView];
}

#pragma mark - Setup Methods

- (void)setupNavigationView {
    // 导航栏容器
    _navigationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SR_SCREEN_WIDTH, SR_TOP_HEIGHT)];
    _navigationView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_navigationView];
    
    // 标题标签
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(SR_SCREEN_WIDTH / 2 - 100, SR_STATUS_BAR_HEIGHT, 200, SR_NAVIGATION_BAR_HEIGHT)];
    _titleLabel.textColor = SR_COLOR_TEXT_PRIMARY;
    _titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [_navigationView addSubview:_titleLabel];
    
    // 返回按钮
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _backButton.frame = CGRectMake(8, SR_STATUS_BAR_HEIGHT, 44, SR_NAVIGATION_BAR_HEIGHT);
    
    // 使用系统图标或自定义图片
    if (@available(iOS 13.0, *)) {
        [_backButton setImage:[UIImage systemImageNamed:@"arrow.left"] forState:UIControlStateNormal];
        _backButton.tintColor = SR_COLOR_TEXT_PRIMARY;
    } else {
        [_backButton setTitle:@"←" forState:UIControlStateNormal];
        [_backButton setTitleColor:SR_COLOR_TEXT_PRIMARY forState:UIControlStateNormal];
        _backButton.titleLabel.font = [UIFont systemFontOfSize:24];
    }
    
    [_backButton addTarget:self action:@selector(backEvent) forControlEvents:UIControlEventTouchUpInside];
    [_navigationView addSubview:_backButton];
    
    // 默认隐藏导航栏（根视图不需要显示）
    _navigationView.hidden = YES;
}

#pragma mark - Actions

- (void)backEvent {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Dealloc

- (void)dealloc {
    NSLog(@"🗑️ %@ dealloc", NSStringFromClass([self class]));
}

@end
