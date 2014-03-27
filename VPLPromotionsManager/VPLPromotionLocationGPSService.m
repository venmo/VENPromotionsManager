#import "VPLPromotionLocationGPSService.h"
#import <CoreLocation/CoreLocation.h>
#import "VPLBeaconPromotion.h"

@interface VPLPromotionLocationGPSService () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (copy) void(^callback)(VPLLocation *location, NSError *error);
@property (nonatomic, assign) float gpsMinimumHorizontalAccuracy;
@property (nonatomic, strong) NSMutableArray *pausedRegions;

@end

@implementation VPLPromotionLocationGPSService

#pragma mark - Initializers

- (id)initWithLocationAccuracy:(CLLocationAccuracy)accuracy
  minimumHorizontalAccuracy:(float)horizontalAccuracy {
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


#pragma mark - Beacon Methods

- (void)startMonitoringForRegion:(CLRegion *)region {
    NSSet *monitoredRegions = [self.locationManager monitoredRegions];
    if (![monitoredRegions containsObject:region]) {
        [self.locationManager startMonitoringForRegion:region];
    }
    [self.locationManager requestStateForRegion:(CLBeaconRegion *)region];
}


- (void)stopMonitoringForRegion:(CLRegion *)region {
    [self.locationManager stopMonitoringForRegion:region];
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        [self.locationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}


#pragma mark - Beacon Location Manager Delegate Methods

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}


- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    [self.locationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
}


- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray *)beacons
               inRegion:(CLBeaconRegion *)region {
    if (self.regionFoundCallback) {
        self.regionFoundCallback(region, beacons, nil);
    }
}


- (void)startRangingBeaconsInRegion:(CLBeaconRegion *)region {
    [self.locationManager startRangingBeaconsInRegion:region];
}


- (void)stopRangingBeaconsInRegion:(CLBeaconRegion *)region {
    [self.locationManager stopRangingBeaconsInRegion:region];
}


- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    if (state != CLRegionStateOutside) {
        [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}

@end
