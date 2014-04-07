## VENPromotionsManager

VENPromotionsManager enables easy definition, management and control of in-app location based promotions including the following:
- Define promotion action events along with trigger locations and active date intervals
- Check for location based promotions on a background timer (optional)
- Use an included location service built on a CLLocationManager or a custom location service

### Demo
<img src="example.gif" width="320">


### Installation

You can install VENPromotionsManager in your project by using [CocoaPods](https://github.com/cocoapods/cocoapods):

```Ruby
pod 'VENPromotionsManager', '~> 1.0.0'
```
### Usage

First create one (or more) promotion(s). Promotions can be either region based (using beacons or geofencing) or location based which require periodic location lookups.
```objc

//Location Promotion
CLLocation *appleHQLocation = [[CLLocation alloc] initWithLatitude:37.3318
                                                         longitude:-122.0312];

VPLLocationPromotion *locationPromotion = [[VPLLocationPromotion alloc] initWithCenter:appleHQLocation
                                                                                 range:3000
                                                                      uniqueIdentifier:userDefaultsKey
                                                                                action:^{
                                                                                    //Implement code to launch promotion here
                                                                                }];

//Beacon based Region Promotion
NSUUID *estimoteUUID = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
CLBeaconRegion *doorRegion = [[CLBeaconRegion alloc] initWithProximityUUID:estimoteUUID
                                                                    identifier:@"VenmoEntrancePromotion"];

VPLRegionPromotion *regionPromotion = [[VPLRegionPromotion alloc] initWithRegion:doorRegion
                                                                  repeatInterval:2
                                                                    enterAction:^{
                                                                      //Implement code to launch promotion here
                                                                   }];
 ```
 
Then start the promotions manager with an array of the created promotion(s)
```objc
[VPLPromotionsManager sharedManagerWithPromotions:@[locationPromotion, regionPromotion]
                                    locationTypes:VPLLocationTypeGPSRequestPermission];
[VPLPromotionsManager sharedManager].refreshInterval = 60 * 60; //Lookup location every 60 minutes
[[VPLPromotionsManager sharedManager] startMonitoringForPromotionLocations];
 ```
The VPLPromotionsManager is a singleton object and will display any valid location based promotions.  It checks for a valid location promotion every 60 minutes, and will trigger any valid region promotions when it enter's the promotion region. Region promotions support background notifications, while location promotions do not.

### Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
