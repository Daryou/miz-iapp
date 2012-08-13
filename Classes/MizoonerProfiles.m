//
//  MizoonerProfiles.m
//  Mizoon
//
//  Created by Daryoush Paknad on 6/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MizoonerProfiles.h"
#import	"MizEntityConverter.h"
#import	"NSString+Helpers.h"
#import	"Constants.h"

@interface MizoonerProfiles (private)
- (void) setProfileValues: (NSDictionary *) personDict;
@end


@implementation MizoonerProfiles



- (id)initWithDictionary:(NSDictionary *) profilesDict {
	
	if (self = [super init]) {
		
		NSUInteger numAtt = [[profilesDict valueForKey:@"num_attrs"] intValue];
		
        // Custom initialization
		profiles = [[NSMutableArray alloc] initWithCapacity:numAtt];
		[self setProfileValues: profilesDict];
		
    }
    return self;
}


- (void)dealloc {
	
	for (int i=0; i < [profiles count]; i++) {
		
		MizoonProfile *p = [profiles objectAtIndex:i];
		
		if ([p.name rangeOfString:PERSON_UID options:NSCaseInsensitiveSearch].length == 0 &&
			[p.name rangeOfString:PERSON_USER_NAME options:NSCaseInsensitiveSearch].length == 0 &&
			[p.name rangeOfString:PERSON_PICTURE options:NSCaseInsensitiveSearch].length == 0 &&
			[p.name rangeOfString:PERSON_FRIEND options:NSCaseInsensitiveSearch].length == 0 ) {
			
			[p.value release];
			[p.name release];
		}		
		[p release]; // xxxx
	}
	
//	[profiles release];  // XXXX

#if 0
	for (int i=0; i < [profiles count]; i++) {
		
		MizoonProfile *p = [profiles objectAtIndex:i];
		
		if ([p.name rangeOfString:PERSON_UID options:NSCaseInsensitiveSearch].length == 0 &&
			[p.name rangeOfString:PERSON_USER_NAME options:NSCaseInsensitiveSearch].length == 0 &&
			[p.name rangeOfString:PERSON_PICTURE options:NSCaseInsensitiveSearch].length == 0 &&
			[p.name rangeOfString:PERSON_FRIEND options:NSCaseInsensitiveSearch].length == 0 ) {
			
			[p.value release];
			[p.name release];
			
		}
		
//		[p release];
	}
#endif	
    [super dealloc];
//	[profiles release];
}




// caller needs to change the "displayed" value
- (MizoonProfile *) getNextProfileOfType: (int) profileType {
	
	for (int i=0; i < [profiles count]; i++) {
		MizoonProfile *p = [profiles objectAtIndex:i];
		
		if (p.type == profileType && !p.displayed) {
			return p;
		}
	}
	return NULL;
}	

- (MizoonProfile *) getProfileValue: (NSString *) attr {


	for (int i=0; i < [profiles count]; i++) {
		
		MizoonProfile *p = [profiles objectAtIndex:i];

		if ([p.name rangeOfString:attr options:NSCaseInsensitiveSearch].length != 0) {
			return p;
		}
	}
	return NULL;
}	


- (NSString *) getProfileAttrValue: (NSString *) attr {
	
	
	for (int i=0; i < [profiles count]; i++) {
		
		MizoonProfile *p = [profiles objectAtIndex:i];
		
		if ([p.name rangeOfString:attr options:NSCaseInsensitiveSearch].length != 0) {
			return p.value;
		}
	}
	return NULL;
}	



/*
 * APersonBasic View displays: PERSON_USER_NAME, PERSON_PICTURE, RELATIONSHIP_STATUS, SEX, HOME_TOWN, INTERESTED_IN, PERSON_CITY.  The
 * rest of profile attributes are considered personal attributes and are displayed by APersonProfileView.
 *
 * Retrurns TRUE if the profile list contains attributes that should be displyed in the APersonProfileView (APersonViewController 2nd table group)
 */
- (BOOL) hasPersonalAttributes {
	
	int numProf = [profiles count];
	
	for (int i=0; i < numProf; i++) {
		MizoonProfile *p = [profiles objectAtIndex:i];
		
		if	(([p.name rangeOfString:PERSON_PICTURE options:NSCaseInsensitiveSearch].length == 0) &&
			([p.name rangeOfString:PERSON_UID options:NSCaseInsensitiveSearch].length == 0) && 
			([p.name rangeOfString:PERSON_USER_NAME options:NSCaseInsensitiveSearch].length == 0) && 
			([p.name rangeOfString:PERSON_FRIEND options:NSCaseInsensitiveSearch].length == 0) && 			 
			([p.name rangeOfString:RELATIONSHIP_STATUS options:NSCaseInsensitiveSearch].length == 0) && 
			([p.name rangeOfString:SEX options:NSCaseInsensitiveSearch].length == 0) &&
			([p.name rangeOfString:HOME_TOWN options:NSCaseInsensitiveSearch].length == 0) && 
			([p.name rangeOfString:INTERESTED_IN options:NSCaseInsensitiveSearch].length == 0) && 
			([p.name rangeOfString:PERSON_CITY options:NSCaseInsensitiveSearch].length == 0) ) 

			return TRUE;
	}
	return FALSE;
}	



- (void) printProfiles {
	
	int numProf = [profiles count];
	
	for (int i=0; i < numProf; i++) {
		MizoonProfile *p = [profiles objectAtIndex:i];
		
		MizoonLog(@"Attr=%@  value=%@", p.name, p.value);
	}
}	


#pragma mark private


- (void) setProfileValues: (NSDictionary *) personDict {
	NSMutableString *attrKey = [NSMutableString stringWithString: @"a00"];
	NSMutableString *valueKey = [NSMutableString stringWithString: @"v00"];
	
	NSUInteger numAttr = [[personDict valueForKey:@"num_attrs"] intValue];
	NSUInteger i;
//	MizoonProfile *profObj = [MizoonProfile alloc];
	MizoonProfile *profObj;

	for (i=0; i<numAttr; i++) {
		
		profObj = [MizoonProfile alloc];
		

		if (i<=9) {
			[attrKey replaceCharactersInRange:NSMakeRange(1, 2) withString: [NSString stringWithFormat:@"0%d", i]];
			[valueKey replaceCharactersInRange:NSMakeRange(1, 2) withString: [NSString stringWithFormat:@"0%d", i]];
		} else {
			[attrKey replaceCharactersInRange:NSMakeRange(1, 2) withString: [NSString stringWithFormat:@"%d", i]];
			[valueKey replaceCharactersInRange:NSMakeRange(1, 2) withString: [NSString stringWithFormat:@"%d", i]];
		}
//		profObj.name = [personDict	valueForKey:attrKey];
//		profObj.value = [personDict	valueForKey:valueKey];

		MizEntityConverter *aCnvt = [[MizEntityConverter alloc] init];
		MizEntityConverter *vCnvt = [[MizEntityConverter alloc] init];

		NSString *cleanAttr = [aCnvt convertEntiesInString:[personDict	valueForKey:attrKey]];
		NSString *cleanValue = [vCnvt convertEntiesInString:[personDict	valueForKey:valueKey]];

		profObj.name = cleanAttr;
		profObj.value = cleanValue;
		profObj.displayed = 0;
		
		
		[aCnvt release];
		[vCnvt release];
//		[cleanAttr release]; // freed when profObj.name and value are released (MizoonProfile dealloc)
//		[cleanValue release];
		
		//		foundRange = [profile rangeOfString:attr];
		
		if (([profObj.name rangeOfString:SEX options:NSCaseInsensitiveSearch].length != 0) || ([profObj.name rangeOfString:PERSON_NAME options:NSCaseInsensitiveSearch].length != 0) || 
			([profObj.name rangeOfString:PERSON_LAST_NAME options:NSCaseInsensitiveSearch].length != 0) || ([profObj.name rangeOfString:BIRTHDAY options:NSCaseInsensitiveSearch].length != 0) ) 
			profObj.type = BASIC_PROFILE;
		
		else if (([profObj.name rangeOfString:PERSON_ADDRESS options:NSCaseInsensitiveSearch].length != 0) || ([profObj.name rangeOfString:PERSON_CITY options:NSCaseInsensitiveSearch].length != 0) ||
				 ([profObj.name rangeOfString:PERSON_STATE options:NSCaseInsensitiveSearch].length != 0) || ([profObj.name rangeOfString:PERSON_COUNTRY options:NSCaseInsensitiveSearch].length != 0) ||
				 ([profObj.name rangeOfString:PERSON_ZIP options:NSCaseInsensitiveSearch].length != 0) || ([profObj.name rangeOfString:PERSON_MOBILE options:NSCaseInsensitiveSearch].length != 0) ||
				 ([profObj.name rangeOfString:PERSON_PHONE options:NSCaseInsensitiveSearch].length != 0) || ([profObj.name rangeOfString:IM options:NSCaseInsensitiveSearch].length != 0) ||
				 ([profObj.name rangeOfString:IM_NAME options:NSCaseInsensitiveSearch].length != 0) )
			profObj.type = CONTACT_PROFILE;
		
		else if (([profObj.name rangeOfString:RELATIONSHIP_STATUS options:NSCaseInsensitiveSearch].length != 0) || ([profObj.name rangeOfString:INTERESTED_IN options:NSCaseInsensitiveSearch].length != 0) ||
				 ([profObj.name rangeOfString:LOOKING_FOR options:NSCaseInsensitiveSearch].length != 0) )
			profObj.type = RELATIONSHIP_PROFILE;
		
		else if (([profObj.name rangeOfString:COLLAGE options:NSCaseInsensitiveSearch].length != 0) || ([profObj.name rangeOfString:GRADUATION_DATE options:NSCaseInsensitiveSearch].length != 0) ||
				 ([profObj.name rangeOfString:HIGH_SCHOOL options:NSCaseInsensitiveSearch].length != 0) )
			profObj.type = EDUCATION_PROFILE;
		
		else if (([profObj.name rangeOfString:EMPLOYER options:NSCaseInsensitiveSearch].length != 0) || ([profObj.name rangeOfString:POSITION options:NSCaseInsensitiveSearch].length != 0) )
			profObj.type = WORK_PROFILE;
		
		else 
			profObj.type = PERSONAL_PROFILE;
		
		
		[profiles addObject:profObj];
		//		[profObj.name release];
		//		[profObj.value release];
	}
	
	// add uid and uname to the profile data
	profObj = [MizoonProfile alloc];
	profObj.name = PERSON_USER_NAME;
	profObj.value = [personDict	valueForKey:@"name"];
	profObj.displayed = 0;
	profObj.type = CORE_PROFILE;
	[profiles addObject:profObj];

	profObj = [MizoonProfile alloc];
	profObj.name = PERSON_UID;
	profObj.value = [personDict	valueForKey:PERSON_UID];
	profObj.displayed = 0;
	profObj.type = CORE_PROFILE;
	[profiles addObject:profObj];
	
	profObj = [MizoonProfile alloc];
	profObj.name = PERSON_PICTURE;
	profObj.value = [personDict	valueForKey:PERSON_PICTURE];
	profObj.displayed = 0;
	profObj.type = CORE_PROFILE;
	[profiles addObject:profObj];
	
	profObj = [MizoonProfile alloc];
	profObj.name = PERSON_FRIEND;
	profObj.value = [personDict	valueForKey:PERSON_FRIEND];
	profObj.displayed = 0;
	profObj.type = CORE_PROFILE;
	[profiles addObject:profObj];
	[profObj release];
}



@end
