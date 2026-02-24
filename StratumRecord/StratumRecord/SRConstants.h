//
//  SRConstants.h
//  StratumRecord
//
//  App constants
//

#import <UIKit/UIKit.h>

// Colors
#define SR_COLOR_PRIMARY [UIColor colorWithRed:38/255.0 green:181/255.0 blue:168/255.0 alpha:1.0]
#define SR_COLOR_HIGH [UIColor colorWithRed:239/255.0 green:83/255.0 blue:80/255.0 alpha:1.0]
#define SR_COLOR_MEDIUM [UIColor colorWithRed:255/255.0 green:167/255.0 blue:38/255.0 alpha:1.0]
#define SR_COLOR_LOW [UIColor colorWithRed:66/255.0 green:165/255.0 blue:245/255.0 alpha:1.0]
#define SR_COLOR_BACKGROUND [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0]
#define SR_COLOR_TEXT_PRIMARY [UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1.0]
#define SR_COLOR_TEXT_SECONDARY [UIColor colorWithRed:117/255.0 green:117/255.0 blue:117/255.0 alpha:1.0]

// Predefined games
#define SR_PREDEFINED_GAMES @[@"League of Legends", @"Valorant", @"Dota 2", @"Counter-Strike 2", @"Apex Legends", @"Overwatch 2", @"Fortnite", @"Rocket League"]

// Storage keys
#define SR_KEY_MY_STRATEGIES @"SR_KEY_MY_STRATEGIES"
#define SR_KEY_PLAZA_STRATEGIES @"SR_KEY_PLAZA_STRATEGIES"
#define SR_KEY_COMMENTS @"SR_KEY_COMMENTS"

@interface SRConstants : NSObject

+ (UIColor *)colorForImportance:(NSInteger)importance;
+ (NSString *)textForImportance:(NSInteger)importance;
+ (UIColor *)borderColorForImportance:(NSInteger)importance;

@end
