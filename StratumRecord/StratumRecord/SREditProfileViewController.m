//
//  SREditProfileViewController.m
//  StratumRecord
//

#import "SREditProfileViewController.h"
#import "SRConstants.h"
#import "SRUserManager.h"
#import "SRUser.h"
#import <Masonry/Masonry.h>
#import <LEEAlert/LEEAlert.h>

@interface SREditProfileViewController () <UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UILabel *avatarLabel;
@property (nonatomic, strong) UIView *avatarContainer;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *avatarEmojiLabel;
@property (nonatomic, strong) UIButton *changeAvatarButton;

@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UITextField *usernameField;

@property (nonatomic, strong) UILabel *bioLabel;
@property (nonatomic, strong) UITextView *bioTextView;
@property (nonatomic, strong) UILabel *bioPlaceholder;

@property (nonatomic, strong) SRUser *user;

@end

@implementation SREditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = SR_COLOR_BACKGROUND;
    self.user = [[SRUserManager sharedManager] currentUser];
    
    // 设置背景图片
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main"]];
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    backgroundImageView.frame = self.view.bounds;
    backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    UIView *coverView = [[UIView alloc] initWithFrame:self.view.bounds];
    coverView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.95];
    [self.view addSubview:backgroundImageView];
    [self.view sendSubviewToBack:backgroundImageView];
    [self.view addSubview:coverView];
    
    [self srm_setupNavigationBar];
    [self srm_setupUI];
    [self srm_loadData];
}

- (void)srm_setupNavigationBar {
    self.title = @"Edit Profile";
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(srm_cancelTapped)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(srm_saveTapped)];
    saveButton.tintColor = SR_COLOR_PRIMARY;
    self.navigationItem.rightBarButtonItem = saveButton;
}

- (void)srm_setupUI {
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:self.scrollView];
    
    self.contentView = [[UIView alloc] init];
    [self.scrollView addSubview:self.contentView];
    
    // Avatar section
    self.avatarLabel = [self srm_createSectionLabel:@"Avatar"];
    [self.contentView addSubview:self.avatarLabel];
    
    self.avatarContainer = [[UIView alloc] init];
    self.avatarContainer.backgroundColor = [UIColor whiteColor];
    self.avatarContainer.layer.cornerRadius = 12;
    [self.contentView addSubview:self.avatarContainer];
    
    // Avatar ImageView (for uploaded photos)
    self.avatarImageView = [[UIImageView alloc] init];
    self.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.layer.cornerRadius = 50;
    self.avatarImageView.layer.borderWidth = 3;
    self.avatarImageView.layer.borderColor = SR_COLOR_PRIMARY.CGColor;
    self.avatarImageView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1];
    self.avatarImageView.hidden = YES;
    [self.avatarContainer addSubview:self.avatarImageView];
    
    self.avatarEmojiLabel = [[UILabel alloc] init];
    self.avatarEmojiLabel.text = @"🎮";
    self.avatarEmojiLabel.font = [UIFont systemFontOfSize:60];
    self.avatarEmojiLabel.textAlignment = NSTextAlignmentCenter;
    [self.avatarContainer addSubview:self.avatarEmojiLabel];
    
    self.changeAvatarButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.changeAvatarButton setTitle:@"Change Avatar" forState:UIControlStateNormal];
    self.changeAvatarButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.changeAvatarButton setTitleColor:SR_COLOR_PRIMARY forState:UIControlStateNormal];
    [self.changeAvatarButton addTarget:self action:@selector(srm_changeAvatarTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.avatarContainer addSubview:self.changeAvatarButton];
    
    // Username section
    self.usernameLabel = [self srm_createSectionLabel:@"Username"];
    [self.contentView addSubview:self.usernameLabel];
    
    self.usernameField = [self srm_createTextField:@"Enter your username"];
    [self.contentView addSubview:self.usernameField];
    
    // Bio section
    self.bioLabel = [self srm_createSectionLabel:@"Bio"];
    [self.contentView addSubview:self.bioLabel];
    
    self.bioTextView = [[UITextView alloc] init];
    self.bioTextView.font = [UIFont systemFontOfSize:16];
    self.bioTextView.textColor = SR_COLOR_TEXT_PRIMARY;
    self.bioTextView.backgroundColor = [UIColor whiteColor];
    self.bioTextView.layer.cornerRadius = 8;
    self.bioTextView.textContainerInset = UIEdgeInsetsMake(12, 12, 12, 12);
    self.bioTextView.delegate = self;
    [self.contentView addSubview:self.bioTextView];
    
    self.bioPlaceholder = [[UILabel alloc] init];
    self.bioPlaceholder.text = @"Tell us about yourself...";
    self.bioPlaceholder.font = [UIFont systemFontOfSize:16];
    self.bioPlaceholder.textColor = SR_COLOR_TEXT_SECONDARY;
    self.bioPlaceholder.numberOfLines = 0;
    [self.bioTextView addSubview:self.bioPlaceholder];
    
    // Layout
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
    
    [self.avatarLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(24);
        make.top.equalTo(self.contentView).offset(24);
    }];
    
    [self.avatarContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView).inset(24);
        make.top.equalTo(self.avatarLabel.mas_bottom).offset(12);
        make.height.mas_equalTo(180);
    }];
    
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.avatarContainer);
        make.top.equalTo(self.avatarContainer).offset(20);
        make.width.height.mas_equalTo(100);
    }];
    
    [self.avatarEmojiLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.avatarContainer);
        make.top.equalTo(self.avatarContainer).offset(30);
    }];
    
    [self.changeAvatarButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.avatarContainer);
        make.top.equalTo(self.avatarEmojiLabel.mas_bottom).offset(16);
    }];
    
    [self.usernameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(24);
        make.top.equalTo(self.avatarContainer.mas_bottom).offset(30);
    }];
    
    [self.usernameField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView).inset(24);
        make.top.equalTo(self.usernameLabel.mas_bottom).offset(12);
        make.height.mas_equalTo(50);
    }];
    
    [self.bioLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(24);
        make.top.equalTo(self.usernameField.mas_bottom).offset(30);
    }];
    
    [self.bioTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView).inset(24);
        make.top.equalTo(self.bioLabel.mas_bottom).offset(12);
        make.height.mas_equalTo(120);
        make.bottom.equalTo(self.contentView).offset(-30);
    }];
    
    [self.bioPlaceholder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.bioTextView).inset(16);
        make.right.equalTo(self.bioTextView).inset(16);
    }];
}

- (void)srm_loadData {
    if (self.user) {
        // Load avatar (image or emoji)
        if (self.user.avatarImageBase64.length > 0) {
            NSData *imageData = [[NSData alloc] initWithBase64EncodedString:self.user.avatarImageBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
            if (imageData) {
                UIImage *avatarImage = [UIImage imageWithData:imageData];
                self.avatarImageView.image = avatarImage;
                self.avatarImageView.hidden = NO;
                self.avatarEmojiLabel.hidden = YES;
            }
        } else {
            self.avatarEmojiLabel.text = self.user.avatarEmoji ?: @"🎮";
            self.avatarImageView.hidden = YES;
            self.avatarEmojiLabel.hidden = NO;
        }
        
        self.usernameField.text = self.user.username;
        self.bioTextView.text = self.user.bio;
        self.bioPlaceholder.hidden = self.user.bio.length > 0;
    }
}

#pragma mark - Actions

- (void)srm_cancelTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)srm_saveTapped {
    NSString *username = self.usernameField.text;
    NSString *bio = self.bioTextView.text;
    
    if (username.length == 0) {
        [LEEAlert alert].config
        .LeeTitle(@"Oops!")
        .LeeContent(@"Please enter a username.")
        .LeeCancelAction(@"OK", nil)
        .LeeShow();
        return;
    }
    
    // Save changes
    self.user.username = username;
    self.user.bio = bio;
    
    // Save avatar (image or emoji)
    if (!self.avatarImageView.hidden && self.avatarImageView.image) {
        // Convert image to base64 string
        NSData *imageData = UIImageJPEGRepresentation(self.avatarImageView.image, 0.8);
        self.user.avatarImageBase64 = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        self.user.avatarEmoji = nil;
    } else {
        self.user.avatarEmoji = self.avatarEmojiLabel.text;
        self.user.avatarImageBase64 = nil;
    }
    
    [[SRUserManager sharedManager] saveCurrentUser];
    
    // Show success message
    [LEEAlert alert].config
    .LeeTitle(@"Success")
    .LeeContent(@"Profile updated successfully!")
    .LeeCancelAction(@"OK", ^{
        if (self.saveCompletion) {
            self.saveCompletion();
        }
        [self.navigationController popViewControllerAnimated:YES];
    })
    .LeeShow();
}

- (void)srm_changeAvatarTapped {
    [LEEAlert actionsheet].config
    .LeeTitle(@"Select Avatar Type")
    .LeeAction(@"📷 Upload Photo", ^{
        [self srm_showImagePicker];
    })
    .LeeAction(@"😀 Choose Emoji", ^{
        [self srm_showEmojiPicker];
    })
    .LeeCancelAction(@"Cancel", nil)
    .LeeShow();
}

- (void)srm_showImagePicker {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)srm_showEmojiPicker {
    // 常用 emoji 列表
    NSArray *emojis = @[@"🎮", @"👾", @"🕹️", @"🎯", @"🏆", @"⚔️", @"🛡️", @"🎲", 
                        @"🎪", @"🎨", @"🎭", @"🎬", @"🎸", @"🎤", @"🎧", @"🎵",
                        @"😀", @"😎", @"🤓", @"🧐", @"🤩", @"🥳", @"😈", @"👻",
                        @"🐶", @"🐱", @"🐼", @"🐯", @"🦁", @"🐺", @"🦊", @"🐸"];
    
    // 创建一个网格视图来显示 emoji
    UIView *emojiGridView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 270, 200)];
    
    CGFloat padding = 10;
    CGFloat buttonSize = 50;
    NSInteger columns = 6;
    
    for (NSInteger i = 0; i < emojis.count; i++) {
        NSInteger row = i / columns;
        NSInteger col = i % columns;
        
        CGFloat x = padding + col * (buttonSize + padding);
        CGFloat y = padding + row * (buttonSize + padding);
        
        UIButton *emojiButton = [UIButton buttonWithType:UIButtonTypeSystem];
        emojiButton.frame = CGRectMake(x, y, buttonSize, buttonSize);
        emojiButton.titleLabel.font = [UIFont systemFontOfSize:30];
        [emojiButton setTitle:emojis[i] forState:UIControlStateNormal];
        emojiButton.tag = i;
        [emojiButton addTarget:self action:@selector(srm_emojiSelected:) forControlEvents:UIControlEventTouchUpInside];
        [emojiGridView addSubview:emojiButton];
    }
    
    [LEEAlert alert].config
    .LeeTitle(@"Choose Emoji")
    .LeeCustomView(emojiGridView)
    .LeeCancelAction(@"Cancel", nil)
    .LeeShow();
}

- (void)srm_emojiSelected:(UIButton *)button {
    self.avatarEmojiLabel.text = button.titleLabel.text;
    self.avatarEmojiLabel.hidden = NO;
    self.avatarImageView.hidden = YES;
    self.avatarImageView.image = nil;
    [LEEAlert closeWithCompletionBlock:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *selectedImage = info[UIImagePickerControllerEditedImage] ?: info[UIImagePickerControllerOriginalImage];
    
    if (selectedImage) {
        self.avatarImageView.image = selectedImage;
        self.avatarImageView.hidden = NO;
        self.avatarEmojiLabel.hidden = YES;
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    self.bioPlaceholder.hidden = textView.text.length > 0;
}

#pragma mark - Helpers

- (UILabel *)srm_createSectionLabel:(NSString *)title {
    UILabel *label = [[UILabel alloc] init];
    label.text = title;
    label.font = [UIFont boldSystemFontOfSize:17];
    label.textColor = SR_COLOR_TEXT_PRIMARY;
    return label;
}

- (UITextField *)srm_createTextField:(NSString *)placeholder {
    UITextField *textField = [[UITextField alloc] init];
    textField.placeholder = placeholder;
    textField.font = [UIFont systemFontOfSize:16];
    textField.textColor = SR_COLOR_TEXT_PRIMARY;
    textField.backgroundColor = [UIColor whiteColor];
    textField.layer.cornerRadius = 8;
    textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, 0)];
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.delegate = self;
    return textField;
}

@end
