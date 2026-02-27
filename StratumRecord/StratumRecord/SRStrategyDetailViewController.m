//
//  SRStrategyDetailViewController.m
//  StratumRecord
//

#import "SRStrategyDetailViewController.h"
#import "SRConstants.h"
#import "SRDataManager.h"
#import "SRComment.h"
#import <Masonry/Masonry.h>

@interface SRStrategyDetailViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) SRStrategy *strategy;
@property (nonatomic, strong) NSMutableArray<SRComment *> *comments;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UIView *headerCard;
@property (nonatomic, strong) UIView *avatarView;
@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIView *gameTagView;
@property (nonatomic, strong) UILabel *gameLabel;
@property (nonatomic, strong) UILabel *importanceLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;

@property (nonatomic, strong) UITableView *commentsTableView;
@property (nonatomic, strong) UIView *commentInputContainer;
@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic, strong) UIButton *sendButton;

@end

@implementation SRStrategyDetailViewController

- (instancetype)initWithStrategy:(SRStrategy *)strategy {
    if (self = [super init]) {
        _strategy = strategy;
        _comments = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = SR_COLOR_BACKGROUND;
    self.title = @"Strategy Details";
    
    // 设置背景图片
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main"]];
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    backgroundImageView.frame = self.view.bounds;
    backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:backgroundImageView];
    [self.view sendSubviewToBack:backgroundImageView];
    
    UIView *coverView = [[UIView alloc] init];
    coverView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    [self.view addSubview:coverView];
    [self srm_setupNavigationBar];
    [self srm_setupUI];
    [self srm_loadComments];
    
    // Keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification 
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)srm_setupNavigationBar {
    UIBarButtonItem *moreButton = [[UIBarButtonItem alloc] initWithImage:[self srm_imageWithSystemName:@"ellipsis"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(srm_moreTapped)];
    self.navigationItem.rightBarButtonItem = moreButton;
}

- (void)srm_setupUI {
    self.scrollView = [[UIScrollView alloc] init];
    [self.view addSubview:self.scrollView];
    
    self.contentView = [[UIView alloc] init];
    [self.scrollView addSubview:self.contentView];
    
    // Header card
    self.headerCard = [[UIView alloc] init];
    self.headerCard.backgroundColor = [UIColor whiteColor];
    self.headerCard.layer.cornerRadius = 12;
    self.headerCard.layer.shadowColor = [UIColor blackColor].CGColor;
    self.headerCard.layer.shadowOffset = CGSizeMake(0, 1);
    self.headerCard.layer.shadowRadius = 3;
    self.headerCard.layer.shadowOpacity = 0.1;
    [self.contentView addSubview:self.headerCard];
    
    // Avatar
    self.avatarView = [[UIView alloc] init];
    self.avatarView.backgroundColor = SR_COLOR_PRIMARY;
    self.avatarView.layer.cornerRadius = 20;
    [self.headerCard addSubview:self.avatarView];
    
    self.authorLabel = [[UILabel alloc] init];
    self.authorLabel.font = [UIFont boldSystemFontOfSize:15];
    self.authorLabel.textColor = SR_COLOR_TEXT_PRIMARY;
    self.authorLabel.text = self.strategy.authorName;
    [self.headerCard addSubview:self.authorLabel];
    
    self.dateLabel = [[UILabel alloc] init];
    self.dateLabel.font = [UIFont systemFontOfSize:13];
    self.dateLabel.textColor = SR_COLOR_TEXT_SECONDARY;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"M/d/yyyy";
    self.dateLabel.text = [formatter stringFromDate:self.strategy.createdDate];
    [self.headerCard addSubview:self.dateLabel];
    
    // Game tag
    self.gameTagView = [[UIView alloc] init];
    self.gameTagView.layer.cornerRadius = 4;
    self.gameTagView.backgroundColor = [SRConstants colorForImportance:self.strategy.importance];
    [self.headerCard addSubview:self.gameTagView];
    
    self.gameLabel = [[UILabel alloc] init];
    self.gameLabel.font = [UIFont boldSystemFontOfSize:11];
    self.gameLabel.textColor = [UIColor whiteColor];
    self.gameLabel.text = self.strategy.gameName;
    [self.gameTagView addSubview:self.gameLabel];
    
    self.importanceLabel = [[UILabel alloc] init];
    self.importanceLabel.font = [UIFont boldSystemFontOfSize:10];
    self.importanceLabel.textAlignment = NSTextAlignmentCenter;
    self.importanceLabel.layer.cornerRadius = 4;
    self.importanceLabel.layer.borderWidth = 1;
    self.importanceLabel.clipsToBounds = YES;
    UIColor *color = [SRConstants colorForImportance:self.strategy.importance];
    self.importanceLabel.text = [SRConstants textForImportance:self.strategy.importance];
    self.importanceLabel.textColor = color;
    self.importanceLabel.layer.borderColor = color.CGColor;
    self.importanceLabel.backgroundColor = [color colorWithAlphaComponent:0.1];
    [self.headerCard addSubview:self.importanceLabel];
    
    // Title
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    self.titleLabel.textColor = SR_COLOR_TEXT_PRIMARY;
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.text = self.strategy.title;
    [self.headerCard addSubview:self.titleLabel];
    
    // Content
    self.contentLabel = [[UILabel alloc] init];
    self.contentLabel.font = [UIFont systemFontOfSize:15];
    self.contentLabel.textColor = SR_COLOR_TEXT_SECONDARY;
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.text = self.strategy.content;
    [self.headerCard addSubview:self.contentLabel];
    
    // Comments section
    UILabel *commentsTitle = [[UILabel alloc] init];
    commentsTitle.text = @"Comments";
    commentsTitle.font = [UIFont boldSystemFontOfSize:18];
    commentsTitle.textColor = SR_COLOR_TEXT_PRIMARY;
    [self.contentView addSubview:commentsTitle];
    
    self.commentsTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.commentsTableView.delegate = self;
    self.commentsTableView.dataSource = self;
    self.commentsTableView.backgroundColor = [UIColor clearColor];
    self.commentsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.commentsTableView.scrollEnabled = NO;
    [self.contentView addSubview:self.commentsTableView];
    
    // Comment input
    self.commentInputContainer = [[UIView alloc] init];
    self.commentInputContainer.backgroundColor = [UIColor whiteColor];
    self.commentInputContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    self.commentInputContainer.layer.shadowOffset = CGSizeMake(0, -1);
    self.commentInputContainer.layer.shadowRadius = 3;
    self.commentInputContainer.layer.shadowOpacity = 0.1;
    [self.view addSubview:self.commentInputContainer];
    
    self.commentTextField = [[UITextField alloc] init];
    self.commentTextField.placeholder = @"Add a comment...";
    self.commentTextField.font = [UIFont systemFontOfSize:15];
    self.commentTextField.backgroundColor = SR_COLOR_BACKGROUND;
    self.commentTextField.layer.cornerRadius = 20;
    self.commentTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, 0)];
    self.commentTextField.leftViewMode = UITextFieldViewModeAlways;
    self.commentTextField.delegate = self;
    [self.commentInputContainer addSubview:self.commentTextField];
    
    self.sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
    self.sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    self.sendButton.tintColor = SR_COLOR_PRIMARY;
    [self.sendButton addTarget:self action:@selector(srm_sendComment) forControlEvents:UIControlEventTouchUpInside];
    [self.commentInputContainer addSubview:self.sendButton];
    
    // Layout
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.commentInputContainer.mas_top);
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
    
    [self.headerCard mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView).inset(16);
        make.top.equalTo(self.contentView).offset(16);
    }];
    
    [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.headerCard).offset(16);
        make.width.height.mas_equalTo(40);
    }];
    
    [self.authorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avatarView.mas_right).offset(12);
        make.top.equalTo(self.avatarView).offset(4);
    }];
    
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.authorLabel);
        make.top.equalTo(self.authorLabel.mas_bottom).offset(2);
    }];
    
    [self.gameTagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerCard).offset(16);
        make.top.equalTo(self.avatarView.mas_bottom).offset(16);
        make.height.mas_equalTo(22);
    }];
    
    [self.gameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.gameTagView).offset(8);
        make.right.equalTo(self.gameTagView).offset(-8);
        make.centerY.equalTo(self.gameTagView);
    }];
    
    [self.importanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.gameTagView.mas_right).offset(8);
        make.centerY.equalTo(self.gameTagView);
        make.height.mas_equalTo(22);
        make.width.mas_equalTo(60);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.headerCard).inset(16);
        make.top.equalTo(self.gameTagView.mas_bottom).offset(12);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.titleLabel);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(12);
        make.bottom.equalTo(self.headerCard).offset(-16);
    }];
    
    [commentsTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(16);
        make.top.equalTo(self.headerCard.mas_bottom).offset(24);
    }];
    
    [self.commentsTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.top.equalTo(commentsTitle.mas_bottom).offset(12);
        make.height.mas_equalTo(0); // Will update dynamically
        make.bottom.equalTo(self.contentView).offset(-16);
    }];
    
    [self.commentInputContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        make.height.mas_equalTo(60);
    }];
    
    [self.commentTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.commentInputContainer).offset(16);
        make.centerY.equalTo(self.commentInputContainer);
        make.height.mas_equalTo(40);
    }];
    
    [self.sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.commentTextField.mas_right).offset(12);
        make.right.equalTo(self.commentInputContainer).offset(-16);
        make.centerY.equalTo(self.commentInputContainer);
        make.width.mas_equalTo(50);
    }];
}

- (void)srm_loadComments {
    self.comments = [[[SRDataManager sharedManager] srm_loadCommentsForStrategy:self.strategy.strategyId] mutableCopy];
    [self.commentsTableView reloadData];
    [self srm_updateCommentsTableHeight];
}

- (void)srm_updateCommentsTableHeight {
    CGFloat height = self.comments.count * 60; // Estimated height per comment
    [self.commentsTableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
}

#pragma mark - Actions

- (void)srm_moreTapped {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Report Strategy"
                                             style:UIAlertActionStyleDestructive
                                           handler:^(UIAlertAction * _Nonnull action) {
        [self srm_reportStrategy];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Block User"
                                             style:UIAlertActionStyleDestructive
                                           handler:^(UIAlertAction * _Nonnull action) {
        [self srm_blockUser];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    if (alert.popoverPresentationController) {
        alert.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
    }
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)srm_reportStrategy {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Report Submitted"
                                                                   message:@"Thank you for your report."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)srm_blockUser {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"User Blocked"
                                                                   message:[NSString stringWithFormat:@"You will no longer see posts from %@", self.strategy.authorName]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)srm_sendComment {
    NSString *text = self.commentTextField.text;
    if (text.length == 0) {
        return;
    }
    
    SRComment *comment = [[SRComment alloc] init];
    comment.strategyId = self.strategy.strategyId;
    comment.authorName = @"Me";
    comment.content = text;
    comment.isUnderReview = YES; // Mark as under review
    
    [[SRDataManager sharedManager] srm_addComment:comment];
    
    self.commentTextField.text = @"";
    [self.commentTextField resignFirstResponder];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Comment Submitted"
                                                                   message:@"Your comment is under review and will be visible after approval."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"CommentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        cell.detailTextLabel.textColor = SR_COLOR_TEXT_SECONDARY;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    SRComment *comment = self.comments[indexPath.row];
    cell.textLabel.text = comment.content;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ · Just now", comment.authorName];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SRComment *comment = self.comments[indexPath.row];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Report Comment"
                                             style:UIAlertActionStyleDestructive
                                           handler:^(UIAlertAction * _Nonnull action) {
        [self srm_reportComment:comment];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    if (alert.popoverPresentationController) {
        alert.popoverPresentationController.sourceView = tableView;
        alert.popoverPresentationController.sourceRect = [tableView rectForRowAtIndexPath:indexPath];
    }
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)srm_reportComment:(SRComment *)comment {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Report Submitted"
                                                                   message:@"Thank you for reporting this comment."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Keyboard

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    CGRect keyboardFrame = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [info[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        [self.commentInputContainer mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(-keyboardFrame.size.height);
        }];
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    CGFloat duration = [info[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        [self.commentInputContainer mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        }];
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self srm_sendComment];
    return YES;
}

#pragma mark - Helpers

- (UIImage *)srm_imageWithSystemName:(NSString *)systemName {
    if (@available(iOS 13.0, *)) {
        return [UIImage systemImageNamed:systemName];
    }
    return nil;
}

@end
