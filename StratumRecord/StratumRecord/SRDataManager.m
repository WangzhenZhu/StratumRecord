//
//  SRDataManager.m
//  StratumRecord
//

#import "SRDataManager.h"
#import "SRConstants.h"

@implementation SRDataManager

+ (instancetype)sharedManager {
    static SRDataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SRDataManager alloc] init];
    });
    return manager;
}

#pragma mark - My Strategies

- (NSArray<SRStrategy *> *)loadMyStrategies {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SR_KEY_MY_STRATEGIES];
    if (data) {
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return array ?: @[];
    }
    return @[];
}

- (void)saveMyStrategies:(NSArray<SRStrategy *> *)strategies {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:strategies];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:SR_KEY_MY_STRATEGIES];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)addMyStrategy:(SRStrategy *)strategy {
    NSMutableArray *strategies = [[self loadMyStrategies] mutableCopy];
    [strategies insertObject:strategy atIndex:0];
    [self saveMyStrategies:strategies];
}

- (void)updateMyStrategy:(SRStrategy *)strategy {
    NSMutableArray *strategies = [[self loadMyStrategies] mutableCopy];
    for (NSInteger i = 0; i < strategies.count; i++) {
        SRStrategy *s = strategies[i];
        if ([s.strategyId isEqualToString:strategy.strategyId]) {
            strategies[i] = strategy;
            break;
        }
    }
    [self saveMyStrategies:strategies];
}

- (void)deleteMyStrategy:(NSString *)strategyId {
    NSMutableArray *strategies = [[self loadMyStrategies] mutableCopy];
    for (NSInteger i = 0; i < strategies.count; i++) {
        SRStrategy *s = strategies[i];
        if ([s.strategyId isEqualToString:strategyId]) {
            [strategies removeObjectAtIndex:i];
            break;
        }
    }
    [self saveMyStrategies:strategies];
}

#pragma mark - Plaza Strategies

- (NSArray<SRStrategy *> *)loadPlazaStrategies {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SR_KEY_PLAZA_STRATEGIES];
    if (data) {
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return array ?: @[];
    }
    return @[];
}

- (void)savePlazaStrategies:(NSArray<SRStrategy *> *)strategies {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:strategies];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:SR_KEY_PLAZA_STRATEGIES];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)publishStrategy:(SRStrategy *)strategy {
    strategy.isPublished = YES;
    strategy.authorName = @"Me";
    strategy.authorAvatar = @"user_avatar";
    
    NSMutableArray *plazaStrategies = [[self loadPlazaStrategies] mutableCopy];
    [plazaStrategies insertObject:strategy atIndex:0];
    [self savePlazaStrategies:plazaStrategies];
}

- (void)updatePlazaStrategy:(SRStrategy *)strategy {
    NSMutableArray *strategies = [[self loadPlazaStrategies] mutableCopy];
    for (NSInteger i = 0; i < strategies.count; i++) {
        SRStrategy *s = strategies[i];
        if ([s.strategyId isEqualToString:strategy.strategyId]) {
            strategies[i] = strategy;
            break;
        }
    }
    [self savePlazaStrategies:strategies];
}

#pragma mark - Comments

- (NSArray<SRComment *> *)loadAllComments {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SR_KEY_COMMENTS];
    if (data) {
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return array ?: @[];
    }
    return @[];
}

- (void)saveComments:(NSArray<SRComment *> *)comments {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:comments];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:SR_KEY_COMMENTS];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray<SRComment *> *)loadCommentsForStrategy:(NSString *)strategyId {
    NSArray *allComments = [self loadAllComments];
    NSMutableArray *filtered = [NSMutableArray array];
    for (SRComment *comment in allComments) {
        if ([comment.strategyId isEqualToString:strategyId] && !comment.isUnderReview) {
            [filtered addObject:comment];
        }
    }
    return filtered;
}

- (void)addComment:(SRComment *)comment {
    NSMutableArray *comments = [[self loadAllComments] mutableCopy];
    [comments insertObject:comment atIndex:0];
    [self saveComments:comments];
    
    // Update comment count in plaza strategy
    NSMutableArray *plazaStrategies = [[self loadPlazaStrategies] mutableCopy];
    for (SRStrategy *strategy in plazaStrategies) {
        if ([strategy.strategyId isEqualToString:comment.strategyId]) {
            strategy.commentCount++;
            [self savePlazaStrategies:plazaStrategies];
            break;
        }
    }
}

#pragma mark - Mock Data

- (void)initializeMockDataIfNeeded {
    // Check if already initialized
    BOOL initialized = [[NSUserDefaults standardUserDefaults] boolForKey:@"SR_MOCK_DATA_INITIALIZED"];
    if (initialized) {
        return;
    }
    
    // Create mock plaza strategies
    NSMutableArray *plazaStrategies = [NSMutableArray array];
    
    // Strategy 1
    SRStrategy *s1 = [[SRStrategy alloc] init];
    s1.gameName = @"Apex Legends";
    s1.title = @"Hot Drop Survival Tips";
    s1.content = @"Land on weapon spawns first. Grab armor immediately. Use ping system to coordinate with team. Avoid prolonged fights early game.";
    s1.importance = SRImportanceLevelHigh;
    s1.authorName = @"ProGamer_X";
    s1.authorAvatar = @"avatar1";
    s1.likeCount = 234;
    s1.commentCount = 45;
    s1.createdDate = [NSDate dateWithTimeIntervalSinceNow:-86400 * 8];
    [plazaStrategies addObject:s1];
    
    // Strategy 2
    SRStrategy *s2 = [[SRStrategy alloc] init];
    s2.gameName = @"Counter-Strike 2";
    s2.title = @"Mirage B Site Retake";
    s2.content = @"Smoke CT and van. Molly default plant. Flash from market. Check bench and van first. Trade kills efficiently.";
    s2.importance = SRImportanceLevelHigh;
    s2.authorName = @"TacticalMaster";
    s2.authorAvatar = @"avatar2";
    s2.likeCount = 189;
    s2.commentCount = 32;
    s2.createdDate = [NSDate dateWithTimeIntervalSinceNow:-86400 * 10];
    [plazaStrategies addObject:s2];
    
    // Strategy 3
    SRStrategy *s3 = [[SRStrategy alloc] init];
    s3.gameName = @"Overwatch 2";
    s3.title = @"Support Positioning Guide";
    s3.content = @"Stay behind natural cover. Maintain line of sight to tanks. Use high ground when possible. Rotate with team.";
    s3.importance = SRImportanceLevelMedium;
    s3.authorName = @"HealerQueen";
    s3.authorAvatar = @"avatar3";
    s3.likeCount = 156;
    s3.commentCount = 28;
    s3.createdDate = [NSDate dateWithTimeIntervalSinceNow:-86400 * 11];
    [plazaStrategies addObject:s3];
    
    // Strategy 4
    SRStrategy *s4 = [[SRStrategy alloc] init];
    s4.gameName = @"Fortnite";
    s4.title = @"Building Defense Techniques";
    s4.content = @"Box up immediately when taking damage. Edit windows for shots. Reset edits quickly. Keep mats above 300.";
    s4.importance = SRImportanceLevelMedium;
    s4.authorName = @"BuildKing";
    s4.authorAvatar = @"avatar4";
    s4.likeCount = 298;
    s4.commentCount = 67;
    s4.createdDate = [NSDate dateWithTimeIntervalSinceNow:-86400 * 12];
    [plazaStrategies addObject:s4];
    
    // Strategy 5
    SRStrategy *s5 = [[SRStrategy alloc] init];
    s5.gameName = @"Rocket League";
    s5.title = @"Rotation Fundamentals";
    s5.content = @"Never double commit. Rotate back post. Maintain spacing. Challenge when you have boost. Trust teammates.";
    s5.importance = SRImportanceLevelLow;
    s5.authorName = @"AerialAce";
    s5.authorAvatar = @"avatar5";
    s5.likeCount = 142;
    s5.commentCount = 19;
    s5.createdDate = [NSDate dateWithTimeIntervalSinceNow:-86400 * 13];
    [plazaStrategies addObject:s5];
    
    // Strategy 6
    SRStrategy *s6 = [[SRStrategy alloc] init];
    s6.gameName = @"League of Legends";
    s6.title = @"Wave Management Mastery";
    s6.content = @"Freeze near your tower when ahead. Slow push before roaming. Fast push before recall. Crash wave before recall.";
    s6.importance = SRImportanceLevelHigh;
    s6.authorName = @"LaneGod";
    s6.authorAvatar = @"avatar6";
    s6.likeCount = 421;
    s6.commentCount = 89;
    s6.createdDate = [NSDate dateWithTimeIntervalSinceNow:-86400 * 14];
    [plazaStrategies addObject:s6];
    
    [self savePlazaStrategies:plazaStrategies];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"SR_MOCK_DATA_INITIALIZED"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
