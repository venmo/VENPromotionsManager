#import "VPLPromotionLocationGPSService.h"
#import <CoreLocation/CoreLocation.h>

@interface VPLPromotionLocationGPSService () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (copy) void(^callback)(VPLLocation *location, NSError *error);
@property (nonatomic) float gpsMinimumHorizontalAccuracy;

@end

@implementation VPLPromotionLocationGPSService

#pragma mark - Initializers

- (id)initWithLocationAccuracy:(CLLocationAccuracy)accuracy
  andMinimumHorizontalAccuracy:(float)horizontalAccuracy {
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = accuracy;
        self.locationManager.delegate = self;
        self.gpsMinimumHorizontalAccuracy = horizontalAccuracy;
    }
    return self;
}


- (void)requestCurrentLocationWithCompletion:(void(^)(VPLLocation *location, NSError *error))callback {
    self.callback = callback;
    [self.locationManager startUpdatingLocation];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *myCurrentLocation = [locations lastObject];
    
    if(myCurrentLocation.horizontalAccuracy <= self.gpsMinimumHorizontalAccuracy) {
        [self.locationManager stopUpdatingLocation];
        VPLLocation *currentVPLLocation = [[VPLLocation alloc] initWithLocation:myCurrentLocation];
        if (self.callback) {
            self.callback(currentVPLLocation,nil);
        }
        self.callback = nil;
    }
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (self.callback) {
    self.callback(nil,error);
    }
    self.callback = nil;
}

@end
