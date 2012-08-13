//
//  APersonProfileView.h
//  Mizoon
//
//  Created by Daryoush Paknad on 6/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import	"MizoonerProfiles.h"


@interface APersonProfileView : UIView {
	UIWebView		*pView;
}

@property (nonatomic, retain) UIWebView *pView;

- (id)initWithFrame:(CGRect)frame personalProfile: (MizoonerProfiles *) profiles;
- (float) getProfileHeight: (MizoonerProfiles *) profiles;
- (void) setPersonalProfileValues: (MizoonerProfiles *) profiles;


@end