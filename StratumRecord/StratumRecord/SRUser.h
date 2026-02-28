//
//  SRUser.h
//  StratumRecord
//
//  User model
//

#import <Foundation/Foundation.h>

@interface SRUser : NSObject <NSCoding>

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *avatarEmoji;
@property (nonatomic, copy) NSString *avatarImageBase64;
@property (nonatomic, copy) NSString *bio;
@property (nonatomic, assign) NSInteger level;
@property (nonatomic, assign) NSInteger currentExp;
@property (nonatomic, assign) NSInteger maxExp;

// Stats
@property (nonatomic, assign) NSInteger strategiesCount;
@property (nonatomic, assign) NSInteger likesCount;
@property (nonatomic, assign) NSInteger commentsCount;

// Badges
@property (nonatomic, assign) BOOL hasHotAuthorBadge;
@property (nonatomic, assign) BOOL hasTop100Badge;
@property (nonatomic, assign) BOOL hasLikesBadge;
@property (nonatomic, assign) BOOL hasCreatorBadge;

// Favorite games
@property (nonatomic, strong) NSArray<NSString *> *favoriteGames;

// Account info
@property (nonatomic, strong) NSDate *joinedDate;
@property (nonatomic, copy) NSString *memberLevel;

- (instancetype)initWithEmail:(NSString *)email;
- (NSDictionary *)toDictionary;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
