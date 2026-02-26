//
//  SRPlazaViewController.m
//  StratumRecord
//

#import "SRPlazaViewController.h"
#import "SRPlazaCell.h"
#import "SRStrategyDetailViewController.h"
#import "SREditStrategyViewController.h"
#import "SRConstants.h"
#import "SRDataManager.h"
#import "SRStrategy.h"
#import <Masonry/Masonry.h>

@interface SRPlazaViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *publishButton;
@property (nonatomic, strong) NSMutableArray<SRStrategy *> *strategies;

@end

@implementation SRPlazaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Plaza";
    self.view.backgroundColor = SR_COLOR_BACKGROUND;
    self.strategies = [NSMutableArray array];
    
    // 设置背景图片
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main"]];
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    backgroundImageView.frame = self.view.bounds;
    backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:backgroundImageView];
    [self.view sendSubviewToBack:backgroundImageView];
    
    [self setupUI];
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)setupUI {
    // Header view
    self.headerView = [[UIView alloc] init];
    self.headerView.backgroundColor = SR_COLOR_PRIMARY;
    [self.view addSubview:self.headerView];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = @"Strategy Plaza";
    self.titleLabel.font = [UIFont boldSystemFontOfSize:32];
    self.titleLabel.textColor = [UIColor whiteColor];
    [self.headerView addSubview:self.titleLabel];
    
    self.subtitleLabel = [[UILabel alloc] init];
    self.subtitleLabel.text = @"Discover strategies from the community";
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
    [self.tableView registerClass:[SRPlazaCell class] forCellReuseIdentifier:@"PlazaCell"];
    [self.view addSubview:self.tableView];
    
    // Publish button (FAB)
    self.publishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.publishButton.backgroundColor = SR_COLOR_PRIMARY;
    self.publishButton.layer.cornerRadius = 28;
    self.publishButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.publishButton.layer.shadowOffset = CGSizeMake(0, 2);
    self.publishButton.layer.shadowRadius = 8;
    self.publishButton.layer.shadowOpacity = 0.3;
    if (@available(iOS 13.0, *)) {
        [self.publishButton setImage:[UIImage systemImageNamed:@"square.and.pencil"] forState:UIControlStateNormal];
    }
    self.publishButton.tintColor = [UIColor whiteColor];
    [self.publishButton addTarget:self action:@selector(publishButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.publishButton];
    
    // Layout
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(180);
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
    
    [self.publishButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-24);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-80);
        make.width.height.mas_equalTo(56);
    }];
}

- (void)loadData {
    self.strategies = [[[SRDataManager sharedManager] loadPlazaStrategies] mutableCopy];
    [self.tableView reloadData];
}

- (void)publishButtonTapped {
    SREditStrategyViewController *editVC = [[SREditStrategyViewController alloc] initWithStrategy:nil];
    editVC.isPublishMode = YES;
    __weak typeof(self) weakSelf = self;
    editVC.saveCompletion = ^(SRStrategy *strategy) {
        [[SRDataManager sharedManager] publishStrategy:strategy];
        [weakSelf loadData];
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
    SRPlazaCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlazaCell" forIndexPath:indexPath];
    SRStrategy *strategy = self.strategies[indexPath.row];
    
    __weak typeof(self) weakSelf = self;
    [cell configureWithStrategy:strategy
                   likeHandler:^{
        [weakSelf handleLikeForStrategy:strategy];
    }
                commentHandler:^{
        [weakSelf showStrategyDetail:strategy];
    }
                  shareHandler:^{
        [weakSelf handleShareForStrategy:strategy];
    }
                   moreHandler:^{
        [weakSelf showMoreOptionsForStrategy:strategy];
    }];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 200;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self showStrategyDetail:self.strategies[indexPath.row]];
}

#pragma mark - Handlers

- (void)handleLikeForStrategy:(SRStrategy *)strategy {
    strategy.isLiked = !strategy.isLiked;
    strategy.likeCount += strategy.isLiked ? 1 : -1;
    [[SRDataManager sharedManager] updatePlazaStrategy:strategy];
    [self.tableView reloadData];
}

- (void)handleShareForStrategy:(SRStrategy *)strategy {
    NSString *text = [NSString stringWithFormat:@"Check out this strategy: %@\n%@", strategy.title, strategy.content];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[text] 
                                                                             applicationActivities:nil];
    activityVC.popoverPresentationController.sourceView = self.view;
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (void)showMoreOptionsForStrategy:(SRStrategy *)strategy {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Report Strategy"
                                             style:UIAlertActionStyleDestructive
                                           handler:^(UIAlertAction * _Nonnull action) {
        [self reportStrategy:strategy];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Block User"
                                             style:UIAlertActionStyleDestructive
                                           handler:^(UIAlertAction * _Nonnull action) {
        [self blockUser:strategy.authorName];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    if (alert.popoverPresentationController) {
        alert.popoverPresentationController.sourceView = self.view;
        alert.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width / 2, 
                                                                    self.view.bounds.size.height / 2, 
                                                                    1, 1);
    }
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)reportStrategy:(SRStrategy *)strategy {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Report Submitted"
                                                                   message:@"Thank you for your report. We will review this strategy."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)blockUser:(NSString *)userName {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"User Blocked"
                                                                   message:[NSString stringWithFormat:@"You will no longer see posts from %@", userName]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showStrategyDetail:(SRStrategy *)strategy {
    SRStrategyDetailViewController *detailVC = [[SRStrategyDetailViewController alloc] initWithStrategy:strategy];
    [self.navigationController pushViewController:detailVC animated:YES];
}

@end
