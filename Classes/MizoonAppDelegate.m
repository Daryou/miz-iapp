//
//  View_SwitcherAppDelegate.m
//  View SwitcherMizoonLog
//
//  Created by Daryoush Paknad on 12/16/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "MizoonAppDelegate.h"
#import "RootViewController.h"
#import	"MizDataManager.h"
#import	"Mizooner.h"
#import	"Mizoon.h"
#import	"NSString+Helpers.h"



@interface MizoonAppDelegate  (private)

- (void) checkIfStatsShouldRun;
- (void) runStats;

@end

@implementation MizoonAppDelegate

@synthesize window;
@synthesize rootViewController, alertRunning;

- (void)applicationDidFinishLaunching:(UIApplication *)application {   
		
	/****************************
	http://iphoneincubator.com/blog/security/a-simple-way-to-download-data-from-a-password-protected-web-page
	NSURLAuthenticationChallengeSender and NSURLCredential, which require that you use NSURLConnection   
	 NSData dataWithContentsOfURL.
	*************************** */

//	sleep(1);
	
	[self checkIfStatsShouldRun];
	
	
    // Override point for customization after application launch
	[window addSubview:rootViewController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {

    [window release];
	[rootViewController release];
    [super dealloc];
}


#pragma mark fbconnect

- (BOOL) application: (UIApplication *) application handleOpenURL: (NSURL *) url {
//	return [fbSession handleOpenURL:url];

	return [[Mizoon  sharedMizoon].fbSession handleOpenURL:url];
}


#pragma mark private

- (void) checkIfStatsShouldRun {
	
	//check if statsDate exists in user defaults, if not, add it and run stats since this is obviously the first time
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if (![defaults objectForKey:@"statsDate"]){
		MizoonLog(@"not a statsDate in userdefaults");
		NSDate *theDate = [NSDate date];
		MizoonLog(@"date %@", theDate);
		[defaults setObject:theDate forKey:@"statsDate"];
		[self runStats];
	}else{ 
		//if statsDate existed, check if it's 7 days since last stats run, if it is > 7 days, run stats
		NSDate *statsDate = [defaults objectForKey:@"statsDate"];
		MizoonLog(@"statsDate %@", statsDate);
		NSDate *today = [NSDate date];
		NSTimeInterval difference = [today timeIntervalSinceDate:statsDate];
		
		NSTimeInterval statsInterval = 7 * 24 * 60 * 60; 
//		NSTimeInterval statsInterval = 1; //for testing and beta, if it's one second different, run again. will only happen on startup of app anyway...
		if (difference > statsInterval) //if it's been more than 7 days since last stats run
		{
			[self runStats];
		}
	}
}

- (void) runStats{
	//generate and post the stats data
	/*
	 - device_uuid – A unique identifier to the iPhone/iPod that the app is installed on. 
	 - app_version – the version number of the WP iPhone app
	 - language – language setting for the device. What does that look like? Is it EN or English?
	 - os_version – the version of the iPhone/iPod OS for the device
	 
	 NSString *deviceType = [UIDevice currentDevice].model;
	 if([deviceType isEqualToString:@"iPhone"])
	 // it's an iPhone
	 
	 
	 */
	NSString *deviceuuid = [[UIDevice currentDevice] uniqueIdentifier];
	
	NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
	NSString *appversion = [info objectForKey:@"CFBundleVersion"];
	[appversion stringByUrlEncoding];
	
	NSLocale *locale = [NSLocale currentLocale];
	
	NSString *language = [locale objectForKey: NSLocaleIdentifier];
	[language stringByUrlEncoding];
	
	NSString *osversion = [[UIDevice currentDevice] systemVersion];
	[osversion stringByUrlEncoding];
		
	NSString *sysName = [[UIDevice currentDevice] systemName];
	NSString *encodedSysName = [sysName stringByUrlEncoding];

	NSString *name = [[UIDevice currentDevice] name];
	NSString *encodedName = [name stringByUrlEncoding];
	
	MizoonLog(@"UUID %@", deviceuuid);
	MizoonLog(@"app version %@",appversion);
	MizoonLog(@"language %@",language);
	MizoonLog(@"os_version, %@", osversion);
	MizoonLog(@"sys_name, %@", sysName);
	MizoonLog(@"name, %@", name);

	//handle data coming back
	[statsData release];
	statsData = [[NSMutableData alloc] init];
	
	NSString *mizoonStatUrl = [[NSString alloc] initWithFormat:@"%@/?q=iphone_stats", MIZOON_HOST];
	
	NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:mizoonStatUrl]
														cachePolicy:NSURLRequestUseProtocolCachePolicy
														timeoutInterval:30.0];
	
	[theRequest setHTTPMethod:@"POST"];
	[theRequest addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
	//create the body
	NSMutableData *postBody = [NSMutableData data];
	
	
	
	[postBody appendData:[[NSString stringWithFormat:@"device_uuid=%@&app_version=%@&language=%@&os_version=%@&sys_name=%@&name=%@", 
						   deviceuuid,
						   appversion,
						   language,
						   osversion,
						   sysName,
						   name] dataUsingEncoding:NSUTF8StringEncoding]];
	
#ifdef MIZOON_DEBUG	
	NSString *htmlStr = [[[NSString alloc] initWithData:postBody encoding:NSUTF8StringEncoding] autorelease];
	MizoonLog(@"htmlStr %@", htmlStr);
#endif
	[theRequest setHTTPBody:postBody];
	
	NSURLConnection *conn=[[[NSURLConnection alloc] initWithRequest:theRequest delegate:self]autorelease];

	if (conn)  {  
		MizoonLog(@"Request was scheduled to post");
	}   
	else {  
		MizoonLog(@"Failed to create a connection!");
	}  	

	[mizoonStatUrl release];
	[encodedName release];
	[encodedSysName release];
}




#pragma mark NSURLConnection callbacks

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[statsData appendData: data];
	//MizoonLog(@"did recieve data");
}

-(void) connection:(NSURLConnection *)connection  didFailWithError: (NSError *)error {
	
	MizoonLog(@"Connection failed with error.");
	/*
	UIAlertView *errorAlert = [[UIAlertView alloc]
							   initWithTitle: [error localizedDescription]
							   message: [error localizedFailureReason]
							   delegate:nil
							   cancelButtonTitle:@"OK"
							   otherButtonTitles:nil];
	[errorAlert show];
	[errorAlert release];
	 */
}


- (void) connectionDidFinishLoading: (NSURLConnection*) connection {
	//MizoonLog(@"connectionDidFinishLoading");
	//process statsData here or call a helper method to do so.
	//it should parse the "latest version" and the over the air download url and give user some opportunity to upgrade if version numbers don't match...
	//all of this should get pulled out of WPAppDelegate and into it's own class... http request, check for stats methods, delegate methods for http, and present user with option to upgrade
	NSString *statsDataString = [[NSString alloc] initWithData:statsData encoding:NSUTF8StringEncoding];
	
//	MizoonLog(@"should be statsDataString %@", statsDataString);
	//need to break this up based on the \n
	
	[statsDataString release];
	
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	//MizoonLog (@"connectionDidReceiveResponse %@", response);
}



- (void)connection:(NSURLConnection *)connection
didReceiveAuthenticationChallenge:
(NSURLAuthenticationChallenge *)challenge {
	
}





- (void) handleAuthenticationOKForChallenge:
(NSURLAuthenticationChallenge *) aChallenge
								   withUser: (NSString*) username
								   password: (NSString*) password {
	
}



- (void) handleAuthenticationCancelForChallenge: (NSURLAuthenticationChallenge *) aChallenge {
	
}




@end
