//
//  SREditStrategyViewController.m
//  StratumRecord
//

#import "SREditStrategyViewController.h"
#import "SRConstants.h"
#import "SRDataManager.h"
#import "SRAnalyticsManager.h"
#import <Masonry/Masonry.h>

@interface SREditStrategyViewController () <UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate>

@property (nonatomic, strong) SRStrategy *strategy;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UILabel *gameLabel;
@property (nonatomic, strong) UIButton *gamePickerButton;
@property (nonatomic, strong) UITextField *customGameField;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextField *titleField;

@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UITextView *contentTextView;
@property (nonatomic, strong) UILabel *contentPlaceholder;

@property (nonatomic, strong) UILabel *importanceLabel;
@property (nonatomic, strong) UIButton *highButton;
@property (nonatomic, strong) UIButton *mediumButton;
@property (nonatomic, strong) UIButton *lowButton;

@property (nonatomic, strong) UIPickerView *gamePicker;
@property (nonatomic, strong) NSArray<NSString *> *games;
@property (nonatomic, assign) NSInteger selectedImportance;
@property (nonatomic, strong) NSString *selectedGame;
@property (nonatomic, strong) NSString *selectedGameIcon;

@end

@implementation SREditStrategyViewController

- (instancetype)initWithStrategy:(SRStrategy *)strategy {
    if (self = [super init]) {
        _strategy = strategy ?: [[SRStrategy alloc] init];
        _selectedImportance = _strategy.importance;
        _selectedGame = _strategy.gameName;
        _selectedGameIcon = _strategy.gameIcon;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = SR_COLOR_BACKGROUND;
    self.games = SR_PREDEFINED_GAMES;
    
    // 设置背景图片
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main"]];
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    backgroundImageView.frame = self.view.bounds;
    backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    UIView *coverView = [[UIView alloc] initWithFrame:self.view.bounds];
    coverView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    [self.view addSubview:backgroundImageView];
    [self.view sendSubviewToBack:backgroundImageView];
    [self.view addSubview:coverView];
    
    
    [self srm_setupNavigationBar];
    [self srm_setupUI];
    [self srm_prefillData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSString *pageName = self.isPublishMode ? @"PublishStrategy_Page" : @"EditStrategy_Page";
    [[SRAnalyticsManager sharedManager] trackPageViewBegin:pageName];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSString *pageName = self.isPublishMode ? @"PublishStrategy_Page" : @"EditStrategy_Page";
    [[SRAnalyticsManager sharedManager] trackPageViewEnd:pageName];
}

- (void)srm_setupNavigationBar {
    if (self.isPublishMode) {
        self.title = @"Publish Strategy";
    } else {
        self.title = self.strategy.title.length > 0 ? @"Edit Strategy" : @"New Strategy";
    }
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithImage:[self srm_imageWithSystemName:@"xmark"] 
                                                                     style:UIBarButtonItemStylePlain 
                                                                    target:self 
                                                                    action:@selector(srm_closeTapped)];
    self.navigationItem.leftBarButtonItem = closeButton;
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:self.isPublishMode ? @"Publish" : @"Save"
                                                                   style:UIBarButtonItemStyleDone 
                                                                  target:self 
                                                                  action:@selector(srm_saveTapped)];
    saveButton.tintColor = SR_COLOR_PRIMARY;
    self.navigationItem.rightBarButtonItem = saveButton;
    
    // Add delete button if editing existing strategy
    if (self.strategy.title.length > 0 && !self.isPublishMode) {
        UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithImage:[self srm_imageWithSystemName:@"trash"]
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(srm_deleteTapped)];
        deleteButton.tintColor = SR_COLOR_HIGH;
        self.navigationItem.rightBarButtonItems = @[saveButton, deleteButton];
    }
}

- (void)srm_setupUI {
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.scrollView];
    
    self.contentView = [[UIView alloc] init];
    [self.scrollView addSubview:self.contentView];
    
    // Game section
    self.gameLabel = [self srm_createSectionLabel:@"Game"];
    [self.contentView addSubview:self.gameLabel];
    
    self.gamePickerButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.gamePickerButton setTitle:@"🎮 Select a game" forState:UIControlStateNormal];
    self.gamePickerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.gamePickerButton.backgroundColor = [UIColor whiteColor];
    self.gamePickerButton.layer.cornerRadius = 8;
    self.gamePickerButton.contentEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 16);
    self.gamePickerButton.tintColor = SR_COLOR_TEXT_SECONDARY;
    self.gamePickerButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.gamePickerButton addTarget:self action:@selector(srm_gamePickerTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.gamePickerButton];
    
    self.customGameField = [self srm_createTextField:@"Or enter custom game name"];
    [self.contentView addSubview:self.customGameField];
    
    // Title section
    self.titleLabel = [self srm_createSectionLabel:@"Title"];
    [self.contentView addSubview:self.titleLabel];
    
    self.titleField = [self srm_createTextField:@"Enter strategy title"];
    [self.contentView addSubview:self.titleField];
    
    // Content section
    self.contentLabel = [self srm_createSectionLabel:@"Strategy Content"];
    [self.contentView addSubview:self.contentLabel];
    
    self.contentTextView = [[UITextView alloc] init];
    self.contentTextView.font = [UIFont systemFontOfSize:16];
    self.contentTextView.textColor = SR_COLOR_TEXT_PRIMARY;
    self.contentTextView.backgroundColor = [UIColor whiteColor];
    self.contentTextView.layer.cornerRadius = 8;
    self.contentTextView.textContainerInset = UIEdgeInsetsMake(12, 12, 12, 12);
    self.contentTextView.delegate = self;
    [self.contentView addSubview:self.contentTextView];
    
    self.contentPlaceholder = [[UILabel alloc] init];
    self.contentPlaceholder.text = self.isPublishMode ? @"Share your strategy with the community..." : @"Describe your strategy in detail...";
    self.contentPlaceholder.font = [UIFont systemFontOfSize:16];
    self.contentPlaceholder.textColor = SR_COLOR_TEXT_SECONDARY;
    self.contentPlaceholder.numberOfLines = 0;
    [self.contentTextView addSubview:self.contentPlaceholder];
    
    // Importance section
    self.importanceLabel = [self srm_createSectionLabel:@"Importance Level"];
    [self.contentView addSubview:self.importanceLabel];
    
    UIStackView *importanceStack = [[UIStackView alloc] init];
    importanceStack.axis = UILayoutConstraintAxisHorizontal;
    importanceStack.distribution = UIStackViewDistributionFillEqually;
    importanceStack.spacing = 12;
    [self.contentView addSubview:importanceStack];
    
    self.highButton = [self srm_createImportanceButton:@"High" importance:SRImportanceLevelHigh];
    self.mediumButton = [self srm_createImportanceButton:@"Medium" importance:SRImportanceLevelMedium];
    self.lowButton = [self srm_createImportanceButton:@"Low" importance:SRImportanceLevelLow];
    
    [importanceStack addArrangedSubview:self.highButton];
    [importanceStack addArrangedSubview:self.mediumButton];
    [importanceStack addArrangedSubview:self.lowButton];
    
    // Layout
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
    
    [self.gameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(24);
        make.top.equalTo(self.contentView).offset(24);
    }];
    
    [self.gamePickerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView).inset(24);
        make.top.equalTo(self.gameLabel.mas_bottom).offset(12);
        make.height.mas_equalTo(50);
    }];
    
    [self.customGameField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.gamePickerButton);
        make.top.equalTo(self.gamePickerButton.mas_bottom).offset(12);
        make.height.mas_equalTo(50);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.gameLabel);
        make.top.equalTo(self.customGameField.mas_bottom).offset(24);
    }];
    
    [self.titleField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.gamePickerButton);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(12);
        make.height.mas_equalTo(50);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.gameLabel);
        make.top.equalTo(self.titleField.mas_bottom).offset(24);
    }];
    
    [self.contentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.gamePickerButton);
        make.top.equalTo(self.contentLabel.mas_bottom).offset(12);
        make.height.mas_equalTo(200);
    }];
    
    [self.contentPlaceholder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.contentTextView).offset(16);
        make.right.equalTo(self.contentTextView).offset(-16);
    }];
    
    [self.importanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.gameLabel);
        make.top.equalTo(self.contentTextView.mas_bottom).offset(24);
    }];
    
    [importanceStack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.gamePickerButton);
        make.top.equalTo(self.importanceLabel.mas_bottom).offset(12);
        make.height.mas_equalTo(50);
        make.bottom.equalTo(self.contentView).offset(-40);
    }];
    
    [self srm_updateImportanceButtons];
}

- (UILabel *)srm_createSectionLabel:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont boldSystemFontOfSize:17];
    label.textColor = SR_COLOR_TEXT_PRIMARY;
    return label;
}

- (UITextField *)srm_createTextField:(NSString *)placeholder {
    UITextField *field = [[UITextField alloc] init];
    field.placeholder = placeholder;
    field.font = [UIFont systemFontOfSize:16];
    field.backgroundColor = [UIColor whiteColor];
    field.layer.cornerRadius = 8;
    field.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, 0)];
    field.leftViewMode = UITextFieldViewModeAlways;
    return field;
}

- (UIButton *)srm_createImportanceButton:(NSString *)title importance:(SRImportanceLevel)importance {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    button.layer.cornerRadius = 8;
    button.layer.borderWidth = 2;
    button.tag = importance;
    [button addTarget:self action:@selector(srm_importanceTapped:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)srm_prefillData {
    if (self.strategy.gameName.length > 0) {
        if ([self.games containsObject:self.strategy.gameName]) {
            NSString *icon = self.strategy.gameIcon.length > 0 ? self.strategy.gameIcon : [SRConstants iconForGameName:self.strategy.gameName];
            [self.gamePickerButton setTitle:self.strategy.gameName forState:UIControlStateNormal];
            self.selectedGame = self.strategy.gameName;
            self.selectedGameIcon = icon;
        } else {
            self.customGameField.text = self.strategy.gameName;
            if (self.strategy.gameIcon.length > 0) {
                self.selectedGameIcon = self.strategy.gameIcon;
            }
        }
    }
    
    self.titleField.text = self.strategy.title;
    self.contentTextView.text = self.strategy.content;
    self.contentPlaceholder.hidden = self.strategy.content.length > 0;
}

- (void)srm_updateImportanceButtons {
    NSArray *buttons = @[self.highButton, self.mediumButton, self.lowButton];
    for (UIButton *button in buttons) {
        SRImportanceLevel importance = (SRImportanceLevel)button.tag;
        UIColor *color = [SRConstants colorForImportance:importance];
        
        if (importance == self.selectedImportance) {
            button.backgroundColor = color;
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            button.layer.borderColor = color.CGColor;
        } else {
            button.backgroundColor = [UIColor whiteColor];
            [button setTitleColor:color forState:UIControlStateNormal];
            button.layer.borderColor = [color colorWithAlphaComponent:0.3].CGColor;
        }
    }
}

#pragma mark - Actions

- (void)srm_gamePickerTapped {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select Game"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (NSString *game in self.games) {
        NSString *icon = [SRConstants iconForGameName:game];
        [alert addAction:[UIAlertAction actionWithTitle:game
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * _Nonnull action) {
            [self.gamePickerButton setTitle:game forState:UIControlStateNormal];
            self.selectedGame = game;
            self.selectedGameIcon = icon;
            self.customGameField.text = @"";
        }]];
    }
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    if (alert.popoverPresentationController) {
        alert.popoverPresentationController.sourceView = self.gamePickerButton;
        alert.popoverPresentationController.sourceRect = self.gamePickerButton.bounds;
    }
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)srm_importanceTapped:(UIButton *)button {
    self.selectedImportance = (SRImportanceLevel)button.tag;
    [self srm_updateImportanceButtons];
}

- (void)srm_closeTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)srm_saveTapped {
    // Validate
    NSString *gameName = self.customGameField.text.length > 0 ? self.customGameField.text : self.selectedGame;
    if (gameName.length == 0 || self.titleField.text.length == 0 || self.contentTextView.text.length == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Missing Information"
                                                                       message:@"Please fill in all fields"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    // Update strategy
    self.strategy.gameName = gameName;
    self.strategy.gameIcon = self.selectedGameIcon.length > 0 ? self.selectedGameIcon : [SRConstants iconForGameName:gameName];
    self.strategy.title = self.titleField.text;
    self.strategy.content = self.contentTextView.text;
    self.strategy.importance = self.selectedImportance;
    
    if (self.saveCompletion) {
        self.saveCompletion(self.strategy);
    }
    
    // Show review notice for publish mode
    if (self.isPublishMode) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Strategy Submitted"
                                                                       message:@"Your strategy has been submitted successfully. The platform will review it within 24 hours. It will not be displayed in the list until the review is approved."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)srm_deleteTapped {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete Strategy"
                                                                   message:@"Are you sure you want to delete this strategy?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Delete"
                                             style:UIAlertActionStyleDestructive
                                           handler:^(UIAlertAction * _Nonnull action) {
        if (self.deleteCompletion) {
            self.deleteCompletion(self.strategy.strategyId);
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    self.contentPlaceholder.hidden = textView.text.length > 0;
}

#pragma mark - Helpers

- (UIImage *)srm_imageWithSystemName:(NSString *)systemName {
    if (@available(iOS 13.0, *)) {
        return [UIImage systemImageNamed:systemName];
    }
    return nil;
}

@end
