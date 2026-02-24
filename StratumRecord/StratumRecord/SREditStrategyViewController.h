//
//  SREditStrategyViewController.h
//  StratumRecord
//
//  Edit/Create strategy view controller
//

#import <UIKit/UIKit.h>
#import "SRStrategy.h"

@interface SREditStrategyViewController : UIViewController

@property (nonatomic, assign) BOOL isPublishMode; // YES for publish, NO for save
@property (nonatomic, copy) void(^saveCompletion)(SRStrategy *strategy);
@property (nonatomic, copy) void(^deleteCompletion)(NSString *strategyId);

- (instancetype)initWithStrategy:(SRStrategy *)strategy;

@end
