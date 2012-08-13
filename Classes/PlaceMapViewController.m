//
//  PlaceMapViewController.m
//  Mizoon
//
//  Created by Daryoush Paknad on 9/25/10.
//  Copyright 2010 Mizoon. All rights reserved.
//

#import "PlaceMapViewController.h"
#import "Mizoon.h"
#import	"LocationAnnotation.h"



@implementation PlaceMapViewController

@synthesize	locAnnotation, mapView;


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
	Mizoon *miz = [Mizoon sharedMizoon];
	MizoonLocation *theLocation = [miz getSelectedLocation];

	self.view.frame = [[UIScreen mainScreen] applicationFrame];


	mapView = [[MKMapView alloc] initWithFrame: CGRectMake(0, 25, 320, 460)];//  self.view.bounds];
	
	CLLocationCoordinate2D coord = {.latitude =  theLocation.latitude , .longitude = theLocation.longitude};
	MKCoordinateSpan span = {.latitudeDelta =  0.008, .longitudeDelta =  0.008};
	MKCoordinateRegion region = {coord, span};
	[mapView setRegion:region animated:YES];
	
	mapView.delegate = self;
	mapView.showsUserLocation = YES;
	mapView.zoomEnabled = YES;

//	NSLog(@"User location= %f %f ", mapView.userLocation.location.coordinate.latitude, mapView.userLocation.location.coordinate.longitude);
		
	// annotation for the City of San Francisco
    LocationAnnotation *locAnn = [[LocationAnnotation alloc] initWithCoordinate: theLocation.coords ];
	self.locAnnotation = locAnn;
    [locAnn release];
	
	self.locAnnotation.currentTitle = theLocation.name;
	self.locAnnotation.currentSubTitle = theLocation.address;

	[mapView addAnnotation:locAnnotation];
	[mapView selectAnnotation: locAnnotation animated: YES];
	[mapView deselectAnnotation: locAnnotation animated: YES];

//	mapView.mapType=MKMapTypeHybrid;
	/******************************/
	UIImageView *imgView = nil;
	for (UIView *subview in mapView.subviews) {
		if ([subview isMemberOfClass:[UIImageView class]]) {
			imgView = (UIImageView*)subview;
			
			CGRect frame = imgView.frame;
			frame.origin.y = 380.0; // _toolbar.frame.origin.y - frame.size.height - frame.origin.x;
			imgView.frame = frame;
			
			break;
		}
	}
	/*********************************/
	
	
	
	[self.view insertSubview:mapView atIndex:0];
	[super viewDidLoad];

}





/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc 
{
	[mapView	release];
	[locAnnotation	release];
	
    [super dealloc];
}


#pragma mark MKAnnotation



- (CLLocationCoordinate2D)coordinate;
{
	Mizoon *miz = [Mizoon sharedMizoon];

    CLLocationCoordinate2D theCoordinate;
    theCoordinate.latitude = [miz getUserlat];
    theCoordinate.longitude = [miz getUserlon];
    return theCoordinate; 
}

// required if you set the MKPinAnnotationView's "canShowCallout" property to YES
- (NSString *)title
{
    return @"Golden Gate Bridge";
}

// optional
- (NSString *)subtitle
{
    return @"Opened: May 27, 1937";
}




#pragma mark -
#pragma mark MKMapViewDelegate

- (void)showDetails:(id)sender
{
	MizoonLog(@"showDetails");
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	MizoonLog(@"----------MKMapView user loc.lat=%f lon=%f", mapView.userLocation.location.coordinate.latitude, mapView.userLocation.location.coordinate.longitude);

	// try to dequeue an existing pin view first
	static NSString  *AnnotationIdentifier = @"StandardAnnotationIdentifier";
		
	// If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
	
	MKPinAnnotationView* pinView = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
	if (!pinView) {

		// if an existing pin view was not available, create one
		MKPinAnnotationView* customPinView = [[[MKPinAnnotationView alloc]
												   initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier] autorelease];
		customPinView.pinColor = MKPinAnnotationColorRed;
		customPinView.animatesDrop = YES;
		customPinView.canShowCallout = YES;
            
		// add a detail disclosure button to the callout which will open a new view controller page
		//
		// note: you can assign a specific call out accessory view, or as MKMapViewDelegate you can implement:
		//  - (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control;
		//
//		UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//		[rightButton addTarget:self action:@selector(showDetails:)  forControlEvents:UIControlEventTouchUpInside];
//		
//		customPinView.rightCalloutAccessoryView = rightButton;
			
		return customPinView;
	} else {
		pinView.annotation = annotation;
	}
	return pinView;
}

@end
