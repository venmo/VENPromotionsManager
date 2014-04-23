#import "VPLPromotionLocationGPSService.h"
#import <CoreLocation/CoreLocation.h>
#import "VPLRegionPromotion.h"

@interface VPLPromotionLocationGPSService () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (copy) void(^locationFoundCallback)(VPLLocation *location, NSError *error);
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
        self.geocoder = [[CLGeocoder alloc] init];
    }
    return self;
}


- (void)requestCurrentLocationWithCompletion:(void(^)(VPLLocation *location, NSError *error))callback {
    self.locationFoundCallback = callback;
    [self.locationManager startUpdatingLocation];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *myCurrentLocation = [locations lastObject];
    if(myCurrentLocation.horizontalAccuracy <= self.gpsMinimumHorizontalAccuracy) {
        [self.locationManager stopUpdatingLocation];
        if (self.locationFoundCallback) {
            [self.geocoder reverseGeocodeLocation:myCurrentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
                if (!error) {
                    CLPlacemark *placemark = [placemarks lastObject];
                    NSDictionary *locationDictionary = @{VPLLocationCityKey     : placemark.locality,
                                                         VPLLocationStateKey    : placemark.administrativeArea,
                                                         VPLLocationCountryKey  : placemark.country};
                    VPLLocation *currentVPLLocation = [[VPLLocation alloc] initWithLocationDictionary:locationDictionary];
                    if (self.locationFoundCallback) {
                        self.locationFoundCallback(currentVPLLocation,nil);
                    }
                    self.locationFoundCallback = nil;
                }
            }];
        }
    }
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (self.locationFoundCallback) {
        self.locationFoundCallback(nil,error);
    }
    self.locationFoundCallback = nil;
}


#pragma mark - Region Methods

- (void)startMonitoringForRegion:(CLRegion *)region {
    NSSet *monitoredRegions = [self.locationManager monitoredRegions];
    if (![monitoredRegions containsObject:region]) {
        [self.locationManager startMonitoringForRegion:region];
    }
    [self.locationManager requestStateForRegion:region];
}


- (void)stopMonitoringForRegion:(CLRegion *)region {
    [self.locationManager stopMonitoringForRegion:region];
}


#pragma mark - Region Location Manager Delegate Methods

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    if (state == CLRegionStateInside && self.regionEnteredCallback) {
        self.regionEnteredCallback(region);
    }
}

@end
