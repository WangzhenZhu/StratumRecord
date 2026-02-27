//
//  SRStrategyCell.m
//  StratumRecord
//

#import "SRStrategyCell.h"
#import "SRConstants.h"
#import <Masonry/Masonry.h>

@interface SRStrategyCell ()

@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UIView *gameTagView;
@property (nonatomic, strong) UIImageView *gameIconImageView;
@property (nonatomic, strong) UILabel *gameLabel;
@property (nonatomic, strong) UILabel *importanceLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UILabel *dateLabel;

@end

@implementation SRStrategyCell

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
    
    // Game tag view
    self.gameTagView = [[UIView alloc] init];
    self.gameTagView.layer.cornerRadius = 4;
    [self.cardView addSubview:self.gameTagView];
    
    // Game icon
    self.gameIconImageView = [[UIImageView alloc] init];
    self.gameIconImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.gameIconImageView.clipsToBounds = YES;
    [self.gameTagView addSubview:self.gameIconImageView];
    
    self.gameLabel = [[UILabel alloc] init];
    self.gameLabel.font = [UIFont boldSystemFontOfSize:12];
    self.gameLabel.textColor = [UIColor whiteColor];
    [self.gameTagView addSubview:self.gameLabel];
    
    // Importance label
    self.importanceLabel = [[UILabel alloc] init];
    self.importanceLabel.font = [UIFont boldSystemFontOfSize:11];
    self.importanceLabel.textAlignment = NSTextAlignmentRight;
    [self.cardView addSubview:self.importanceLabel];
    
    // Title label
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    self.titleLabel.textColor = SR_COLOR_TEXT_PRIMARY;
    self.titleLabel.numberOfLines = 0;
    [self.cardView addSubview:self.titleLabel];
    
    // Content label
    self.contentLabel = [[UILabel alloc] init];
    self.contentLabel.font = [UIFont systemFontOfSize:14];
    self.contentLabel.textColor = SR_COLOR_TEXT_SECONDARY;
    self.contentLabel.numberOfLines = 2;
    [self.cardView addSubview:self.contentLabel];
    
    // Date label
    self.dateLabel = [[UILabel alloc] init];
    self.dateLabel.font = [UIFont systemFontOfSize:13];
    self.dateLabel.textColor = SR_COLOR_TEXT_SECONDARY;
    [self.cardView addSubview:self.dateLabel];
    
    // Layout
    [self.cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(16);
        make.right.equalTo(self.contentView).offset(-16);
        make.top.equalTo(self.contentView).offset(8);
        make.bottom.equalTo(self.contentView).offset(-8);
    }];
    
    [self.gameTagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.cardView).offset(16);
        make.top.equalTo(self.cardView).offset(16);
        make.height.mas_equalTo(24);
    }];
    
    [self.gameIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.gameTagView).offset(6);
        make.centerY.equalTo(self.gameTagView);
        make.width.height.mas_equalTo(20);
    }];
    
    [self.gameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.gameIconImageView.mas_right).offset(6);
        make.right.equalTo(self.gameTagView).offset(-10);
        make.centerY.equalTo(self.gameTagView);
    }];
    
    [self.importanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.cardView).offset(-16);
        make.centerY.equalTo(self.gameTagView);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.cardView).offset(16);
        make.right.equalTo(self.cardView).offset(-16);
        make.top.equalTo(self.gameTagView.mas_bottom).offset(12);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.titleLabel);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(8);
    }];
    
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.cardView).offset(16);
        make.top.equalTo(self.contentLabel.mas_bottom).offset(12);
        make.bottom.equalTo(self.cardView).offset(-16);
    }];
}

- (void)srm_configureWithStrategy:(SRStrategy *)strategy {
    // Game tag with icon
    UIColor *borderColor = [SRConstants borderColorForImportance:strategy.importance];
    self.gameTagView.backgroundColor = [SRConstants colorForImportance:strategy.importance];
    
    NSString *iconName = strategy.gameIcon.length > 0 ? strategy.gameIcon : [SRConstants iconForGameName:strategy.gameName];
    self.gameIconImageView.image = [UIImage imageNamed:iconName];
    self.gameLabel.text = strategy.gameName;
    
    // Apply border to card based on importance
    self.cardView.layer.borderWidth = 2;
    self.cardView.layer.borderColor = borderColor.CGColor;
    
    // Importance
    self.importanceLabel.text = [SRConstants textForImportance:strategy.importance];
    self.importanceLabel.textColor = [SRConstants colorForImportance:strategy.importance];
    
    // Title and content
    self.titleLabel.text = strategy.title;
    self.contentLabel.text = strategy.content;
    
    // Date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"M/d/yyyy";
    self.dateLabel.text = [formatter stringFromDate:strategy.createdDate];
}

@end
