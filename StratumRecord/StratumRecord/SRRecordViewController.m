//
//  SRRecordViewController.m
//  StratumRecord
//

#import "SRRecordViewController.h"
#import "SREditStrategyViewController.h"
#import "SRStrategyCell.h"
#import "SRConstants.h"
#import "SRDataManager.h"
#import "SRStrategy.h"
#import <Masonry/Masonry.h>

@interface SRRecordViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) NSMutableArray<SRStrategy *> *strategies;

@end

@implementation SRRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"My Strategies";
    self.view.backgroundColor = SR_COLOR_BACKGROUND;
    self.strategies = [NSMutableArray array];
    
    // 设置背景图片
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main"]];
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    backgroundImageView.frame = self.view.bounds;
    backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:backgroundImageView];
    [self.view sendSubviewToBack:backgroundImageView];
    
    [self srm_setupUI];
    [self srm_loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self srm_loadData];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)srm_setupUI {
    // Header view
    self.headerView = [[UIView alloc] init];
    self.headerView.backgroundColor = SR_COLOR_PRIMARY;
    [self.view addSubview:self.headerView];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = @"My Strategies";
    self.titleLabel.font = [UIFont boldSystemFontOfSize:32];
    self.titleLabel.textColor = [UIColor whiteColor];
    [self.headerView addSubview:self.titleLabel];
    
    self.subtitleLabel = [[UILabel alloc] init];
    self.subtitleLabel.text = @"Record and manage your game strategies";
    self.subtitleLabel.font = [UIFont systemFontOfSize:16];
    self.subtitleLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    [self.headerView addSubview:self.subtitleLabel];
    
    // Table view
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(16, 0, 80, 0);
    [self.tableView registerClass:[SRStrategyCell class] forCellReuseIdentifier:@"StrategyCell"];
    [self.view addSubview:self.tableView];
    
    // Add button (FAB)
    self.addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.addButton.backgroundColor = SR_COLOR_PRIMARY;
    self.addButton.layer.cornerRadius = 28;
    self.addButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.addButton.layer.shadowOffset = CGSizeMake(0, 2);
    self.addButton.layer.shadowRadius = 8;
    self.addButton.layer.shadowOpacity = 0.3;
    [self.addButton setTitle:@"+" forState:UIControlStateNormal];
    self.addButton.titleLabel.font = [UIFont systemFontOfSize:32 weight:UIFontWeightLight];
    [self.addButton addTarget:self action:@selector(srm_addButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addButton];
    
    // Layout
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(200);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerView).offset(24);
        make.bottom.equalTo(self.headerView).offset(-50);
    }];
    
    [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(8);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerView.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-24);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-80);
        make.width.height.mas_equalTo(56);
    }];
}

- (void)srm_loadData {
    self.strategies = [[[SRDataManager sharedManager] srm_loadMyStrategies] mutableCopy];
    [self.tableView reloadData];
}

- (void)srm_addButtonTapped {
    SREditStrategyViewController *editVC = [[SREditStrategyViewController alloc] initWithStrategy:nil];
    editVC.isPublishMode = NO;
    __weak typeof(self) weakSelf = self;
    editVC.saveCompletion = ^(SRStrategy *strategy) {
        [[SRDataManager sharedManager] srm_addMyStrategy:strategy];
        [weakSelf srm_loadData];
    };
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:editVC];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.strategies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SRStrategyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StrategyCell" forIndexPath:indexPath];
    [cell srm_configureWithStrategy:self.strategies[indexPath.row]];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 150;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SRStrategy *strategy = self.strategies[indexPath.row];
    SREditStrategyViewController *editVC = [[SREditStrategyViewController alloc] initWithStrategy:strategy];
    editVC.isPublishMode = NO;
    __weak typeof(self) weakSelf = self;
    editVC.saveCompletion = ^(SRStrategy *updatedStrategy) {
        [[SRDataManager sharedManager] srm_updateMyStrategy:updatedStrategy];
        [weakSelf srm_loadData];
    };
    editVC.deleteCompletion = ^(NSString *strategyId) {
        [[SRDataManager sharedManager] srm_deleteMyStrategy:strategyId];
        [weakSelf srm_loadData];
    };
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:editVC];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}

@end
