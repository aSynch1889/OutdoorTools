//
//  ViewController.m
//  OutdoorTools
//
//  Created by aaaa on 16/8/30.
//  Copyright © 2016年 aihua Co.,Ltd. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
@interface ViewController ()<CLLocationManagerDelegate>{
    CLLocationManager *_locationManager;
    CLGeocoder *_geocoder;
}
@property (weak, nonatomic) IBOutlet UILabel *altitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *temLabel;
@property (weak, nonatomic) IBOutlet UILabel *windLabel;
@property (weak, nonatomic) IBOutlet UILabel *sunriseLabel;
@property (weak, nonatomic) IBOutlet UILabel *sunsetLabel;
@property (weak, nonatomic) IBOutlet UILabel *compassLabel;
@property (weak, nonatomic) IBOutlet UILabel *navigationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *pointer;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    _locationManager = [[CLLocationManager alloc]init];
    if (![CLLocationManager locationServicesEnabled]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"您的定位服务没有开启" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [_locationManager requestWhenInUseAuthorization];
        
    }else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse){
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        CLLocationDistance distance = 10.0;
        _locationManager.distanceFilter = distance;
        [_locationManager startUpdatingLocation];
        
        _geocoder = [[CLGeocoder alloc]init];
        
        if ([CLLocationManager headingAvailable]) {
            [_locationManager startUpdatingHeading];
        }
        
    }
    [self.navigationController setNavigationBarHidden:YES];
    
    

}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    CLLocation *location = [locations firstObject];
    CLLocationCoordinate2D coordinate = location.coordinate;
    NSString *msg = [NSString stringWithFormat:@"经度：%f,纬度：%f,海拔：%f,航向：%f,行走速度：%f",coordinate.longitude,coordinate.latitude,location.altitude,location.course,location.speed];
    //获取海拔高度
    self.altitudeLabel.text = [NSString stringWithFormat:@"%.2f 米",location.altitude];
    //获取经纬度
    self.navigationLabel.text = [NSString stringWithFormat:@"经度：%f \n 纬度: %f",coordinate.longitude,coordinate.latitude];
    //地理反编码，获取城市和国家名
    [_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        CLPlacemark *placemark = placemarks[0];

        self.addressLabel.text = [NSString stringWithFormat:@"%@， %@",placemark.locality,placemark.country];
        
    }];
    //TODO: 获取温度，风速，日出，日落时间等需要天气API接口获取
    //TODO: 顶部的地图视图使用原生的即可
    if (location != nil) {
        [_locationManager stopUpdatingLocation];
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
    CGFloat headings = -1.0f * M_PI * newHeading.magneticHeading / 180.0f;
    self.pointer.transform = CGAffineTransformMakeRotation(headings);
    NSLog(@"%f --- ", headings);
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager{
    return YES;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"定位失败");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
