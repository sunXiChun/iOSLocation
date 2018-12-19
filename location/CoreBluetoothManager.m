//
//  CoreBlueTeachManager.m
//  location
//
//  Created by 孙西纯 on 2018/12/18.
//  Copyright © 2018 孙西纯. All rights reserved.
//

#import "CoreBluetoothManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "GlobalToast.h"

@interface CoreBluetoothManager () <CBPeripheralManagerDelegate>

@property (nonatomic,strong) CBPeripheralManager *peripheralManager;
@property (nonatomic,strong) CLBeaconRegion *region;

@end

@implementation CoreBluetoothManager

+ (CLBeaconRegion *)defaultRegion
{
    time_t t;
    srand((unsigned) time(&t));
    
    NSUUID *uuid = [[NSUUID alloc]initWithUUIDString:@"E6651486-4678-4353-9C74-95EBD6A307ED"];
    CLBeaconMajorValue major = 1;
    CLBeaconMajorValue minor = 1;
    NSString *identifier = @"怪蜀黍的ibeacon";
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:major minor:minor identifier:identifier];
    return region;
}

- (void)startBeaconSingal:(CLBeaconRegion *)region
{
    _region = region;
    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
}

- (void)stopBeaconSingal
{
    [_peripheralManager stopAdvertising];
}

- (BOOL)isAdvertising
{
    return [_peripheralManager isAdvertising];
}

#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
        {
            NSLog(@"peripheralManager powered on");
            NSDictionary *peripheralData = [_region peripheralDataWithMeasuredPower:nil];
            [peripheral startAdvertising:peripheralData];
        }
            break;
        case CBPeripheralManagerStatePoweredOff:
            NSLog(@"peripheralManager powered off");
            break;

        default:
            break;
    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(nullable NSError *)error
{
    NSLog(@"peripheralManager DidStartAdvertising: %@",error.localizedDescription);
}




@end
