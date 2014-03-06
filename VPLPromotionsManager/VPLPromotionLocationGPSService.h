#import <Foundation/Foundation.h>
#import "VPLLocationServiceProtocol.h"
#import "VPLPromotionsManager.h"

@interface VPLPromotionLocationGPSService : NSObject <VPLLocationServiceProtocol>

- (id)initWithLocationAccuracy:(CLLocationAccuracy)accuracy
  andMinimumHorizontalAccuracy:(float)horizontalAccuracy;

@end
