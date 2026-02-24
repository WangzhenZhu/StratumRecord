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

@end
