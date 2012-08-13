//
//  LocationAnnotation.h
//  Mizoon
//
//  Created by Daryoush Paknad on 9/26/10.
//  Copyright 2010 Mizoon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface LocationAnnotation : NSObject <MKAnnotation>{
	
	CLLocationCoordinate2D coordinate;
	
	NSString *currentSubTitle;
	NSString *currentTitle;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *currentTitle;
@property (nonatomic, retain) NSString *currentSubTitle;

- (NSString *)title;
- (NSString *)subtitle;

-(id)initWithCoordinate:(CLLocationCoordinate2D) c;


@end
