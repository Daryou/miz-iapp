//
//  APersonProfileView.m
//  Mizoon
//
//  Created by Daryoush Paknad on 6/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "APersonProfileView.h"
#import	"Mizoon.h"




#define CONTENT_MARGIN		5.0f

#define	CONTENT_WIDTH		280.0f
#define	LINE_HEIGHT			18.0f

#define PROFILE_FONT_SIZE	14



@interface APersonProfileView (private)
	- (NSMutableString *) getAVs: (MizoonerProfiles *) profiles;
@end


@implementation APersonProfileView
@synthesize	pView;



- (id)initWithFrame:(CGRect)frame personalProfile: (MizoonerProfiles *) profiles {
	
	if (self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1];
				
//		[self initLabels];
//		[self setPersonalProfileValues: profiles];
    }
    return self;
}


- (float) getProfileHeight: (MizoonerProfiles *) profiles {
	
	NSMutableString *av = [self getAVs: profiles];
	
	CGSize constraint = CGSizeMake(CONTENT_WIDTH - (CONTENT_MARGIN * 2), 20000.0f);
	CGSize size = [av sizeWithFont:[UIFont systemFontOfSize:PROFILE_FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
	
	[av release];
	
	return size.height+100.0;
}


- (void)drawRect:(CGRect)rect {
}


- (void)dealloc {
    [super dealloc];
	[pView release];
}



- (void) setPersonalProfileValues: (MizoonerProfiles *) profiles {
	
	NSMutableString *av = [self getAVs:profiles];
	float height = [self getProfileHeight:profiles];
	
	pView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 280, height)]; 
	pView.backgroundColor = [UIColor whiteColor]; 
	[pView setUserInteractionEnabled:NO];
	
	[pView loadHTMLString:av baseURL:[NSURL URLWithString:MIZOON_RESTFUL_SERVER]];  
	[self addSubview:pView];
	[av release];
}



#pragma mark private

- (NSMutableString *) getAVs: (MizoonerProfiles *) profiles {
	MizoonProfile *p;
	NSMutableString *av = [[NSMutableString alloc] initWithCapacity:10];
	
	if ((p = [profiles getProfileValue: ABOUT_ME])) 
		[av appendFormat:@"<b>%@</b> %@<br/><br/>",  p.name, p.value];
	
	if ((p = [profiles getProfileValue: POLITICAL_VIEWS])) 
		[av appendFormat:@"<b>%@</b> %@<br/><br/>",  p.name, p.value];
	
	if ((p = [profiles getProfileValue: RELIGIOUS_VIEWS])) 
		[av appendFormat:@"<b>%@</b> %@<br/><br/>",  p.name, p.value];
	
	if ((p = [profiles getProfileValue: LOOKING_FOR])) 
		[av appendFormat:@"<b>%@</b> %@<br/><br/>",  p.name, p.value];
	
	if ((p = [profiles getProfileValue: NETWORKING])) 
		[av appendFormat:@"<b>%@</b> %@<br/><br/>",  p.name, p.value];
	
	if ((p = [profiles getProfileValue: ACTIVITIES])) 
		[av appendFormat:@"<b>%@</b> %@<br/><br/>",  p.name, p.value];
	
	if ((p = [profiles getProfileValue: FAVORITE_MOVIES])) 
		[av appendFormat:@"<b>%@</b> %@<br/><br/>",  p.name, p.value];
	
	if ((p = [profiles getProfileValue: FAVORITE_TV])) 
		[av appendFormat:@"<b>%@</b> %@<br/><br/>",  p.name, p.value];
	
	if ((p = [profiles getProfileValue: FAVORITE_BOOKS])) 
		[av appendFormat:@"<b>%@</b> %@<br/><br/>",  p.name, p.value];
	
	if ((p = [profiles getProfileValue: FAVORITE_QUOTES])) 
		[av appendFormat:@"<b>%@</b> %@<br/><br/>",  p.name, p.value];
	
	if ((p = [profiles getProfileValue: COLLAGE])) 
		[av appendFormat:@"<b>%@</b> %@<br/><br/>",  p.name, p.value];
	
	if ((p = [profiles getProfileValue: GRADUATION_DATE])) 
		[av appendFormat:@"<b>%@</b> %@<br/><br/>",  p.name, p.value];
	
	if ((p = [profiles getProfileValue: HIGH_SCHOOL]))
		[av appendFormat:@"<b>%@</b> %@<br/><br/>",  p.name, p.value];
	
	if ((p = [profiles getProfileValue: EMPLOYER])) 
		[av appendFormat:@"<b>%@</b> %@<br/><br/>",  p.name, p.value];
	
	if ((p = [profiles getProfileValue: BIRTHDAY])) 
		[av appendFormat:@"<b>%@</b> %@<br/><br/>",  p.name, p.value];
	
	if ((p = [profiles getProfileValue: POSITION])) 
		[av appendFormat:@"<b>%@</b> %@",  p.name, p.value];

	return av;
}



@end
