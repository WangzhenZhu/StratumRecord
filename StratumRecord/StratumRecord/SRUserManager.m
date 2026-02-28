//
//  SRUserManager.m
//  StratumRecord
//

#import "SRUserManager.h"
#import "SRDataManager.h"

static NSString * const kCurrentUserKey = @"CURRENT_USER";
static NSString * const kIsLoggedInKey = @"IS_LOGGED_IN";
static NSString * const kSRTestAccountEmail = @"test@stratumrecord.com";
static NSString * const kSRTestAccountCode = @"123456";

@interface SRUserManager ()

@property (nonatomic, strong, readwrite) SRUser *currentUser;
@property (nonatomic, assign, readwrite) BOOL isLoggedIn;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *verificationCodes;

@end

@implementation SRUserManager

+ (instancetype)sharedManager {
    static SRUserManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SRUserManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _verificationCodes = [NSMutableDictionary dictionary];
        [self srm_prepareTestAccount];
        [self loadCurrentUser];
    }
    return self;
}

#pragma mark - Login/Logout

- (void)loginWithEmail:(NSString *)email completion:(void(^)(BOOL success, NSString *message))completion {
    // Check if user exists
    SRUser *existingUser = [self loadUserByEmail:email];
    
    if (existingUser) {
        // Existing user - login
        self.currentUser = existingUser;
        self.isLoggedIn = YES;
        [self saveCurrentUser];
        
        if (completion) {
            completion(YES, @"Welcome back!");
        }
    } else {
        // New user - register
        SRUser *newUser = [[SRUser alloc] initWithEmail:email];
        self.currentUser = newUser;
        self.isLoggedIn = YES;
        [self saveCurrentUser];
        [self saveUserByEmail:newUser];
        
        if (completion) {
            completion(YES, @"Registration successful! Welcome to StratumRecord!");
        }
    }
    
    // Update user stats from strategies
    [self updateUserStats];
}

- (void)logout {
    self.currentUser = nil;
    self.isLoggedIn = NO;
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kIsLoggedInKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCurrentUserKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - User Info

- (void)saveCurrentUser {
    if (self.currentUser) {
        NSData *userData = [NSKeyedArchiver archivedDataWithRootObject:self.currentUser];
        [[NSUserDefaults standardUserDefaults] setObject:userData forKey:kCurrentUserKey];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsLoggedInKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // Also save to email-based key for persistence
        [self saveUserByEmail:self.currentUser];
    }
}

- (void)loadCurrentUser {
    NSData *userData = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUserKey];
    if (userData) {
        self.currentUser = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
        self.isLoggedIn = [[NSUserDefaults standardUserDefaults] boolForKey:kIsLoggedInKey];
    } else {
        self.isLoggedIn = NO;
    }
}

- (void)updateUserStats {
    if (!self.currentUser) return;
    
    // Get strategies count
    NSArray *myStrategies = [[SRDataManager sharedManager] srm_loadMyStrategies];
    self.currentUser.strategiesCount = myStrategies.count;
    
    // Calculate total comments received on user's strategies
    NSInteger totalComments = 0;
    for (id strategy in myStrategies) {
        if ([strategy respondsToSelector:@selector(commentCount)]) {
            totalComments += [[strategy valueForKey:@"commentCount"] integerValue];
        }
    }
    
    // Note: likesCount is the number of likes user has given, not received
    // It's manually updated when user likes/unlikes a strategy
    self.currentUser.commentsCount = totalComments;
    
    // Update badges based on stats
    self.currentUser.hasHotAuthorBadge = (self.currentUser.likesCount >= 50);
    self.currentUser.hasTop100Badge = (self.currentUser.strategiesCount >= 20);
    self.currentUser.hasLikesBadge = (self.currentUser.likesCount >= 100);
    self.currentUser.hasCreatorBadge = (self.currentUser.strategiesCount >= 5);
    
    // Update level based on activity
    NSInteger totalActivity = self.currentUser.strategiesCount * 10 + self.currentUser.likesCount + self.currentUser.commentsCount;
    self.currentUser.level = 1 + (totalActivity / 100);
    
    // Update member level
    if (self.currentUser.level >= 42) {
        self.currentUser.memberLevel = @"Lv.42 Elite";
    } else if (self.currentUser.level >= 30) {
        self.currentUser.memberLevel = @"Lv.30+ Master";
    } else if (self.currentUser.level >= 20) {
        self.currentUser.memberLevel = @"Lv.20+ Expert";
    } else if (self.currentUser.level >= 10) {
        self.currentUser.memberLevel = @"Lv.10+ Advanced";
    } else if (self.currentUser.level >= 5) {
        self.currentUser.memberLevel = @"Lv.5+ Intermediate";
    } else {
        self.currentUser.memberLevel = [NSString stringWithFormat:@"Lv.%ld Newbie", (long)self.currentUser.level];
    }
    
    [self saveCurrentUser];
}

#pragma mark - Verification Code

- (void)sendVerificationCodeToEmail:(NSString *)email completion:(void(^)(BOOL success, NSString *message))completion {
    // Generate 6-digit code
    NSInteger code = 100000 + arc4random_uniform(900000);
    NSString *codeString = [NSString stringWithFormat:@"%06ld", (long)code];
    
    // Store code (in real app, would send via email service)
    self.verificationCodes[email] = codeString;
    
    // Simulate network delay
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"Verification code for %@: %@", email, codeString);
        
        if (completion) {
            completion(YES, [NSString stringWithFormat:@"Verification code sent to %@", email]);
        }
    });
}

- (BOOL)verifyCode:(NSString *)code forEmail:(NSString *)email {
    if ([email isEqualToString:kSRTestAccountEmail] && [code isEqualToString:kSRTestAccountCode]) {
        return YES;
    }
    
    NSString *storedCode = self.verificationCodes[email];
    
    if (storedCode && [storedCode isEqualToString:code]) {
        // Clear code after successful verification
        [self.verificationCodes removeObjectForKey:email];
        return YES;
    }
    
    return NO;
}

#pragma mark - User Storage

- (void)saveUserByEmail:(SRUser *)user {
    NSString *key = [NSString stringWithFormat:@"USER_%@", user.email];
    NSData *userData = [NSKeyedArchiver archivedDataWithRootObject:user];
    [[NSUserDefaults standardUserDefaults] setObject:userData forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (SRUser *)loadUserByEmail:(NSString *)email {
    NSString *key = [NSString stringWithFormat:@"USER_%@", email];
    NSData *userData = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    if (userData) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:userData];
    }
    
    return nil;
}

#pragma mark - Test Account

- (void)srm_prepareTestAccount {
    self.verificationCodes[kSRTestAccountEmail] = kSRTestAccountCode;
    
    SRUser *testUser = [self loadUserByEmail:kSRTestAccountEmail];
    if (!testUser) {
        testUser = [[SRUser alloc] initWithEmail:kSRTestAccountEmail];
    }
    
    // Fill all SRUser model fields for a complete test profile.
    testUser.userId = @"SR_TEST_USER_001";
    testUser.email = kSRTestAccountEmail;
    testUser.username = @"TestUser";
    testUser.avatarEmoji = @"🧪";
    testUser.level = 42;
    testUser.strategiesCount = 12;
    testUser.likesCount = 188;
    testUser.commentsCount = 76;
    testUser.hasHotAuthorBadge = YES;
    testUser.hasTop100Badge = YES;
    testUser.hasLikesBadge = YES;
    testUser.hasCreatorBadge = YES;
    testUser.favoriteGames = @[@"Apex Legends", @"Counter-Strike 2", @"Overwatch 2"];
    testUser.joinedDate = [NSDate dateWithTimeIntervalSince1970:1711238400]; // 2024-03-24
    testUser.memberLevel = @"Lv.42 Elite";
    
    [self saveUserByEmail:testUser];
}

@end
