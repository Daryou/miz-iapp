//
//  Utilities.m
//  Mizoon
//
//  Created by Daryoush Paknad on 6/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Utilities.h"
#import	"Constants.h"

// caller needs to change the "displayed" value
MizoonProfile * getNextProfile(NSArray *profiles, int profileType) {
	
	for (int i=0; i < [profiles count]; i++) {
		MizoonProfile *p = [profiles objectAtIndex:i];
		
		if (p.type == profileType && !p.displayed) {
			return p;
		}
	}
	return NULL;
}	

MizoonProfile * getProfile(NSArray *profiles, NSString *attr) {
	
	int numProf = [profiles count];
	
	for (int i=0; i < numProf; i++) {
		MizoonProfile *p = [profiles objectAtIndex:i];
		MizoonLog(@"Attr=%@  value=%@", p.name, p.value);

//		if ([p.name isEqualToString:attr options:NSCaseInsensitiveSearch]) 
		if ([p.name caseInsensitiveCompare:attr] == NSOrderedSame) 
			return p;
	}
	return NULL;
}	

void printProfiles(NSArray *profiles) {
	
	int numProf = [profiles count];
	
	for (int i=0; i < numProf; i++) {
		MizoonProfile *p = [profiles objectAtIndex:i];
		
		MizoonLog(@"Attr=%@  value=%@", p.name, p.value);
	}
}	