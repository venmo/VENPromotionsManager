#import "VPLPromotionLocationGPSService.h"
#import <CoreLocation/CoreLocation.h>

@interface VPLPromotionLocationGPSService () <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (copy) void(^callback)(VPLLocation *location, NSError *error);

@end

@implementation VPLPromotionLocationGPSService

#pragma mark - Initializers

- (id)init {
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    }
    return self;
}


- (void)requestCurrentLocationWithCompletion:(void(^)(VPLLocation *location, NSError *error))callback {
    self.callback = callback;
    self.locationManager.desiredAccuracy = self.delegate.gpsDesiredLocationAccuracy;
    [self.locationManager startUpdatingLocation];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *myCurrentLocation = [locations lastObject];
    
    if(myCurrentLocation.horizontalAccuracy <= self.delegate.gpsMinimumHorizontalAccuracy) {
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
