//
//  SRReportViewController.m
//  StratumRecord
//

#import "SRReportViewController.h"
#import "SRStrategy.h"
#import "SRConstants.h"
#import <LEEAlert/LEEAlert.h>
#import <Masonry/Masonry.h>

@interface SRReportViewController () <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) SRStrategy *strategy;

@property (nonatomic, strong) UILabel *strategyInfoLabel;
@property (nonatomic, strong) UILabel *typeLabel;
@property (nonatomic, strong) UIStackView *typeStackView;
@property (nonatomic, strong) NSMutableArray<UIButton *> *typeButtons;
@property (nonatomic, assign) NSInteger selectedTypeIndex;

@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UITextView *descriptionTextView;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) UILabel *countLabel;

@property (nonatomic, strong) UILabel *imageLabel;
@property (nonatomic, strong) UIView *imageContainer;
@property (nonatomic, strong) UIImageView *screenshotImageView;
@property (nonatomic, strong) UIButton *addImageButton;
@property (nonatomic, strong) UIButton *removeImageButton;
@property (nonatomic, strong) UIImage *selectedImage;

@property (nonatomic, strong) UIButton *submitButton;

@end

@implementation SRReportViewController

static NSInteger const kSRReportMaxLength = 500;

- (instancetype)initWithStrategy:(SRStrategy *)strategy {
    if (self = [super init]) {
        _strategy = strategy;
        _selectedTypeIndex = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Report Strategy";
    self.view.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.98 alpha:1.0];
    
    [self srm_setupScrollView];
    [self srm_setupUI];
    [self srm_setupConstraints];
    [self srm_setupKeyboardNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Setup Methods

- (void)srm_setupScrollView {
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.showsVerticalScrollIndicator = YES;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    [self.view addSubview:self.scrollView];
    
    self.contentView = [[UIView alloc] init];
    [self.scrollView addSubview:self.contentView];
}

- (void)srm_setupUI {
    // 被举报策略信息
    self.strategyInfoLabel = [[UILabel alloc] init];
    self.strategyInfoLabel.text = [NSString stringWithFormat:@"Reporting: \"%@\"", self.strategy.title];
    self.strategyInfoLabel.font = [UIFont systemFontOfSize:14];
    self.strategyInfoLabel.textColor = SR_COLOR_TEXT_SECONDARY;
    self.strategyInfoLabel.numberOfLines = 2;
    [self.contentView addSubview:self.strategyInfoLabel];
    
    // 举报类型标签
    self.typeLabel = [[UILabel alloc] init];
    self.typeLabel.text = @"Reason for Report";
    self.typeLabel.font = [UIFont boldSystemFontOfSize:16];
    self.typeLabel.textColor = SR_COLOR_TEXT_PRIMARY;
    [self.contentView addSubview:self.typeLabel];
    
    // 举报类型按钮容器 (使用垂直 StackView)
    self.typeStackView = [[UIStackView alloc] init];
    self.typeStackView.axis = UILayoutConstraintAxisVertical;
    self.typeStackView.spacing = 10;
    self.typeStackView.alignment = UIStackViewAlignmentLeading;
    self.typeStackView.distribution = UIStackViewDistributionFill;
    [self.contentView addSubview:self.typeStackView];
    
    // 第一行按钮
    UIStackView *row1 = [[UIStackView alloc] init];
    row1.axis = UILayoutConstraintAxisHorizontal;
    row1.spacing = 10;
    row1.alignment = UIStackViewAlignmentCenter;
    row1.distribution = UIStackViewDistributionFill;
    
    // 第二行按钮
    UIStackView *row2 = [[UIStackView alloc] init];
    row2.axis = UILayoutConstraintAxisHorizontal;
    row2.spacing = 10;
    row2.alignment = UIStackViewAlignmentCenter;
    row2.distribution = UIStackViewDistributionFill;
    
    // 举报类型按钮
    self.typeButtons = [NSMutableArray array];
    NSArray *types = @[@"Spam", @"Inappropriate", @"Misleading", @"Copyright", @"Other"];
    for (NSInteger i = 0; i < types.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:types[i] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        button.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 15);
        button.layer.cornerRadius = 18;
        button.layer.borderWidth = 1.5;
        button.tag = i;
        [button addTarget:self action:@selector(srm_typeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        // 前三个放第一行，后两个放第二行
        if (i < 3) {
            [row1 addArrangedSubview:button];
        } else {
            [row2 addArrangedSubview:button];
        }
        
        [self.typeButtons addObject:button];
    }
    
    [self.typeStackView addArrangedSubview:row1];
    [self.typeStackView addArrangedSubview:row2];
    
    [self srm_updateTypeButtons];
    
    // 详细描述标签
    self.descriptionLabel = [[UILabel alloc] init];
    self.descriptionLabel.text = @"Description";
    self.descriptionLabel.font = [UIFont boldSystemFontOfSize:16];
    self.descriptionLabel.textColor = SR_COLOR_TEXT_PRIMARY;
    [self.contentView addSubview:self.descriptionLabel];
    
    // 描述文本框
    self.descriptionTextView = [[UITextView alloc] init];
    self.descriptionTextView.backgroundColor = [UIColor whiteColor];
    self.descriptionTextView.layer.cornerRadius = 12;
    self.descriptionTextView.layer.borderWidth = 1;
    self.descriptionTextView.layer.borderColor = [UIColor colorWithWhite:0.92 alpha:1.0].CGColor;
    self.descriptionTextView.font = [UIFont systemFontOfSize:15];
    self.descriptionTextView.textContainerInset = UIEdgeInsetsMake(14, 12, 14, 12);
    self.descriptionTextView.delegate = self;
    self.descriptionTextView.returnKeyType = UIReturnKeyDefault;
    [self.contentView addSubview:self.descriptionTextView];
    
    // 占位符
    self.placeholderLabel = [[UILabel alloc] init];
    self.placeholderLabel.text = @"Please provide details about why you're reporting this strategy...";
    self.placeholderLabel.font = [UIFont systemFontOfSize:15];
    self.placeholderLabel.textColor = [UIColor colorWithWhite:0.75 alpha:1.0];
    self.placeholderLabel.numberOfLines = 0;
    [self.descriptionTextView addSubview:self.placeholderLabel];
    
    // 字符计数
    self.countLabel = [[UILabel alloc] init];
    self.countLabel.text = [NSString stringWithFormat:@"0/%ld", (long)kSRReportMaxLength];
    self.countLabel.font = [UIFont systemFontOfSize:13];
    self.countLabel.textColor = SR_COLOR_TEXT_SECONDARY;
    self.countLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:self.countLabel];
    
    // 图片标签
    self.imageLabel = [[UILabel alloc] init];
    self.imageLabel.text = @"Screenshot (Optional)";
    self.imageLabel.font = [UIFont boldSystemFontOfSize:16];
    self.imageLabel.textColor = SR_COLOR_TEXT_PRIMARY;
    [self.contentView addSubview:self.imageLabel];
    
    // 图片容器
    self.imageContainer = [[UIView alloc] init];
    self.imageContainer.backgroundColor = [UIColor whiteColor];
    self.imageContainer.layer.cornerRadius = 12;
    self.imageContainer.layer.borderWidth = 1;
    self.imageContainer.layer.borderColor = [UIColor colorWithWhite:0.92 alpha:1.0].CGColor;
    [self.contentView addSubview:self.imageContainer];
    
    // 图片预览
    self.screenshotImageView = [[UIImageView alloc] init];
    self.screenshotImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.screenshotImageView.clipsToBounds = YES;
    self.screenshotImageView.layer.cornerRadius = 8;
    self.screenshotImageView.hidden = YES;
    [self.imageContainer addSubview:self.screenshotImageView];
    
    // 添加图片按钮
    self.addImageButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.addImageButton setTitle:@"📷 Add Screenshot" forState:UIControlStateNormal];
    self.addImageButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.addImageButton setTitleColor:SR_COLOR_TEXT_SECONDARY forState:UIControlStateNormal];
    [self.addImageButton addTarget:self action:@selector(srm_addImageTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.imageContainer addSubview:self.addImageButton];
    
    // 移除图片按钮
    self.removeImageButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.removeImageButton setTitle:@"✕" forState:UIControlStateNormal];
    self.removeImageButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [self.removeImageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.removeImageButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    self.removeImageButton.layer.cornerRadius = 15;
    self.removeImageButton.hidden = YES;
    [self.removeImageButton addTarget:self action:@selector(srm_removeImageTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.imageContainer addSubview:self.removeImageButton];
    
    // 提交按钮
    self.submitButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.submitButton setTitle:@"Submit Report" forState:UIControlStateNormal];
    self.submitButton.backgroundColor = [UIColor colorWithRed:1.0 green:0.3 blue:0.3 alpha:1.0];
    [self.submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.submitButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    self.submitButton.layer.cornerRadius = 12;
    self.submitButton.layer.shadowColor = [UIColor colorWithRed:1.0 green:0.3 blue:0.3 alpha:1.0].CGColor;
    self.submitButton.layer.shadowOffset = CGSizeMake(0, 4);
    self.submitButton.layer.shadowOpacity = 0.3;
    self.submitButton.layer.shadowRadius = 8;
    [self.submitButton addTarget:self action:@selector(srm_submitReport) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.submitButton];
}

- (void)srm_setupConstraints {
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
    
    [self.strategyInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(20);
        make.left.right.equalTo(self.contentView).inset(20);
    }];
    
    [self.typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.strategyInfoLabel.mas_bottom).offset(20);
        make.left.right.equalTo(self.contentView).inset(20);
    }];
    
    [self.typeStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.typeLabel.mas_bottom).offset(12);
        make.left.equalTo(self.contentView).offset(20);
    }];
    
    // 按钮高度约束
    for (UIButton *button in self.typeButtons) {
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(36);
        }];
    }
    
    [self.descriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.typeStackView.mas_bottom).offset(24);
        make.left.right.equalTo(self.contentView).inset(20);
    }];
    
    [self.descriptionTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.descriptionLabel.mas_bottom).offset(12);
        make.left.right.equalTo(self.contentView).inset(20);
        make.height.mas_equalTo(150);
    }];
    
    [self.placeholderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.descriptionTextView).offset(18);
        make.left.equalTo(self.descriptionTextView).offset(16);
        make.right.equalTo(self.descriptionTextView).offset(-16);
    }];
    
    [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.descriptionTextView.mas_bottom).offset(8);
        make.right.equalTo(self.descriptionTextView);
    }];
    
    [self.imageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.countLabel.mas_bottom).offset(20);
        make.left.right.equalTo(self.contentView).inset(20);
    }];
    
    [self.imageContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imageLabel.mas_bottom).offset(12);
        make.left.right.equalTo(self.contentView).inset(20);
        make.height.mas_equalTo(150);
    }];
    
    [self.addImageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.imageContainer);
    }];
    
    [self.screenshotImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.imageContainer).inset(10);
    }];
    
    [self.removeImageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imageContainer).offset(8);
        make.right.equalTo(self.imageContainer).offset(-8);
        make.width.height.mas_equalTo(30);
    }];
    
    [self.submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imageContainer.mas_bottom).offset(32);
        make.left.right.equalTo(self.contentView).inset(20);
        make.height.mas_equalTo(52);
        make.bottom.equalTo(self.contentView).offset(-40);
    }];
}

- (void)srm_setupKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(srm_keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(srm_keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

#pragma mark - Type Buttons

- (void)srm_typeButtonTapped:(UIButton *)sender {
    if (self.selectedTypeIndex != sender.tag) {
        self.selectedTypeIndex = sender.tag;
        [self srm_updateTypeButtons];
    }
}

- (void)srm_updateTypeButtons {
    for (UIButton *button in self.typeButtons) {
        BOOL isSelected = (button.tag == self.selectedTypeIndex);
        if (isSelected) {
            button.backgroundColor = [UIColor colorWithRed:1.0 green:0.3 blue:0.3 alpha:1.0];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            button.layer.borderColor = [UIColor colorWithRed:1.0 green:0.3 blue:0.3 alpha:1.0].CGColor;
        } else {
            button.backgroundColor = [UIColor whiteColor];
            [button setTitleColor:SR_COLOR_TEXT_SECONDARY forState:UIControlStateNormal];
            button.layer.borderColor = [UIColor colorWithWhite:0.88 alpha:1.0].CGColor;
        }
    }
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length > kSRReportMaxLength) {
        textView.text = [textView.text substringToIndex:kSRReportMaxLength];
    }
    self.placeholderLabel.hidden = (textView.text.length > 0);
    self.countLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)textView.text.length, (long)kSRReportMaxLength];
    
    // 更新计数标签颜色
    if (textView.text.length >= kSRReportMaxLength) {
        self.countLabel.textColor = [UIColor colorWithRed:1.0 green:0.3 blue:0.3 alpha:1.0];
    } else {
        self.countLabel.textColor = SR_COLOR_TEXT_SECONDARY;
    }
}

#pragma mark - Keyboard Handling

- (void)srm_keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardFrame.size.height;
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
        self.scrollView.scrollIndicatorInsets = self.scrollView.contentInset;
    }];
}

- (void)srm_keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        self.scrollView.contentInset = UIEdgeInsetsZero;
        self.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
    }];
}

#pragma mark - Image Handling

- (void)srm_addImageTapped {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)srm_removeImageTapped {
    self.selectedImage = nil;
    self.screenshotImageView.image = nil;
    self.screenshotImageView.hidden = YES;
    self.removeImageButton.hidden = YES;
    self.addImageButton.hidden = NO;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *image = info[UIImagePickerControllerEditedImage] ?: info[UIImagePickerControllerOriginalImage];
    if (image) {
        self.selectedImage = image;
        self.screenshotImageView.image = image;
        self.screenshotImageView.hidden = NO;
        self.removeImageButton.hidden = NO;
        self.addImageButton.hidden = YES;
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Actions

- (void)srm_submitReport {
    NSString *description = [self.descriptionTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (description.length == 0) {
        [LEEAlert alert].config
        .LeeTitle(@"Missing Description")
        .LeeContent(@"Please provide a description of the issue")
        .LeeAddAction(^(LEEAction *action) {
            action.type = LEEActionTypeCancel;
            action.title = @"OK";
        })
        .LeeShow();
        return;
    }
    
    if (description.length < 10) {
        [LEEAlert alert].config
        .LeeTitle(@"Description Too Short")
        .LeeContent(@"Please provide more details (at least 10 characters)")
        .LeeAddAction(^(LEEAction *action) {
            action.type = LEEActionTypeCancel;
            action.title = @"OK";
        })
        .LeeShow();
        return;
    }
    
    // 显示加载动画
    [LEEAlert actionsheet].config
    .LeeTitle(@"Submitting Report...")
    .LeeShow();
    
    // 模拟网络请求
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [LEEAlert closeWithCompletionBlock:^{
            // 获取举报类型
            NSArray *types = @[@"Spam", @"Inappropriate", @"Misleading", @"Copyright", @"Other"];
            NSString *typeString = types[self.selectedTypeIndex];
            
            NSLog(@"🚨 Report Type: %@", typeString);
            NSLog(@"🚨 Strategy: %@", self.strategy.title);
            NSLog(@"🚨 Description: %@", description);
            if (self.selectedImage) {
                NSData *imageData = UIImageJPEGRepresentation(self.selectedImage, 0.8);
                NSLog(@"🚨 Screenshot: %ld bytes", (long)imageData.length);
            } else {
                NSLog(@"🚨 Screenshot: None");
            }
            
            [LEEAlert alert].config
            .LeeTitle(@"Report Submitted")
            .LeeContent(@"Thank you for your report. We will review this strategy and take appropriate action if necessary.")
            .LeeAddAction(^(LEEAction *action) {
                action.type = LEEActionTypeDefault;
                action.title = @"Done";
                action.clickBlock = ^{
                    [self.navigationController popViewControllerAnimated:YES];
                };
            })
            .LeeShow();
        }];
    });
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
