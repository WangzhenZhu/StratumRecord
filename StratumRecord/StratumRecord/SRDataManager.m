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

- (NSArray<SRStrategy *> *)srm_loadMyStrategies {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SR_KEY_MY_STRATEGIES];
    if (data) {
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return array ?: @[];
    }
    return @[];
}

- (void)srm_saveMyStrategies:(NSArray<SRStrategy *> *)strategies {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:strategies];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:SR_KEY_MY_STRATEGIES];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)srm_addMyStrategy:(SRStrategy *)strategy {
    NSMutableArray *strategies = [[self srm_loadMyStrategies] mutableCopy];
    [strategies insertObject:strategy atIndex:0];
    [self srm_saveMyStrategies:strategies];
}

- (void)srm_updateMyStrategy:(SRStrategy *)strategy {
    NSMutableArray *strategies = [[self srm_loadMyStrategies] mutableCopy];
    for (NSInteger i = 0; i < strategies.count; i++) {
        SRStrategy *s = strategies[i];
        if ([s.strategyId isEqualToString:strategy.strategyId]) {
            strategies[i] = strategy;
            break;
        }
    }
    [self srm_saveMyStrategies:strategies];
}

- (void)srm_deleteMyStrategy:(NSString *)strategyId {
    NSMutableArray *strategies = [[self srm_loadMyStrategies] mutableCopy];
    for (NSInteger i = 0; i < strategies.count; i++) {
        SRStrategy *s = strategies[i];
        if ([s.strategyId isEqualToString:strategyId]) {
            [strategies removeObjectAtIndex:i];
            break;
        }
    }
    [self srm_saveMyStrategies:strategies];
}

#pragma mark - Plaza Strategies

- (NSArray<SRStrategy *> *)srm_loadPlazaStrategies {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SR_KEY_PLAZA_STRATEGIES];
    if (data) {
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return array ?: @[];
    }
    return @[];
}

- (void)srm_savePlazaStrategies:(NSArray<SRStrategy *> *)strategies {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:strategies];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:SR_KEY_PLAZA_STRATEGIES];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)srm_publishStrategy:(SRStrategy *)strategy {
    strategy.isPublished = YES;
    strategy.authorName = @"Me";
    strategy.authorAvatar = @"user_avatar";
    
    NSMutableArray *plazaStrategies = [[self srm_loadPlazaStrategies] mutableCopy];
    [plazaStrategies insertObject:strategy atIndex:0];
    [self srm_savePlazaStrategies:plazaStrategies];
}

- (void)srm_updatePlazaStrategy:(SRStrategy *)strategy {
    NSMutableArray *strategies = [[self srm_loadPlazaStrategies] mutableCopy];
    for (NSInteger i = 0; i < strategies.count; i++) {
        SRStrategy *s = strategies[i];
        if ([s.strategyId isEqualToString:strategy.strategyId]) {
            strategies[i] = strategy;
            break;
        }
    }
    [self srm_savePlazaStrategies:strategies];
}

#pragma mark - Comments

- (NSArray<SRComment *> *)srm_loadAllComments {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SR_KEY_COMMENTS];
    if (data) {
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return array ?: @[];
    }
    return @[];
}

- (void)srm_saveComments:(NSArray<SRComment *> *)comments {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:comments];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:SR_KEY_COMMENTS];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray<SRComment *> *)srm_loadCommentsForStrategy:(NSString *)strategyId {
    NSArray *allComments = [self srm_loadAllComments];
    NSMutableArray *filtered = [NSMutableArray array];
    for (SRComment *comment in allComments) {
        if ([comment.strategyId isEqualToString:strategyId] && !comment.isUnderReview) {
            [filtered addObject:comment];
        }
    }
    return filtered;
}

- (void)srm_addComment:(SRComment *)comment {
    NSMutableArray *comments = [[self srm_loadAllComments] mutableCopy];
    [comments insertObject:comment atIndex:0];
    [self srm_saveComments:comments];
    
    // Update comment count in plaza strategy
    NSMutableArray *plazaStrategies = [[self srm_loadPlazaStrategies] mutableCopy];
    for (SRStrategy *strategy in plazaStrategies) {
        if ([strategy.strategyId isEqualToString:comment.strategyId]) {
            strategy.commentCount++;
            [self srm_savePlazaStrategies:plazaStrategies];
            break;
        }
    }
}

#pragma mark - Mock Data

- (void)srm_initializeMockDataIfNeeded {
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
    s1.gameIcon = [SRConstants iconForGameName:@"Apex Legends"];
    s1.title = @"Hot Drop Survival Tips";
    s1.content = @"Land on weapon spawns first. Grab armor immediately. Use ping system to coordinate with team. Avoid prolonged fights early game.";
    s1.importance = SRImportanceLevelHigh;
    s1.authorName = @"ProGamer_X";
    s1.authorAvatar = @"plaze_1";
    s1.likeCount = 1;
    s1.commentCount = 0;
    s1.createdDate = [NSDate dateWithTimeIntervalSinceNow:-86400 * 8];
    [plazaStrategies addObject:s1];
    
    // Strategy 2
    SRStrategy *s2 = [[SRStrategy alloc] init];
    s2.gameName = @"Counter-Strike 2";
    s2.gameIcon = [SRConstants iconForGameName:@"Counter-Strike 2"];
    s2.title = @"Mirage B Site Retake";
    s2.content = @"Smoke CT and van. Molly default plant. Flash from market. Check bench and van first. Trade kills efficiently.";
    s2.importance = SRImportanceLevelHigh;
    s2.authorName = @"TacticalMaster";
    s2.authorAvatar = @"plaze_2";
    s2.likeCount = 2;
    s2.commentCount = 0;
    s2.createdDate = [NSDate dateWithTimeIntervalSinceNow:-86400 * 10];
    [plazaStrategies addObject:s2];
    
    // Strategy 3
    SRStrategy *s3 = [[SRStrategy alloc] init];
    s3.gameName = @"Overwatch 2";
    s3.gameIcon = [SRConstants iconForGameName:@"Overwatch 2"];
    s3.title = @"Support Positioning Guide";
    s3.content = @"Stay behind natural cover. Maintain line of sight to tanks. Use high ground when possible. Rotate with team.";
    s3.importance = SRImportanceLevelMedium;
    s3.authorName = @"HealerQueen";
    s3.authorAvatar = @"plaze_3";
    s3.likeCount = 1;
    s3.commentCount = 0;
    s3.createdDate = [NSDate dateWithTimeIntervalSinceNow:-86400 * 11];
    [plazaStrategies addObject:s3];
    
    // Strategy 4
    SRStrategy *s4 = [[SRStrategy alloc] init];
    s4.gameName = @"Fortnite";
    s4.gameIcon = [SRConstants iconForGameName:@"Fortnite"];
    s4.title = @"Building Defense Techniques";
    s4.content = @"Box up immediately when taking damage. Edit windows for shots. Reset edits quickly. Keep mats above 300.";
    s4.importance = SRImportanceLevelMedium;
    s4.authorName = @"BuildKing";
    s4.authorAvatar = @"plaze_4";
    s4.likeCount = 10;
    s4.commentCount = 0;
    s4.createdDate = [NSDate dateWithTimeIntervalSinceNow:-86400 * 12];
    [plazaStrategies addObject:s4];
    
    // Strategy 5
    SRStrategy *s5 = [[SRStrategy alloc] init];
    s5.gameName = @"Rocket League";
    s5.gameIcon = [SRConstants iconForGameName:@"Rocket League"];
    s5.title = @"Rotation Fundamentals";
    s5.content = @"Never double commit. Rotate back post. Maintain spacing. Challenge when you have boost. Trust teammates.";
    s5.importance = SRImportanceLevelLow;
    s5.authorName = @"AerialAce";
    s5.authorAvatar = @"plaze_5";
    s5.likeCount = 22;
    s5.commentCount = 0;
    s5.createdDate = [NSDate dateWithTimeIntervalSinceNow:-86400 * 13];
    [plazaStrategies addObject:s5];
    
    // Strategy 6
    SRStrategy *s6 = [[SRStrategy alloc] init];
    s6.gameName = @"League of Legends";
    s6.gameIcon = [SRConstants iconForGameName:@"League of Legends"];
    s6.title = @"Wave Management Mastery";
    s6.content = @"Freeze near your tower when ahead. Slow push before roaming. Fast push before recall. Crash wave before recall.";
    s6.importance = SRImportanceLevelHigh;
    s6.authorName = @"LaneGod";
    s6.authorAvatar = @"plaze_6";
    s6.likeCount = 0;
    s6.commentCount = 0;
    s6.createdDate = [NSDate dateWithTimeIntervalSinceNow:-86400 * 14];
    [plazaStrategies addObject:s6];
    
    [self srm_savePlazaStrategies:plazaStrategies];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"SR_MOCK_DATA_INITIALIZED"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
