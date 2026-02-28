//
//  SRSettingsViewController.m
//  StratumRecord
//

#import "SRSettingsViewController.h"
#import "SRConstants.h"
#import "SRUserManager.h"
#import "SRTabBarController.h"
#import "SRFeedbackViewController.h"
#import "SREditProfileViewController.h"
#import "SRAnalyticsManager.h"
#import <LEEAlert/LEEAlert.h>
#import <Masonry/Masonry.h>
#import <WebKit/WebKit.h>
#import <StoreKit/StoreKit.h>

@interface SRSettingsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;

// Header (top section with gradient)
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *avatarContainerView;
@property (nonatomic, strong) UIView *avatarView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *levelBadgeLabel;
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UILabel *bioLabel;
@property (nonatomic, strong) UILabel *levelLabel;
@property (nonatomic, strong) UILabel *expLabel;
@property (nonatomic, strong) UIView *progressBarBG;
@property (nonatomic, strong) UIView *progressBarFill;

// Stats card
@property (nonatomic, strong) UIView *statsCard;
@property (nonatomic, strong) UILabel *strategiesLabel;
@property (nonatomic, strong) UILabel *likesLabel;
@property (nonatomic, strong) UILabel *commentsLabel;

// Content sections
@property (nonatomic, strong) UIView *badgesSection;
@property (nonatomic, strong) UIView *gamesSection;
@property (nonatomic, strong) UIView *accountSection;
@property (nonatomic, strong) UILabel *memberLevelLabel;
@property (nonatomic, strong) UITableView *settingsTable;

@property (nonatomic, strong) NSArray<NSDictionary *> *settingsItems;

@end

@implementation SRSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Settings";
    self.view.backgroundColor = SR_COLOR_BACKGROUND;
    
    // 设置背景图片
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main"]];
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    backgroundImageView.frame = self.view.bounds;
    backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:backgroundImageView];
    [self.view sendSubviewToBack:backgroundImageView];
    
    [self srm_setupData];
    [self srm_setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    
    if ([[SRUserManager sharedManager] isLoggedIn]) {
        // Update user stats
        [[SRUserManager sharedManager] updateUserStats];
        [self srm_updateUserInfo];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 神策页面埋点
    [[SRAnalyticsManager sharedManager] trackPageViewBegin:@"Settings_Page"];
    
    // 设置用户属性
    SRUser *user = [[SRUserManager sharedManager] currentUser];
    if (user) {
        [[SRAnalyticsManager sharedManager] login:user.userId];
        [[SRAnalyticsManager sharedManager] setUserProperties:@{
            @"user_level": @(user.level),
            @"user_email": user.email ?: @""
        }];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[SRAnalyticsManager sharedManager] trackPageViewEnd:@"Settings_Page"];
}

- (void)srm_setupData {
    self.settingsItems = @[
        @{@"icon": @"trash", @"title": @"Clear Cache", @"hasArrow": @YES},
        @{@"icon": @"shield", @"title": @"Privacy Policy", @"hasArrow": @YES},
        @{@"icon": @"info.circle", @"title": @"Version", @"value": @"v1.0.0", @"hasArrow": @NO},
        @{@"icon": @"exclamationmark.bubble", @"title": @"Feedback", @"hasArrow": @YES},
        @{@"icon": @"square.and.arrow.up", @"title": @"Share with Friends", @"hasArrow": @YES},
        @{@"icon": @"star", @"title": @"Rate the App", @"hasArrow": @YES},
        @{@"icon": @"trash.circle", @"title": @"Delete Account", @"hasArrow": @YES},
        @{@"icon": @"rectangle.portrait.and.arrow.right", @"title": @"Logout", @"hasArrow": @YES}
    ];
}

- (void)srm_setupUI {
    // Main scroll view
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];
    
    self.contentView = [[UIView alloc] init];
    [self.scrollView addSubview:self.contentView];
    
    // Header with gradient background
    self.headerView = [[UIView alloc] init];
    self.headerView.backgroundColor = SR_COLOR_PRIMARY;
    self.headerView.clipsToBounds = YES;
    [self.contentView addSubview:self.headerView];
    
    // Header background image
    UIImageView *headerBackgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mine_bg"]];
    headerBackgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    headerBackgroundImageView.clipsToBounds = YES;
    [self.headerView addSubview:headerBackgroundImageView];
    [headerBackgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.headerView);
    }];
    
    [self srm_setupHeaderSection];
    [self srm_setupStatsCard];
    [self srm_setupBadgesSection];
    [self srm_setupGamesSection];
    [self srm_setupAccountSection];
    [self srm_setupSettingsSection];
    [self srm_setupConstraints];
}

#pragma mark - Setup Sections

- (void)srm_setupHeaderSection {
    // Avatar container with level badge
    self.avatarContainerView = [[UIView alloc] init];
    [self.headerView addSubview:self.avatarContainerView];
    
    // Main avatar
    self.avatarView = [[UIView alloc] init];
    self.avatarView.backgroundColor = [UIColor colorWithRed:0.2 green:0.3 blue:0.4 alpha:1.0];
    self.avatarView.layer.cornerRadius = 40;
    self.avatarView.layer.borderWidth = 3;
    self.avatarView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.avatarView.clipsToBounds = YES;
    [self.avatarContainerView addSubview:self.avatarView];
    
    // Avatar ImageView (for uploaded photos)
    self.avatarImageView = [[UIImageView alloc] init];
    self.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.hidden = YES;
    [self.avatarView addSubview:self.avatarImageView];
    
    // Avatar image/emoji
    UILabel *avatarEmoji = [[UILabel alloc] init];
    avatarEmoji.text = @"🎮";
    avatarEmoji.font = [UIFont systemFontOfSize:40];
    avatarEmoji.textAlignment = NSTextAlignmentCenter;
    [self.avatarView addSubview:avatarEmoji];
    
    // Level badge
    self.levelBadgeLabel = [[UILabel alloc] init];
    self.levelBadgeLabel.text = @"42";
    self.levelBadgeLabel.font = [UIFont boldSystemFontOfSize:14];
    self.levelBadgeLabel.textColor = SR_COLOR_PRIMARY;
    self.levelBadgeLabel.backgroundColor = [UIColor whiteColor];
    self.levelBadgeLabel.textAlignment = NSTextAlignmentCenter;
    self.levelBadgeLabel.layer.cornerRadius = 15;
    self.levelBadgeLabel.layer.borderWidth = 2;
    self.levelBadgeLabel.layer.borderColor = SR_COLOR_PRIMARY.CGColor;
    self.levelBadgeLabel.clipsToBounds = YES;
    [self.avatarContainerView addSubview:self.levelBadgeLabel];
    
    // Username with edit button
    self.usernameLabel = [[UILabel alloc] init];
    self.usernameLabel.text = @"ShadowTactici...";
    self.usernameLabel.font = [UIFont boldSystemFontOfSize:22];
    self.usernameLabel.textColor = [UIColor whiteColor];
    [self.headerView addSubview:self.usernameLabel];
    
    self.editButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.editButton setTitle:@"Edit" forState:UIControlStateNormal];
    self.editButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.editButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.editButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
    self.editButton.layer.cornerRadius = 4;
    self.editButton.contentEdgeInsets = UIEdgeInsetsMake(4, 8, 4, 8);
    [self.editButton addTarget:self action:@selector(srm_editUserInfo) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:self.editButton];
    
    // Bio
    self.bioLabel = [[UILabel alloc] init];
    self.bioLabel.text = @"Hardcore gamer & strategy enthusiast. Love sharing tips with the community 🎮";
    self.bioLabel.font = [UIFont systemFontOfSize:14];
    self.bioLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    self.bioLabel.numberOfLines = 2;
    [self.headerView addSubview:self.bioLabel];
    
    // Level and EXP
    self.levelLabel = [[UILabel alloc] init];
    self.levelLabel.text = @"Lv.42";
    self.levelLabel.font = [UIFont boldSystemFontOfSize:13];
    self.levelLabel.textColor = [UIColor whiteColor];
    [self.headerView addSubview:self.levelLabel];
    
    self.expLabel = [[UILabel alloc] init];
    self.expLabel.text = @"7800 / 10000 EXP";
    self.expLabel.font = [UIFont systemFontOfSize:12];
    self.expLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    self.expLabel.textAlignment = NSTextAlignmentRight;
    [self.headerView addSubview:self.expLabel];
    
    // Progress bar
    self.progressBarBG = [[UIView alloc] init];
    self.progressBarBG.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
    self.progressBarBG.layer.cornerRadius = 4;
    [self.headerView addSubview:self.progressBarBG];
    
    self.progressBarFill = [[UIView alloc] init];
    self.progressBarFill.backgroundColor = [UIColor colorWithRed:1.0 green:0.75 blue:0.2 alpha:1.0];
    self.progressBarFill.layer.cornerRadius = 4;
    [self.progressBarBG addSubview:self.progressBarFill];
}

- (void)srm_setupStatsCard {
    self.statsCard = [[UIView alloc] init];
    self.statsCard.backgroundColor = [UIColor whiteColor];
    self.statsCard.layer.cornerRadius = 12;
    self.statsCard.layer.shadowColor = [UIColor blackColor].CGColor;
    self.statsCard.layer.shadowOffset = CGSizeMake(0, 2);
    self.statsCard.layer.shadowRadius = 8;
    self.statsCard.layer.shadowOpacity = 0.1;
    [self.contentView addSubview:self.statsCard];
    
    SRUser *user = [[SRUserManager sharedManager] currentUser];
    NSArray *stats = @[
        @{@"value": @(user.strategiesCount), @"label": @"Strategies"},
        @{@"value": @(user.likesCount), @"label": @"Likes"},
        @{@"value": @(user.commentsCount), @"label": @"Comments"}
    ];
    
    UIView *lastStatView = nil;
    for (int i = 0; i < stats.count; i++) {
        UIView *statView = [[UIView alloc] init];
        [self.statsCard addSubview:statView];
        
        UILabel *valueLabel = [[UILabel alloc] init];
        valueLabel.text = [NSString stringWithFormat:@"%@", stats[i][@"value"]];
        valueLabel.font = [UIFont systemFontOfSize:32 weight:UIFontWeightBold];
        valueLabel.textColor = SR_COLOR_TEXT_PRIMARY;
        valueLabel.textAlignment = NSTextAlignmentCenter;
        [statView addSubview:valueLabel];
        
        // Store references to labels
        if (i == 0) self.strategiesLabel = valueLabel;
        else if (i == 1) self.likesLabel = valueLabel;
        else if (i == 2) self.commentsLabel = valueLabel;
        
        UILabel *labelText = [[UILabel alloc] init];
        labelText.text = stats[i][@"label"];
        labelText.font = [UIFont systemFontOfSize:13];
        labelText.textColor = SR_COLOR_TEXT_SECONDARY;
        labelText.textAlignment = NSTextAlignmentCenter;
        [statView addSubview:labelText];
        
        [valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(statView);
            make.centerY.equalTo(statView).offset(-8);
        }];
        
        [labelText mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(statView);
            make.top.equalTo(valueLabel.mas_bottom).offset(4);
        }];
        
        [statView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (i == 0) {
                make.left.equalTo(self.statsCard);
            } else {
                make.left.equalTo(lastStatView.mas_right);
            }
            make.top.bottom.equalTo(self.statsCard);
            make.width.equalTo(self.statsCard).dividedBy(3);
        }];
        
        lastStatView = statView;
    }
}

- (void)srm_setupBadgesSection {
    self.badgesSection = [[UIView alloc] init];
    self.badgesSection.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.95];
    self.badgesSection.layer.cornerRadius = 12;
    [self.contentView addSubview:self.badgesSection];
    
    UILabel *badgesTitle = [[UILabel alloc] init];
    badgesTitle.text = @"Badges";
    badgesTitle.font = [UIFont boldSystemFontOfSize:18];
    badgesTitle.textColor = SR_COLOR_TEXT_PRIMARY;
    [self.badgesSection addSubview:badgesTitle];
    
    NSArray *badges = @[
        @{@"icon": @"mine_hot", @"label": @"Hot Author"},
        @{@"icon": @"mine_rank", @"label": @"Top 100"},
        @{@"icon": @"mine_like", @"label": @"100+ Likes"},
        @{@"icon": @"mine_creator", @"label": @"Creator"}
    ];
    
    UIView *badgesContainer = [[UIView alloc] init];
    [self.badgesSection addSubview:badgesContainer];
    
    UIView *lastBadge = nil;
    for (int i = 0; i < badges.count; i++) {
        UIView *badgeView = [self srm_createBadgeViewWithIcon:badges[i][@"icon"] label:badges[i][@"label"]];
        [badgesContainer addSubview:badgeView];
        
        [badgeView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (i == 0) {
                make.left.equalTo(badgesContainer);
            } else {
                make.left.equalTo(lastBadge.mas_right).offset(12);
            }
            make.top.bottom.equalTo(badgesContainer);
            make.width.equalTo(badgesContainer).dividedBy(4).offset(-9);
        }];
        
        lastBadge = badgeView;
    }
    
    [badgesTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.badgesSection).offset(20);
        make.top.equalTo(self.badgesSection).offset(16);
    }];
    
    [badgesContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.badgesSection).offset(20);
        make.right.equalTo(self.badgesSection).offset(-20);
        make.top.equalTo(badgesTitle.mas_bottom).offset(12);
        make.bottom.equalTo(self.badgesSection).offset(-16);
        make.height.mas_equalTo(90);
    }];
}

- (void)srm_setupGamesSection {
    self.gamesSection = [[UIView alloc] init];
    self.gamesSection.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.95];
    self.gamesSection.layer.cornerRadius = 12;
    [self.contentView addSubview:self.gamesSection];
    
    UILabel *gamesTitle = [[UILabel alloc] init];
    gamesTitle.text = @"Favorite Games";
    gamesTitle.font = [UIFont boldSystemFontOfSize:18];
    gamesTitle.textColor = SR_COLOR_TEXT_PRIMARY;
    [self.gamesSection addSubview:gamesTitle];
    
    NSArray *games = @[@"Genshin Impact", @"Valorant", @"Elden Ring"];
    
    UIView *lastGameButton = nil;
    for (int i = 0; i < games.count; i++) {
        UIButton *gameButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [gameButton setTitle:games[i] forState:UIControlStateNormal];
        gameButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [gameButton setTitleColor:SR_COLOR_PRIMARY forState:UIControlStateNormal];
        gameButton.backgroundColor = [[UIColor colorWithRed:38/255.0 green:181/255.0 blue:168/255.0 alpha:1.0] colorWithAlphaComponent:0.1];
        gameButton.layer.cornerRadius = 16;
        gameButton.contentEdgeInsets = UIEdgeInsetsMake(8, 16, 8, 16);
        [self.gamesSection addSubview:gameButton];
        
        [gameButton mas_makeConstraints:^(MASConstraintMaker *make) {
            if (i == 0) {
                make.left.equalTo(self.gamesSection).offset(20);
            } else {
                make.left.equalTo(lastGameButton.mas_right).offset(10);
            }
            make.top.equalTo(gamesTitle.mas_bottom).offset(12);
        }];
        
        lastGameButton = gameButton;
    }
    
    [gamesTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.gamesSection).offset(20);
        make.top.equalTo(self.gamesSection).offset(16);
    }];
}

- (void)srm_setupAccountSection {
    self.accountSection = [[UIView alloc] init];
    self.accountSection.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.95];
    self.accountSection.layer.cornerRadius = 12;
    [self.contentView addSubview:self.accountSection];
    
    UILabel *accountTitle = [[UILabel alloc] init];
    accountTitle.text = @"Account Info";
    accountTitle.font = [UIFont boldSystemFontOfSize:18];
    accountTitle.textColor = SR_COLOR_TEXT_PRIMARY;
    [self.accountSection addSubview:accountTitle];
    
    // Joined row
    UIView *joinedRow = [self srm_createInfoRowWithIcon:@"calendar" label:@"Joined" value:@"Mar 15, 2024"];
    [self.accountSection addSubview:joinedRow];
    
    // Member Level row
    UIView *levelRow = [self srm_createInfoRowWithIcon:@"crown" label:@"Member Level" value:@"Lv.42 Elite" valueColor:[UIColor orangeColor]];
    [self.accountSection addSubview:levelRow];
    
    // Store reference to member level label (it's the last subview - the value label)
    self.memberLevelLabel = [levelRow.subviews lastObject];
    
    [accountTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.accountSection).offset(20);
        make.top.equalTo(self.accountSection).offset(16);
    }];
    
    [joinedRow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.accountSection).inset(20);
        make.top.equalTo(accountTitle.mas_bottom).offset(12);
        make.height.mas_equalTo(44);
    }];
    
    [levelRow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.accountSection).inset(20);
        make.top.equalTo(joinedRow.mas_bottom).offset(8);
        make.height.mas_equalTo(44);
        make.bottom.equalTo(self.accountSection).offset(-16);
    }];
}

- (void)srm_setupSettingsSection {
    UILabel *settingsTitle = [[UILabel alloc] init];
    settingsTitle.text = @"Settings";
    settingsTitle.font = [UIFont boldSystemFontOfSize:18];
    settingsTitle.textColor = SR_COLOR_TEXT_PRIMARY;
    [self.contentView addSubview:settingsTitle];
    
    self.settingsTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.settingsTable.delegate = self;
    self.settingsTable.dataSource = self;
    self.settingsTable.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.95];
    self.settingsTable.layer.cornerRadius = 12;
    self.settingsTable.scrollEnabled = NO;
    self.settingsTable.separatorInset = UIEdgeInsetsMake(0, 56, 0, 0);
    [self.contentView addSubview:self.settingsTable];
    
    // Store references for constraints
    self.settingsTable.tag = 100;
    settingsTitle.tag = 99;
}

- (void)srm_setupConstraints {
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
    
    // Header
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(280);
    }];
    
    [self.avatarContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerView).offset(20);
        make.top.equalTo(self.headerView).offset(60);
        make.width.height.mas_equalTo(80);
    }];
    
    [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.avatarContainerView);
    }];
    
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.avatarView);
    }];
    
    [[self.avatarView.subviews lastObject] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.avatarView);
    }];
    
    [self.levelBadgeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.equalTo(self.avatarContainerView);
        make.width.height.mas_equalTo(30);
    }];
    
    [self.usernameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avatarContainerView.mas_right).offset(16);
        make.top.equalTo(self.avatarContainerView).offset(8);
    }];
    
    [self.editButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.usernameLabel.mas_right).offset(12);
        make.centerY.equalTo(self.usernameLabel);
        make.height.mas_equalTo(28);
    }];
    
    [self.bioLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.usernameLabel);
        make.right.equalTo(self.headerView).offset(-20);
        make.top.equalTo(self.usernameLabel.mas_bottom).offset(6);
    }];
    
    [self.levelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerView).offset(20);
        make.bottom.equalTo(self.progressBarBG.mas_top).offset(-8);
    }];
    
    [self.expLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.headerView).offset(-20);
        make.centerY.equalTo(self.levelLabel);
    }];
    
    [self.progressBarBG mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerView).offset(20);
        make.right.equalTo(self.headerView).offset(-20);
        make.bottom.equalTo(self.headerView).offset(-20);
        make.height.mas_equalTo(8);
    }];
    
    [self.progressBarFill mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self.progressBarBG);
        make.width.equalTo(self.progressBarBG).multipliedBy(0.78); // 7800/10000
    }];
    
    // Stats card
    [self.statsCard mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(20);
        make.right.equalTo(self.contentView).offset(-20);
        make.top.equalTo(self.headerView.mas_bottom).offset(20);
        make.height.mas_equalTo(90);
    }];
    
    // Badges section
    [self.badgesSection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(20);
        make.right.equalTo(self.contentView).offset(-20);
        make.top.equalTo(self.statsCard.mas_bottom).offset(16);
    }];
    
    // Games section
    [self.gamesSection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(20);
        make.right.equalTo(self.contentView).offset(-20);
        make.top.equalTo(self.badgesSection.mas_bottom).offset(16);
        make.height.mas_equalTo(90);
    }];
    
    // Account section
    [self.accountSection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(20);
        make.right.equalTo(self.contentView).offset(-20);
        make.top.equalTo(self.gamesSection.mas_bottom).offset(16);
    }];
    
    // Settings section
    UILabel *settingsTitle = [self.contentView viewWithTag:99];
    [settingsTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(20);
        make.top.equalTo(self.accountSection.mas_bottom).offset(24);
    }];
    
    [self.settingsTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(20);
        make.right.equalTo(self.contentView).offset(-20);
        make.top.equalTo(settingsTitle.mas_bottom).offset(12);
        make.height.mas_equalTo(self.settingsItems.count * 56);
        make.bottom.equalTo(self.contentView).offset(-100);
    }];
}

#pragma mark - Helper Methods

- (UIView *)srm_createBadgeViewWithEmoji:(NSString *)emoji label:(NSString *)label {
    UIView *container = [[UIView alloc] init];
    container.backgroundColor = [[UIColor systemGrayColor] colorWithAlphaComponent:0.1];
    container.layer.cornerRadius = 12;
    
    UILabel *emojiLabel = [[UILabel alloc] init];
    emojiLabel.text = emoji;
    emojiLabel.font = [UIFont systemFontOfSize:32];
    emojiLabel.textAlignment = NSTextAlignmentCenter;
    [container addSubview:emojiLabel];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = label;
    titleLabel.font = [UIFont systemFontOfSize:11];
    titleLabel.textColor = SR_COLOR_TEXT_SECONDARY;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 2;
    [container addSubview:titleLabel];
    
    [emojiLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(container);
        make.top.equalTo(container).offset(12);
    }];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(container).inset(4);
        make.top.equalTo(emojiLabel.mas_bottom).offset(4);
        make.bottom.lessThanOrEqualTo(container).offset(-8);
    }];
    
    return container;
}

- (UIView *)srm_createBadgeViewWithIcon:(NSString *)iconName label:(NSString *)label {
    UIView *container = [[UIView alloc] init];
    container.backgroundColor = [[UIColor systemGrayColor] colorWithAlphaComponent:0.1];
    container.layer.cornerRadius = 12;
    
    UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:iconName]];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    [container addSubview:iconView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = label;
    titleLabel.font = [UIFont systemFontOfSize:11];
    titleLabel.textColor = SR_COLOR_TEXT_SECONDARY;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 2;
    [container addSubview:titleLabel];
    
    [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(container);
        make.top.equalTo(container).offset(12);
        make.width.height.mas_equalTo(40);
    }];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(container).inset(4);
        make.top.equalTo(iconView.mas_bottom).offset(4);
        make.bottom.lessThanOrEqualTo(container).offset(-8);
    }];
    
    return container;
}

- (UIView *)srm_createInfoRowWithIcon:(NSString *)iconName label:(NSString *)label value:(NSString *)value {
    return [self srm_createInfoRowWithIcon:iconName label:label value:value valueColor:SR_COLOR_TEXT_SECONDARY];
}

- (UIView *)srm_createInfoRowWithIcon:(NSString *)iconName label:(NSString *)label value:(NSString *)value valueColor:(UIColor *)valueColor {
    UIView *row = [[UIView alloc] init];
    
    UIImageView *iconView = [[UIImageView alloc] init];
    if (@available(iOS 13.0, *)) {
        iconView.image = [self srm_imageWithSystemName:iconName];
    }
    iconView.tintColor = SR_COLOR_PRIMARY;
    [row addSubview:iconView];
    
    UILabel *labelText = [[UILabel alloc] init];
    labelText.text = label;
    labelText.font = [UIFont systemFontOfSize:15];
    labelText.textColor = SR_COLOR_TEXT_PRIMARY;
    [row addSubview:labelText];
    
    UILabel *valueText = [[UILabel alloc] init];
    valueText.text = value;
    valueText.font = [UIFont systemFontOfSize:15];
    valueText.textColor = valueColor;
    [row addSubview:valueText];
    
    [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(row);
        make.centerY.equalTo(row);
        make.width.height.mas_equalTo(24);
    }];
    
    [labelText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(iconView.mas_right).offset(12);
        make.centerY.equalTo(row);
    }];
    
    [valueText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(row);
        make.centerY.equalTo(row);
    }];
    
    return row;
}

- (UIImage *)srm_imageWithSystemName:(NSString *)name API_AVAILABLE(ios(13.0)) {
    return [UIImage systemImageNamed:name];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.settingsItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"SettingsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    }
    
    NSDictionary *item = self.settingsItems[indexPath.row];
    cell.textLabel.text = item[@"title"];
    cell.textLabel.textColor = SR_COLOR_TEXT_PRIMARY;
    
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
        cell.imageView.tintColor = [UIColor colorWithWhite:0.4 alpha:1.0];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *item = self.settingsItems[indexPath.row];
    NSString *title = item[@"title"];
    
    if ([title isEqualToString:@"Clear Cache"]) {
        [self srm_clearCache];
    } else if ([title isEqualToString:@"Privacy Policy"]) {
        [self srm_showPrivacyPolicy];
    } else if ([title isEqualToString:@"Feedback"]) {
        [self srm_showFeedback];
    } else if ([title isEqualToString:@"Share with Friends"]) {
        [self srm_shareApp];
    } else if ([title isEqualToString:@"Rate the App"]) {
        [self srm_rateApp];
    } else if ([title isEqualToString:@"Delete Account"]) {
        [self srm_deleteAccount];
    } else if ([title isEqualToString:@"Logout"]) {
        [self srm_logout];
    }
}

#pragma mark - Actions

- (void)srm_clearCache {
    [LEEAlert alert].config
    .LeeTitle(@"Clear Cache")
    .LeeContent(@"Are you sure you want to clear the cache?")
    .LeeCancelAction(@"Cancel", ^{
    })
    .LeeDestructiveAction(@"Clear", ^{
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        
        [LEEAlert alert].config
        .LeeTitle(@"Success")
        .LeeContent(@"Cache cleared successfully")
        .LeeCancelAction(@"OK", ^{
        })
        .LeeShow();
    })
    .LeeShow();
}

- (void)srm_showPrivacyPolicy {
    UIViewController *privacyVC = [[UIViewController alloc] init];
    privacyVC.title = @"Privacy Policy";
    privacyVC.view.backgroundColor = [UIColor whiteColor];
    privacyVC.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                                     style:UIBarButtonItemStylePlain
                                                                                    target:self
                                                                                    action:@selector(srm_backFromPrivacyPolicy)];
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero];
    [privacyVC.view addSubview:webView];
    
    [webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(privacyVC.view);
    }];
    
    NSURL *url = [NSURL URLWithString:@"https://www.freeprivacypolicy.com/live/14f863a1-28b9-465f-afc1-eca9a78805d6"];
    if (url) {
        [webView loadRequest:[NSURLRequest requestWithURL:url]];
    }
    
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController pushViewController:privacyVC animated:YES];
}

- (void)srm_backFromPrivacyPolicy {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)srm_showFeedback {
    SRFeedbackViewController *feedbackVC = [[SRFeedbackViewController alloc] init];
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController pushViewController:feedbackVC animated:YES];
}

- (void)srm_shareApp {
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

- (void)srm_rateApp {
    // 使用系统原生的评分功能 (iOS 10.3+)
    if (@available(iOS 10.3, *)) {
        [SKStoreReviewController requestReview];
    } else {
        // iOS 10.3 以下，显示提示
        [LEEAlert alert].config
        .LeeTitle(@"Rate StratumRecord")
        .LeeContent(@"If you enjoy using StratumRecord, please take a moment to rate it in the App Store!")
        .LeeAction(@"Rate Now", ^{
            // 这里可以跳转到 App Store 页面
             NSString *appStoreURL = @"itms-apps://itunes.apple.com/app/idXXXXXXXXXX";
             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appStoreURL]];
            
            [LEEAlert alert].config
            .LeeTitle(@"Thank You")
            .LeeContent(@"Thank you for your support!")
            .LeeCancelAction(@"OK", ^{
            })
            .LeeShow();
        })
        .LeeCancelAction(@"Later", ^{
        })
        .LeeShow();
    }
}

- (void)srm_deleteAccount {
    [LEEAlert alert].config
    .LeeTitle(@"Delete Account")
    .LeeContent(@"Are you sure you want to delete your account? This action cannot be undone. All your strategies and data will be permanently deleted.")
    .LeeCancelAction(@"Cancel", ^{
    })
    .LeeDestructiveAction(@"Delete", ^{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MY_STRATEGIES"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PLAZA_STRATEGIES"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"COMMENTS"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[SRUserManager sharedManager] logout];
        [LEEAlert alert].config
        .LeeTitle(@"Account Deleted")
        .LeeContent(@"Your account has been successfully deleted.")
        .LeeCancelAction(@"OK", ^{
            self.tabBarController.selectedIndex = 0;
        })
        .LeeShow();
    })
    .LeeShow();
}

- (void)srm_logout {
    [LEEAlert alert].config
    .LeeTitle(@"Logout")
    .LeeContent(@"Are you sure you want to logout?")
    .LeeCancelAction(@"Cancel", ^{
    })
    .LeeDestructiveAction(@"Logout", ^{
        [[SRUserManager sharedManager] logout];
        
        [LEEAlert alert].config
        .LeeTitle(@"Logged Out")
        .LeeContent(@"You have been successfully logged out.")
        .LeeCancelAction(@"OK", ^{
            self.tabBarController.selectedIndex = 0;
            if ([self.tabBarController isKindOfClass:[SRTabBarController class]]) {
                [(SRTabBarController *)self.tabBarController srm_presentLoginIfNeeded];
            }
        })
        .LeeShow();
    })
    .LeeShow();
}

#pragma mark - User Info

- (void)srm_updateUserInfo {
    SRUser *user = [[SRUserManager sharedManager] currentUser];
    if (!user) return;
    
    // Update username
    self.usernameLabel.text = user.username;
    
    // Update avatar (image or emoji)
    if (user.avatarImageBase64.length > 0) {
        NSData *imageData = [[NSData alloc] initWithBase64EncodedString:user.avatarImageBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
        if (imageData) {
            UIImage *avatarImage = [UIImage imageWithData:imageData];
            self.avatarImageView.image = avatarImage;
            self.avatarImageView.hidden = NO;
            
            // Hide emoji label
            UILabel *avatarEmoji = [self.avatarView.subviews lastObject];
            if ([avatarEmoji isKindOfClass:[UILabel class]]) {
                avatarEmoji.hidden = YES;
            }
        }
    } else {
        self.avatarImageView.hidden = YES;
        
        // Show emoji label
        UILabel *avatarEmoji = [self.avatarView.subviews lastObject];
        if ([avatarEmoji isKindOfClass:[UILabel class]]) {
            avatarEmoji.text = user.avatarEmoji ?: @"🎮";
            avatarEmoji.hidden = NO;
        }
    }
    
    // Update bio
    self.bioLabel.text = user.bio ?: @"Hardcore gamer & strategy enthusiast 🎮";
    
    // Update level badge
    self.levelBadgeLabel.text = [NSString stringWithFormat:@"%ld", (long)user.level];
    
    // Update level label
    self.levelLabel.text = [NSString stringWithFormat:@"Lv.%ld", (long)user.level];
    
    // Update experience
    self.expLabel.text = [NSString stringWithFormat:@"%ld / %ld EXP", (long)user.currentExp, (long)user.maxExp];
    
    // Update progress bar
    CGFloat progress = user.maxExp > 0 ? (CGFloat)user.currentExp / (CGFloat)user.maxExp : 0.0;
    progress = MAX(0.0, MIN(1.0, progress)); // Clamp between 0 and 1
    [self.progressBarFill mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self.progressBarBG);
        make.width.equalTo(self.progressBarBG).multipliedBy(progress);
    }];
    
    // Update stats
    self.strategiesLabel.text = [NSString stringWithFormat:@"%ld", (long)user.strategiesCount];
    self.likesLabel.text = [NSString stringWithFormat:@"%ld", (long)user.likesCount];
    self.commentsLabel.text = [NSString stringWithFormat:@"%ld", (long)user.commentsCount];
    
    // Update member level
    if (self.memberLevelLabel) {
        self.memberLevelLabel.text = user.memberLevel ?: @"Lv.1 Newbie";
    }
}

#pragma mark - Edit User Info

- (void)srm_editUserInfo {
    SRUser *user = [[SRUserManager sharedManager] currentUser];
    if (!user) return;
    
    SREditProfileViewController *editVC = [[SREditProfileViewController alloc] init];
    __weak typeof(self) weakSelf = self;
    editVC.saveCompletion = ^{
        [weakSelf srm_updateUserInfo];
    };
    
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController pushViewController:editVC animated:YES];
}

@end
