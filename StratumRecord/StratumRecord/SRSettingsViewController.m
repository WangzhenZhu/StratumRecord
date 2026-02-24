//
//  SRSettingsViewController.m
//  StratumRecord
//

#import "SRSettingsViewController.h"
#import "SRConstants.h"
#import <Masonry/Masonry.h>

@interface SRSettingsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UILabel *appNameLabel;
@property (nonatomic, strong) UILabel *appTaglineLabel;

@property (nonatomic, strong) NSArray<NSDictionary *> *settingsItems;

@end

@implementation SRSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Settings";
    self.view.backgroundColor = SR_COLOR_BACKGROUND;
    
    [self setupData];
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)setupData {
    self.settingsItems = @[
        @{@"icon": @"trash", @"title": @"Clear Cache", @"hasArrow": @YES},
        @{@"icon": @"shield", @"title": @"Privacy Policy", @"hasArrow": @YES},
        @{@"icon": @"info.circle", @"title": @"Version Information", @"value": @"v1.0.0", @"hasArrow": @NO},
        @{@"icon": @"exclamationmark.bubble", @"title": @"Feedback", @"hasArrow": @YES},
        @{@"icon": @"square.and.arrow.up", @"title": @"Share with Friends", @"hasArrow": @YES},
        @{@"icon": @"star", @"title": @"Rate the App", @"hasArrow": @YES}
    ];
}

- (void)setupUI {
    // Header view
    self.headerView = [[UIView alloc] init];
    self.headerView.backgroundColor = SR_COLOR_PRIMARY;
    [self.view addSubview:self.headerView];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = @"Settings";
    self.titleLabel.font = [UIFont boldSystemFontOfSize:32];
    self.titleLabel.textColor = [UIColor whiteColor];
    [self.headerView addSubview:self.titleLabel];
    
    self.subtitleLabel = [[UILabel alloc] init];
    self.subtitleLabel.text = @"Manage your app preferences";
    self.subtitleLabel.font = [UIFont systemFontOfSize:16];
    self.subtitleLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    [self.headerView addSubview:self.subtitleLabel];
    
    // Table view
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = SR_COLOR_BACKGROUND;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 60, 0, 0);
    [self.view addSubview:self.tableView];
    
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
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.settingsItems.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"SettingsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    
    NSDictionary *item = self.settingsItems[indexPath.row];
    cell.textLabel.text = item[@"title"];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    
    if (item[@"value"]) {
        cell.detailTextLabel.text = item[@"value"];
        cell.detailTextLabel.textColor = SR_COLOR_TEXT_SECONDARY;
    } else {
        cell.detailTextLabel.text = nil;
    }
    
    if ([item[@"hasArrow"] boolValue]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    // Icon
    if (@available(iOS 13.0, *)) {
        UIImage *icon = [UIImage systemImageNamed:item[@"icon"]];
        cell.imageView.image = icon;
        cell.imageView.tintColor = SR_COLOR_TEXT_SECONDARY;
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 0) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 200)];
        footerView.backgroundColor = [UIColor clearColor];
        
        // Logo
        UIView *logoView = [[UIView alloc] init];
        logoView.backgroundColor = SR_COLOR_PRIMARY;
        logoView.layer.cornerRadius = 40;
        [footerView addSubview:logoView];
        
        self.appNameLabel = [[UILabel alloc] init];
        self.appNameLabel.text = @"StratumRecord";
        self.appNameLabel.font = [UIFont boldSystemFontOfSize:20];
        self.appNameLabel.textColor = SR_COLOR_TEXT_PRIMARY;
        self.appNameLabel.textAlignment = NSTextAlignmentCenter;
        [footerView addSubview:self.appNameLabel];
        
        self.appTaglineLabel = [[UILabel alloc] init];
        self.appTaglineLabel.text = @"Your Game Strategy Companion";
        self.appTaglineLabel.font = [UIFont systemFontOfSize:14];
        self.appTaglineLabel.textColor = SR_COLOR_TEXT_SECONDARY;
        self.appTaglineLabel.textAlignment = NSTextAlignmentCenter;
        [footerView addSubview:self.appTaglineLabel];
        
        [logoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(footerView);
            make.top.equalTo(footerView).offset(40);
            make.width.height.mas_equalTo(80);
        }];
        
        [self.appNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(footerView);
            make.top.equalTo(logoView.mas_bottom).offset(16);
        }];
        
        [self.appTaglineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(footerView);
            make.top.equalTo(self.appNameLabel.mas_bottom).offset(8);
        }];
        
        return footerView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 200;
    }
    return 0;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *item = self.settingsItems[indexPath.row];
    NSString *title = item[@"title"];
    
    if ([title isEqualToString:@"Clear Cache"]) {
        [self clearCache];
    } else if ([title isEqualToString:@"Privacy Policy"]) {
        [self showPrivacyPolicy];
    } else if ([title isEqualToString:@"Feedback"]) {
        [self showFeedback];
    } else if ([title isEqualToString:@"Share with Friends"]) {
        [self shareApp];
    } else if ([title isEqualToString:@"Rate the App"]) {
        [self rateApp];
    }
}

#pragma mark - Actions

- (void)clearCache {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Clear Cache"
                                                                   message:@"Are you sure you want to clear the cache?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Clear"
                                             style:UIAlertActionStyleDestructive
                                           handler:^(UIAlertAction * _Nonnull action) {
        // Clear cache
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        
        UIAlertController *successAlert = [UIAlertController alertControllerWithTitle:@"Success"
                                                                               message:@"Cache cleared successfully"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
        [successAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:successAlert animated:YES completion:nil];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showPrivacyPolicy {
    UIViewController *privacyVC = [[UIViewController alloc] init];
    privacyVC.title = @"Privacy Policy";
    privacyVC.view.backgroundColor = [UIColor whiteColor];
    
    UITextView *textView = [[UITextView alloc] init];
    textView.text = @"Privacy Policy\n\nStratumRecord respects your privacy. This app does not collect any personal information. All your game strategies are stored locally on your device.\n\nWe do not share your data with any third parties.\n\nLast updated: February 24, 2026";
    textView.font = [UIFont systemFontOfSize:16];
    textView.editable = NO;
    textView.textContainerInset = UIEdgeInsetsMake(20, 20, 20, 20);
    [privacyVC.view addSubview:textView];
    
    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(privacyVC.view);
    }];
    
    [self.navigationController pushViewController:privacyVC animated:YES];
}

- (void)showFeedback {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Feedback"
                                                                   message:@"Please enter your feedback"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Your feedback...";
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Submit"
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * _Nonnull action) {
        UIAlertController *successAlert = [UIAlertController alertControllerWithTitle:@"Thank You"
                                                                               message:@"Your feedback has been submitted"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
        [successAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:successAlert animated:YES completion:nil];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)shareApp {
    NSString *text = @"Check out StratumRecord - Your Game Strategy Companion!";
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[text]
                                                                             applicationActivities:nil];
    
    if (activityVC.popoverPresentationController) {
        activityVC.popoverPresentationController.sourceView = self.view;
        activityVC.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width / 2,
                                                                         self.view.bounds.size.height / 2,
                                                                         1, 1);
    }
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (void)rateApp {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Rate StratumRecord"
                                                                   message:@"If you enjoy using StratumRecord, please take a moment to rate it in the App Store!"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Rate Now"
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * _Nonnull action) {
        // In a real app, this would open the App Store
        UIAlertController *successAlert = [UIAlertController alertControllerWithTitle:@"Thank You"
                                                                               message:@"Thank you for your support!"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
        [successAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:successAlert animated:YES completion:nil];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Later" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
