//
//  TodayViewController.h
//  widget
//
//  Created by KwangHo Kim on 2016. 5. 28..
//
//

#import <UIKit/UIKit.h>

#import	<CoreLocation/CoreLocation.h>

@interface TodayViewController : UIViewController <CLLocationManagerDelegate>
{
    IBOutlet UILabel        *curWeatherLabel;        // current weather
    IBOutlet UILabel        *curTempLabel;           // current temperature
    IBOutlet UILabel        *curDustLabel;           // current dust
    IBOutlet UILabel        *curPosLabel;            // current position
    IBOutlet UILabel        *curSumLabel;            // current summary
    
    IBOutlet UIImageView    *yestStatusIV;            // yesterday weather status
    IBOutlet UILabel        *yestMaxTempLabel;        // yestterday Max Temperature
    IBOutlet UILabel        *yestMinTempLabel;        // yestterday Min Temperature
    
    IBOutlet UIImageView    *tomoStatusIV;            // tomorrow weather status
    IBOutlet UILabel        *tomoMaxTempLabel;        // tomorrow Max Temperature
    IBOutlet UILabel        *tomoMinTempLabel;        // tomorrow Min Temperature
    
    IBOutlet UIButton       *editWidgetBtn;
    IBOutlet UIButton       *updateDataBtn;
    
    // current postion
    double								gMylatitude;;
    double								gMylongitude;
    
    CLLocationManager						*locationManager;
    CLLocation								*startingPoint;
}

@property (retain, nonatomic) CLLocationManager					*locationManager;
@property (retain, nonatomic) CLLocation						*startingPoint;


- (IBAction) editWidget:(id)sender;
- (IBAction) updateData:(id)sender;

- (void) refreshDatas;


- (void) initLocationInfo;

@end
