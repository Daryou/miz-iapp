//
//  APostViewController.m
//  Mizoon
//
//  Created by Daryoush Paknad on 3/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#import	"PostsViewController.h"
#import "APostViewController.h"
#import "MizEntityConverter.h"

#define POST_FONT_SIZE		14
#define	POST_MSG_FONT_SIZE	15

@interface APostViewController() 
- (BOOL) cellHasPhoto;
- (UITableViewCell *) loadPostCell: (UITableView *) tableView rowNumber: (NSUInteger) row;
- (UITableViewCell *) loadPostPhotoCell: (UITableView *) tableView rowNumber: (NSUInteger) row;
- (void)addNameLabel: (UITableViewCell *) cell ;
- (void)addMessageLabel: (UITableViewCell *) cell ;
- (void)addPostInfoLabel: (UITableViewCell *) cell ;
- (float) calculateHeightOfTextFromWidth:(NSString*) text: (UIFont*)withFont: (float)width :(UILineBreakMode)lineBreakMode;
@end


@implementation APostViewController
@synthesize msgHeight;



// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		
		self.view.frame = CGRectMake(0.0, 0, 320.0, 480.0);
		[self.view viewWithTag:kViewTableViewTag].frame = CGRectMake(0.0, TOP_BAR_WITH, 320.0, 440.0);
		[self.view viewWithTag:kViewTableViewTag].backgroundColor = [UIColor clearColor];
		
		self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
		
	}
	return self;
}



/// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}



- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	MizoonLog(@"---------------> didReceiveMemoryWarning: APostsView");

	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[nameLabel release];
	[postInfoLabel release];
	[messageLabel release];
	[userPic release];
	[postPhoto release];
	
    [super dealloc];
}


#pragma mark private
- (float) calculateHeightOfTextFromWidth:(NSString*) text: (UIFont*)withFont: (float)width :(UILineBreakMode)lineBreakMode
{
	[text retain];
	[withFont retain];
	CGSize suggestedSize = [text sizeWithFont:withFont constrainedToSize:CGSizeMake(width, FLT_MAX) lineBreakMode:lineBreakMode];
	
	[text release];
	[withFont release];
	
	return suggestedSize.height;
}

/*
- (NSDictionary *) getSelectedPost {
	Mizoon *miz = [Mizoon sharedMizoon];
	RootViewController *rvc = [miz getRootViewController];

	PostsViewController *postsView = rvc.postsViewController;   
	MizDataManager *dm = [MizDataManager sharedDataManager];
	
	NSArray *posts = dm.nearbyPosts;                                                                               
	
	return (NSDictionary *)[posts objectAtIndex: postsView.selectedRow];                                              
}

*/

- (void)addNameLabel: (UITableViewCell *) cell  {
    CGRect rect = CGRectMake(LEFT_OFFSET, 0, LABEL_WIDTH, NAME_HEIGHT);
	
    nameLabel = [[UILabel alloc] initWithFrame:rect];
    nameLabel.font = [UIFont boldSystemFontOfSize:POST_FONT_SIZE];
    nameLabel.highlightedTextColor = [UIColor whiteColor];
    nameLabel.backgroundColor = [UIColor clearColor];
	
    [cell.contentView addSubview:nameLabel];
}



- (void)addMessageLabel: (UITableViewCell *) cell  {
    CGRect rect = CGRectMake(LEFT_OFFSET, 60, LABEL_WIDTH, msgHeight);
	
    messageLabel = [[UILabel alloc] initWithFrame:rect];
	messageLabel.numberOfLines = 0;
    messageLabel.font = [UIFont boldSystemFontOfSize:POST_MSG_FONT_SIZE];
	messageLabel.textAlignment = UITextAlignmentLeft;
    messageLabel.highlightedTextColor = [UIColor whiteColor];
    messageLabel.backgroundColor = [UIColor clearColor];
	
    [cell.contentView addSubview:messageLabel];
}



- (void)addPostInfoLabel: (UITableViewCell *) cell {
    CGRect rect = CGRectMake(LEFT_OFFSET, 30, LABEL_WIDTH, MESSAGE_HEIGHT);
	
    postInfoLabel = [[UILabel alloc] initWithFrame:rect];
    postInfoLabel.font = [UIFont boldSystemFontOfSize:POSTINFO_FONT_SIZE];
	postInfoLabel.textAlignment = UITextAlignmentLeft;
    postInfoLabel.highlightedTextColor = [UIColor whiteColor];
    postInfoLabel.backgroundColor = [UIColor clearColor];
	
    [cell.contentView addSubview:postInfoLabel];
}



- (UITableViewCell *) loadPostPhotoCell: (UITableView *) tableView rowNumber: (NSUInteger) row 
{
	Mizoon *miz = [Mizoon sharedMizoon];	
    static NSString *CellIdentifier = @"APostPhotCell";
//	NSDictionary *stream = [self getSelectedPost];                                              
	NSDictionary *stream = [miz getSelectedPost];
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;

	} 	
	// Assign cell values...
	postPhoto = [[AsyncImageView alloc] initWithFrame:CGRectMake(0, 10, 300, 310)];
	postPhoto.tag = kPostPhotoTag;
	
	NSString *imageUrl = [[NSString alloc] initWithFormat:@"%@/%@", MIZOON_HOST, [stream valueForKey:@"photo"]];
	NSURL *url = [[NSURL alloc] initWithString:imageUrl];
	[postPhoto loadImageFromURL:url withStyle: UIActivityIndicatorViewStyleWhiteLarge];
	[cell.contentView addSubview:postPhoto];
	[imageUrl release];
	[url release];
	
	
	return cell;
}




- (UITableViewCell *) loadPostCell: (UITableView *) tableView rowNumber: (NSUInteger) row 
{
	Mizoon *miz = [Mizoon sharedMizoon];	
	
    static NSString *CellIdentifier = @"APostCell";
//	NSDictionary *stream = [self getSelectedPost];                                              
	NSDictionary *stream = [miz getSelectedPost];                                              

	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		[self addNameLabel: cell];
		[self addMessageLabel: cell];
		[self addPostInfoLabel: cell];
	} 	
	// Assign cell values...
	userPic = [[AsyncImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
	userPic.tag = kPersonPictureTag;
	
	NSString *imageUrl = [[NSString alloc] initWithFormat:@"%@/%@", MIZOON_HOST, [stream valueForKey:@"pic"]];
	NSURL *url = [[NSURL alloc] initWithString:imageUrl];
	[userPic loadImageFromURL:url  withStyle: UIActivityIndicatorViewStyleGray];
	[cell.contentView addSubview:userPic];
	[imageUrl release];
	[url release];
	
	nameLabel.text = [stream valueForKey:@"name"];
	
	MizEntityConverter *entityCnvt = [[MizEntityConverter alloc] init];
	NSString *cleanInfo = [entityCnvt convertEntiesInString:[stream valueForKey:@"message"]];	
	messageLabel.text = cleanInfo;
	[cleanInfo release];
	[entityCnvt release];

	
//	messageLabel.text = [stream valueForKey:@"message"];
	postInfoLabel.text = [stream valueForKey:@"postinfo"];

	return cell;
}



- (BOOL) cellHasPhoto 
{
	Mizoon *miz = [Mizoon sharedMizoon];	
	
//	NSDictionary *stream = [self getSelectedPost];                                              
	NSDictionary *stream = [miz getSelectedPost];                                              


	if ([[stream valueForKey:@"photo"] length] > 1) 
		return TRUE;
	
	return FALSE;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
	if ([self cellHasPhoto]) 
		return 2;
	
    return 1;                                                                                                       
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  
{  
	Mizoon *miz = [Mizoon sharedMizoon];		
	NSUInteger section = [indexPath section];
//	NSDictionary *stream = [self getSelectedPost];   
	NSDictionary *stream = [miz getSelectedPost];   

	
	switch (section) {
		case 0:
			
			msgHeight = [self calculateHeightOfTextFromWidth:[stream valueForKey:@"message"] :[UIFont boldSystemFontOfSize:MAIN_FONT_SIZE] : 250.0 :UILineBreakModeWordWrap];
			MizoonLog(@"Height=%f", msgHeight);
			return msgHeight+80.0;
			break;
			
		case 1:
			return 0.0;
			if ([self cellHasPhoto]) {
				return 100.0;
			} else {
				return 0.0;
			}
			
		default:
			break;
	}
	return 150.0; //returns floating point which will be used for a cell row height at specified row index  
}  


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0)
		return 1;                                                                                                           
	
	if (section == 1)
		return 1;                                                                                                           
	
    return 2;                                                                                                       
}




- (NSString *) tableView:(UITableView *) tableView titleForHeaderInSection:(NSInteger) section {
	
	return nil; // don't set the title for now

	
	switch (section) {
		case 0:
			return nil; // don't set the title for now
		case 1:
			return @"Attached photo -";                                                                                
		default:
			return nil; // don't set the title for now
	}
}




// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSUInteger		row = [indexPath row];
	NSUInteger		sec = [indexPath section];
	
	switch (sec) {
		case 0:
			return [self loadPostCell:tableView rowNumber: row];
			
		case 1:
			return [self loadPostPhotoCell:tableView rowNumber: row];
			
		default:
			break;
	}
	return [self loadPostCell:tableView rowNumber: row];    
}




- (void) tableView:(UITableView *) tableView willDisplayCell:(UITableViewCell *) cell forRowAtIndexPath:(NSIndexPath *) indexPath {
	
	return;
	
	NSUInteger		sec = [indexPath section];
//	UIImage *bkgImg = [UIImage imageNamed:@"cellBkg-blue.png"];
//	UIImageView *imageView = [[UIImageView alloc] initWithImage:bkgImg];
	UIView *transparentBackground = [[UIView alloc] initWithFrame:CGRectZero];

	switch (sec) {
		case 0:
//			imageView.contentMode = UIViewContentModeScaleToFill;
//			cell.backgroundView = imageView;
//			[imageView release];
			break;
			
		case 1: {
			transparentBackground.backgroundColor = [UIColor clearColor];
			cell.backgroundView = transparentBackground;
			[transparentBackground release];
			
			UIView *cellImage = cell.contentView;
			CGRect imageRect = cellImage.frame;
			
			MizoonLog(@"CONTENT  height=%f  width=%f", imageRect.size.height, imageRect.size.width);
			
			imageRect.size.height = 80.0;
			
			UIImageView *photo = (UIImageView *) [tableView viewWithTag: kAsyncImageTag];
			CGRect photoRect = photo.bounds;

			MizoonLog(@"ACTUAL IMAGE height=%f  width=%f", photoRect.size.height, photoRect.size.width);
			
		}
//			cell.backgroundView.backgroundColor = [UIColor clearColor];
//			cell.contentView.backgroundColor = [UIColor clearColor];
//			cell.backgroundView.opaque = NO;
//			cell.contentView.opaque = NO;
//			
//			
			break;
			
		default:
			cell.backgroundView.backgroundColor = [UIColor clearColor];
			break;
	}
}



@end
