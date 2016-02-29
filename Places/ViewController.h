//
//  ViewController.h
//  Important functions
//
//  Created by developer9  on 10/15/15.
//  Copyright (c) 2015 developer9 . All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "Helper.h"
#import "Location.h"





@interface ViewController : UIViewController<CLLocationManagerDelegate,MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *latitude;
@property (weak, nonatomic) IBOutlet UILabel *longitude;
@property (nonatomic, retain) MKPolyline *routeLine; //your line
@property (nonatomic, retain) MKPolylineView *routeLineView; //overlay view
@property (weak,nonatomic) NSString *type;





@end

