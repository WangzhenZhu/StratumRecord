//
//  SRPlazaCell.h
//  StratumRecord
//
//  Plaza strategy cell
//

#import <UIKit/UIKit.h>
#import "SRStrategy.h"

@interface SRPlazaCell : UITableViewCell

- (void)srm_configureWithStrategy:(SRStrategy *)strategy
                      likeHandler:(void(^)(void))likeHandler
                   commentHandler:(void(^)(void))commentHandler
                     shareHandler:(void(^)(void))shareHandler
                      moreHandler:(void(^)(void))moreHandler;

@end
