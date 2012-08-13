//
//  APersonBasicView.m
//  Mizoon
//
//  Created by Daryoush Paknad on 6/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "APersonBasicView.h"
#import	"MizoonerProfiles.h"
#import	"MizProgressHUD.h"



#define LEFT_CONTENT_OFFSET	85
#define	CONTENT_WIDTH		200
#define	LINE_HEIGHT			18
#define BUTTONS_X			5
#define BUTTONS_Y			125
#define	BUTTONS_WIDTH		130
#define	BUTTONS_HEIGHT		40


@interface APersonBasicView (private)
- (void) initLabels;
- (IBAction) sendMessage;
- (void) setPersonPicture: (NSString *) image;
- (BOOL) profileIsSet: (NSString *) attr inPersonDict: (NSDictionary *) personDict;
- (NSString *) getProfileValue: (NSString *) attr inPersonDict: (NSDictionary *) personDict;
- (UILabel *) getNextLabel: (UILabel *) lablePtr;
- (void) createMessageButton;
- (void) createFriendsButton: (MizoonerProfiles *) profiles;
- (void) createWebsiteButton: (MizoonerProfiles *) profiles;
@end

@implementation APersonBasicView
@synthesize	uNameLbl, profile1Lbl, profile2Lbl, profile3Lbl, profile4Lbl, asyncImage, msgBtn, websiteBtn, friendBtn, nextBtnX;



- (id)initWithFrame:(CGRect)frame personProfile: (MizoonerProfiles *) profiles {
	
	if (self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
		
		nextBtnX = BUTTONS_X;
		
		[self initLabels];
		[self createMessageButton];
		[self createFriendsButton:profiles];
    }
    return self;
}


- (void) setProfileValues: (MizoonerProfiles *) profiles {
	
	MizoonProfile *p;
	NSString *av;
	UILabel  *lablePtr;
	
	lablePtr = profile1Lbl;
	p = [profiles getProfileValue: PERSON_USER_NAME];
	uNameLbl.text = p.value;
	
	p = [profiles getProfileValue: PERSON_PICTURE];
	[self setPersonPicture:p.value];
	
	if ((p = [profiles getProfileValue: RELATIONSHIP_STATUS])) {
		av = [[NSString alloc] initWithFormat:@"%@ %@", p.name, p.value];
		lablePtr.text = av;
		lablePtr = [self getNextLabel:lablePtr];
		p.displayed = YES;
		[av	release];
	}
	if ((p = [profiles getProfileValue: SEX])) {
		av = [[NSString alloc] initWithFormat:@"%@ %@", p.name, p.value];
		lablePtr.text = av;
		lablePtr = [self getNextLabel:lablePtr];
		p.displayed = YES;
		[av	release];
	}
	if ((p = [profiles getProfileValue: HOME_TOWN])) {
		av = [[NSString alloc] initWithFormat:@"%@ %@", p.name, p.value];
		lablePtr.text = av;
		lablePtr = [self getNextLabel:lablePtr];
		p.displayed = YES;
		[av	release];
	}
	if ((p = [profiles getProfileValue: INTERESTED_IN])) {
		av = [[NSString alloc] initWithFormat:@"%@ %@", p.name, p.value];
		lablePtr.text = av;
		lablePtr = [self getNextLabel:lablePtr];
		p.displayed = YES;
		[av	release];
	}
	if ((p = [profiles getProfileValue: PERSON_CITY])) {
		av = [[NSString alloc] initWithFormat:@"%@ %@", p.name, p.value];
		lablePtr.text = av;
		lablePtr = [self getNextLabel:lablePtr];
		p.displayed = YES;
		[av	release];
	}
}

- (void)drawRect:(CGRect)rect {
	//	UIGraphicsBeginImageContext(CGSizeMake(theSizeOf, yourTextView));
	//	
	//	CGContextSetLineWidth(UIGraphicsGetCurrentContext, 3.0); //or whatever width you want
	//	CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0); 
	//	CGContextStrokeRect(UIGraphicsGetCurrentContext, CGContextGetClipBoundingBox(UIGraphicsGetCurrentContext)); //Note, you may need to set the clip bounding box first.  That's CGContextClipToRect(UIGraphicsGetCurrentContext, theRectOfYourUITextField);
	//	
	//	UIImage *backgroundImage = (UIImage *)UIGraphicsGetImageFromCurrentImageContext();
	//	[self addSubview:backgroundImage];
	//	[backgroundImage release];
	//	
	//	UIGraphicsEndImageContext();
}

- (void) createMessageButton {
	
	if (!msgBtn) {
		msgBtn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		[msgBtn setImage:[UIImage imageNamed:@"private-message-button.png"] forState:UIControlStateNormal];
		msgBtn.frame = CGRectMake(nextBtnX, BUTTONS_Y , BUTTONS_WIDTH, BUTTONS_HEIGHT);
		[msgBtn addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];	
		msgBtn.userInteractionEnabled = YES;
		[self addSubview:msgBtn];
		nextBtnX += 145;
	}
}

- (void) createFriendsButton: (MizoonerProfiles *) profiles {
	
	MizoonProfile *p;

	if ((p = [profiles getProfileValue: PERSON_FRIEND])) {
		if ([p.value rangeOfString:@"no" options:NSCaseInsensitiveSearch].length == 0) 
			return;
	} else {
		return;
	}
	
//	if (!friendBtn) {
//		friendBtn = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
//		friendBtn.frame = CGRectMake(nextBtnX, BUTTONS_Y , BUTTONS_WIDTH, BUTTONS_HEIGHT);
//		[friendBtn setTitle:@"Make Friends" forState:UIControlStateNormal];
//		[friendBtn addTarget:self action:@selector(makeFriends) forControlEvents:UIControlEventTouchUpInside];	
//		[self addSubview:friendBtn];
//		nextBtnX += 90;
//	}
	
	
	if (!friendBtn) {
		friendBtn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		[friendBtn setImage:[UIImage imageNamed:@"make-friends-button.png"] forState:UIControlStateNormal];
		friendBtn.frame = CGRectMake(nextBtnX, BUTTONS_Y , BUTTONS_WIDTH, BUTTONS_HEIGHT);
		[friendBtn addTarget:self action:@selector(makeFriends) forControlEvents:UIControlEventTouchUpInside];	
		[self addSubview:friendBtn];
		nextBtnX += 90;
	}
}

- (void) createWebsiteButton: (MizoonerProfiles *) profiles {
	
	MizoonProfile *p;

	if (!(p = [profiles getProfileValue: PERSON_WEBSITE])) 
		return;
	
	if (!websiteBtn) {
		websiteBtn = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
		websiteBtn.frame = CGRectMake(nextBtnX, BUTTONS_Y , BUTTONS_WIDTH, BUTTONS_HEIGHT);
		websiteBtn.backgroundColor = [UIColor grayColor];
		[websiteBtn setTitle:@"Website" forState:UIControlStateNormal];
		[websiteBtn addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];	
		[self addSubview:websiteBtn];
		nextBtnX += 90;
	}
}


- (void) setPersonPicture: (NSString *) image {
	
//	NSLog(@"The location image = %@", image);
	NSString *imageUrl;
	
	if (asyncImage) {
		[asyncImage release];
	}
	asyncImage = [[[AsyncImageView alloc] initWithFrame:CGRectMake(5, 10, 70, 70)] autorelease];
	asyncImage.tag = kPersonPictureTag;
	
	if ([image characterAtIndex:0] == '/') 
		imageUrl = [[NSString alloc] initWithFormat:@"%@%@", MIZOON_HOST, image];
	else 
		imageUrl = [[NSString alloc] initWithFormat:@"%@/%@", MIZOON_HOST, image];
	
    NSURL *url = [[NSURL alloc] initWithString:imageUrl];
	[asyncImage loadImageFromURL:url  withStyle: UIActivityIndicatorViewStyleGray];
	[self addSubview:asyncImage];
	
	[imageUrl release];
	[url	release];
}

- (void)dealloc {
    [super dealloc];
	[uNameLbl release];
	[profile1Lbl release];
	[profile2Lbl release];
	[profile3Lbl release];
	[profile4Lbl release];

	[msgBtn release];
	[websiteBtn release];
	[friendBtn release];
//	[asyncImage	release];
}


#pragma mark private




-(IBAction) makeFriends {
	
	MizDataManager *md = [MizDataManager sharedDataManager];
	Mizoon *miz = [Mizoon sharedMizoon];
	
//	MizProgressHUD *progressAlert = [[MizProgressHUD alloc] initWithLabel:@"Sending..."];
//	[progressAlert show];
	
	@try {
		[md sendFriendRequest: [miz getSelectedPersonUID]];
	}
	@catch (NSException * e) {
		MizoonLog(@"xxx hasn't been retained before!");
	}
		
//	[progressAlert dismissWithClickedButtonIndex:0 animated:YES];
//    [progressAlert release];

	UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle:@""
											message:@"Sent your friendship request."
										   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert1 show];
    [alert1 release];
}




-(IBAction) sendMessage {
	
	MizoonAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	RootViewController *rvc = delegate.rootViewController;
//	MizDataManager *md = [MizDataManager sharedDataManager];
	
//	[md checkinMizoonLoc:md.selectedLocation];
	
	[rvc renderView:SEND_MESSAGE_VIEW fromView:A_PERSON_VIEW];
}

/*
- (BOOL) profileIsSet: (NSString *) attr inPersonDict: (NSDictionary *) personDict {
	
	NSUInteger i;
	NSUInteger	numAttr = [[personDict valueForKey:@"num_attrs"] intValue];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSMutableString *key = [NSMutableString stringWithString: @"a0"];
	NSRange	foundRange;
	
	if (!numAttr) 
		return FALSE;
	
	for (i=0; i<numAttr; i++) {
		[key replaceCharactersInRange:NSMakeRange(1, 1) withString: [NSString stringWithFormat:@"%d", i]];
		NSString *profile = [personDict	valueForKey:key];
		foundRange = [profile rangeOfString:attr];
		if (foundRange.length != 0) {
			return	TRUE;
		}
	}
	
	[pool release];
	return FALSE;
}



- (NSString *) getProfileValue: (NSString *) attr inPersonDict: (NSDictionary *) personDict {
	
	NSUInteger i;
	NSUInteger	numAttr = [[personDict valueForKey:@"num_attrs"] intValue];
	NSMutableString *attrKey = [NSMutableString stringWithString: @"a0"];
	NSMutableString *valueKey = [NSMutableString stringWithString: @"v0"];
	NSRange	foundRange;


	if (!numAttr) 
		return FALSE;
	
	for (i=0; i<numAttr; i++) {
		
		[attrKey replaceCharactersInRange:NSMakeRange(1, 1) withString: [NSString stringWithFormat:@"%d", i]];
		
		NSString *profile = [personDict	valueForKey:attrKey];
		
		foundRange = [profile rangeOfString:attr];
	
		if (foundRange.length != 0) {
			
			[valueKey replaceCharactersInRange:NSMakeRange(1, 1) withString: [NSString stringWithFormat:@"%d", i]];
			return [personDict	valueForKey:valueKey];
		}
	}
	
	return NULL;
}
*/



- (void) initLabels {
	
	uNameLbl = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_CONTENT_OFFSET, 10, CONTENT_WIDTH, LINE_HEIGHT)];
	uNameLbl.tag = kLocNameTag;
	uNameLbl.textAlignment = UITextAlignmentLeft;
	uNameLbl.font = [UIFont boldSystemFontOfSize:LOCATION_INFO_FONT_SIZE];
	[self addSubview:uNameLbl];
	
	profile1Lbl = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_CONTENT_OFFSET, 35, CONTENT_WIDTH, LINE_HEIGHT)];
	profile1Lbl.textAlignment = UITextAlignmentLeft;
	profile1Lbl.font = [UIFont systemFontOfSize:LOCATION_INFO_FONT_SIZE];
	[self addSubview:profile1Lbl];
	
	profile2Lbl = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_CONTENT_OFFSET, 55, CONTENT_WIDTH, LINE_HEIGHT)];
	profile2Lbl.textAlignment = UITextAlignmentLeft;
	profile2Lbl.font = [UIFont systemFontOfSize:LOCATION_INFO_FONT_SIZE];
	[self addSubview:profile2Lbl];
	
	profile3Lbl = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_CONTENT_OFFSET, 75, CONTENT_WIDTH, LINE_HEIGHT)];
	profile3Lbl.textAlignment = UITextAlignmentLeft;
	profile3Lbl.font = [UIFont systemFontOfSize:LOCATION_INFO_FONT_SIZE];
	[self addSubview:profile3Lbl];
	
	profile4Lbl = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_CONTENT_OFFSET, 95, CONTENT_WIDTH, LINE_HEIGHT)];
	profile4Lbl.textAlignment = UITextAlignmentLeft;
	profile4Lbl.font = [UIFont systemFontOfSize:LOCATION_INFO_FONT_SIZE];
	[self addSubview:profile4Lbl];
}	


- (UILabel *) getNextLabel: (UILabel *) lablePtr {
	if (lablePtr == profile1Lbl) 
		return profile2Lbl;
	
	if (lablePtr == profile2Lbl) 
		return profile3Lbl;
	
	if (lablePtr == profile3Lbl) 
		return profile4Lbl;
	
	return profile1Lbl;
}

@end

