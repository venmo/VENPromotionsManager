## VENPromotionsManager

VENPromotionsManager enables easy definition, management and control of in-app location based promotions including the following:
- Define promotion action events along with trigger locations and active date intervals
- Check for location based promotions on a background timer (optional)
- Use an included location service built on a CLLocationManager or a custom location service

### Usage

First create one (or more) promotion(s)
```objc
    CLLocation *appleHQLocation = [[CLLocation alloc] initWithLatitude:37.3318 longitude:-122.0312];
    NSDate *newYears2014 = [NSDate dateWithTimeIntervalSince1970:1388552400];
    NSDate *newYears2015 = [NSDate dateWithTimeIntervalSince1970:1420088400];

   VPLPromotion *promotion1 = [[VPLPromotion alloc] initWithCenter:appleHQLocation
                                                                  range:3000 //in meters
                                                              startDate:newYears2014
                                                               endDate:newYears2015
                                                showOnceUserDefaultsKey:kUserDefaultsKey //userDefaultsKey to persist trigger history
                                                                 action:^{
                                                                     //Implement code to launch promotion here
                                                                 }];
 ```
Then start the promotions manager with an array of the created promotion(s)
```objc
        [VPLPromotionsManager startWithPromotions:@[promotion1,promotion2,promotion3]
                                locationTypes:VPLLocationTypeGPSRequestPermission
                              locationService:nil //custom location service. use nil if you plan to use the included CLLocationManger.
                          withRefreshInterval:600 //in seconds
                      withMultipleTriggerType:VPLMultipleTriggerOnRefreshTypeTriggerOnce];
 ```
The VPLPromotionsManager is a singleton object and will display any valid location based promotions.  It checks for a valid promotion every 10 minutes.  By supplying a userdefaults key, you gurantee a user will not see a repeat promotion on subsequent launches.
### Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
