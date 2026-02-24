//
//  SRStrategyCell.h
//  StratumRecord
//
//  Strategy table view cell
//

#import <UIKit/UIKit.h>
#import "SRStrategy.h"

@interface SRStrategyCell : UITableViewCell

- (void)configureWithStrategy:(SRStrategy *)strategy;

@end
