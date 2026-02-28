//
//  SRLoginViewController.m
//  StratumRecord
//

#import "SRLoginViewController.h"
#import "SRUserManager.h"
#import "SRConstants.h"
#import "SRAnalyticsManager.h"
#import <LEEAlert/LEEAlert.h>
#import <Masonry/Masonry.h>

@interface SRLoginViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;

@property (nonatomic, strong) UIView *emailContainer;
@property (nonatomic, strong) UITextField *emailTextField;

@property (nonatomic, strong) UIView *codeContainer;
@property (nonatomic, strong) UITextField *codeTextField;
@property (nonatomic, strong) UIButton *sendCodeButton;

@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UILabel *hintLabel;

@property (nonatomic, assign) NSInteger countdown;
@property (nonatomic, strong) NSTimer *countdownTimer;

@end

@implementation SRLoginViewController

static NSString * const kSRSkipLoginOnceKey = @"SR_SKIP_LOGIN_ONCE";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = SR_COLOR_BACKGROUND;
    
    // Background image
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main"]];
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    backgroundImageView.frame = self.view.bounds;
    backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:backgroundImageView];
    [self.view sendSubviewToBack:backgroundImageView];
    
    // White overlay mask above background image
    UIView *overlayView = [[UIView alloc] init];
    overlayView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    overlayView.userInteractionEnabled = NO;
    [self.view addSubview:overlayView];
    [overlayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self srm_setupUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[SRAnalyticsManager sharedManager] trackPageViewBegin:@"Login_Page"];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[SRAnalyticsManager sharedManager] trackPageViewEnd:@"Login_Page"];
}

- (void)srm_setupUI {
    self.closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    if (@available(iOS 13.0, *)) {
        [self.closeButton setImage:[UIImage systemImageNamed:@"xmark.circle.fill"] forState:UIControlStateNormal];
    } else {
        [self.closeButton setTitle:@"Close" forState:UIControlStateNormal];
    }
    self.closeButton.tintColor = [UIColor colorWithWhite:0.35 alpha:1.0];
    [self.closeButton addTarget:self action:@selector(srm_closeTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.closeButton];
    
    // Scroll view
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:self.scrollView];
    [self.view bringSubviewToFront:self.closeButton];
    
    self.contentView = [[UIView alloc] init];
    [self.scrollView addSubview:self.contentView];
    
    // Logo
    self.logoImageView = [[UIImageView alloc] init];
    self.logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.logoImageView.backgroundColor = SR_COLOR_PRIMARY;
    self.logoImageView.layer.cornerRadius = 50;
    self.logoImageView.clipsToBounds = YES;
    [self.contentView addSubview:self.logoImageView];
    
    // Add emoji to logo
    UILabel *emojiLabel = [[UILabel alloc] init];
    emojiLabel.text = @"🎮";
    emojiLabel.font = [UIFont systemFontOfSize:50];
    emojiLabel.textAlignment = NSTextAlignmentCenter;
    [self.logoImageView addSubview:emojiLabel];
    
    // Title
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = @"Welcome to StratumRecord";
    self.titleLabel.font = [UIFont boldSystemFontOfSize:28];
    self.titleLabel.textColor = SR_COLOR_TEXT_PRIMARY;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.titleLabel];
    
    // Subtitle
    self.subtitleLabel = [[UILabel alloc] init];
    self.subtitleLabel.text = @"Your Game Strategy Companion";
    self.subtitleLabel.font = [UIFont systemFontOfSize:16];
    self.subtitleLabel.textColor = SR_COLOR_TEXT_SECONDARY;
    self.subtitleLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.subtitleLabel];
    
    // Email container
    self.emailContainer = [[UIView alloc] init];
    self.emailContainer.backgroundColor = [UIColor whiteColor];
    self.emailContainer.layer.cornerRadius = 12;
    [self.contentView addSubview:self.emailContainer];
    
    UIImageView *emailIcon = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"envelope"]];
    emailIcon.tintColor = SR_COLOR_TEXT_SECONDARY;
    [self.emailContainer addSubview:emailIcon];
    
    self.emailTextField = [[UITextField alloc] init];
    self.emailTextField.placeholder = @"Email address";
    self.emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    self.emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.emailTextField.returnKeyType = UIReturnKeyNext;
    self.emailTextField.delegate = self;
    [self.emailContainer addSubview:self.emailTextField];
    
    // Code container
    self.codeContainer = [[UIView alloc] init];
    self.codeContainer.backgroundColor = [UIColor whiteColor];
    self.codeContainer.layer.cornerRadius = 12;
    [self.contentView addSubview:self.codeContainer];
    
    UIImageView *codeIcon = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"lock.shield"]];
    codeIcon.tintColor = SR_COLOR_TEXT_SECONDARY;
    [self.codeContainer addSubview:codeIcon];
    
    self.codeTextField = [[UITextField alloc] init];
    self.codeTextField.placeholder = @"Verification code";
    self.codeTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.codeTextField.returnKeyType = UIReturnKeyDone;
    self.codeTextField.delegate = self;
    [self.codeContainer addSubview:self.codeTextField];
    
    self.sendCodeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.sendCodeButton setTitle:@"Send Code" forState:UIControlStateNormal];
    self.sendCodeButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.sendCodeButton setTitleColor:SR_COLOR_PRIMARY forState:UIControlStateNormal];
    [self.sendCodeButton addTarget:self action:@selector(srm_sendCodeTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.codeContainer addSubview:self.sendCodeButton];
    
    // Login button
    self.loginButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.loginButton setTitle:@"Login / Register" forState:UIControlStateNormal];
    self.loginButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.loginButton.backgroundColor = SR_COLOR_PRIMARY;
    self.loginButton.layer.cornerRadius = 12;
    [self.loginButton addTarget:self action:@selector(srm_loginTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.loginButton];
    
    // Hint label
    self.hintLabel = [[UILabel alloc] init];
    self.hintLabel.text = @"First time login will automatically create an account";
    self.hintLabel.font = [UIFont systemFontOfSize:13];
    self.hintLabel.textColor = SR_COLOR_TEXT_SECONDARY;
    self.hintLabel.textAlignment = NSTextAlignmentCenter;
    self.hintLabel.numberOfLines = 0;
    [self.contentView addSubview:self.hintLabel];
    
    [self srm_setupConstraints];
}

- (void)srm_setupConstraints {
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(8);
        make.right.equalTo(self.view).offset(-16);
        make.width.height.mas_equalTo(30);
    }];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
    
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(80);
        make.width.height.mas_equalTo(100);
    }];
    
    [[self.logoImageView.subviews firstObject] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.logoImageView);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(self.logoImageView.mas_bottom).offset(24);
        make.left.right.equalTo(self.contentView).inset(40);
    }];
    
    [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(8);
        make.left.right.equalTo(self.contentView).inset(40);
    }];
    
    [self.emailContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView).inset(40);
        make.top.equalTo(self.subtitleLabel.mas_bottom).offset(40);
        make.height.mas_equalTo(56);
    }];
    
    [[self.emailContainer.subviews firstObject] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.emailContainer).offset(16);
        make.centerY.equalTo(self.emailContainer);
        make.width.height.mas_equalTo(20);
    }];
    
    [self.emailTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo([[self.emailContainer.subviews firstObject] mas_right]).offset(12);
        make.right.equalTo(self.emailContainer).offset(-16);
        make.centerY.equalTo(self.emailContainer);
    }];
    
    [self.codeContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView).inset(40);
        make.top.equalTo(self.emailContainer.mas_bottom).offset(16);
        make.height.mas_equalTo(56);
    }];
    
    [[self.codeContainer.subviews firstObject] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.codeContainer).offset(16);
        make.centerY.equalTo(self.codeContainer);
        make.width.height.mas_equalTo(20);
    }];
    
    [self.sendCodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.codeContainer).offset(-16);
        make.centerY.equalTo(self.codeContainer);
        make.width.mas_equalTo(90);
    }];
    
    [self.codeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo([[self.codeContainer.subviews firstObject] mas_right]).offset(12);
        make.right.equalTo(self.sendCodeButton.mas_left).offset(-12);
        make.centerY.equalTo(self.codeContainer);
    }];
    
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView).inset(40);
        make.top.equalTo(self.codeContainer.mas_bottom).offset(32);
        make.height.mas_equalTo(56);
    }];
    
    [self.hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(self.loginButton.mas_bottom).offset(16);
        make.left.right.equalTo(self.contentView).inset(40);
        make.bottom.equalTo(self.contentView).offset(-40);
    }];
}

#pragma mark - Actions

- (void)srm_closeTapped {
    __weak UIViewController *presentingVC = self.presentingViewController;
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSRSkipLoginOnceKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self dismissViewControllerAnimated:YES completion:^{
        UITabBarController *tabBarController = presentingVC.tabBarController;
        if (tabBarController) {
            tabBarController.selectedIndex = 0;
        }
    }];
}

- (void)srm_sendCodeTapped {
    NSString *email = self.emailTextField.text;
    
    // Validate email
    if (email.length == 0) {
        [self srm_showAlert:@"Error" message:@"Please enter your email address"];
        return;
    }
    
    if (![self srm_isValidEmail:email]) {
        [self srm_showAlert:@"Error" message:@"Please enter a valid email address"];
        return;
    }
    
    // Disable button
    self.sendCodeButton.enabled = NO;
    
    [[SRUserManager sharedManager] sendVerificationCodeToEmail:email completion:^(BOOL success, NSString *message) {
        if (success) {
            [self srm_showAlert:@"Success" message:message];
            [self srm_startCountdown];
        } else {
            [self srm_showAlert:@"Error" message:message];
            self.sendCodeButton.enabled = YES;
        }
    }];
}

- (void)srm_loginTapped {
    NSString *email = self.emailTextField.text;
    NSString *code = self.codeTextField.text;
    
    // Validate inputs
    if (email.length == 0 || code.length == 0) {
        [self srm_showAlert:@"Error" message:@"Please fill in all fields"];
        return;
    }
    
    if (![self srm_isValidEmail:email]) {
        [self srm_showAlert:@"Error" message:@"Please enter a valid email address"];
        return;
    }
    
    // Verify code
    if (![[SRUserManager sharedManager] verifyCode:code forEmail:email]) {
        [self srm_showAlert:@"Error" message:@"Invalid verification code"];
        return;
    }
    
    // Login/Register
    [[SRUserManager sharedManager] loginWithEmail:email completion:^(BOOL success, NSString *message) {
        if (success) {
            [self srm_showAlert:@"Success" message:message];
            
            // Dismiss after 1 second
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        } else {
            [self srm_showAlert:@"Error" message:message];
        }
    }];
}

- (void)srm_startCountdown {
    self.countdown = 60;
    [self.sendCodeButton setTitle:[NSString stringWithFormat:@"%ld s", (long)self.countdown] forState:UIControlStateNormal];
    
    self.countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        self.countdown--;
        
        if (self.countdown > 0) {
            [self.sendCodeButton setTitle:[NSString stringWithFormat:@"%ld s", (long)self.countdown] forState:UIControlStateNormal];
        } else {
            [timer invalidate];
            self.countdownTimer = nil;
            [self.sendCodeButton setTitle:@"Send Code" forState:UIControlStateNormal];
            self.sendCodeButton.enabled = YES;
        }
    }];
}

#pragma mark - Helpers

- (BOOL)srm_isValidEmail:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}";
    NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailPredicate evaluateWithObject:email];
}

- (void)srm_showAlert:(NSString *)title message:(NSString *)message {
    [LEEAlert alert].config
    .LeeTitle(title)
    .LeeContent(message)
    .LeeCancelAction(@"OK", ^{
    })
    .LeeShow();
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailTextField) {
        [self.codeTextField becomeFirstResponder];
    } else if (textField == self.codeTextField) {
        [textField resignFirstResponder];
        [self srm_loginTapped];
    }
    return YES;
}

- (void)dealloc {
    [self.countdownTimer invalidate];
}

@end
