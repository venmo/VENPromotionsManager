#import <Foundation/Foundation.h>
#import "VPLLocation.h"

@protocol VPLLocationServiceProtocol <NSObject>
@required

-(void(^)(VPLLocation * location, NSError *)) callback;

/**
 Requests the user's current location and passes it in the completion block.
 */
- (void)requestCurrentLocationWithCompletion:(void(^)(VPLLocation * location, NSError *))callback;
@end
