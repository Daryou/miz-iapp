//
//  PlaceMapViewController.h
//  Mizoon
//
//  Created by Daryoush Paknad on 9/25/10.
//  Copyright 2010 Mizoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import	"LocationAnnotation.h"

@interface PlaceMapViewController : UIViewController <MKMapViewDelegate>{
	MKMapView			*mapView;
	LocationAnnotation	*locAnnotation;
}

@property (nonatomic, retain) MKMapView				*mapView;
@property (nonatomic, retain) LocationAnnotation	*locAnnotation;

@end
