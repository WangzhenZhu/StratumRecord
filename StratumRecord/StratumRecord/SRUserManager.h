//
//  SRUserManager.h
//  StratumRecord
//
//  User management singleton
//

#import <Foundation/Foundation.h>
#import "SRUser.h"

@interface SRUserManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, strong, readonly) SRUser *currentUser;
@property (nonatomic, assign, readonly) BOOL isLoggedIn;

// Login/Logout
- (void)loginWithEmail:(NSString *)email completion:(void(^)(BOOL success, NSString *message))completion;
- (void)logout;

// User info
- (void)saveCurrentUser;
- (void)loadCurrentUser;
- (void)updateUserStats;

// Verification code
- (void)sendVerificationCodeToEmail:(NSString *)email completion:(void(^)(BOOL success, NSString *message))completion;
- (BOOL)verifyCode:(NSString *)code forEmail:(NSString *)email;

@end
