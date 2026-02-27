//
//  SRStrategy.m
//  StratumRecord
//

#import "SRStrategy.h"

@implementation SRStrategy

- (instancetype)init {
    if (self = [super init]) {
        _strategyId = [[NSUUID UUID] UUIDString];
        _createdDate = [NSDate date];
        _importance = SRImportanceLevelMedium;
        _likeCount = 0;
        _commentCount = 0;
        _isLiked = NO;
        _isPublished = NO;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        _strategyId = dict[@"strategyId"] ?: [[NSUUID UUID] UUIDString];
        _gameName = dict[@"gameName"];
        _gameIcon = dict[@"gameIcon"];
        _title = dict[@"title"];
        _content = dict[@"content"];
        _importance = [dict[@"importance"] integerValue];
        _createdDate = dict[@"createdDate"] ?: [NSDate date];
        _authorName = dict[@"authorName"];
        _authorAvatar = dict[@"authorAvatar"];
        _likeCount = [dict[@"likeCount"] integerValue];
        _commentCount = [dict[@"commentCount"] integerValue];
        _isLiked = [dict[@"isLiked"] boolValue];
        _isPublished = [dict[@"isPublished"] boolValue];
    }
    return self;
}

- (NSDictionary *)toDictionary {
    return @{
        @"strategyId": self.strategyId ?: @"",
        @"gameName": self.gameName ?: @"",
        @"gameIcon": self.gameIcon ?: @"",
        @"title": self.title ?: @"",
        @"content": self.content ?: @"",
        @"importance": @(self.importance),
        @"createdDate": self.createdDate ?: [NSDate date],
        @"authorName": self.authorName ?: @"",
        @"authorAvatar": self.authorAvatar ?: @"",
        @"likeCount": @(self.likeCount),
        @"commentCount": @(self.commentCount),
        @"isLiked": @(self.isLiked),
        @"isPublished": @(self.isPublished)
    };
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.strategyId forKey:@"strategyId"];
    [coder encodeObject:self.gameName forKey:@"gameName"];
    [coder encodeObject:self.gameIcon forKey:@"gameIcon"];
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.content forKey:@"content"];
    [coder encodeInteger:self.importance forKey:@"importance"];
    [coder encodeObject:self.createdDate forKey:@"createdDate"];
    [coder encodeObject:self.authorName forKey:@"authorName"];
    [coder encodeObject:self.authorAvatar forKey:@"authorAvatar"];
    [coder encodeInteger:self.likeCount forKey:@"likeCount"];
    [coder encodeInteger:self.commentCount forKey:@"commentCount"];
    [coder encodeBool:self.isLiked forKey:@"isLiked"];
    [coder encodeBool:self.isPublished forKey:@"isPublished"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        _strategyId = [coder decodeObjectForKey:@"strategyId"];
        _gameName = [coder decodeObjectForKey:@"gameName"];
        _gameIcon = [coder decodeObjectForKey:@"gameIcon"];
        _title = [coder decodeObjectForKey:@"title"];
        _content = [coder decodeObjectForKey:@"content"];
        _importance = [coder decodeIntegerForKey:@"importance"];
        _createdDate = [coder decodeObjectForKey:@"createdDate"];
        _authorName = [coder decodeObjectForKey:@"authorName"];
        _authorAvatar = [coder decodeObjectForKey:@"authorAvatar"];
        _likeCount = [coder decodeIntegerForKey:@"likeCount"];
        _commentCount = [coder decodeIntegerForKey:@"commentCount"];
        _isLiked = [coder decodeBoolForKey:@"isLiked"];
        _isPublished = [coder decodeBoolForKey:@"isPublished"];
    }
    return self;
}

@end
