//
//  ViewController.m
//  Important functions
//
//  Created by developer9  on 10/15/15.
//  Copyright (c) 2015 developer9 . All rights reserved.
//

#import "ViewController.h"



@implementation ViewController{
    CLLocationManager *locationManager;
    CLLocation *currentLocation,*myLocation,*togoLocation,*distanceLoc;
    Location *togo;
    
    MKCoordinateRegion viewRegion,adjustedRegion;
    MKPointAnnotation *originAnnotation,*currentAnnotation,*destinationAnnotation;
    
    UIAlertView *errorAlert;
    BOOL location_service;
    MKMapView *mapView;
    
    int i;
    BOOL firstLocation;
    
    NSURL *url;
    NSDictionary *route;
    NSDictionary *locations;
    
    NSMutableDictionary *PlaceLocations;
    NSMutableArray *AllLocations;
    NSArray *paths;
    
    Location *nearestPlc;
    double minDistance;
    BOOL nextPageToken;
    NSString *token;
    NSInteger datacount;
   
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Location Info" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
   
    datacount=0;
    nextPageToken=false;
    
    //checking for location authorization
    [self check_auth];
    
    
    if (location_service) {
        
        firstLocation=TRUE;
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter=10;
        [locationManager startUpdatingLocation];
        
        
        AllLocations=[[NSMutableArray alloc] init];
        originAnnotation=[[MKPointAnnotation alloc] init];
        currentAnnotation = [[MKPointAnnotation alloc] init];
        destinationAnnotation = [[MKPointAnnotation alloc] init];
        togo=[[Location alloc]init];
        
        
        mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
        mapView.showsUserLocation = YES;
        mapView.delegate = self;
        [self.view addSubview:mapView];
        
        
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                              initWithTarget:self action:@selector(handleLongPress:)];
        lpgr.minimumPressDuration = 2.0; //user needs to press for 2 seconds
        [mapView addGestureRecognizer:lpgr];
     }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%@",error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (newLocation != nil) {
        
            myLocation=newLocation;
            firstLocation=FALSE;
            originAnnotation.coordinate = CLLocationCoordinate2DMake(myLocation.coordinate.latitude, myLocation.coordinate.longitude);
            originAnnotation.title = @"Origin";
            [mapView addAnnotation:originAnnotation];
            
           
            [self getAddressFromCurruntLocation:myLocation];
            
            
            [self getPlaces:^(BOOL finishes) {
                if (finishes) {
                    NSLog(@"%@",AllLocations);
  
                        for (int k=0; k<[AllLocations count]; k++) {
                            
                            //placing annotation in every single places in list
                            MKPointAnnotation *plc= [[MKPointAnnotation alloc]init];
                            
                            double lat=[[[[[AllLocations objectAtIndex:k] objectForKey:@"geometry"] objectForKey:@"location"]objectForKey:@"lat"]doubleValue];
                            double longi=[[[[[AllLocations objectAtIndex:k] objectForKey:@"geometry"] objectForKey:@"location"]objectForKey:@"lng"]doubleValue];
                            
                            plc.coordinate = CLLocationCoordinate2DMake(lat,longi);
                            plc.title =[[AllLocations objectAtIndex:k] objectForKey:@"name"];
                            [mapView addAnnotation:plc];
                            
                             distanceLoc=[[CLLocation alloc]initWithLatitude:lat longitude:longi];
                            if (k==0) {
                               

                                nearestPlc=[[Location alloc]init];
                                nearestPlc.latitude=lat;
                                nearestPlc.longitude=longi;
                                nearestPlc.title=[[AllLocations objectAtIndex:k] objectForKey:@"name"];
                                minDistance=[myLocation distanceFromLocation:distanceLoc];
                             }
                            else{
                                if ([myLocation distanceFromLocation:distanceLoc]<minDistance) {
                                    minDistance=[myLocation distanceFromLocation:distanceLoc];
                                    nearestPlc=[[Location alloc]init];
                                    nearestPlc.latitude=lat;
                                    nearestPlc.longitude=longi;
                                    nearestPlc.title=[[AllLocations objectAtIndex:k] objectForKey:@"name"];

                                }
                            }
                        }
                    
                        // destination anotation adding here i.e the nearest place searched
                        destinationAnnotation.coordinate = CLLocationCoordinate2DMake(nearestPlc.latitude ,nearestPlc.longitude);
                        destinationAnnotation.title = nearestPlc.title;
                        togo.latitude=nearestPlc.latitude;
                        togo.longitude=nearestPlc.longitude;
                        [mapView addAnnotation:destinationAnnotation];
                    
                    
                    CLLocation *myoriginLocation = [[CLLocation alloc] initWithLatitude:originAnnotation.coordinate.latitude   longitude: originAnnotation.coordinate.longitude];
                    CLLocation *myfinalLocation = [[CLLocation alloc] initWithLatitude:destinationAnnotation.coordinate.latitude   longitude: destinationAnnotation.coordinate.longitude];
                        CLLocationDistance d = [myfinalLocation distanceFromLocation:myoriginLocation];
                        viewRegion  = MKCoordinateRegionMakeWithDistance( myoriginLocation.coordinate, 2*d, 2*d);
                        adjustedRegion  = [mapView regionThatFits:viewRegion];
                        [mapView setRegion:adjustedRegion animated:YES];
                    
                        [self completionBlock:^(BOOL succeeded) {
                            if (succeeded  ) {
                                
                                //here placing the red polymark from origin place to nearest place as a direction
                                
                                if ([[route valueForKey:@"status"] isEqualToString:@"OK"]) {
                                    
                                    paths= [[NSArray alloc]init];
                                    NSArray *routes = [route objectForKey:@"routes"];
                                    NSDictionary *route_a = [routes lastObject];
                                    if (route_a) {
                                        NSString *overviewPolyline =  [[route_a valueForKey:@"overview_polyline"] valueForKey:@"points"];
                                        
                                        paths = [self decodePolyLine:overviewPolyline];
                                    }
                                    
                                    NSInteger numberOfSteps = paths.count;
                                    
                                    CLLocationCoordinate2D coordinates[numberOfSteps];
                                    for (NSInteger index = 0; index < numberOfSteps; index++) {
                                        CLLocation *location = [paths objectAtIndex:index];
                                        CLLocationCoordinate2D coordinate = location.coordinate;
                                        coordinates[index] = coordinate;
                                    }
                                    //removing all polylay if exist before
                                    
                                    [mapView removeOverlays:mapView.overlays];
                                    MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates count:numberOfSteps];
                                    [mapView addOverlay:polyLine];
                                    
                                    
                                    
                                   
                                    /* Add a circular radius in origin point if you like
                                    MKCircle *circle = [MKCircle circleWithCenterCoordinate:myLocation.coordinate radius:100];
                                    [mapView addOverlay:circle];
                                     */
                                }
                            }
                        }];
                }
            }];
        
        
        
        currentLocation=newLocation;
        //setting the initial view region
        
        
    }
    else{
        errorAlert.message=@"Couldnt alert location";
        [errorAlert show];
    }
}


#pragma -marks to get current user location Administrative address
-(void)getAddressFromCurruntLocation:(CLLocation *)location{
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if(placemarks && placemarks.count > 0)
         {
             CLPlacemark *placemark= [placemarks objectAtIndex:0];
             NSString *address = [NSString stringWithFormat:@"%@ %@",[placemark country],[placemark administrativeArea]];
             NSLog(@"New Address Is:%@",address);
         }
     }];
}


#pragma -marks mapview overlay and decode polyline
-(NSMutableArray *)decodePolyLine:(NSString *)encodedStr {
    NSMutableString *encoded = [[NSMutableString alloc] initWithCapacity:[encodedStr length]];
    [encoded appendString:encodedStr];
    [encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\"
                                options:NSLiteralSearch
                                  range:NSMakeRange(0, [encoded length])];
    NSInteger len = [encoded length];
    NSInteger index = 0;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger lat=0;
    NSInteger lng=0;
    while (index < len) {
        NSInteger b;
        NSInteger shift = 0;
        NSInteger result = 0;
        do {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lat += dlat;
        shift = 0;
        result = 0;
        do {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lng += dlng;
        NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
        NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        [array addObject:location];
    }
    return array;
}




- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    /* add a new marker, if any place we know but not in map
     
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    CGPoint touchPoint = [gestureRecognizer locationInView:mapView];
    CLLocationCoordinate2D touchMapCoordinate =
    [mapView convertPoint:touchPoint toCoordinateFromView:mapView];
    
    
    MKPointAnnotation *annot = [[MKPointAnnotation alloc] init];
    annot.coordinate = touchMapCoordinate;
    [mapView addAnnotation:annot];
     */
    
}


- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    
    if([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
        polylineView.strokeColor = [UIColor redColor];
        polylineView.lineWidth = 3.0;
         return polylineView;
    }
    else{
        MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay];
        circleView.strokeColor = [UIColor redColor];
        circleView.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.4];
        return  circleView;
    }
}

-(MKAnnotationView *) mapView:(MKMapView *)mymapView viewForAnnotation:(id<MKAnnotation>)annotation{
  
    
    MKAnnotationView *pinView = nil;
    
    static NSString *defaultPinID = @"hospital";
    pinView = (MKAnnotationView *)[mymapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
    if ( pinView == nil )
        pinView = [[MKAnnotationView alloc]
                   initWithAnnotation:annotation reuseIdentifier:defaultPinID];
    
    
    pinView.canShowCallout = YES;

    
    if ([annotation.title isEqualToString:@"Origin"] || [annotation.title isEqualToString:@"Destination"] )
    {
         pinView.image = [UIImage imageNamed:@"my.png"];
    }
    
    else if ([annotation.title isEqualToString:@"Current Location"]){
        pinView.image = [UIImage imageNamed:@"my.png"];
    }
    else
        pinView.image = [UIImage imageNamed:@"placesPin.png"];
    
    return pinView;
 }


#pragma -marks geting json data between 2 places
-(void)completionBlock:(void (^)(BOOL succeeded))completionBlock

{
    url= [NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&key=AIzaSyBVSeVHPbhndGp7CWSrMzyq1fIvFXbEDYg&mode=walking", myLocation.coordinate.latitude, myLocation.coordinate.longitude, togo.latitude, togo.longitude]];

    
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                  NSMutableData  *lookServerResponseData = [[NSMutableData alloc] init];
                                    [lookServerResponseData appendData:data];
                                   NSError *errorJson=nil;
                                  route= [NSJSONSerialization JSONObjectWithData:lookServerResponseData options:kNilOptions error:&errorJson];
                                   completionBlock(YES);

                               } else{
                                   errorAlert.message=@"Could not retrieve locations";
                                   [errorAlert show];
                                   completionBlock(NO);

                               }
                           }];
}



-(void)getPlaces:(void (^)(BOOL succeeded))getPlace
{
    if(!nextPageToken)
        url= [NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&radius=10000&types=%@&key=AIzaSyBVSeVHPbhndGp7CWSrMzyq1fIvFXbEDYg",myLocation.coordinate.latitude,myLocation.coordinate.longitude,self.type]];
    else
        url=[NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?pagetoken=%@&key=AIzaSyBVSeVHPbhndGp7CWSrMzyq1fIvFXbEDYg",token]];
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   NSMutableData  *lookServerResponseData = [[NSMutableData alloc] init];
                                   [lookServerResponseData appendData:data];
                                   NSError *errorJson=nil;
                                   
                                   PlaceLocations=[NSJSONSerialization JSONObjectWithData:lookServerResponseData options:kNilOptions error:&errorJson];
                                  
                                   datacount++;
                                   
                                   if ([[PlaceLocations valueForKey:@"status" ] isEqualToString:@"OK"])
                                   {
                                       NSArray *perData= [PlaceLocations objectForKey:@"results"];
                                       [AllLocations addObjectsFromArray:perData];
                                       
                                       if ([PlaceLocations valueForKey:@"next_page_token"])
                                       {
                                           nextPageToken=TRUE;
                                           token= [NSString stringWithFormat:@"%@",[PlaceLocations valueForKey:@"next_page_token"]];
                                        }
                                        getPlace(YES);
                                   }
                                   
                               } else{
                                   errorAlert.message=@"Could not retrieve locations";
                                   [errorAlert show];
                                   getPlace(NO);
                               }
                           }];
}



#pragma -marks additional methods


-(BOOL) check_auth{

    #pragma -mark Authorization check for location
    
    if([CLLocationManager locationServicesEnabled]){
        if ([CLLocationManager authorizationStatus]== kCLAuthorizationStatusDenied)
        {
            location_service=FALSE;
            errorAlert.message=@"Location Service was denied by user";
            [errorAlert show];
            [locationManager requestWhenInUseAuthorization ];
        }
        else if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusNotDetermined)
        {
            location_service=TRUE;
            [locationManager requestWhenInUseAuthorization ];
        }
        else if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusRestricted)
        {
            location_service=FALSE;
            errorAlert.message=@"Location Service is restricted";
            [errorAlert show];
        }
        else{
            location_service=TRUE;
        }
    }
    else{
        location_service=FALSE;
        errorAlert.message=@"Not Enabled.Please enable location service";
        [errorAlert show];
    }
    return  location_service;
}
@end
