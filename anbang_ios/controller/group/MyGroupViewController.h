//
//  GroupViewController.h

#import <UIKit/UIKit.h>


@interface MyGroupViewController : UITableViewController<UITableViewDataSource,UITableViewDelegate, UISearchBarDelegate>{
    UISearchBar *mySearchBar;
    UISearchDisplayController *searchDisplayController;
}
@property(nonatomic,retain)NSMutableArray *groupArray;
@property(nonatomic, retain)UISearchBar* searchC;
@end
