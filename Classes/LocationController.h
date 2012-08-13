//
//  LocationController.h
//  Mizoon
//
//  Created by Daryoush Paknad on 2/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>


@protocol LocationControllerDelegate 
@required
- (void)locationUpdate:(CLLocation *)location;
- (void)locationError:(NSError *)error;
@end

@interface LocationController : NSObject <CLLocationManagerDelegate> {
	CLLocationManager *locationManager;
    id		delegate;
	BOOL	haveLocation;
	BOOL	haveNewLocation;
	int		attempts;
	BOOL	locationChanged;
}

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, assign) id delegate;
@property	BOOL	haveNewLocation;
@property	BOOL	locationChanged;


- (BOOL)haveLocation;
- (void)setHaveLocation:(BOOL)input;
- (void)getLocation;

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error;

@end