//
//  CoreBlueTeachManager.h
//  location
//
//  Created by 孙西纯 on 2018/12/18.
//  Copyright © 2018 孙西纯. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface CoreBluetoothManager : NSObject

+ (CLBeaconRegion *)defaultRegion;

- (void)startBeaconSingal:(CLBeaconRegion *)region;

- (void)stopBeaconSingal;

- (BOOL)isAdvertising;

@end
