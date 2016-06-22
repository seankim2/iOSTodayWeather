//
//  TodayViewController.h
//  widget
//
//  Created by KwangHo Kim on 2016. 5. 28..
//
//

/********************************************************************
 Declare include files
 ********************************************************************/
#import <UIKit/UIKit.h>

#import	<CoreLocation/CoreLocation.h>


/********************************************************************
 Declare Class Definitions
 ********************************************************************/
@interface TodayViewController : UIViewController <CLLocationManagerDelegate>
{
    IBOutlet UILabel        *addressLabel;
    IBOutlet UILabel        *updateTimeLabel;
    
    IBOutlet UILabel        *curTitleLabel;        // current weather title
    IBOutlet UILabel        *curSumLabel;            // current summary(text)

    IBOutlet UIImageView    *todayWTIconIV;            // yesterday weather status
    
    IBOutlet UILabel        *todayMaxTempLabel;        // yestterday Max Temperature
    IBOutlet UILabel        *todayMinTempLabel;        // yestterday Min Temperature
    
    IBOutlet UILabel        *tomoMaxTempLabel;        // tomorrow Max Temperature
    IBOutlet UILabel        *tomoMinTempLabel;        // tomorrow Min Temperature
    
    IBOutlet UILabel        *yestMaxTempLabel;        // yestterday Max Temperature
    IBOutlet UILabel        *yestMinTempLabel;        // yestterday Min Temperature
    
    IBOutlet UIButton       *editWidgetBtn;
    IBOutlet UIButton       *updateDataBtn;
    
    // current postion
    double								gMylatitude;;
    double								gMylongitude;
    
    CLLocationManager						*locationManager;
    CLLocation								*startingPoint;
    
    NSMutableData *responseData;
}

/********************************************************************
 Declare Class properties
 ********************************************************************/
@property (retain, nonatomic) CLLocationManager					*locationManager;
@property (retain, nonatomic) CLLocation						*startingPoint;
@property (retain, nonatomic) NSMutableData						*responseData;

/********************************************************************
 Declare Class functions
 ********************************************************************/
- (IBAction) editWidget:(id)sender;
- (IBAction) updateData:(id)sender;

- (void) initLocationInfo;
- (void) refreshDatas;
- (void) getAddressFromDaum:(double)latitude longitude:(double)longitude;
- (void) requestAsyncRequest:(NSString *)nssURL reqType:(NSUInteger)type;
- (void) makeJSONWithData:(NSData *)jsonData reqType:(NSUInteger)type;;
- (void) parseJSONData:(NSDictionary *)jsonDict;
- (void) processWeatherResults:(NSDictionary *)jsonDict;

@end
