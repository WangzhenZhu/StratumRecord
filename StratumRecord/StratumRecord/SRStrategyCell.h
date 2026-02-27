//
//  SRStrategyCell.h
//  StratumRecord
//
//  Strategy table view cell
//

#import <UIKit/UIKit.h>
#import "SRStrategy.h"

@interface SRStrategyCell : UITableViewCell

- (void)srm_configureWithStrategy:(SRStrategy *)strategy;

@end
