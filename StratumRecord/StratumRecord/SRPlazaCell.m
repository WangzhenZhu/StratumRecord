//
//  SRPlazaCell.m
//  StratumRecord
//

#import "SRPlazaCell.h"
#import "SRConstants.h"
#import <Masonry/Masonry.h>

@interface SRPlazaCell ()

@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIButton *moreButton;

@property (nonatomic, strong) UIView *gameTagView;
@property (nonatomic, strong) UIImageView *gameIconImageView;
@property (nonatomic, strong) UILabel *gameLabel;
@property (nonatomic, strong) UILabel *importanceLabel;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;

@property (nonatomic, strong) UIButton *likeButton;
@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, strong) UIButton *shareButton;

@property (nonatomic, copy) void(^likeHandler)(void);
@property (nonatomic, copy) void(^commentHandler)(void);
@property (nonatomic, copy) void(^shareHandler)(void);
@property (nonatomic, copy) void(^moreHandler)(void);

@end

@implementation SRPlazaCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // Card view
    self.cardView = [[UIView alloc] init];
    self.cardView.backgroundColor = [UIColor whiteColor];
    self.cardView.layer.cornerRadius = 12;
    self.cardView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.cardView.layer.shadowOffset = CGSizeMake(0, 1);
    self.cardView.layer.shadowRadius = 3;
    self.cardView.layer.shadowOpacity = 0.1;
    [self.contentView addSubview:self.cardView];
    
    // Avatar
    self.avatarView = [[UIImageView alloc] init];
    self.avatarView.layer.cornerRadius = 20;
    [self.cardView addSubview:self.avatarView];
    
    // Author
    self.authorLabel = [[UILabel alloc] init];
    self.authorLabel.font = [UIFont boldSystemFontOfSize:15];
    self.authorLabel.textColor = SR_COLOR_TEXT_PRIMARY;
    [self.cardView addSubview:self.authorLabel];
    
    // Date
    self.dateLabel = [[UILabel alloc] init];
    self.dateLabel.font = [UIFont systemFontOfSize:13];
    self.dateLabel.textColor = SR_COLOR_TEXT_SECONDARY;
    [self.cardView addSubview:self.dateLabel];
    
    // More button
    self.moreButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.moreButton setTitle:@"⋯" forState:UIControlStateNormal];
    self.moreButton.titleLabel.font = [UIFont systemFontOfSize:24];
    self.moreButton.tintColor = SR_COLOR_TEXT_SECONDARY;
    [self.moreButton addTarget:self action:@selector(moreTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.cardView addSubview:self.moreButton];
    
    // Game tag
    self.gameTagView = [[UIView alloc] init];
    self.gameTagView.layer.cornerRadius = 4;
    [self.cardView addSubview:self.gameTagView];
    
    // Game icon
    self.gameIconImageView = [[UIImageView alloc] init];
    self.gameIconImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.gameIconImageView.clipsToBounds = YES;
    [self.gameTagView addSubview:self.gameIconImageView];
    
    self.gameLabel = [[UILabel alloc] init];
    self.gameLabel.font = [UIFont boldSystemFontOfSize:11];
    self.gameLabel.textColor = [UIColor whiteColor];
    [self.gameTagView addSubview:self.gameLabel];
    
    // Importance
    self.importanceLabel = [[UILabel alloc] init];
    self.importanceLabel.font = [UIFont boldSystemFontOfSize:10];
    self.importanceLabel.layer.cornerRadius = 4;
    self.importanceLabel.layer.borderWidth = 1;
    self.importanceLabel.textAlignment = NSTextAlignmentCenter;
    self.importanceLabel.clipsToBounds = YES;
    [self.cardView addSubview:self.importanceLabel];
    
    // Title
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    self.titleLabel.textColor = SR_COLOR_TEXT_PRIMARY;
    self.titleLabel.numberOfLines = 0;
    [self.cardView addSubview:self.titleLabel];
    
    // Content
    self.contentLabel = [[UILabel alloc] init];
    self.contentLabel.font = [UIFont systemFontOfSize:14];
    self.contentLabel.textColor = SR_COLOR_TEXT_SECONDARY;
    self.contentLabel.numberOfLines = 3;
    [self.cardView addSubview:self.contentLabel];
    
    // Action buttons
        self.likeButton = [self createActionButton];
        [self.likeButton addTarget:self action:@selector(likeTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.likeButton setImage:[UIImage imageNamed:@"like_s_icon"] forState:UIControlStateNormal];
        self.likeButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.cardView addSubview:self.likeButton];

        self.commentButton = [self createActionButton];
        [self.commentButton addTarget:self action:@selector(commentTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.commentButton setImage:[UIImage imageNamed:@"comment_icon"] forState:UIControlStateNormal];
        self.commentButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.cardView addSubview:self.commentButton];

        self.shareButton = [self createActionButton];
        [self.shareButton addTarget:self action:@selector(shareTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.shareButton setImage:[UIImage systemImageNamed:@"square.and.arrow.down"] forState:UIControlStateNormal];
    [self.cardView addSubview:self.shareButton];
    // Layout
    [self.cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(16);
        make.right.equalTo(self.contentView).offset(-16);
        make.top.equalTo(self.contentView).offset(8);
        make.bottom.equalTo(self.contentView).offset(-8);
    }];
    
    [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.cardView).offset(16);
        make.top.equalTo(self.cardView).offset(16);
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
    
    [self.moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.cardView).offset(-8);
        make.centerY.equalTo(self.avatarView);
        make.width.height.mas_equalTo(40);
    }];
    
    [self.gameTagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.cardView).offset(16);
        make.top.equalTo(self.avatarView.mas_bottom).offset(16);
        make.height.mas_equalTo(22);
    }];
    
    [self.gameIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.gameTagView).offset(6);
        make.centerY.equalTo(self.gameTagView);
        make.width.height.mas_equalTo(20);
    }];
    
    [self.gameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.gameIconImageView.mas_right).offset(5);
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
        make.left.right.equalTo(self.cardView).inset(16);
        make.top.equalTo(self.gameTagView.mas_bottom).offset(12);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.titleLabel);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(8);
    }];
    
    [self.likeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.cardView).offset(16);
        make.top.equalTo(self.contentLabel.mas_bottom).offset(16);
        make.bottom.equalTo(self.cardView).offset(-16);
    }];
    
    [self.commentButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.likeButton.mas_right).offset(24);
        make.centerY.equalTo(self.likeButton);
    }];
    
    [self.shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.commentButton.mas_right).offset(24);
        make.centerY.equalTo(self.likeButton);
    }];
}

- (UIButton *)createActionButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    button.tintColor = SR_COLOR_TEXT_SECONDARY;
    [button setTitleColor:SR_COLOR_TEXT_SECONDARY forState:UIControlStateNormal];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
    return button;
}

- (void)srm_configureWithStrategy:(SRStrategy *)strategy
                      likeHandler:(void(^)(void))likeHandler
                   commentHandler:(void(^)(void))commentHandler
                     shareHandler:(void(^)(void))shareHandler
                      moreHandler:(void(^)(void))moreHandler {
    
    self.likeHandler = likeHandler;
    self.commentHandler = commentHandler;
    self.shareHandler = shareHandler;
    self.moreHandler = moreHandler;
    
    // Author info
    self.avatarView.image = [UIImage imageNamed:strategy.authorAvatar];
    self.authorLabel.text = strategy.authorName;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"M/d/yyyy";
    self.dateLabel.text = [formatter stringFromDate:strategy.createdDate];
    
    // Game and importance
    UIColor *color = [SRConstants colorForImportance:strategy.importance];
    self.gameTagView.backgroundColor = color;
    
    NSString *iconName = strategy.gameIcon.length > 0 ? strategy.gameIcon : [SRConstants iconForGameName:strategy.gameName];
    self.gameIconImageView.image = [UIImage imageNamed:iconName];
    self.gameLabel.text = strategy.gameName;
    
    self.importanceLabel.text = [SRConstants textForImportance:strategy.importance];
    self.importanceLabel.textColor = color;
    self.importanceLabel.layer.borderColor = color.CGColor;
    self.importanceLabel.backgroundColor = [color colorWithAlphaComponent:0.1];
    
    // Content
    self.titleLabel.text = strategy.title;
    self.contentLabel.text = strategy.content;
    
    // Actions
    NSString *likeIconName = strategy.isLiked ? @"like_icon" : @"like_s_icon";
    [self.likeButton setImage:[UIImage imageNamed:likeIconName] forState:UIControlStateNormal];
    [self.likeButton setTitle:[NSString stringWithFormat:@"%ld", (long)strategy.likeCount] forState:UIControlStateNormal];
    self.likeButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 8);
    self.likeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, -8);

    [self.commentButton setImage:[UIImage imageNamed:@"comment_icon"] forState:UIControlStateNormal];
    [self.commentButton setTitle:[NSString stringWithFormat:@"%ld", (long)strategy.commentCount] forState:UIControlStateNormal];
    self.commentButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 8);
    self.commentButton.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, -8);

    [self.shareButton setImage:[UIImage systemImageNamed:@"square.and.arrow.down"] forState:UIControlStateNormal];
    [self.shareButton setTitle:@"" forState:UIControlStateNormal];
}

- (void)likeTapped {
    if (self.likeHandler) {
        self.likeHandler();
    }
}

- (void)commentTapped {
    if (self.commentHandler) {
        self.commentHandler();
    }
}

- (void)shareTapped {
    if (self.shareHandler) {
        self.shareHandler();
    }
}

- (void)moreTapped {
    if (self.moreHandler) {
        self.moreHandler();
    }
}

@end
