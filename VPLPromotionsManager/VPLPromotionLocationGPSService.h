#import <Foundation/Foundation.h>
#import "VPLLocationServiceProtocol.h"
#import "VPLPromotionsManager.h"

@interface VPLPromotionLocationGPSService : NSObject <VPLLocationServiceProtocol>

@property (nonatomic, strong) NSMutableDictionary *beaconPromotions;

- (id)initWithLocationAccuracy:(CLLocationAccuracy)accuracy
  andMinimumHorizontalAccuracy:(float)horizontalAccuracy;

- (void)startMonitoringForBeaconPromotions:(NSMutableDictionary *)beaconPromotions;


- (void)stopMonitoringForRegion:(CLRegion *)region;


- (void)stopMonitoringForRegion:(CLRegion *)region;
@end
