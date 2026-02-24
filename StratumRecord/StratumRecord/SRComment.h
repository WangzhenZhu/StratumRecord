//
//  SRComment.h
//  StratumRecord
//
//  Comment model
//

#import <Foundation/Foundation.h>

@interface SRComment : NSObject <NSCoding>

@property (nonatomic, copy) NSString *commentId;
@property (nonatomic, copy) NSString *strategyId;
@property (nonatomic, copy) NSString *authorName;
@property (nonatomic, copy) NSString *authorAvatar;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, strong) NSDate *createdDate;
@property (nonatomic, assign) BOOL isUnderReview; // Temporarily hidden for review

- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)toDictionary;

@end
