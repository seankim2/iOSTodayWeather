//
//  TodayViewController.m
//  widget
//
//  Created by KwangHo Kim on 2016. 5. 28..
//
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>


/********************************************************************
 Definitions
 ********************************************************************/

#define USE_LOCATION

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //curWeatherLabel.frame = CGRectMake(0, 0, 100, 50);
    [self setPreferredContentSize:CGSizeMake(320.0, 250.0)];
    //[self refresh];
    
    //curWeatherLabel.center = CGPointMake(200, 8);
    NSLog(@"22222");
    
    [self initLocationInfo];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

- (IBAction) editWidget:(id)sender
{
}

- (IBAction) updateData:(id)sender
{
    [self refreshDatas];
}

- (void) refreshDatas
{
    //NSLog(@"Data %s received", (char*)data);
}

// Location

/********************************************************************
 *
 * Name			: initLocationInfo
 * Description	: Init Location Infomation
 * Returns		: void
 * Side effects :
 * Date			: 2010. 08. 06
 * Author		: KwangHo Kim	( khkim@huboro.co.kr )
 * History		: 20100806 khkim Create function
 *
 ********************************************************************/
- (void) initLocationInfo
{
    self.locationManager = [[CLLocationManager	alloc]	init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    // Update if you move 200 meter
    locationManager.distanceFilter = 200;
    [locationManager startUpdatingLocation];
    
    NSLog(@"11111");
}

/********************************************************************
 *
 * Name			: locationManager:didUpdateToLocation:fromLocation
 * Description	: get newLocation and oldLocation
 * Returns		: void
 * Side effects :
 * Date			: 2010. 08. 06
 * Author		: KwangHo Kim	( khkim@huboro.co.kr )
 * History		: 20100806 khkim Create function
 *
 ********************************************************************/
- (void) locationManager:(CLLocationManager *)manager
     didUpdateToLocation:(CLLocation *)newLocation
            fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"4444");
    
    NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval	howRecent = [eventDate timeIntervalSinceNow];
    
    NSLog(@"3333");
    
    if(startingPoint == nil)
        self.startingPoint = newLocation;
    
    //if(abs(howRecent) < 5.0)
    if(fabs(howRecent) < 5.0)
    {
        [locationManager stopUpdatingLocation];
        
        gMylatitude		= newLocation.coordinate.latitude;
        gMylongitude	= newLocation.coordinate.longitude;
        
        NSLog(@"latitude : %g•, longitude : %g•",
              newLocation.coordinate.latitude,
              newLocation.coordinate.longitude);
        
#if 0
        CLLocation *testCLL = [[CLLocation alloc] initWithLatitude:gMylatitude longitude:gMylongitude];
        
        CLLocationDistance distance = [newLocation distanceFromLocation:testCLL];
        NSLog(@"Distance : %g", distance);
        
        [testCLL release];
#endif		
    }
}

/********************************************************************
 *
 * Name			: locationManager:didFailWithError
 * Description	: get Error Value
 * Returns		: void
 * Side effects :
 * Date			: 2010. 08. 06
 * Author		: KwangHo Kim	( khkim@huboro.co.kr )
 * History		: 20100806 khkim Create function
 *
 ********************************************************************/
- (void) locationManager:(CLLocationManager *)manager
        didFailWithError:(NSError *)error
{
    NSString *errorType;
    
    NSLog(@"5555");
    
    if(error.code == kCLErrorDenied)
    {
        errorType = @"Access Denied ! If Location Service want to use, Turn on Location Service in Settings";
        
        NSLog(@"error message : %@", errorType);
    }
    else
    {
        errorType = @"Unknown Error";
        NSLog(@"error code : %ld", (long)error.code);
    }
}


@end
