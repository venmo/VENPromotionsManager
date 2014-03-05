#import <Foundation/Foundation.h>
#import "VPLLocationServiceProtocol.h"
#import "VPLPromotionsManager.h"

@interface VPLPromotionLocationGPSService : NSObject <VPLLocationServiceProtocol>

@property (nonatomic, weak) VPLPromotionsManager *delegate;

- (id)init;

@end
