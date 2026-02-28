//
//  SRUser.m
//  StratumRecord
//

#import "SRUser.h"

@implementation SRUser

- (instancetype)initWithEmail:(NSString *)email {
    if (self = [super init]) {
        _userId = [[NSUUID UUID] UUIDString];
        _email = email;
        _username = [email componentsSeparatedByString:@"@"].firstObject;
        _avatarEmoji = @"🎮";
        _avatarImageBase64 = nil;
        _bio = @"Hardcore gamer & strategy enthusiast 🎮";
        _level = 1;
        _currentExp = 0;
        _maxExp = 1000;
        _strategiesCount = 0;
        _likesCount = 0;
        _commentsCount = 0;
        _hasHotAuthorBadge = NO;
        _hasTop100Badge = NO;
        _hasLikesBadge = NO;
        _hasCreatorBadge = NO;
        _favoriteGames = @[];
        _joinedDate = [NSDate date];
        _memberLevel = @"Lv.1 Newbie";
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        _userId = [coder decodeObjectForKey:@"userId"];
        _email = [coder decodeObjectForKey:@"email"];
        _username = [coder decodeObjectForKey:@"username"];
        _avatarEmoji = [coder decodeObjectForKey:@"avatarEmoji"];
        _avatarImageBase64 = [coder decodeObjectForKey:@"avatarImageBase64"];
        _bio = [coder decodeObjectForKey:@"bio"];
        _level = [coder decodeIntegerForKey:@"level"];
        _currentExp = [coder decodeIntegerForKey:@"currentExp"];
        _maxExp = [coder decodeIntegerForKey:@"maxExp"];
        _strategiesCount = [coder decodeIntegerForKey:@"strategiesCount"];
        _likesCount = [coder decodeIntegerForKey:@"likesCount"];
        _commentsCount = [coder decodeIntegerForKey:@"commentsCount"];
        _hasHotAuthorBadge = [coder decodeBoolForKey:@"hasHotAuthorBadge"];
        _hasTop100Badge = [coder decodeBoolForKey:@"hasTop100Badge"];
        _hasLikesBadge = [coder decodeBoolForKey:@"hasLikesBadge"];
        _hasCreatorBadge = [coder decodeBoolForKey:@"hasCreatorBadge"];
        _favoriteGames = [coder decodeObjectForKey:@"favoriteGames"];
        _joinedDate = [coder decodeObjectForKey:@"joinedDate"];
        _memberLevel = [coder decodeObjectForKey:@"memberLevel"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_userId forKey:@"userId"];
    [coder encodeObject:_email forKey:@"email"];
    [coder encodeObject:_username forKey:@"username"];
    [coder encodeObject:_avatarEmoji forKey:@"avatarEmoji"];
    [coder encodeObject:_avatarImageBase64 forKey:@"avatarImageBase64"];
    [coder encodeObject:_bio forKey:@"bio"];
    [coder encodeInteger:_level forKey:@"level"];
    [coder encodeInteger:_currentExp forKey:@"currentExp"];
    [coder encodeInteger:_maxExp forKey:@"maxExp"];
    [coder encodeInteger:_strategiesCount forKey:@"strategiesCount"];
    [coder encodeInteger:_likesCount forKey:@"likesCount"];
    [coder encodeInteger:_commentsCount forKey:@"commentsCount"];
    [coder encodeBool:_hasHotAuthorBadge forKey:@"hasHotAuthorBadge"];
    [coder encodeBool:_hasTop100Badge forKey:@"hasTop100Badge"];
    [coder encodeBool:_hasLikesBadge forKey:@"hasLikesBadge"];
    [coder encodeBool:_hasCreatorBadge forKey:@"hasCreatorBadge"];
    [coder encodeObject:_favoriteGames forKey:@"favoriteGames"];
    [coder encodeObject:_joinedDate forKey:@"joinedDate"];
    [coder encodeObject:_memberLevel forKey:@"memberLevel"];
}

- (NSDictionary *)toDictionary {
    return @{
        @"userId": self.userId ?: @"",
        @"email": self.email ?: @"",
        @"username": self.username ?: @"",
        @"avatarEmoji": self.avatarEmoji ?: @"🎮",
        @"avatarImageBase64": self.avatarImageBase64 ?: @"",
        @"bio": self.bio ?: @"",
        @"level": @(self.level),
        @"currentExp": @(self.currentExp),
        @"maxExp": @(self.maxExp),
        @"strategiesCount": @(self.strategiesCount),
        @"likesCount": @(self.likesCount),
        @"commentsCount": @(self.commentsCount),
        @"hasHotAuthorBadge": @(self.hasHotAuthorBadge),
        @"hasTop100Badge": @(self.hasTop100Badge),
        @"hasLikesBadge": @(self.hasLikesBadge),
        @"hasCreatorBadge": @(self.hasCreatorBadge),
        @"favoriteGames": self.favoriteGames ?: @[],
        @"joinedDate": self.joinedDate ?: [NSDate date],
        @"memberLevel": self.memberLevel ?: @"Lv.1 Newbie"
    };
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _userId = dictionary[@"userId"];
        _email = dictionary[@"email"];
        _username = dictionary[@"username"];
        _avatarEmoji = dictionary[@"avatarEmoji"];
        _avatarImageBase64 = dictionary[@"avatarImageBase64"];
        _bio = dictionary[@"bio"];
        _level = [dictionary[@"level"] integerValue];
        _currentExp = [dictionary[@"currentExp"] integerValue];
        _maxExp = [dictionary[@"maxExp"] integerValue];
        if (_maxExp == 0) _maxExp = 1000;
        _strategiesCount = [dictionary[@"strategiesCount"] integerValue];
        _likesCount = [dictionary[@"likesCount"] integerValue];
        _commentsCount = [dictionary[@"commentsCount"] integerValue];
        _hasHotAuthorBadge = [dictionary[@"hasHotAuthorBadge"] boolValue];
        _hasTop100Badge = [dictionary[@"hasTop100Badge"] boolValue];
        _hasLikesBadge = [dictionary[@"hasLikesBadge"] boolValue];
        _hasCreatorBadge = [dictionary[@"hasCreatorBadge"] boolValue];
        _favoriteGames = dictionary[@"favoriteGames"];
        _joinedDate = dictionary[@"joinedDate"];
        _memberLevel = dictionary[@"memberLevel"];
    }
    return self;
}

@end
