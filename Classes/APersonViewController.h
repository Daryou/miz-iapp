//
//  APersonViewController.h
//  Mizoon
//
//  Created by Daryoush Paknad on 5/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import	"Constants.h"
#import	"Mizoon.h"
#import	"MizoonerProfiles.h"
#import	"MizDataManager.h"
#import	"APersonBasicView.h"
#import	"APersonProfileView.h"

#define kBasicProfileTag	20
#define kPersonalProfileTag	40


@interface APersonViewController : UIViewController  <UITableViewDelegate, UITableViewDataSource>  {
	MizoonerProfiles	*profile;
	APersonBasicView	*basicView;
	APersonProfileView	*personalView;
	BOOL				hasPersonal;
}

@property (nonatomic, retain) MizoonerProfiles *profile;
@property (nonatomic, retain) APersonBasicView *basicView;
@property (nonatomic, retain) APersonProfileView *personalView;

@end
