//
//  SRComment.m
//  StratumRecord
//

#import "SRComment.h"

@implementation SRComment

- (instancetype)init {
    if (self = [super init]) {
        _commentId = [[NSUUID UUID] UUIDString];
        _createdDate = [NSDate date];
        _isUnderReview = NO;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        _commentId = dict[@"commentId"] ?: [[NSUUID UUID] UUIDString];
        _strategyId = dict[@"strategyId"];
        _authorName = dict[@"authorName"];
        _authorAvatar = dict[@"authorAvatar"];
        _content = dict[@"content"];
        _createdDate = dict[@"createdDate"] ?: [NSDate date];
        _isUnderReview = [dict[@"isUnderReview"] boolValue];
    }
    return self;
}

- (NSDictionary *)toDictionary {
    return @{
        @"commentId": self.commentId ?: @"",
        @"strategyId": self.strategyId ?: @"",
        @"authorName": self.authorName ?: @"",
        @"authorAvatar": self.authorAvatar ?: @"",
        @"content": self.content ?: @"",
        @"createdDate": self.createdDate ?: [NSDate date],
        @"isUnderReview": @(self.isUnderReview)
    };
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.commentId forKey:@"commentId"];
    [coder encodeObject:self.strategyId forKey:@"strategyId"];
    [coder encodeObject:self.authorName forKey:@"authorName"];
    [coder encodeObject:self.authorAvatar forKey:@"authorAvatar"];
    [coder encodeObject:self.content forKey:@"content"];
    [coder encodeObject:self.createdDate forKey:@"createdDate"];
    [coder encodeBool:self.isUnderReview forKey:@"isUnderReview"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        _commentId = [coder decodeObjectForKey:@"commentId"];
        _strategyId = [coder decodeObjectForKey:@"strategyId"];
        _authorName = [coder decodeObjectForKey:@"authorName"];
        _authorAvatar = [coder decodeObjectForKey:@"authorAvatar"];
        _content = [coder decodeObjectForKey:@"content"];
        _createdDate = [coder decodeObjectForKey:@"createdDate"];
        _isUnderReview = [coder decodeBoolForKey:@"isUnderReview"];
    }
    return self;
}

@end
