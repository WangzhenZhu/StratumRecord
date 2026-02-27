//
//  SRConstants.m
//  StratumRecord
//

#import "SRConstants.h"

@implementation SRConstants

+ (UIColor *)colorForImportance:(NSInteger)importance {
    switch (importance) {
        case 0: // Low
            return SR_COLOR_LOW;
        case 1: // Medium
            return SR_COLOR_MEDIUM;
        case 2: // High
            return SR_COLOR_HIGH;
        default:
            return SR_COLOR_MEDIUM;
    }
}

+ (NSString *)textForImportance:(NSInteger)importance {
    switch (importance) {
        case 0:
            return @"LOW";
        case 1:
            return @"MEDIUM";
        case 2:
            return @"HIGH";
        default:
            return @"MEDIUM";
    }
}

+ (UIColor *)borderColorForImportance:(NSInteger)importance {
    UIColor *color = [self colorForImportance:importance];
    return [color colorWithAlphaComponent:0.3];
}

+ (NSString *)iconForGameName:(NSString *)gameName {
    NSDictionary *icons = SR_GAME_ICONS;
    return icons[gameName] ?: @"game_icon1"; // Default icon
}

+ (NSArray<NSString *> *)availableGameIcons {
    return @[@"game_icon1", @"game_icon2", @"game_icon3", @"game_icon4", @"game_icon5", @"game_icon6", @"game_icon7", @"game_icon8"];
}

@end
