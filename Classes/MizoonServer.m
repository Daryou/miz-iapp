//
//  MizoonServer.m
//  Mizoon
//
//  Created by Daryoush Paknad on 12/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MizoonServer.h"
#import	"NSData+Base64.h"
#import	"Constants.h"

static MizoonServer  *sharedMizoonServer;

@interface MizoonServer()  // private methods

- (NSString *)sendRequest:(NSURL *)url;
- (id) sendRequestJson:(NSURL *)url;

@end


@implementation MizoonServer
@synthesize receivedData, name, password;





// Initialize the singleton instance if needed and return
+ (MizoonServer *)sharedMizoonServer {
    {
        if (!sharedMizoonServer)
            sharedMizoonServer = [[MizoonServer alloc] init];
		
        return sharedMizoonServer;
    }
}

+ (id)alloc {
	//	@synchronized(self)
    {
        NSAssert(sharedMizoonServer == nil, @"Attempted to allocate a second instance of a singleton.");
        sharedMizoonServer = [super alloc];
        return sharedMizoonServer;
    }
}

+ (id)copy {
	//	@synchronized(self)
    {
        NSAssert(sharedMizoonServer == nil, @"Attempted to copy the singleton.");
        return sharedMizoonServer;
    }
}


- (id)init {
    if (self = [super init]) {
 		
    }
	
    return self;
}




- (NSString *)sendRequest:(NSURL *)url
{
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url
												cachePolicy:NSURLRequestReturnCacheDataElseLoad
											timeoutInterval:30];
	// Fetch the JSON response
	NSData *urlData;
	NSURLResponse *response;
	NSError *error;
	
	// Make synchronous request
	urlData = [NSURLConnection sendSynchronousRequest:urlRequest
									returningResponse:&response
												error:&error];
	

	
 	// Construct a String around the Data from the response
	return [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
}


- (id) sendRequestJson:(NSURL *)url
{
	SBJSON *jsonParser = [SBJSON new];
	NSString *jsonString = [self sendRequest:url];

//	NSLog(@"urlData = %@", (char *)jsonString);

	// Parse the JSON into an Object
	return [jsonParser objectWithString:jsonString error:NULL];
}



- (NSArray *) nearbyPeopleWithLongitude: (double) lon latitude: (double) lat radius: (int) radius atIndex: (int) index numberToRet:(int)num_ret {
	
	if (lat) {
		NSLog(@"nearbyPeopleithLongitude - using Palo Alto");
		
		lat=37.44184;
		lon=-122.165404;
	}
	//	&lon=12.232&lat=144.435&index=20&ret=20
	
//	NSString * peopleURL = [NSString stringWithFormat: @"http://192.168.1.103/?q=api/n-people/&lat=%f&lon=%f&index=%i&ret=%i&radius=%i", lat, lon, index, num_ret, radius];
	NSString * peopleURL = [NSString stringWithFormat: @"%@/?q=api/n-people/&lat=%f&lon=%f&index=%i&ret=%i&radius=%i", MIZOON_SERVER, lat, lon, index, num_ret, radius];
	
	NSLog(@".............>>>>>>>>>>>>>>>>>>>>>>>>>>>>name = %@",  peopleURL);
	
	id response = [self sendRequestJson:[NSURL URLWithString:peopleURL]];
	
	NSDictionary *feed = (NSDictionary *)response;
	
	// get the array of "stream" from the feed and cast to NSArray
	NSArray *streams = (NSArray *)[feed valueForKey:@"stream"];
	
	/*
	NSLog(@"number of items = %i",  streams.count);

	 // loop over all the stream objects and print their titles
	 int ndx;
	 for (ndx = 0; ndx < streams.count; ndx++) {
		 NSDictionary *stream = (NSDictionary *)[streams objectAtIndex:ndx];
		 
		 NSLog(@"name = %@", (NSString *)[stream valueForKey:@"name"]);
		 NSLog(@"image = %@", (NSString *)[stream valueForKey:@"pic"]);
		 NSLog(@"a1 = %@ %@", (NSString *)[stream valueForKey:@"a1"], (NSString *)[stream valueForKey:@"v1"]);

		 NSLog(@"a2 = %@ %@", (NSString *)[stream valueForKey:@"a2"], (NSString *)[stream valueForKey:@"v2"]);

		 NSLog(@"a3 = %@ %@", (NSString *)[stream valueForKey:@"a3"], (NSString *)[stream valueForKey:@"v3"]);

		 NSLog(@"a4 = %@ %@", (NSString *)[stream valueForKey:@"a4"], (NSString *)[stream valueForKey:@"v4"]);

	 }
	*/
	return streams;
}	


- (NSArray *) nearbyPlacesWithLongitude: (double) lon latitude: (double) lat radius: (int) radius atIndex: (int) index numberToRet:(int)num_ret {

	if (lat) {
		NSLog(@"nearbyPlacesWithLongitude - using Palo Alto");

		lat=37.44184;
		lon=-122.165404;
	}
//	&lon=12.232&lat=144.435&index=20&ret=20
	
//	NSString * placesURL = [NSString stringWithFormat: @"http://192.168.1.103/?q=api/places/&lat=%f&lon=%f&index=%i&ret=%i&radius=%i", lat, lon, index, num_ret, radius];
	NSString * placesURL = [NSString stringWithFormat: @"%@/?q=api/places/&lat=%f&lon=%f&index=%i&ret=%i&radius=%i", MIZOON_SERVER, lat, lon, index, num_ret, radius];

	
	NSLog(@".............>>>>>>>>>>>>>>>>>>>>>>>>>>>>name = %@",  placesURL);

	id response = [self sendRequestJson:[NSURL URLWithString:placesURL]];
	
	NSDictionary *feed = (NSDictionary *)response;
	
	
//	NSString *title = (NSString *)[feed valueForKey:@"title"];

	
	
	// get the array of "stream" from the feed and cast to NSArray
	NSArray *streams = (NSArray *)[feed valueForKey:@"stream"];
	
/*	
	// loop over all the stream objects and print their titles
	int ndx;
	for (ndx = 0; ndx < streams.count; ndx++) {
		NSDictionary *stream = (NSDictionary *)[streams objectAtIndex:ndx];
		
		NSString *name = (NSString *)[stream valueForKey:@"name"];
		NSLog(@"--------------------name = %@", (char *) name);
		NSLog(@"image = %@", (NSString *)[stream valueForKey:@"image"]);
		NSLog(@"address = %@", (NSString *)[stream valueForKey:@"address"]);
		NSLog(@"city = %@", (NSString *)[stream valueForKey:@"city"]);
		NSLog(@"state = %@", (NSString *)[stream valueForKey:@"state"]);
		NSLog(@"zip = %@", (NSString *)[stream valueForKey:@"zip"]);
		NSLog(@"review = %@", (NSString *)[stream valueForKey:@"review"]);
		NSLog(@"website = %@", (NSString *)[stream valueForKey:@"website"]);
		NSLog(@"phone = %@", (NSString *)[stream valueForKey:@"phone"]);
		NSLog(@"lat = %@", (NSString *)[stream valueForKey:@"lat"]);
		NSLog(@"lon = %@", (NSString *)[stream valueForKey:@"lon"]);
	}
 */
	return streams;
}	




- (NSString *)sendAuthenticatedRequest:(NSString *) username withPassword: (NSString *) password
{
	/*
	//(NSURL *)url
	NSURLResponse *urlres; 
	NSError *err = NULL;
//	NSMutableURLRequest *request = [[xmlRequest request] mutableCopy];
	
	NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];

	NSData *reqData = [[NSString stringWithFormat:@"%@:%@", @"dp",  @"dpp"] dataUsingEncoding:NSUTF8StringEncoding];
	
	NSString *encoded = [reqData base64EncodedString];
	
	NSString *format = [NSString stringWithFormat:@"%@:%@", @"dp", @"dpp"];
	NSString *test = [format base64Encoding];
	NSString *authString = [[[NSString stringWithFormat:@"%@:%@", @"dp",  @"dpp"] dataUsingEncoding:NSUTF8StringEncoding] base64Encoding];

	authString = [NSString stringWithFormat: @"Basic %@", authString];
	
	[request setValue:authString forHTTPHeaderField:@"Authorization"];

//	[request addValue:[NSString stringWithFormat:@"Basic %@", [format base64Encoding]] forHTTPHeaderField:@"Authorization"];
	
	
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlres error:&err];
		     
	NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Succeeded! Received %d bytes of data  \n %@ ",[data length], response);
	
	
*/
	
	/******************************
	 
	
	// create the connection with the request
	// and start loading the data
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	if (theConnection) {
		// Create the NSMutableData that will hold
		// the received data
		// receivedData is declared as a method instance elsewhere
		receivedData=[[NSMutableData data] retain];
	} else {
		// inform the user that the download could not be made
	}
	*******************************/
	return NULL;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // append the new data to the receivedData
    // receivedData is declared as a method instance elsewhere
    [receivedData appendData:data];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
	
	NSString *response = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    NSLog(@"Succeeded! Received %d bytes of data  \n %@ ",[receivedData length], response);
	
    // release the connection, and the data object
    [connection release];
    [receivedData release];
}


-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge previousFailureCount] == 0) {
        NSURLCredential *newCredential;
        newCredential=[NSURLCredential credentialWithUser:[self name]
                                                 password:[self password]
                                              persistence:NSURLCredentialPersistenceNone];
        [[challenge sender] useCredential:newCredential
               forAuthenticationChallenge:challenge];
    } else {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
        // inform the user that the user name and password
        // in the preferences are incorrect
    //    [self showPreferencesCredentialsAreIncorrectPanel:self];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // this method is called when the server has determined that it
    // has enough information to create the NSURLResponse
	
    // it can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    // receivedData is declared as a method instance elsewhere
    [receivedData setLength:0];
}




- (void)connection:(NSURLConnection *)connection didFailWithError: (NSError *)error
{
    // release the connection, and the data object
    [connection release];
    // receivedData is declared as a method instance elsewhere
    [receivedData release];
	
    // inform the user
//    NSLog(@"Connection failed! Error - %@ %@",
//          [error localizedDescription],
//          [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
}




- (void)dealloc {
//	[placesList release];
    [super dealloc];
}

@end
