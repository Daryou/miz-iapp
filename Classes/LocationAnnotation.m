//
//  LocationAnnotation.m
//  Mizoon
//
//  Created by Daryoush Paknad on 9/26/10.
//  Copyright 2010 Mizoon. All rights reserved.
//

#import "LocationAnnotation.h"
#import <MapKit/MapKit.h>
#import	"Constants.h"

@implementation LocationAnnotation

@synthesize coordinate;
@synthesize currentTitle;
@synthesize currentSubTitle;



- (NSString *)subtitle
{
	MizoonLog(@"currenttitle: %@",currentSubTitle);	
	return currentSubTitle;
}

- (NSString *)title{
	MizoonLog(@"currenttitle: %@",currentTitle);
	return currentTitle;
}


-(id)initWithCoordinate:(CLLocationCoordinate2D) c
{
	coordinate=c;
	return self;
}

@end
