## iOS定位使用全解

因项目需要，最近对iOS定位api进行了一次彻底的学习。其中不乏基站定位、iBeacon等意料之外的用法。经过一番尝试之后，把各方资料整理一下分享给大家。

### 一、知识点普及

手机基站定位、WIFI定位、GPS定位、IBeacon技术

#### 手机基站定位

```
手机基站定位服务又叫做移动位置服务（LBS——Location Based Service）
通过电信移动运营商的网络（如GSM网）获取移动终端用户的位置信息（经纬度坐标）

传统的基站定位需要连接云端服务器，产生网络流量，iOS 4对其进行了优化，可以在没有网络连接时支持无网定位。
因为苹果预先已经将一些重要基站（几十公里选一个）提前存储在iOS系统中，在无网情况下，不用上网也能通过这些本地基站信息定位到用户位置，
但这个误差范围更大，在10公里到50公里。

无网基站定位的前提是：您的手机能接受到内置在手机中的那些“重要基站”的信号，不一定是您手机所属运营商，只要能收到信号就可以了。

特点

定位速度最快, 耗电最少，误差几百上千米.
```


#### WIFI定位

```
通过无线网卡手机周围所有的WIFI热点（不需要连接上，只需要有信号就行），获得它们的MAC地址，
然后到苹果云端服务器查询这个热点登记的位置,计算（多个热点折中）得到当前位置。

传统的WIFI定位需要网络，但是iOS对其进行了优化，可以实现无网WIFI定位。
iOS设备在您有网络连接时，根据您的位置，自动下载您所在地区周围（几个街区宽度或者更多）所有的WIFI热点的信息到本地。
之后，当您在周围行走并WIFI定位的时候，即使没有网络，iOS照样可以利用之前下载的WIFI热点信息定位出您的位置。

特点

WIFI定位速度、耗电和精度都介于基站和GPS之间，精度大概在几十米。
WIFI定位的支持范围没有基站定位广，但是苹果的云端服务器一直在不断增加新的热点信息，使得热点定位支持的地区越来越多。
```


#### GPS定位

```
GPS（Global Positioning System）即全球定位系统，是由美国建立的一个卫星导航定位系统，利用该系统，
用户可以在全球范围内实现全天候、连续、实时的三维导航定位和测速；

GPS定位精度可达10米以内, 不过这是美国军方控制的, 战争时期可能变的不稳定或者误报. 

特点：
与基站定位和WIFI定位相比，GPS耗电最大，速度最慢，但是精度最高。

```

#### IBeacon技术

```
iBeacon是苹果公司2013年9月发布的移动设备用OS(iOS7)上配备的新功能。
它采用了基于蓝牙4.0的低功耗蓝牙技术(Bluetooth Low Energy, BLE),主要是用作辅助室内定位的功能。

iOS7对接收到的iBeacon信号进行解释后，向等待iBeacon资讯的所有应用软件发送UUID、Major、Minor及靠近程度。
接收资讯的应用软件先确认UUID，如果确认是发送给自己的资讯，则再根据Major、Minor的组合进行处理。

此技术被广泛使用在了商家信息推送，汽车泊车定位，展会等室内精准定位场景。国内有不少硬件厂商专攻这块，如智石科技的Bright Beacon。

特点：
低功耗，距离范围小，定位精准度高。

```

## 二、iOS定位api详细解读


[工程Demo传送门](https://github.com/sunXiChun/fullLocation)

**1、标准定位**

iPhone的GPS与纯粹的GPS定位不同, 称为A-GPS, 即辅助GPS.
是一种将基站定位、WIFI定位、GPS定位混合使用的技术，定位时间长，精度高。

```
//一次性定位
- (void)requestLocation;

//持续定位
- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;

//通过CLLocationManagerDelegate回调告知定位结果
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations;

//requestLocation的错误通知
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error;
```

**2、重大变化的位置服务**

对于定位精度要求相对低的场景。可以使用基站定位告知重大位置变化，降低功耗。

```
- (void)startMonitoringSignificantLocationChanges;
- (void)stopMonitoringSignificantLocationChanges;

//通过CLLocationManagerDelegate回调告知定位结果
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations;
``` 
基站定位的使用需要基于AlwaysAuthorization权限。

有意思的是基站定位不仅能在后台上报定位信息，在app被杀死的情况也能将app激活上报。
根据这种特性，几乎可以把app做成杀不死的小强，不过苹果审核能不能过还是要看具体的应用场景。

下面这段代码可以使app在杀死情况下被激活。

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
        //定位并上报
    }
    
    return YES;
}
```

这里app在后台被激活时，有些坑需要避免下。主线程的访问在后台是会被暂停的。

**3、指南针**

```
//开启关闭指南针定位
- (void)startUpdatingHeading;
- (void)stopUpdatingHeading;

//停止方向校对
- (void)dismissHeadingCalibrationDisplay;

//通过CLLocationManagerDelegate回调告知定位结果
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading;

//停是否显示方向的校对,返回yes的时候,将会校对正确之后才会停止
- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager;
``` 
CLHeading 中封装了指南针方向的信息。通过一定计算可以将方向计算出来。如demo中：

```
CGFloat heading = -1.0f * M_PI * newHeading.magneticHeading / 180.0f;
```

**4、访问事件**

获取用户访问过的兴趣地点的位置信息, 应用可以使用访问服务, 它是重大变化的位置服务(2)的替代方案。

如果在一段时间之前用户曾在某个位置呆过, 该服务能在用户到达或离开该位置时分别生成事件。
该服务用于已经使用了显著位置变更服务的应用想要得到更低的电量消耗的情况下。

```
- (void)startMonitoringVisits;
- (void)stopMonitoringVisits;

//通过CLLocationManagerDelegate回调告知定位结果
- (void)locationManager:(CLLocationManager *)manager didVisit:(CLVisit *)visit;
```
同2 也可以杀死情况被激活。

**5、区域监听**

对于指定经纬度、可设定半径范围进行监听。

```
- (void)startMonitoringForRegion:(CLRegion *)region;
- (void)stopMonitoringForRegion:(CLRegion *)region; 

//通过CLLocationManagerDelegate回调告知定位结果
//进入该区域会调用此代理方法
- (void)locationManager:(CLLocationManager *)manager
    didEnterRegion:(CLRegion *)region;
    
//离开该区域是调用此代理方法
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region;

//判断状态（是否在该区域内）
- (void)locationManager:(CLLocationManager *)manager
    didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region;

```
CLRegion是一个虚基类，这里使用CLCircularRegion来初始化。

```
CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:coordinate2D radius:radius identifier:@"identifier"];
```

同2 也可以杀死情况被激活。

**6、iBeacon监听**

iBeacon监听稍微复杂一些。

需要先使用 CoreBluetooth 框架下的CBPeripheralManager建立一个蓝牙基站。

```
_peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()]; 

//通过CBPeripheralManagerDelegate回调
#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
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

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(nullable NSError *)error {
    NSLog(@"peripheralManager DidStartAdvertising: %@",error.localizedDescription);
}

```
注意这里的(CLBeaconRegion *)_region，UUID，major，minor都应该与接收者同步，否则无法定位。

```
NSUUID *uuid = [[NSUUID alloc]initWithUUIDString:@"E6651486-4678-4353-9C74-95EBD6A307ED"];
CLBeaconMajorValue major = 1;
CLBeaconMajorValue minor = 1;
NSString *identifier = @"怪蜀黍的ibeacon";
CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:major minor:minor identifier:identifier];
```
iBeacon信号发射部分，也可以使用三方app代替，前提是UUID，major，minor都要匹配。

下面接收端是重点。


```
- (void)startRangingBeaconsInRegion:(CLBeaconRegion *)region;

- (void)stopRangingBeaconsInRegion:(CLBeaconRegion *)region;

//通过CLLocationManagerDelegate回调告知定位结果
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region;

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error;
```

这里(CLBeaconRegion *)region UUID，major，minor必须与发射者保持一致。

返回结果CLBeacon中保存了相对位置信息：	

- proximity 距离信息 用Immediate Near Far表示   
- accuracy proximity的精确度表达，米为单位   
- rssi 信号强度 分贝为单位

实际测量结果 500ms上报一次，accuracy浮点数表示。

**7、延迟定位**

在设备进入低耗电量的状态，会进入延迟定位模式，省电。

```
- (void)allowDeferredLocationUpdatesUntilTraveled:(CLLocationDistance)distance timeout:(NSTimeInterval)timeout;

- (void)disallowDeferredLocationUpdates;

//通过CLLocationManagerDelegate回调告知定位结果
- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager;

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager;

- (void)locationManager:(CLLocationManager *)manager
	didFinishDeferredUpdatesWithError:(nullable NSError *)error;
```

使用这个方法有很多要注意的地方：

- desiredAccuracy必须设置成kCLLocationAccuracyBest
- distanceFilter必须设置成kCLErrorDeferredDistanceFiltered
- 必须能够使用GPS进行定位（而不仅仅是移动数据或者Wi-Fi）

**8、反地理编码**

这块就是常规用法了，经纬度换城市信息。

```
CLGeocoder *revGeo = [[CLGeocoder alloc] init];

- (void)reverseGeocodeLocation:(CLLocation *)location completionHandler:(CLGeocodeCompletionHandler)completionHandler;;

```
国内的相对倾向于高德定位和百度定位的反地理编码，相对城市信息较全。

## 三、最后

其中基站定位的部分很多还是需要大量测试的，因为基站定位有时几公里才发生一次，难以调试，加上应用在后台主线程调用被挂起等等因素，很容易写出bug。所以，我经常是骑着小黄车或者打车回家的路上测试。


好了，全部介绍就到这里了，用法都在demo里可以找到，更深层的技术有兴趣的同学可以深入学习下，也可以一起完善这个项目，欢迎提pr。

