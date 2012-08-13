//
//  MizoonProfile.h
//  Mizoon
//
//  Created by Daryoush Paknad on 6/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define	BASIC_PROFILE			0
#define	CONTACT_PROFILE			1
#define	RELATIONSHIP_PROFILE	2
#define	EDUCATION_PROFILE		3
#define	PERSONAL_PROFILE		4
#define	WORK_PROFILE			5
#define	CORE_PROFILE			6


#define	PERSON_USER_NAME	@"uname"
#define	PERSON_UID			@"uid"
#define	PERSON_PICTURE		@"pic"
#define	PERSON_FRIEND		@"friends"
#define	PERSON_NAME			@"Name"
#define	PERSON_LAST_NAME	@"Last Name"
#define	BIRTHDAY			@"Birthday"
#define	RELATIONSHIP_STATUS	@"I'm"
#define	SEX					@"Gender"
#define	HOME_TOWN			@"Home Town"
#define	PERSON_ADDRESS		@"Address"
#define	PERSON_CITY			@"City"
#define	PERSON_STATE		@"State"
#define	PERSON_COUNTRY		@"Country"
#define	PERSON_ZIP			@"Zip"
#define	PERSON_MOBILE		@"Mobile"
#define	PERSON_PHONE		@"Phone"
#define	PERSON_WEBSITE		@"Website"
#define	ABOUT_ME			@"About Me"
#define	INTERESTED_IN		@"Interested In"
#define	LOOKING_FOR			@"Looking for"
#define	NETWORKING			@"Networking"
#define	ACTIVITIES			@"ACtivities"
#define	POLITICAL_VIEWS		@"Political Views"
#define	RELIGIOUS_VIEWS		@"Religious Views"
#define	FAVORITE_MUSIC		@"Favorite Music"
#define	FAVORITE_MOVIES		@"Favorite Movies"
#define	FAVORITE_TV			@"Favorite TV"
#define	FAVORITE_BOOKS		@"Favorite Books"
#define	FAVORITE_QUOTES		@"Favorite Quotes"
#define	COLLAGE				@"Collage"
#define	GRADUATION_DATE		@"Graduation Date"
#define	HIGH_SCHOOL			@"High School"
#define	EMPLOYER			@"Employer"
#define	POSITION			@"Position"
#define	IM					@"IM"
#define	IM_NAME				@"IM SCreen Name"


@interface MizoonProfile : NSObject {
	NSString	*name;
	NSString	*value;
	NSUInteger	type;
	BOOL		displayed;
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * value;
@property NSUInteger type;
@property BOOL	displayed;


@end
