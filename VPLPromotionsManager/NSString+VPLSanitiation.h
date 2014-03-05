#import <Foundation/Foundation.h>

extern NSString *kVPLWildCardLocationAttribute;

@interface NSString (VPLSanitiation)
/**
 @return A string that is stripped of all non-alphanumeric characters and spaces of the reciever.
 */
- (NSString *)sanitizeString;

@end
