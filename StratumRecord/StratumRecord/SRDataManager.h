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
- (NSArray<SRStrategy *> *)srm_loadMyStrategies;
- (void)srm_saveMyStrategies:(NSArray<SRStrategy *> *)strategies;
- (void)srm_addMyStrategy:(SRStrategy *)strategy;
- (void)srm_updateMyStrategy:(SRStrategy *)strategy;
- (void)srm_deleteMyStrategy:(NSString *)strategyId;

// Plaza Strategies
- (NSArray<SRStrategy *> *)srm_loadPlazaStrategies;
- (void)srm_savePlazaStrategies:(NSArray<SRStrategy *> *)strategies;
- (void)srm_publishStrategy:(SRStrategy *)strategy;
- (void)srm_updatePlazaStrategy:(SRStrategy *)strategy;

// Comments
- (NSArray<SRComment *> *)srm_loadCommentsForStrategy:(NSString *)strategyId;
- (void)srm_addComment:(SRComment *)comment;
- (NSArray<SRComment *> *)srm_loadAllComments;
- (void)srm_saveComments:(NSArray<SRComment *> *)comments;

// Initialize mock data
- (void)srm_initializeMockDataIfNeeded;

@end
