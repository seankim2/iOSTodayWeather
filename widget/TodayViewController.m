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
 Enumration
 ********************************************************************/
typedef enum
{
    TYPE_REQUEST_NONE,
    TYPE_REQUEST_ADDR,
    TYPE_REQUEST_WEATHER,
    TYPE_REQUEST_MAX,
} TYPE_REQUEST;

/********************************************************************
 Definitions
 ********************************************************************/

#define STR_DAUM_COORD2ADDR_URL         @"https://apis.daum.net/local/geo/coord2addr"
#define STR_APIKEY                      @"?apikey="
#define STR_DAUM_SERVICE_KEY            @""
#define STR_LONGITUDE                   @"&longitude="
#define STR_LATITUDE                    @"&latitude="
#define STR_INPUT_COORD                 @"&inputCoordSystem=WGS84"
#define STR_OUTPUT_JSON                 @"&output=json"

@interface TodayViewController () <NCWidgetProviding>

@end



@implementation TodayViewController

@synthesize locationManager;
@synthesize startingPoint;
@synthesize responseData;

#if 1
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setPreferredContentSize:CGSizeMake(self.view.bounds.size.width, 180)];
    //curWeatherLabel.center = CGPointMake(0, 0);
    //curWeatherLabel.text = @"good TW";
//
    //[self refresh];
    
    [self initLocationInfo];
}
#endif

#if 0
- (void) loadView
{
    
    
    
}
#endif

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
    [self initLocationInfo];
}

// Location

- (void) getAddressFromDaum:(double)latitude longitude:(double)longitude
{
    // for emulator - delete me
    latitude = 37.574226;
    longitude = 127.191671;
    
    NSString *nssURL = [NSString stringWithFormat:@"%@%@%@%@%g%@%g%@%@", STR_DAUM_COORD2ADDR_URL, STR_APIKEY, STR_DAUM_SERVICE_KEY, STR_LONGITUDE, longitude, STR_LATITUDE, latitude, STR_INPUT_COORD, STR_OUTPUT_JSON];
    
    NSLog(@"url : %@", nssURL);
    
    [self requestAsyncRequest:nssURL reqType:TYPE_REQUEST_ADDR];
}

- (void) requestAsyncRequest:(NSString *)nssURL reqType:(NSUInteger)type
{
    //NSURL *myURL = [NSURL URLWithString:@"http://www.example.com"];
    //NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    
    //[[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    NSURL *url = [NSURL URLWithString:nssURL];
  
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url
                                                         completionHandler:
                              ^(NSData *data, NSURLResponse *response, NSError *error) {
                                  if (data) {
                                      // Do stuff with the data
                                      NSLog(@"data : %@", data);
                                      [self makeJSONWithData:data reqType:type];
                                  } else {
                                      NSLog(@"Failed to fetch %@: %@", url, error);
                                  }
                              }];
    
    [task resume];
}

- (void) makeJSONWithData:(NSData *)jsonData reqType:(NSUInteger)type
{
    NSError *error;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    NSLog(@"%@", jsonDict);
    
    if(type == TYPE_REQUEST_ADDR)
        [self parseJSONData:jsonDict];
    else if(type == TYPE_REQUEST_WEATHER)
        [self processWeatherResults:jsonDict];
    
    //NSLog(@"request weather result %@", jsonDict);
}

- (void) parseJSONData:(NSDictionary *)jsonDict
{
    NSDictionary *dict;
    NSString *nssFullName;
    NSString *nssName;
    NSString *nssName0;
    NSString *nssName1;
    NSString *nssName2;
    NSString *nssName3;
    NSString *nssURL;
    NSCharacterSet *set;
    
    dict = [jsonDict objectForKey:@"error"];
    NSLog(@"error dict : %@", dict);
    
    if(dict)
    {
        NSLog(@"error message : %@", [dict objectForKey:@"message"]);
    }
    else
    {
        NSLog(@"I am valid json data!!!");
        
        nssFullName = [jsonDict objectForKey:@"fullName"];
        nssName = [jsonDict objectForKey:@"name"];
        nssName0 = [jsonDict objectForKey:@"name0"];
        nssName1 = [jsonDict objectForKey:@"name1"];
        nssName2 = [jsonDict objectForKey:@"name2"];
        nssName3 = [jsonDict objectForKey:@"name3"];
        
        NSLog(@"nssFullName : %@", nssFullName);
        NSLog(@"nssName : %@", nssName);
        NSLog(@"nssName0 : %@", nssName0);
        NSLog(@"nssName1 : %@", nssName1);
        NSLog(@"nssName2 : %@", nssName2);
        NSLog(@"nssName3 : %@", nssName3);
        
        nssURL = [NSString stringWithFormat:@"https://tw-wzdfac.rhcloud.com/v000705/daily/town/%@/%@/%@", nssName1, nssName2, nssName3];
        NSLog(@"nssURL %@", nssURL);
        set = [NSCharacterSet URLQueryAllowedCharacterSet];
        
        nssURL = [nssURL stringByAddingPercentEncodingWithAllowedCharacters:set];
        NSLog(@"after %@", nssURL);

        [self requestAsyncRequest:nssURL reqType:TYPE_REQUEST_WEATHER];
    }
}

- (void) processWeatherResults:(NSDictionary *)jsonDict
{
    NSDictionary *nsdDailySumDict = nil;
    
    NSString *nssDSIcon = nil;
    NSString *nssDSIconImgName = nil;
    NSString *nssDSText = nil;    // DailySummary Text
    NSString *nssDSTitle = nil;    // DailySummary;
    
    NSDictionary *todayDict = nil;
    NSDictionary *tomoDict = nil;
    NSDictionary *yestDict = nil;
    
    NSUInteger todayMinTemp = 0;
    NSUInteger todayMaxTemp = 0;
    
    NSUInteger tomoMinTemp = 0;
    NSUInteger tomoMaxTemp = 0;
    
    NSUInteger yestMinTemp = 0;
    NSUInteger yestMaxTemp = 0;
    
    NSString    *nssCityName = nil;
    NSString    *nssRegionName = nil;
    NSString    *nssTownName = nil;
    NSString    *nssAddress = nil;
    
    NSString    *nssDate = nil;
    
    NSLog(@"processWeatherResults : %@", jsonDict);
    
    nssCityName = [jsonDict objectForKey:@"cityName"];
    nssRegionName = [jsonDict objectForKey:@"regionName"];
    nssTownName = [jsonDict objectForKey:@"townName"];
    nssAddress = [NSString stringWithFormat:@"%@ %@", nssCityName, nssTownName];
    
    
    nsdDailySumDict = [jsonDict objectForKey:@"dailySummary"];
    
    nssDate     = [nsdDailySumDict objectForKey:@"date"];
    
    nssDSIcon   = [nsdDailySumDict objectForKey:@"icon"];
    nssDSIconImgName = [NSString stringWithFormat:@"%@.png", nssDSIcon];
    
    nssDSText   = [nsdDailySumDict objectForKey:@"text"];
    nssDSTitle  = [nsdDailySumDict objectForKey:@"title"];
    
    todayDict = [nsdDailySumDict objectForKey:@"today"];
    tomoDict = [nsdDailySumDict objectForKey:@"tomorrow"];
    yestDict = [nsdDailySumDict objectForKey:@"yesterday"];
    
    todayMinTemp = [[todayDict valueForKey:@"tmn"] unsignedIntValue];
    todayMaxTemp = [[todayDict valueForKey:@"tmx"] unsignedIntValue];
    
    tomoMinTemp = [[tomoDict valueForKey:@"tmn"] unsignedIntValue];
    tomoMaxTemp = [[tomoDict valueForKey:@"tmx"] unsignedIntValue];
    
    yestMinTemp = [[yestDict valueForKey:@"tmn"] unsignedIntValue];
    yestMaxTemp = [[yestDict valueForKey:@"tmx"] unsignedIntValue];
    
    NSLog(@"nssDSIcon : %@", nssDSIcon);
    
    NSLog(@"nssDSIconImgName : %@", nssDSIconImgName);
    NSLog(@"nssDSText : %@", nssDSText);
    NSLog(@"nssDSTitle : %@", nssDSTitle);
    
    NSLog(@"todayMinTemp : %lu", todayMinTemp);
    NSLog(@"todayMaxTemp : %lu", todayMaxTemp);
    
    NSLog(@"tomoMinTemp : %lu", tomoMinTemp);
    NSLog(@"tomoMaxTemp : %lu", tomoMaxTemp);
    
    NSLog(@"yestMinTemp : %lu", yestMinTemp);
    NSLog(@"yestMaxTemp : %lu", yestMaxTemp);
    
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // code here
        addressLabel.text       = nssAddress;
        updateTimeLabel.text    = nssDate;
        
        curSumLabel.text        = nssDSText;
        curTitleLabel.text      = nssDSTitle;
        
        todayMaxTempLabel.text  = [NSString stringWithFormat:@"%lu도", todayMaxTemp];        // yestterday Max Temperature
        todayMinTempLabel.text  = [NSString stringWithFormat:@"%lu도", todayMinTemp];        // yestterday Min Temperature
        
        tomoMaxTempLabel.text  = [NSString stringWithFormat:@"%lu도", tomoMaxTemp];        // tomorrow Max Temperature
        tomoMinTempLabel.text  = [NSString stringWithFormat:@"%lu도", tomoMinTemp];        // tomorrow Min Temperature
        
        yestMaxTempLabel.text  = [NSString stringWithFormat:@"%lu도", yestMaxTemp];        // yestterday Max Temperature
        yestMinTempLabel.text  = [NSString stringWithFormat:@"%lu도", yestMinTemp];        // yestterday Min Temperature
        
        todayWTIconIV.image = [UIImage imageNamed:nssDSIconImgName];
    });
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    //[responseData release];
    //[connection release];
    //[textView setString:@"Unable to fetch data"];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Succeeded! Received %lu bytes of data",(unsigned long)[responseData length]);
    NSString *txt = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
    
    NSLog(@"txt : %@", txt);
}

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
    NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval	howRecent = [eventDate timeIntervalSinceNow];
    
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
        
        [self getAddressFromDaum:gMylatitude longitude:gMylongitude];
        
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
    
    if(error.code == kCLErrorDenied)
    {
        errorType = @"Access Denied ! If Location Service want to use, Turn on Location Service in Settings";
        
        NSLog(@"error message : %@", errorType);
    }
    else
    {
        errorType = @"Unknown Error";
        NSLog(@"error code : %ld", (long)error.code);
        
        // just test - delete me
        [self getAddressFromDaum:gMylatitude longitude:gMylongitude];
    }
}


@end
