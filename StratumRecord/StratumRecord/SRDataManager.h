//
//  SRDataManager.h
//  StratumRecord
//
//  Data persistence manager
//

#import <Foundation/Foundation.h>
#import "SRStrategy.h"
#import "SRComment.h"

@interface SRDataManager : NSObject

+ (instancetype)sharedManager;

// My Strategies
- (NSArray<SRStrategy *> *)loadMyStrategies;
- (void)saveMyStrategies:(NSArray<SRStrategy *> *)strategies;
- (void)addMyStrategy:(SRStrategy *)strategy;
- (void)updateMyStrategy:(SRStrategy *)strategy;
- (void)deleteMyStrategy:(NSString *)strategyId;

// Plaza Strategies
- (NSArray<SRStrategy *> *)loadPlazaStrategies;
- (void)savePlazaStrategies:(NSArray<SRStrategy *> *)strategies;
- (void)publishStrategy:(SRStrategy *)strategy;
- (void)updatePlazaStrategy:(SRStrategy *)strategy;

// Comments
- (NSArray<SRComment *> *)loadCommentsForStrategy:(NSString *)strategyId;
- (void)addComment:(SRComment *)comment;
- (NSArray<SRComment *> *)loadAllComments;
- (void)saveComments:(NSArray<SRComment *> *)comments;

// Initialize mock data
- (void)initializeMockDataIfNeeded;

@end
