//
//  PlacesViewController.h
//  Mizoon
//
//  Created by Daryoush Paknad on 1/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import "EGORefreshTableHeaderView.h"
#import	"Constants.h"
//#import "GAConnectionDelegate.h"
//
//@class GAConnectionManager;


//@interface PlacesViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource> {
@interface PlacesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate> {
	NSUInteger			selectedRow;	
	UIAlertView			*progressAlert;
	UITableView 		*placesTableView;
	RootViewController	*rootViewController;
	UISearchBar			*theSearchBar;
	NSTimer				*timer;

	
//	UIView				*disableViewOverlay;
//	GAConnectionManager *geoapiManager_;

#ifdef	PULL_REFRESH
	EGORefreshTableHeaderView *refreshHeaderView;
	BOOL _reloading;
#endif
}

@property (nonatomic, retain) RootViewController	*rootViewController;
@property (nonatomic, retain) UIAlertView			*progressAlert;
@property (nonatomic, retain) UITableView			*placesTableView;
@property (nonatomic, retain) UISearchBar			*theSearchBar;
@property NSUInteger								selectedRow;

- (void)searchBar:(UISearchBar *)searchBar activate:(BOOL) active;

 
#ifdef	PULL_REFRESH

@property(assign,getter=isReloading) BOOL reloading;
@property(nonatomic,readonly) EGORefreshTableHeaderView *refreshHeaderView;

- (void)reloadTableViewDataSource;
- (void)dataSourceDidFinishLoadingNewData;
#endif



@end
