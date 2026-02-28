//
//  SREditProfileViewController.h
//  StratumRecord
//
//  Edit user profile view controller
//

#import <UIKit/UIKit.h>

@interface SREditProfileViewController : UIViewController

@property (nonatomic, copy) void(^saveCompletion)(void);

@end
