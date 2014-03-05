#import "NSString+VPLSanitiation.h"

NSString *kVPLWildCardLocationAttribute = @"*";

@implementation NSString (VPLSanitiation)

- (NSString *)sanitizeString {
    if ([self isEqualToString:kVPLWildCardLocationAttribute]) {
        return self;
    }
    NSArray *components         = [self componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *sanitizedString   = [components componentsJoinedByString:@""];
    components                  = [sanitizedString componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
    sanitizedString             = [components componentsJoinedByString:@""];
    return [sanitizedString lowercaseString];
}

@end
