//
//  SRStrategy.h
//  StratumRecord
//
//  Game strategy model
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SRImportanceLevel) {
    SRImportanceLevelLow = 0,
    SRImportanceLevelMedium = 1,
    SRImportanceLevelHigh = 2
};

@interface SRStrategy : NSObject <NSCoding>

@property (nonatomic, copy) NSString *strategyId;
@property (nonatomic, copy) NSString *gameName;
@property (nonatomic, copy) NSString *gameIcon; // Game icon emoji
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) SRImportanceLevel importance;
@property (nonatomic, strong) NSDate *createdDate;

// For plaza strategies
@property (nonatomic, copy) NSString *authorName;
@property (nonatomic, copy) NSString *authorAvatar;
@property (nonatomic, assign) NSInteger likeCount;
@property (nonatomic, assign) NSInteger commentCount;
@property (nonatomic, assign) BOOL isLiked;
@property (nonatomic, assign) BOOL isPublished; // Whether it's published to plaza
@property (nonatomic, assign) BOOL isUnderReview; // Whether it's under review

- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)toDictionary;

@end
